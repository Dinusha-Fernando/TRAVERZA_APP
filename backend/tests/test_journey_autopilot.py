import uuid
from datetime import UTC, date, datetime, time

import pytest
from httpx import ASGITransport, AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import create_access_token, hash_password
from app.main import app
from app.modules.bookings.models import ServiceBooking
from app.modules.catalogue.models import Destination, Listing
from app.modules.identity.models import Organization, User
from app.modules.trips.models import ItineraryDay, ItineraryItem, Trip


@pytest.mark.asyncio
async def test_autopilot_flight_delay_adaptation(test_db: AsyncSession):
    """
    TRAVERZA 2.0 Scenario Test:
    Ingest verified flight delay event, assess downstream impact on airport transfer,
    generate candidate proposal, enforce human authorization, and verify with TripGraph.
    """
    # 1. Setup seed user, trip and Day 1 items
    user = User(
        email="traveler.pilot@example.com",
        hashed_password=hash_password("Pass1234!"),
        full_name="Dinusha Traveler",
        phone_number="+447911123456",
        is_staff=False,
    )
    test_db.add(user)
    await test_db.flush()

    trip = Trip(
        traveler_id=user.id,
        title="Colombo to Cultural Highlands",
        start_date=date(2026, 10, 24),
        end_date=date(2026, 10, 26),
        party_size=2,
        corridor_name="Colombo - Sigiriya - Kandy - Nuwara Eliya",
        status="DRAFT",
    )
    test_db.add(trip)
    await test_db.flush()

    day1 = ItineraryDay(trip_id=trip.id, day_number=1, date=date(2026, 10, 24), title="Arrival & Transfer")
    test_db.add(day1)
    await test_db.flush()

    flight_item = ItineraryItem(
        day_id=day1.id,
        title="Bandaranaike Intl Airport (UL-504) Arrival",
        category="FLIGHT",
        start_time=time(9, 0),
        end_time=time(10, 0),
        latitude=7.1808,
        longitude=79.8841,
        is_fixed_time=True,
        requires_booking=False,
        booking_status="NONE",
    )
    transfer_item = ItineraryItem(
        day_id=day1.id,
        title="Airport to Sigiriya Private Chauffeur Transfer",
        category="TRANSFER",
        start_time=time(10, 30),
        end_time=time(14, 0),
        latitude=7.1808,
        longitude=79.8841,
        is_fixed_time=True,
        requires_booking=True,
        booking_status="CONFIRMED",
    )

    test_db.add_all([flight_item, transfer_item])
    await test_db.commit()

    token = create_access_token(
        subject=str(user.id),
        extra_claims={"email": user.email, "role": "TRAVELER", "org_ids": []},
    )
    headers = {"Authorization": f"Bearer {token}"}

    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        # Step 1, 2, 3: Ingest Disruption Event (Observe -> Assess -> Propose)
        disruption_payload = {
            "trip_id": str(trip.id),
            "event_type": "FLIGHT_DELAY",
            "severity": "MEDIUM",
            "source": "SRILANKAN_AIRLINES_VERIFIED_FEED",
            "summary": "UL-504 London Heathrow to Colombo delayed by 90 minutes due to Mediterranean air traffic control",
            "details": {"delay_minutes": 90, "original_eta": "10:00", "revised_eta": "11:30"},
            "idempotency_key": "FLIGHT-DELAY-UL504-20261024",
            "delay_minutes": 90,
        }

        resp = await ac.post("/api/v1/autopilot/events", json=disruption_payload, headers=headers)
        assert resp.status_code == 201
        data = resp.json()

        assert data["disruption_event"]["event_type"] == "FLIGHT_DELAY"
        assert len(data["proposals_generated"]) == 1

        proposal = data["proposals_generated"][0]
        assert proposal["timing_delta_minutes"] == 90
        assert proposal["requires_authorization"] is True
        assert proposal["authorization_status"] == "PENDING_AUTHORIZATION"
        assert "90 mins" in proposal["explanation"]

        proposal_id = proposal["id"]

        # Step 4, 5, 6: Authorize Proposal (Execute -> Verify with TripGraph)
        auth_payload = {"decision": "APPROVE"}
        auth_resp = await ac.post(
            f"/api/v1/autopilot/proposals/{proposal_id}/authorize",
            json=auth_payload,
            headers=headers,
        )
        assert auth_resp.status_code == 200, auth_resp.text
        auth_data = auth_resp.json()


        assert auth_data["authorization_status"] == "EXECUTED"
        assert "Executed & Verified" in auth_data["execution_notes"]

        # Verify transfer item was mutated accurately (10:30 + 90m = 12:00)
        trip_resp = await ac.get(f"/api/v1/trips/{trip.id}", headers=headers)
        assert trip_resp.status_code == 200
        trip_data = trip_resp.json()
        items = trip_data["days"][0]["items"]
        rescheduled_transfer = next(it for it in items if it["category"] == "TRANSFER")
        assert rescheduled_transfer["start_time"] == "12:00:00"
        assert rescheduled_transfer["end_time"] == "15:30:00"


