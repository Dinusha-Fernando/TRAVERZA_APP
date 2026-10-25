import uuid
from datetime import UTC, datetime, timedelta

import pytest
from httpx import ASGITransport, AsyncClient

from app.main import app
from app.modules.bookings.models import QuoteSnapshot, ServiceBooking
from app.modules.catalogue.models import Listing
from app.modules.identity.models import Organization, User
from app.modules.messenger.schemas import ChatMessageCreate
from app.modules.messenger.service import MessengerService
from app.modules.trips.models import ItineraryDay, ItineraryItem, Trip


@pytest.mark.asyncio
async def test_complete_booking_lifecycle_and_voucher_generation(test_db):
    """
    Tests the authoritative booking lifecycle:
    DRAFT -> REQUEST_SUBMITTED -> PROVIDER_ACCEPTED -> CONFIRMED (Voucher Issued) -> Trip Summary
    """
    # 1. Seed user, provider org, and listing
    traveler_id = uuid.uuid4()
    org_id = uuid.uuid4()
    provider_user_id = uuid.uuid4()

    traveler = User(id=traveler_id, email="traveler@traverza.lk", hashed_password="pw", full_name="Traveler One")
    org = Organization(
        id=org_id,
        name="Sigiriya Luxury Stays",
        legal_name="Sigiriya Luxury Stays (Pvt) Ltd",
        sltda_license_no="SLTDA/ACC/2026/01",
        category="STAYS",
        is_verified=True,
        contact_email="reservations@sigiriyaresort.lk",
        contact_phone="+94 66 228 9012",
    )
    test_db.add_all([traveler, org])
    await test_db.flush()

    listing = Listing(
        id=uuid.uuid4(),
        organization_id=org_id,
        category="STAY",
        title="Sigiriya Luxury Chalet",
        description="Boutique chalets with citadel views",
        base_price_minor=4500000,  # 45,000.00 LKR
        currency="LKR",
        cancellation_policy="MODERATE",
        is_published=True,
    )
    test_db.add(listing)

    # 2. Seed Trip & Itinerary
    trip = Trip(
        id=uuid.uuid4(),
        traveler_id=traveler_id,
        title="Cultural Triangle Explorer",
        start_date=datetime.now(UTC).date(),
        end_date=(datetime.now(UTC) + timedelta(days=3)).date(),
    )
    test_db.add(trip)
    await test_db.flush()

    day = ItineraryDay(id=uuid.uuid4(), trip_id=trip.id, day_number=1, date=trip.start_date)
    test_db.add(day)
    await test_db.flush()

    item1 = ItineraryItem(
        id=uuid.uuid4(),
        day_id=day.id,
        title="Sigiriya Luxury Chalet Check-in",
        category="STAY",
        start_time=datetime.min.time(),
        end_time=datetime.min.time(),
        latitude=7.95,
        longitude=80.75,
        requires_booking=True,
        booking_status="DRAFT",
    )
    item2 = ItineraryItem(
        id=uuid.uuid4(),
        day_id=day.id,
        title="Sigiriya Rock Guided Ascent",
        category="TOUR",
        start_time=datetime.min.time(),
        end_time=datetime.min.time(),
        latitude=7.957,
        longitude=80.76,
        requires_booking=True,
        booking_status="DRAFT",
    )
    test_db.add_all([item1, item2])
    await test_db.commit()

    # 3. Create Quote Snapshot
    app.dependency_overrides[
        lambda: None
    ] = None  # Dependency override helper handled via token payload injection

    from app.core.security import get_current_user_token

    async def mock_traveler_token():
        return {"sub": str(traveler_id), "role": "TRAVELER", "org_ids": []}

    async def mock_provider_token():
        return {"sub": str(provider_user_id), "role": "PROVIDER", "org_ids": [str(org_id)]}

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        # Override token to traveler
        app.dependency_overrides[get_current_user_token] = mock_traveler_token

        # A. Create Quote
        quote_res = await client.post(
            f"/api/v1/trips/{trip.id}/quotes",
            json={"listing_id": str(listing.id), "validity_hours": 24},
        )
        assert quote_res.status_code == 201
        quote_data = quote_res.json()
        assert quote_data["amount_minor"] == 4500000
        quote_id = quote_data["id"]

        # B. Submit Booking Request
        booking_res = await client.post(
            "/api/v1/bookings",
            json={
                "trip_id": str(trip.id),
                "itinerary_item_id": str(item1.id),
                "quote_snapshot_id": quote_id,
            },
        )
        assert booking_res.status_code == 201
        booking_data = booking_res.json()
        assert booking_data["status"] == "REQUEST_SUBMITTED"
        booking_id = booking_data["id"]

        # Verify initial booking summary (Overall status: REQUEST_SUBMITTED)
        summary_res = await client.get(f"/api/v1/trips/{trip.id}/booking-summary")
        assert summary_res.status_code == 200
        summary_data = summary_res.json()
        assert summary_data["total_bookable_items"] == 2
        assert summary_data["requested_count"] == 1
        assert summary_data["confirmed_count"] == 0
        assert summary_data["overall_status"] == "REQUEST_SUBMITTED"

        # C. Provider Accepts Booking
        app.dependency_overrides[get_current_user_token] = mock_provider_token
        respond_res = await client.post(
            f"/api/v1/provider/bookings/{booking_id}/respond",
            headers={"X-Organization-Id": str(org_id)},
            json={"action": "ACCEPT"},
        )
        assert respond_res.status_code == 200
        assert respond_res.json()["status"] == "PROVIDER_ACCEPTED"

        # D. Confirm Payment & Generate Cryptographic Offline Voucher
        app.dependency_overrides[get_current_user_token] = mock_traveler_token
        pay_res = await client.post(
            f"/api/v1/bookings/{booking_id}/confirm-payment",
            json={
                "payment_reference": "PAYHERE-REC-908123",
                "payment_method": "VISA",
            },
        )
        assert pay_res.status_code == 200
        paid_data = pay_res.json()
        assert paid_data["status"] == "CONFIRMED"
        assert paid_data["voucher_code"] is not None
        assert paid_data["voucher_code"].startswith("VOUCH-LK-")
        assert paid_data["signed_voucher_token"] is not None
        assert paid_data["signed_voucher_token"].startswith("TRV.")

        # E. Verify Partial Confirmation status (1 of 2 confirmed)
        summary_res2 = await client.get(f"/api/v1/trips/{trip.id}/booking-summary")
        assert summary_res2.status_code == 200
        summary2 = summary_res2.json()
        assert summary2["confirmed_count"] == 1
        assert summary2["total_bookable_items"] == 2
        assert summary2["overall_status"] == "PARTIALLY_CONFIRMED"
        assert summary2["total_committed_lkr"] == 45000.0


