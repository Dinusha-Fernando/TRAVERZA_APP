import pytest
from httpx import ASGITransport, AsyncClient

from app.main import app


@pytest.mark.asyncio
async def test_provinces_endpoint_returns_official_9_provinces():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        response = await client.get("/api/v1/geography/provinces")
        assert response.status_code == 200
        provinces = response.json()
        assert len(provinces) == 9

        slugs = [p["slug"] for p in provinces]
        expected_slugs = [
            "western", "central", "southern", "northern",
            "eastern", "north-western", "north-central", "uva", "sabaragamuwa"
        ]
        for s in expected_slugs:
            assert s in slugs


@pytest.mark.asyncio
async def test_districts_endpoint_returns_exact_25_districts():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        response = await client.get("/api/v1/geography/districts")
        assert response.status_code == 200
        districts = response.json()
        # Per Strategy Section 1: "Sri Lanka has 9 provinces and 25 administrative districts, not 26."
        assert len(districts) == 25

        district_ids = [d["id"] for d in districts]
        # Verify representative districts from all corners of the island
        assert "colombo" in district_ids
        assert "kandy" in district_ids
        assert "galle" in district_ids
        assert "jaffna" in district_ids
        assert "trincomalee" in district_ids
        assert "anuradhapura" in district_ids
        assert "badulla" in district_ids
        assert "ratnapura" in district_ids


@pytest.mark.asyncio
async def test_district_overview_with_specialities_and_places():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        response = await client.get("/api/v1/districts/kandy/overview")
        assert response.status_code == 200
        data = response.json()
        assert data["district"]["name"] == "Kandy"
        assert data["province_name"] == "Central Province"
        assert len(data["specialities"]) > 0
        assert len(data["destinations"]) > 0
        assert "Temple of the Sacred Tooth Relic" in data["destinations"][0]["name"]


@pytest.mark.asyncio
async def test_destinations_search_multilingual():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        # Search by English name
        res_en = await client.get("/api/v1/destinations?q=Galle")
        assert res_en.status_code == 200
        assert len(res_en.json()) > 0

        # Search by Sinhala name
        res_si = await client.get("/api/v1/destinations?q=ගාල්ල")
        assert res_si.status_code == 200
        assert len(res_si.json()) > 0

        # Search by Tamil name
        res_ta = await client.get("/api/v1/destinations?q=காலி")
        assert res_ta.status_code == 200
        assert len(res_ta.json()) > 0


@pytest.mark.asyncio
async def test_destination_detail_profile():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        response = await client.get("/api/v1/destinations/galle-dutch-fort")
        assert response.status_code == 200
        data = response.json()
        assert data["name"] == "Galle Dutch Fort"
        assert data["dwell_duration_mins"] > 0
        assert data["access_state"] == "OPEN"
        assert data["evidence_source"] != ""
        assert data["review_status"] == "APPROVED"
        assert len(data["nearby_services"]) > 0


@pytest.mark.asyncio
async def test_nearby_destinations():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        # Coordinates around Colombo (6.9271, 79.8612)
        response = await client.get("/api/v1/destinations/nearby?lat=6.9271&lon=79.8612&radius_km=30")
        assert response.status_code == 200
        places = response.json()
        assert len(places) > 0
        names = [p["name"] for p in places]
        assert any("Colombo" in n or "Gangaramaya" in n for n in names)


@pytest.mark.asyncio
async def test_curated_collections():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        response = await client.get("/api/v1/collections")
        assert response.status_code == 200
        collections = response.json()
        assert len(collections) >= 3

        slug = collections[0]["slug"]
        single_res = await client.get(f"/api/v1/collections/{slug}")
        assert single_res.status_code == 200
        assert single_res.json()["title"] == collections[0]["title"]


@pytest.mark.asyncio
async def test_community_contribution_submission():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        payload = {
            "place_name": "Seetha Amman Temple",
            "district_id": "nuwara-eliya",
            "contributor_name": "Ravi S.",
            "contributor_contact": "ravi.guide@example.com",
            "submission_type": "NEW_PLACE",
            "details": "Ancient Ramayana trail shrine near Hakgala botanical gardens with distinctive footprints.",
            "evidence_url": "https://sltda.gov.lk/heritage/seetha-eliya",
        }
        response = await client.post("/api/v1/contributions", json=payload)
        assert response.status_code == 201
        data = response.json()
        assert data["status"] == "PENDING"
        assert data["place_name"] == "Seetha Amman Temple"

        # Verify it appears in moderation queue
        mod_res = await client.get("/api/v1/contributions?status_filter=PENDING")
        assert mod_res.status_code == 200
        assert any(c["place_name"] == "Seetha Amman Temple" for c in mod_res.json())


@pytest.mark.asyncio
async def test_build_district_day_plan():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        payload = {
            "district_id": "colombo",
            "available_hours": 8,
            "interests": ["HERITAGE", "NATURE"],
            "walking_tolerance": "MODERATE",
            "transport_mode": "PRIVATE_VEHICLE",
        }
        response = await client.post("/api/v1/districts/colombo/day-plan", json=payload)
        assert response.status_code == 200
        plan = response.json()
        assert plan["district_id"] == "colombo"
        assert plan["feasibility_status"] in ["FEASIBLE", "WARNING_TIGHT_BUFFER"]
        assert len(plan["stops"]) > 0
        assert len(plan["tripgraph_validation_notes"]) > 0