@pytest.mark.asyncio
async def test_autopilot_disruption_idempotency(test_db: AsyncSession):
    """
    Scenario Test:
    Verify that duplicate disruption events with identical idempotency keys
    do not create duplicate database records or phantom proposals.
    """
    user = User(
        email="traveler.idem@example.com",
        hashed_password=hash_password("Pass1234!"),
        full_name="Idem Traveler",
        phone_number="+447911123457",
        is_staff=False,
    )
    test_db.add(user)
    await test_db.flush()

    trip = Trip(
        traveler_id=user.id,
        title="Colombo to Sigiriya",
        start_date=date(2026, 10, 24),
        end_date=date(2026, 10, 25),
        party_size=2,
        corridor_name="Colombo - Sigiriya - Kandy - Nuwara Eliya",
        status="DRAFT",
    )
    test_db.add(trip)
    await test_db.flush()

    day = ItineraryDay(trip_id=trip.id, day_number=1, date=date(2026, 10, 24), title="Day 1")
    test_db.add(day)
    await test_db.commit()

    token = create_access_token(
        subject=str(user.id),
        extra_claims={"email": user.email, "role": "TRAVELER", "org_ids": []},
    )
    headers = {"Authorization": f"Bearer {token}"}

    payload = {
        "trip_id": str(trip.id),
        "event_type": "WEATHER_ROAD_DISRUPTION",
        "severity": "HIGH",
        "source": "DISASTER_MANAGEMENT_CENTRE",
        "summary": "Heavy rainfall warning on Ramboda mountain pass",
        "details": {"extra_buffer_minutes": 45},
        "idempotency_key": "WEATHER-RAMBODA-20261024-AM",
    }

    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        # First POST
        r1 = await ac.post("/api/v1/autopilot/events", json=payload, headers=headers)
        assert r1.status_code == 201
        event_id_1 = r1.json()["disruption_event"]["id"]

        # Duplicate POST with same key
        r2 = await ac.post("/api/v1/autopilot/events", json=payload, headers=headers)
        assert r2.status_code == 201
        event_id_2 = r2.json()["disruption_event"]["id"]

        # IDs must match; zero duplication
        assert event_id_1 == event_id_2

        # Check list endpoint contains exactly 1 event
        events_resp = await ac.get(f"/api/v1/autopilot/trips/{trip.id}/events", headers=headers)
        assert len(events_resp.json()) == 1


