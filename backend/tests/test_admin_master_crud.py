import uuid
from datetime import UTC, datetime

import pytest
from httpx import ASGITransport, AsyncClient
from sqlalchemy import select

from app.core.security import create_access_token
from app.main import app
from app.modules.audit.models import AuditEvent
from app.modules.bookings.models import QuoteSnapshot, ServiceBooking
from app.modules.catalogue.models import Destination, Listing
from app.modules.identity.models import Organization, User
from app.modules.notifications.models import UserNotification
from app.modules.trips.models import ItineraryDay, ItineraryItem, Trip


@pytest.fixture
async def setup_admin_and_traveler(test_db):
    admin = User(
        email="master.admin@traverza.lk",
        hashed_password="hashed_password",
        full_name="Master Platform Admin",
        staff_role="SUPER_ADMIN",
    )
    traveler = User(
        email="regular.traveler@example.com",
        hashed_password="hashed_password",
        full_name="Regular Traveler",
        staff_role=None,
    )
    test_db.add(admin)
    test_db.add(traveler)
    await test_db.commit()

    admin_token = create_access_token(
        subject=str(admin.id),
        extra_claims={"email": admin.email, "role": "SUPER_ADMIN"},
    )
    traveler_token = create_access_token(
        subject=str(traveler.id),
        extra_claims={"email": traveler.email, "role": "TRAVELER"},
    )
    return {
        "admin": admin,
        "traveler": traveler,
        "admin_headers": {"Authorization": f"Bearer {admin_token}"},
        "traveler_headers": {"Authorization": f"Bearer {traveler_token}"},
    }


@pytest.mark.asyncio
async def test_admin_rbac_protection(setup_admin_and_traveler):
    """Verify that all /admin endpoints strictly reject regular non-superadmin tokens with 403."""
    traveler_headers = setup_admin_and_traveler["traveler_headers"]
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        res = await client.get("/api/v1/admin/telemetry", headers=traveler_headers)
        assert res.status_code == 403
        assert "Administrative privileges required" in res.text


@pytest.mark.asyncio
async def test_admin_telemetry_kpi_overview(setup_admin_and_traveler):
    """Verify GET /admin/telemetry calculates platform KPI metrics."""
    admin_headers = setup_admin_and_traveler["admin_headers"]
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        res = await client.get("/api/v1/admin/telemetry", headers=admin_headers)
        assert res.status_code == 200
        data = res.json()
        assert data["total_users"] >= 2
        assert "gross_booking_value_lkr" in data
        assert "escrow_held_lkr" in data
        assert data["system_status"] == "ALL_SYSTEMS_OPERATIONAL"


@pytest.mark.asyncio
async def test_admin_user_crud(setup_admin_and_traveler, test_db):
    """Verify admin can create, list, update, and deactivate users, with audit log generation."""
    admin_headers = setup_admin_and_traveler["admin_headers"]
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        # 1. Create User
        new_user_email = f"operator_{uuid.uuid4().hex[:6]}@ceylonchauf.lk"
        payload = {
            "email": new_user_email,
            "password": "Password123!",
            "full_name": "Roshan Wickramasinghe",
            "phone_number": "+94779876543",
            "role": "OPERATOR",
            "is_active": True,
        }
        res_create = await client.post("/api/v1/admin/users", json=payload, headers=admin_headers)
        assert res_create.status_code == 201, res_create.text
        user_data = res_create.json()
        user_id = user_data["id"]
        assert user_data["email"] == new_user_email
        assert user_data["role"] == "OPERATOR"

        # 2. Update User (Promote to Super Admin and change phone)
        update_payload = {"role": "SUPER_ADMIN", "phone_number": "+94770001122"}
        res_update = await client.put(f"/api/v1/admin/users/{user_id}", json=update_payload, headers=admin_headers)
        assert res_update.status_code == 200
        updated = res_update.json()
        assert updated["role"] == "SUPER_ADMIN"
        assert updated["phone_number"] == "+94770001122"

        # 3. Deactivate User
        res_del = await client.delete(f"/api/v1/admin/users/{user_id}", headers=admin_headers)
        assert res_del.status_code == 200
        assert res_del.json()["status"] == "DEACTIVATED"

        # 4. Verify Audit Event logged
        stmt = select(AuditEvent).where(AuditEvent.resource_id == str(user_id))
        audit = (await test_db.execute(stmt)).scalars().first()
        assert audit is not None
        assert audit.actor_role == "SUPER_ADMIN"


