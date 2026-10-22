import uuid
from datetime import datetime

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
    confirmed_at: datetime | None = None
    cancellation_reason: str | None = None
    voucher_code: str | None = None
    signed_voucher_token: str | None = None
    payment_reference: str | None = None
    refund_amount_minor: int | None = None

    model_config = {"from_attributes": True}


class ProviderRespondRequest(BaseModel):
    action: str  # 'ACCEPT' or 'DECLINE'
    reason: str | None = None


class PaymentConfirmRequest(BaseModel):
    payment_reference: str
    payment_method: str = "CARD"
    idempotency_key: str | None = None


class CancellationRequest(BaseModel):
    reason: str


class CancellationResponse(BaseModel):
    booking_id: uuid.UUID
    status: str
    cancellation_terms: str
    cancellation_reason: str | None
    amount_minor: int
    refund_amount_minor: int
    cancellation_fee_minor: int
    currency: str
    cancelled_at: datetime


class BookingItemSummary(BaseModel):
    booking_id: uuid.UUID
    itinerary_item_id: uuid.UUID
    title: str
    category: str
    status: str
    amount_minor: int
    currency: str
    voucher_code: str | None = None
    response_deadline_at: datetime | None = None


class TripBookingSummaryResponse(BaseModel):
    trip_id: uuid.UUID
    overall_status: str  # 'DRAFT', 'PARTIALLY_CONFIRMED', 'CONFIRMED', 'CANCELLED'
    total_bookable_items: int
    requested_count: int
    accepted_count: int
    confirmed_count: int
    cancelled_count: int
    total_committed_lkr: float
    items: list[BookingItemSummary]

