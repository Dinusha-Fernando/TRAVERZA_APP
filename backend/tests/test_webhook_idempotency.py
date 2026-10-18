import json
import uuid
import pytest
from httpx import ASGITransport, AsyncClient

from app.core.database import get_db
from app.main import app
from app.modules.payments.models import LedgerEntry, PaymentIntent, WebhookEvent


@pytest.mark.asyncio
async def test_webhook_idempotency_and_duplicate_handling(test_db):
    """
    Gate 5: Webhook Idempotency & Replay Defense.
    Posting the exact same webhook payload twice executes the ledger booking once;
    second call returns duplicate_ignored with zero duplicate ledger rows.
    """
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        # Seed payment intent
        trip_id = uuid.uuid4()
        ref = f"pay_{uuid.uuid4().hex[:12]}"
        pi = PaymentIntent(
            trip_id=trip_id,
            gateway_name="SANDBOX",
            gateway_reference=ref,
            amount_minor=1500000,
            currency="LKR",
            status="CREATED",
            idempotency_key=str(uuid.uuid4()),
        )
        test_db.add(pi)
        await test_db.commit()

        webhook_event_id = f"evt_{uuid.uuid4().hex}"
        payload = {
            "event_id": webhook_event_id,
            "event_type": "PAYMENT_CAPTURED",
            "gateway_reference": ref,
            "amount_minor": 1500000,
            "currency": "LKR",
            "data": {},
        }

        # First webhook post
        res1 = await client.post(
            "/api/v1/payments/webhooks/SANDBOX",
            json=payload,
            headers={"X-Signature": "sandbox_valid_sig"},
        )
        assert res1.status_code == 200
        data1 = res1.json()
        assert data1["status"] == "processed"

        # Check ledger entries count after first post
        from sqlalchemy import func, select
        count1 = (
            await test_db.execute(select(func.count(LedgerEntry.id)))
        ).scalar()
        assert count1 == 2  # 1 debit + 1 credit

        # Second webhook post with identical event_id (simulated replay / network retry)
        res2 = await client.post(
            "/api/v1/payments/webhooks/SANDBOX",
            json=payload,
            headers={"X-Signature": "sandbox_valid_sig"},
        )
        assert res2.status_code == 200
        data2 = res2.json()
        assert data2["status"] == "duplicate_ignored"

        # Ledger entries count MUST remain exactly 2 (zero duplicate rows!)
        count2 = (
            await test_db.execute(select(func.count(LedgerEntry.id)))
        ).scalar()
        assert count2 == 2
