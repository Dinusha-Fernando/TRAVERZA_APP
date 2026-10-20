import uuid
import pytest
from httpx import ASGITransport, AsyncClient

from app.core.security import create_access_token
from app.main import app


@pytest.mark.asyncio
async def test_packages_discovery_and_filtering():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        # 1. Fetch public packages (public discovery, no auth required)
        res = await client.get("/api/v1/packages")
        assert res.status_code == 200
        packages = res.json()
        assert len(packages) >= 3

        # Check distinct package types
        types = {p["package_type"] for p in packages}
        assert "OPERATOR_PACKAGE" in types
        assert "ITINERARY_TEMPLATE" in types

        # 2. Filter by corridor
        res_corridor = await client.get("/api/v1/packages?corridor=Cultural")
        assert res_corridor.status_code == 200
        cultural_pkgs = res_corridor.json()
        assert len(cultural_pkgs) >= 1
        assert "Cultural" in cultural_pkgs[0]["corridor_name"]

        # 3. Filter by package_type
        res_type = await client.get("/api/v1/packages?package_type=OPERATOR_PACKAGE")
        assert res_type.status_code == 200
        for p in res_type.json():
            assert p["package_type"] == "OPERATOR_PACKAGE"


@pytest.mark.asyncio
async def test_package_booking_request():
    user_id = uuid.uuid4()
    token = create_access_token(
        subject=str(user_id),
        extra_claims={"email": "traveler@example.com", "role": "TRAVELER", "org_ids": []},
    )
    headers = {"Authorization": f"Bearer {token}"}

    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        res_pkgs = await client.get("/api/v1/packages")
        pkg_id = res_pkgs.json()[0]["id"]

        req_data = {
            "package_id": pkg_id,
            "preferred_start_date": "2026-11-15",
            "party_size": 2,
            "contact_phone": "+94771234567",
            "special_requests": "Vegetarian breakfast preferred",
        }
        res_book = await client.post(
            f"/api/v1/packages/{pkg_id}/booking-requests",
            json=req_data,
            headers=headers,
        )
        assert res_book.status_code == 201
        data = res_book.json()
        assert data["status"] == "REQUEST_SUBMITTED"
        assert "12 hours" in data["message"]


@pytest.mark.asyncio
async def test_plan_overview():
    user_id = uuid.uuid4()
    token = create_access_token(
        subject=str(user_id),
        extra_claims={"email": "traveler@example.com", "role": "TRAVELER", "org_ids": []},
    )
    headers = {"Authorization": f"Bearer {token}"}

    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        res = await client.get("/api/v1/trips/overview", headers=headers)
        assert res.status_code == 200
        overview = res.json()
        assert "total_trips_count" in overview
        assert "saved_packages_count" in overview
        assert "Colombo" in overview["pilot_corridor"]