@pytest.mark.asyncio
async def test_autopilot_proposal_rejection(test_db: AsyncSession):
    """
    Scenario Test:
    Verify that when a traveller or operator rejects an Autopilot proposal,
    no itinerary mutations occur and the proposal is marked REJECTED.
    """
    user = User(
        email="traveler.reject@example.com",
        hashed_password=hash_password("Pass1234!"),
        full_name="Reject Traveler",
        phone_number="+447911123458",
        is_staff=False,
    )
    test_db.add(user)
    await test_db.flush()

    trip = Trip(
        traveler_id=user.id,
        title="Kandy Trip",
        start_date=date(2026, 10, 24),
        end_date=date(2026, 10, 25),
        party_size=2,
        corridor_name="Colombo - Sigiriya - Kandy - Nuwara Eliya",
        status="DRAFT",
    )
    test_db.add(trip)
    await test_db.flush()

    day = ItineraryDay(trip_id=trip.id, day_number=1, date=date(2026, 10, 24), title="Day 1")
    test_db.add(day)
    await test_db.commit()

    token = create_access_token(
        subject=str(user.id),
        extra_claims={"email": user.email, "role": "TRAVELER", "org_ids": []},
    )
    headers = {"Authorization": f"Bearer {token}"}

    payload = {
        "trip_id": str(trip.id),
        "event_type": "DRIVER_CANCEL",
        "severity": "CRITICAL",
        "source": "CHAUFFEUR_DISPATCH_HOTLINE",
        "summary": "Driver reported flat tire near Kadawatha",
        "details": {"delay_minutes": 20},
        "idempotency_key": f"DRIVER-CANCEL-{uuid.uuid4().hex[:8]}",
    }

    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        r = await ac.post("/api/v1/autopilot/events", json=payload, headers=headers)
        assert r.status_code == 201
        proposal_id = r.json()["proposals_generated"][0]["id"]

        # Reject proposal
        reject_payload = {"decision": "REJECT", "rejection_reason": "Traveller arranged self-drive"}
        auth_r = await ac.post(
            f"/api/v1/autopilot/proposals/{proposal_id}/authorize",
            json=reject_payload,
            headers=headers,
        )
        assert auth_r.status_code == 200
        assert auth_r.json()["authorization_status"] == "REJECTED"
        assert "Traveller arranged self-drive" in auth_r.json()["execution_notes"]


@pytest.mark.asyncio
async def test_journey_command_center_endpoint(test_db: AsyncSession):
    """
    Scenario Test:
    Verify the 7 modules of the Journey Command Center endpoint (Section 5):
    Journey Status, Next Action, Trip Health, Budget Breakdown, and Autopilot monitoring.
    """
    user = User(
        email="traveler.cc@example.com",
        hashed_password=hash_password("Pass1234!"),
        full_name="Command Center Traveler",
        phone_number="+447911123459",
        is_staff=False,
    )
    test_db.add(user)
    await test_db.flush()

    trip = Trip(
        traveler_id=user.id,
        title="Colombo to Cultural Highlands",
        start_date=date(2026, 10, 24),
        end_date=date(2026, 10, 26),
        party_size=2,
        corridor_name="Colombo - Sigiriya - Kandy - Nuwara Eliya",
        status="PARTIALLY_CONFIRMED",
    )
    test_db.add(trip)
    await test_db.flush()

    day = ItineraryDay(trip_id=trip.id, day_number=1, date=date(2026, 10, 24), title="Day 1")
    test_db.add(day)
    await test_db.flush()

    item = ItineraryItem(
        day_id=day.id,
        title="Airport Transfer",
        category="TRANSFER",
        start_time=time(10, 30),
        end_time=time(14, 0),
        latitude=7.9570,
        longitude=80.7603,
        is_fixed_time=True,
        requires_booking=True,
        booking_status="CONFIRMED",
    )
    test_db.add(item)
    await test_db.flush()

    booking = ServiceBooking(
        trip_id=trip.id,
        organization_id=uuid.uuid4(),
        itinerary_item_id=item.id,
        quote_snapshot_id=uuid.uuid4(),
        status="CONFIRMED",
        amount_minor=1850000,
        currency="LKR",
        response_deadline_at=datetime.now(UTC),
    )
    test_db.add(booking)
    await test_db.commit()

    token = create_access_token(
        subject=str(user.id),
        extra_claims={"email": user.email, "role": "TRAVELER", "org_ids": []},
    )
    headers = {"Authorization": f"Bearer {token}"}

    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        resp = await ac.get(f"/api/v1/trips/{trip.id}/command-center", headers=headers)
        assert resp.status_code == 200
        data = resp.json()

        assert data["trip_title"] == "Colombo to Cultural Highlands"
        assert data["journey_status"] == "CONFIRMED"
        assert "next_action" in data
        assert "trip_health" in data
        assert data["trip_health"]["transit_buffer_health_score"] == 94
        assert "budget_breakdown" in data
        assert data["budget_breakdown"]["paid_lkr"] == 18500.0
        assert data["budget_breakdown"]["currency"] == "LKR"
        assert data["autopilot_status"] == "ACTIVE_MONITORING"
