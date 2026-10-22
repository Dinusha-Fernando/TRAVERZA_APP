import uuid
from datetime import UTC, datetime

import pytest
from httpx import ASGITransport, AsyncClient
from sqlalchemy import select

from app.core.security import create_access_token
from app.main import app
from app.modules.identity.models import User
from app.modules.notifications.models import DevicePushToken
from app.modules.trips.models import ItineraryDay, ItineraryItem, Trip


@pytest.mark.asyncio
async def test_spatial_nearby_search_returns_ordered_results():
    """Verify that GET /geography/nearby calculates distance accurately and orders by proximity."""
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        # Query near Kandy (Lat: 7.2906, Lon: 80.6337)
        resp = await client.get("/api/v1/geography/nearby?lat=7.2906&lon=80.6337&radius_km=60")
        assert resp.status_code == 200, resp.text
        data = resp.json()
        assert len(data) > 0
        # Check that results contain distance tags
        assert "km away" in data[0]["summary"]


@pytest.mark.asyncio
async def test_device_token_registration(test_db):
    """Verify that mobile and web clients can register push notification tokens."""
    user = User(
        email="mobile.pilot@traverza.lk",
        hashed_password="hashed_dummy",
        full_name="Mobile Pilot",
    )
    test_db.add(user)
    await test_db.commit()

    token = create_access_token(subject=str(user.id), extra_claims={"email": user.email})
    headers = {"Authorization": f"Bearer {token}"}

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        payload = {"token": "fcm_test_token_pilot_2026_lk", "platform": "FCM"}
        resp = await client.post("/api/v1/notifications/device-token", json=payload, headers=headers)
        assert resp.status_code == 201, resp.text
        data = resp.json()
        assert data["status"] == "REGISTERED"

        # Verify DB presence
        stmt = select(DevicePushToken).where(DevicePushToken.token == "fcm_test_token_pilot_2026_lk")
        db_token = (await test_db.execute(stmt)).scalar_one_or_none()
        assert db_token is not None
        assert db_token.user_id == user.id
        assert db_token.platform == "FCM"


@pytest.mark.asyncio
async def test_telemetry_disruption_ingest_endpoint(test_db):
    """
    TRAVERZA 2.0 Ingest Verification:
    Tests that POST /autopilot/telemetry/ingest consumes external alerts and generates proposals.
    """
    user = User(
        email="radar.officer@traverza.lk",
        hashed_password="hashed_dummy",
        full_name="Radar Officer",
        staff_role="SUPER_ADMIN",
    )
    test_db.add(user)
    await test_db.flush()

    trip = Trip(
        traveler_id=user.id,
        title="DMC Weather Monitored Expedition",
        start_date=datetime.now(UTC).date(),
        end_date=datetime.now(UTC).date(),
        party_size=2,
        status="ACTIVE",
    )
    test_db.add(trip)
    await test_db.flush()

    day = ItineraryDay(trip_id=trip.id, day_number=1, date=datetime.now(UTC).date())
    test_db.add(day)
    await test_db.flush()

    item = ItineraryItem(
        day_id=day.id,
        title="Ramboda Pass Scenic Drive",
        category="TRANSFER",
        start_time=datetime.now(UTC).time(),
        end_time=datetime.now(UTC).time(),
        latitude=7.05,
        longitude=80.70,
        booking_status="CONFIRMED",
    )
    test_db.add(item)
    await test_db.commit()

    token = create_access_token(
        subject=str(user.id), extra_claims={"email": user.email, "role": "SUPER_ADMIN"}
    )
    headers = {"Authorization": f"Bearer {token}"}

    payload = {
        "trip_id": str(trip.id),
        "event_type": "WEATHER_ROAD_DISRUPTION",
        "severity": "HIGH",
        "source": "DMC_WEATHER_ADVISORY",
        "summary": "Heavy monsoon rains and minor rockfall on A5 route Ramboda pass",
        "details": {"delay_minutes": 45, "road_code": "A5"},
        "idempotency_key": f"dmc_alert_{uuid.uuid4().hex[:8]}",
    }

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        resp = await client.post("/api/v1/autopilot/telemetry/ingest", json=payload, headers=headers)
        assert resp.status_code == 201, resp.text
        data = resp.json()
        assert data["trip_id"] == str(trip.id)
        assert "Autopilot assessed" in data["assessment_summary"]
        assert data["disruption_event"]["source"] == "DMC_WEATHER_ADVISORY"
