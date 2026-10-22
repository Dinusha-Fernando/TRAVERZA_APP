import uuid
import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app
from app.core.security import create_access_token


@pytest.fixture
def auth_headers():
    user_id = str(uuid.uuid4())
    token = create_access_token(
        subject=user_id,
        extra_claims={"email": "traveller@traverza.lk", "role": "TRAVELLER", "org_ids": []},
    )
    return {"Authorization": f"Bearer {token}"}


@pytest.fixture
def guide_auth_headers():
    token = create_access_token(
        subject="u1000000-0000-0000-0000-000000000001",
        extra_claims={"email": "duminda@traverza.lk", "role": "GUIDE", "org_ids": []},
    )
    return {"Authorization": f"Bearer {token}"}


@pytest.mark.asyncio
async def test_get_community_feed():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        resp = await client.get("/api/v1/community/feed")
        assert resp.status_code == 200
        data = resp.json()
        assert len(data) >= 5
        # Ensure posts have canonical districts and trust labels
        first = data[0]
        assert "district_id" in first
        assert "trust_label" in first
        assert "freshness_label" in first


@pytest.mark.asyncio
async def test_feed_filtering_by_post_type_and_district():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        # Filter by FIELD_REPORT
        resp = await client.get("/api/v1/community/feed?post_type=FIELD_REPORT")
        assert resp.status_code == 200
        reports = resp.json()
        assert all(r["post_type"] == "FIELD_REPORT" for r in reports)

        # Filter by matale district
        resp_matale = await client.get("/api/v1/community/feed?district_id=matale")
        assert resp_matale.status_code == 200
        matale_posts = resp_matale.json()
        assert all(p["district_id"] == "matale" for p in matale_posts)


@pytest.mark.asyncio
async def test_create_post_and_comment(auth_headers):
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        # Create a new local note in Kandy
        payload = {
            "post_type": "LOCAL_NOTE",
            "caption": "Bahirawakanda Vihara Buddha statue climb: stairs are shaded until 10:00 AM. Excellent panoramic view of Kandy lake and sacred city.",
            "district_id": "kandy",
            "destination_name": "Bahirawakanda Vihara Buddha Statue",
            "media_urls": ["https://images.unsplash.com/photo-1544620347-c4fd4a3d5957"],
        }
        create_resp = await client.post("/api/v1/community/posts", json=payload, headers=auth_headers)
        assert create_resp.status_code == 201
        created = create_resp.json()
        assert created["caption"] == payload["caption"]
        assert created["district_id"] == "kandy"
        post_id = created["id"]

        # Add comment
        comment_payload = {"comment_text": "Is there a vehicle parking bay at the top terrace?"}
        comm_resp = await client.post(f"/api/v1/community/posts/{post_id}/comments", json=comment_payload, headers=auth_headers)
        assert comm_resp.status_code == 200
        comment = comm_resp.json()
        assert comment["comment_text"] == comment_payload["comment_text"]


@pytest.mark.asyncio
async def test_mark_accepted_answer(guide_auth_headers):
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        post_id = "c1000000-0000-0000-0000-000000000001"
        comment_id = "cm100000-0000-0000-0000-000000000002"

        resp = await client.post(
            f"/api/v1/community/posts/{post_id}/comments/{comment_id}/accept",
            headers=guide_auth_headers,
        )
        assert resp.status_code == 200
        assert resp.json()["status"] == "SUCCESS"


@pytest.mark.asyncio
async def test_destination_place_signal():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        resp = await client.get("/api/v1/community/destinations/sigiriya-rock-fortress/signal")
        assert resp.status_code == 200
        signal = resp.json()
        assert "destination_name" in signal
        assert "trail_or_road_status" in signal
        assert signal["freshness_status"] in ("VERY_FRESH", "FRESH", "MODERATE")


@pytest.mark.asyncio
async def test_itinerary_addition_tripgraph_validation(auth_headers):
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        # Feasible morning stop
        payload_feasible = {
            "post_id": "c1000000-0000-0000-0000-000000000001",
            "destination_id": str(uuid.uuid4()),
            "target_day_number": 1,
            "requested_start_hour": 10,
            "dwell_duration_mins": 90,
        }
        resp = await client.post("/api/v1/community/itinerary-add/validate", json=payload_feasible, headers=auth_headers)
        assert resp.status_code == 200
        result = resp.json()
        assert result["is_feasible"] is True
        assert result["road_buffer_mins"] == 25

        # Infeasible stop (starts at 17:00 with 120m duration, passing 18:00 closure)
        payload_infeasible = {
            "post_id": "c1000000-0000-0000-0000-000000000001",
            "destination_id": str(uuid.uuid4()),
            "target_day_number": 1,
            "requested_start_hour": 17,
            "dwell_duration_mins": 120,
        }
        resp_inf = await client.post("/api/v1/community/itinerary-add/validate", json=payload_infeasible, headers=auth_headers)
        assert resp_inf.status_code == 200
        result_inf = resp_inf.json()
        assert result_inf["is_feasible"] is False
        assert len(result_inf["conflicts"]) > 0


@pytest.mark.asyncio
async def test_content_reporting_and_moderation(auth_headers):
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        report_payload = {
            "post_id": "c1000000-0000-0000-0000-000000000002",
            "reason": "DANGEROUS_ADVICE",
            "description": "Report testing emergency trail condition",
        }
        resp = await client.post("/api/v1/community/reports", json=report_payload, headers=auth_headers)
        assert resp.status_code == 200
        assert resp.json()["status"] == "PENDING"


@pytest.mark.asyncio
async def test_travel_messenger_conversations_and_messages(auth_headers):
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        # 1. List conversations
        resp = await client.get("/api/v1/messenger/conversations", headers=auth_headers)
        assert resp.status_code == 200
        convs = resp.json()
        assert len(convs) >= 3

        conv1_id = convs[0]["id"]

        # 2. Get messages
        msg_resp = await client.get(f"/api/v1/messenger/conversations/{conv1_id}/messages", headers=auth_headers)
        assert msg_resp.status_code == 200
        msgs = msg_resp.json()
        assert len(msgs) >= 2

        # 3. Send message with client idempotency key
        client_nonce = f"cli-test-{uuid.uuid4()}"
        send_payload = {
            "client_message_id": client_nonce,
            "message_type": "TEXT",
            "text_content": "Thank you, we will arrive at 18:30 on schedule.",
        }
        send_resp = await client.post(
            f"/api/v1/messenger/conversations/{conv1_id}/messages",
            json=send_payload,
            headers=auth_headers,
        )
        assert send_resp.status_code == 201
        created_msg = send_resp.json()
        assert created_msg["text_content"] == send_payload["text_content"]

        # 4. Retry with SAME client_message_id (idempotency check)
        retry_resp = await client.post(
            f"/api/v1/messenger/conversations/{conv1_id}/messages",
            json=send_payload,
            headers=auth_headers,
        )
        assert retry_resp.status_code == 201
        retried_msg = retry_resp.json()
        # Must return the SAME message ID without creating a duplicate!
        assert retried_msg["id"] == created_msg["id"]