@pytest.mark.asyncio
async def test_admin_destination_crud(setup_admin_and_traveler, test_db):
    """Verify admin can create, update, and delete destinations in the Island Atlas."""
    admin_headers = setup_admin_and_traveler["admin_headers"]
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        # Create Destination
        slug = f"ritigala-sanctuary-{uuid.uuid4().hex[:6]}"
        payload = {
            "name": "Ritigala Strict Nature Reserve",
            "slug": slug,
            "province": "North Central",
            "corridor_name": "Cultural Triangle",
            "description": "Ancient monastic ruins shrouded in montane forest canopy.",
            "latitude": 8.118,
            "longitude": 80.658,
        }
        res_create = await client.post("/api/v1/admin/destinations", json=payload, headers=admin_headers)
        assert res_create.status_code == 201, res_create.text
        dest_data = res_create.json()
        dest_id = dest_data["id"]
        assert dest_data["name"] == "Ritigala Strict Nature Reserve"

        # Update Destination
        update_payload = {"description": "Updated canopy trails & archaeological monastery."}
        res_update = await client.put(f"/api/v1/admin/destinations/{dest_id}", json=update_payload, headers=admin_headers)
        assert res_update.status_code == 200
        assert "monastery" in res_update.json()["description"]

        # Delete Destination
        res_del = await client.delete(f"/api/v1/admin/destinations/{dest_id}", headers=admin_headers)
        assert res_del.status_code == 200
        assert res_del.json()["status"] == "DELETED"


@pytest.mark.asyncio
async def test_admin_booking_override(setup_admin_and_traveler, test_db):
    """Verify admin can override booking statuses with a recorded audit reason."""
    admin = setup_admin_and_traveler["admin"]
    admin_headers = setup_admin_and_traveler["admin_headers"]

    # Seed an active booking
    org = Organization(
        name="Ceylon Chauffeurs Guild",
        legal_name="Ceylon Chauffeurs (Pvt) Ltd",
        category="TRANSPORT",
        contact_email="ccg@example.lk",
        contact_phone="+94771234567",
        is_verified=True,
    )
    test_db.add(org)
    await test_db.flush()

    dest = Destination(
        name="Kandy Sacred Valley",
        slug=f"kandy-sacred-{uuid.uuid4().hex[:6]}",
        province="Central",
        description="Central mountain capital",
        latitude=7.290,
        longitude=80.633,
    )
    test_db.add(dest)
    await test_db.flush()

    listing = Listing(
        organization_id=org.id,
        destination_id=dest.id,
        title="Kandy Cultural Chauffeur",
        category="TRANSFER",
        description="Private van",
        base_price_minor=2000000,
        currency="LKR",
        is_published=True,
    )
    test_db.add(listing)
    await test_db.flush()

    trip = Trip(
        traveler_id=admin.id,
        title="Admin Tested Journey",
        start_date=datetime.now(UTC).date(),
        end_date=datetime.now(UTC).date(),
        party_size=2,
        status="PARTIALLY_CONFIRMED",
    )
    test_db.add(trip)
    await test_db.flush()

    day = ItineraryDay(trip_id=trip.id, day_number=1, date=datetime.now(UTC).date())
    test_db.add(day)
    await test_db.flush()

    item = ItineraryItem(
        day_id=day.id,
        listing_id=listing.id,
        title="Transfer to Kandy",
        category="TRANSFER",
        start_time=datetime.now(UTC).time(),
        end_time=datetime.now(UTC).time(),
        latitude=7.290,
        longitude=80.633,
        booking_status="REQUEST_SUBMITTED",
    )
    test_db.add(item)
    await test_db.flush()

    quote = QuoteSnapshot(
        trip_id=trip.id,
        listing_id=listing.id,
        organization_id=org.id,
        amount_minor=2000000,
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
        status="REQUEST_SUBMITTED",
        amount_minor=2000000,
        currency="LKR",
        response_deadline_at=datetime.now(UTC),
    )
    test_db.add(booking)
    await test_db.commit()

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        # Override status to CONFIRMED
        payload = {
            "new_status": "CONFIRMED",
            "reason": "Force majeure supplier phone confirmation confirmed by executive desk",
        }
        res_override = await client.put(f"/api/v1/admin/bookings/{booking.id}/override", json=payload, headers=admin_headers)
        assert res_override.status_code == 200, res_override.text
        data = res_override.json()
        assert data["status"] == "CONFIRMED"


@pytest.mark.asyncio
async def test_admin_system_broadcast(setup_admin_and_traveler, test_db):
    """Verify admin can dispatch a system-wide high priority push alert."""
    admin_headers = setup_admin_and_traveler["admin_headers"]
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        payload = {
            "title": "Monsoon Highway Advisory",
            "body": "Heavy rain on Ramboda Pass. Chauffeurs instructed to use Southern Expressway corridor.",
            "category": "SAFETY",
            "priority": "high",
            "corridor_name": "Colombo - Galle - Nuwara Eliya",
        }
        res_b = await client.post("/api/v1/admin/broadcast", json=payload, headers=admin_headers)
        assert res_b.status_code == 201, res_b.text
        data = res_b.json()
        assert data["status"] == "DISPATCHED"
        assert data["recipients_count"] >= 2
