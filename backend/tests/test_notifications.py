import uuid
import pytest
from httpx import ASGITransport, AsyncClient

from app.core.security import create_access_token
from app.main import app


@pytest.mark.asyncio
async def test_notifications_endpoints():
    """Verifies listing, marking read, and broadcasting corridor notifications."""
    user_id = uuid.uuid4()
    token = create_access_token(
        subject=str(user_id),
        extra_claims={"email": "traveller@traverza.lk", "role": "TRAVELLER"},
    )

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        # 1. List notifications
        res = await client.get(
            "/api/v1/notifications",
            headers={"Authorization": f"Bearer {token}"},
        )
        assert res.status_code == 200
        notifs = res.json()
        assert len(notifs) >= 4
        assert any(n["id"] == "NOTIF-LK-001" for n in notifs)

        # 2. Mark notification as read
        read_res = await client.post(
            "/api/v1/notifications/NOTIF-LK-001/read",
            headers={"Authorization": f"Bearer {token}"},
        )
        assert read_res.status_code == 200
        assert read_res.json()["is_read"] is True

        # 3. Broadcast new operational notification
        broadcast_res = await client.post(
            "/api/v1/notifications/broadcast",
            headers={"Authorization": f"Bearer {token}"},
            json={
                "recipient_email": "traveller@traverza.lk",
                "subject": "Sigiriya Wind Alert",
                "message": "High winds detected near Sigiriya summit.",
                "category": "SAFETY",
                "action_route": "safety",
                "action_label": "Check Weather",
            },
        )
        assert broadcast_res.status_code == 202
        data = broadcast_res.json()
        assert data["status"] == "QUEUED"
        assert data["subject"] == "Sigiriya Wind Alert"

        # 4. Verify the newly broadcast alert appears at top of feed
        list_after = await client.get(
            "/api/v1/notifications",
            headers={"Authorization": f"Bearer {token}"},
        )
        assert list_after.status_code == 200
        new_items = list_after.json()
        assert new_items[0]["title"] == "Sigiriya Wind Alert"