@pytest.mark.asyncio
async def test_cancellation_and_refund_policy_evaluation(test_db):
    """
    Tests cancellation policy calculation and authoritative cancellation event logging.
    """
    traveler_id = uuid.uuid4()
    org_id = uuid.uuid4()

    traveler = User(id=traveler_id, email="traveler2@traverza.lk", hashed_password="pw", full_name="Traveler Two")
    org = Organization(
        id=org_id,
        name="Galle Maritime Fleet",
        legal_name="Galle Maritime Fleet (Pvt) Ltd",
        sltda_license_no="SLTDA/FLEET/02",
        category="TRANSPORT",
        is_verified=True,
        contact_email="ops@gallefleet.lk",
        contact_phone="+94 91 223 4455",
    )
    test_db.add_all([traveler, org])
    await test_db.flush()

    trip = Trip(
        id=uuid.uuid4(),
        traveler_id=traveler_id,
        title="Southern Coast Tour",
        start_date=datetime.now(UTC).date(),
        end_date=(datetime.now(UTC) + timedelta(days=2)).date(),
    )
    test_db.add(trip)
    await test_db.flush()

    day = ItineraryDay(id=uuid.uuid4(), trip_id=trip.id, day_number=1, date=trip.start_date)
    test_db.add(day)
    await test_db.flush()

    item = ItineraryItem(
        id=uuid.uuid4(),
        day_id=day.id,
        title="Whale Watching Catamaran Transfer",
        category="TRANSFER",
        start_time=datetime.min.time(),
        end_time=datetime.min.time(),
        latitude=5.94,
        longitude=80.45,
        requires_booking=True,
        booking_status="REQUEST_SUBMITTED",
    )
    test_db.add(item)
    await test_db.flush()

    quote = QuoteSnapshot(
        id=uuid.uuid4(),
        trip_id=trip.id,
        listing_id=uuid.uuid4(),
        organization_id=org_id,
        amount_minor=2000000,  # 20,000 LKR
        currency="LKR",
        cancellation_terms="FLEXIBLE",
        expires_at=datetime.now(UTC) + timedelta(days=2),
    )
    test_db.add(quote)
    await test_db.flush()

    booking = ServiceBooking(
        id=uuid.uuid4(),
        trip_id=trip.id,
        organization_id=org_id,
        itinerary_item_id=item.id,
        quote_snapshot_id=quote.id,
        status="CONFIRMED",
        amount_minor=2000000,
        currency="LKR",
        response_deadline_at=datetime.now(UTC) + timedelta(hours=12),
        confirmed_at=datetime.now(UTC),
    )
    test_db.add(booking)
    await test_db.commit()

    from app.core.security import get_current_user_token

    async def mock_traveler_token():
        return {"sub": str(traveler_id), "role": "TRAVELER", "org_ids": []}

    app.dependency_overrides[get_current_user_token] = mock_traveler_token

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        cancel_res = await client.post(
            f"/api/v1/bookings/{booking.id}/cancel",
            json={"reason": "Flight rescheduled due to airline delay"},
        )
        assert cancel_res.status_code == 200
        cancel_data = cancel_res.json()
        assert cancel_data["status"] == "CANCELLED"
        assert cancel_data["cancellation_terms"] == "FLEXIBLE"
        # 10% fee for FLEXIBLE = 200,000 minor; 90% refund = 1,800,000 minor
        assert cancel_data["cancellation_fee_minor"] == 200000
        assert cancel_data["refund_amount_minor"] == 1800000
        assert cancel_data["amount_minor"] == 2000000


