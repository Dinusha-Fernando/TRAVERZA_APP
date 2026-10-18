import uuid
from typing import Any, Dict
from pydantic import BaseModel


class PaymentIntentCreateRequest(BaseModel):
    trip_id: uuid.UUID
    idempotency_key: str


class PaymentIntentResponse(BaseModel):
    id: uuid.UUID
    trip_id: uuid.UUID
    gateway_name: str
    gateway_reference: str
    amount_minor: int
    currency: str
    status: str
    idempotency_key: str

    model_config = {"from_attributes": True}


class WebhookPayload(BaseModel):
    event_id: str
    event_type: str  # 'PAYMENT_CAPTURED', 'PAYMENT_FAILED', 'REFUND_PROCESSED'
    gateway_reference: str
    amount_minor: int
    currency: str = "LKR"
    data: Dict[str, Any] = {}
