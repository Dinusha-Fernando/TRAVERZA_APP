import uuid
from datetime import datetime
from typing import Optional
from pydantic import BaseModel


class QuoteCreateRequest(BaseModel):
    listing_id: uuid.UUID
    validity_hours: int = 24


class QuoteSnapshotResponse(BaseModel):
    id: uuid.UUID
    trip_id: uuid.UUID
    listing_id: uuid.UUID
    organization_id: uuid.UUID
    amount_minor: int
    currency: str
    cancellation_terms: str
    expires_at: datetime
    captured_at: datetime

    model_config = {"from_attributes": True}


class BookingCreateRequest(BaseModel):
    trip_id: uuid.UUID
    itinerary_item_id: uuid.UUID
    quote_snapshot_id: uuid.UUID


class BookingResponse(BaseModel):
    id: uuid.UUID
    trip_id: uuid.UUID
    organization_id: uuid.UUID
    itinerary_item_id: uuid.UUID
    quote_snapshot_id: uuid.UUID
    status: str
    amount_minor: int
    currency: str
    response_deadline_at: datetime
    confirmed_at: Optional[datetime]

    model_config = {"from_attributes": True}


class ProviderRespondRequest(BaseModel):
    action: str  # 'ACCEPT' or 'DECLINE'
    reason: Optional[str] = None