def test_messenger_composite_idempotency():
    """
    Verifies server-enforced composite idempotency (sender_id + client_message_id).
    Ensures message deduplication for retried requests while allowing distinct senders.
    """
    service = MessengerService()
    conv_id = "cv100000-0000-0000-0000-000000000001"
    sender_a = "user-alice-101"
    sender_b = "user-bob-202"

    payload_a = ChatMessageCreate(
        client_message_id="msg-nonce-777",
        message_type="TEXT",
        text_content="Are road conditions clear on Ramboda pass?",
    )

    # 1. First send from sender_a
    msg1 = service.send_message(
        conv_id=conv_id,
        sender_id=sender_a,
        sender_name="Alice",
        payload=payload_a,
    )
    assert msg1["text_content"] == "Are road conditions clear on Ramboda pass?"
    assert msg1["delivery_status"] == "DELIVERED"

    # 2. Duplicate retry from sender_a with same client_message_id
    msg2 = service.send_message(
        conv_id=conv_id,
        sender_id=sender_a,
        sender_name="Alice",
        payload=payload_a,
    )
    # Must return exact same message object without duplicating
    assert msg2["id"] == msg1["id"]

    # 3. Sender_b with same client_message_id is NOT blocked because composite key differs
    payload_b = ChatMessageCreate(
        client_message_id="msg-nonce-777",
        message_type="TEXT",
        text_content="Different sender using same nonce",
    )
    msg3 = service.send_message(
        conv_id=conv_id,
        sender_id=sender_b,
        sender_name="Bob",
        payload=payload_b,
    )
    assert msg3["id"] != msg1["id"]
    assert msg3["sender_id"] == sender_b
