import uuid
from datetime import UTC, datetime

import pytest
from httpx import ASGITransport, AsyncClient
from sqlalchemy import func, select

from app.core.security import create_access_token
from app.main import app
from app.modules.bookings.models import QuoteSnapshot, ServiceBooking
from app.modules.catalogue.models import Destination, Listing
from app.modules.identity.models import Organization, User
from app.modules.payments.models import LedgerEntry
from app.modules.trips.models import ItineraryDay, ItineraryItem, Trip


@pytest.mark.asyncio
async def test_escrow_release_and_double_entry_balance(test_db):
    """
    Gate 5 Verification:
    Tests authoritative escrow release to provider upon booking completion.
    Verifies that the double-entry accounting ledger strictly balances:
    Debit PLATFORM_ESCROW = Credit PROVIDER_PAYABLE + Credit PLATFORM_REVENUE.
    """
    # 1. Create Super Admin User
    admin = User(
        email="finance.admin@traverza.lk",
        hashed_password="hashed_dummy",
        full_name="Platform Finance Admin",
        staff_role="SUPER_ADMIN",
    )
    test_db.add(admin)
    await test_db.flush()

    # 2. Create Provider Organization & Listing
    org = Organization(
        name="Ceylon Heritage Chauffeurs",
        legal_name="Ceylon Heritage Chauffeurs (Pvt) Ltd",
        business_reg_no="PV-LK-9041",
        category="TRANSPORT",
        is_verified=True,
        contact_email="dispatch@ceylonchauffeurs.lk",
        contact_phone="+94771234567",
    )
    test_db.add(org)
    await test_db.flush()

    dest = Destination(
        name="Sigiriya Fortress",
        slug="sigiriya-fortress",
        province="Central",
        description="Ancient citadel",
        latitude=7.957,
        longitude=80.760,
    )
    test_db.add(dest)
    await test_db.flush()

    listing = Listing(
        organization_id=org.id,
        destination_id=dest.id,
        title="Toyota Prado CMB Transfer",
        category="TRANSFER",
        description="Private SUV transfer",
        base_price_minor=3500000,  # LKR 35,000.00
        currency="LKR",
        is_published=True,
    )
    test_db.add(listing)
    await test_db.flush()

    # 3. Create Trip & Itinerary Item
    trip = Trip(
        traveler_id=admin.id,
        title="Highland Adventure",
        start_date=datetime.now(UTC).date(),
        end_date=datetime.now(UTC).date(),
        party_size=2,
        status="CONFIRMED",
    )
    test_db.add(trip)
    await test_db.flush()

    day = ItineraryDay(trip_id=trip.id, day_number=1, date=datetime.now(UTC).date())
    test_db.add(day)
    await test_db.flush()

    item = ItineraryItem(
        day_id=day.id,
        listing_id=listing.id,
        title="Airport Transfer",
        category="TRANSFER",
        start_time=datetime.now(UTC).time(),
        end_time=datetime.now(UTC).time(),
        latitude=7.957,
        longitude=80.760,
        booking_status="CONFIRMED",
    )
    test_db.add(item)
    await test_db.flush()

    quote = QuoteSnapshot(
        trip_id=trip.id,
        listing_id=listing.id,
        organization_id=org.id,
        amount_minor=3500000,
        currency="LKR",
        cancellation_terms="FLEXIBLE",
        expires_at=datetime.now(UTC),
    )
    test_db.add(quote)
    await test_db.flush()

    booking = ServiceBooking(
        trip_id=trip.id,
        organization_id=org.id,
        itinerary_item_id=item.id,
        quote_snapshot_id=quote.id,
        status="CONFIRMED",
        amount_minor=3500000,
        currency="LKR",
        response_deadline_at=datetime.now(UTC),
    )
    test_db.add(booking)
    await test_db.commit()

    # 4. Execute Escrow Release via API
    admin_token = create_access_token(
        subject=str(admin.id),
        extra_claims={"email": admin.email, "role": "SUPER_ADMIN"},
    )
    headers = {"Authorization": f"Bearer {admin_token}"}

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        resp = await client.post(f"/api/v1/payments/escrow/release/{booking.id}", headers=headers)
        assert resp.status_code == 200, resp.text
        data = resp.json()
        assert data["status"] == "ESCROW_RELEASED"
        assert data["total_amount_minor"] == 3500000
        assert data["platform_commission_minor"] == 350000  # 10%
        assert data["provider_payable_minor"] == 3150000    # 90%
        assert data["ledger_balanced"] is True

        # 5. Verify Database Double-Entry Balance Invariant: sum(debit) == sum(credit)
        tx_id = uuid.UUID(data["transaction_id"])
        stmt = select(
            func.sum(LedgerEntry.debit_minor).label("total_debit"),
            func.sum(LedgerEntry.credit_minor).label("total_credit"),
        ).where(LedgerEntry.transaction_id == tx_id)

        res = (await test_db.execute(stmt)).one()
        assert res.total_debit == 3500000
        assert res.total_credit == 3500000
        assert res.total_debit == res.total_credit


@pytest.mark.asyncio
async def test_escrow_release_unauthorized_for_regular_user(test_db):
    """Verify that regular travellers cannot trigger unauthorized escrow payouts."""
    user = User(
        email="traveler.hacker@example.com",
        hashed_password="hashed_dummy",
        full_name="Curious Traveler",
        staff_role=None,
    )
    test_db.add(user)
    await test_db.commit()

    user_token = create_access_token(
        subject=str(user.id),
        extra_claims={"email": user.email, "role": "TRAVELER"},
    )
    headers = {"Authorization": f"Bearer {user_token}"}

    fake_id = uuid.uuid4()
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        resp = await client.post(f"/api/v1/payments/escrow/release/{fake_id}", headers=headers)
        assert resp.status_code in (403, 404)
