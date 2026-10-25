import pytest
from httpx import ASGITransport, AsyncClient

from app.main import app


@pytest.mark.asyncio
async def test_google_social_login_mock_token(test_db):
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        payload = {
            "id_token": "mock-google-id-token-12345",
            "email": "pilot.maya@traverza.lk",
            "full_name": "Maya Rathnayake",
        }
        response = await client.post("/api/v1/auth/social/google", json=payload)
        assert response.status_code == 200
        data = response.json()
        assert "access_token" in data
        assert data["email"] == "pilot.maya@traverza.lk"
        assert data["full_name"] == "Maya Rathnayake"


@pytest.mark.asyncio
async def test_google_social_login_invalid_token(test_db):
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        payload = {
            "id_token": "invalid-garbage-token",
            "email": "hacker@domain.com",
        }
        response = await client.post("/api/v1/auth/social/google", json=payload)
        assert response.status_code == 401
