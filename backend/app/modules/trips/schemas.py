import uuid
from datetime import date, time

from pydantic import BaseModel


class ItineraryItemCreateRequest(BaseModel):
    listing_id: uuid.UUID | None = None
    place_id: uuid.UUID | None = None
    title: str
    category: str
    start_time: time
    end_time: time
    latitude: float
    longitude: float
    is_fixed_time: bool = True
    requires_booking: bool = True


class ItineraryItemResponse(BaseModel):
    id: uuid.UUID
    day_id: uuid.UUID
    listing_id: uuid.UUID | None
    place_id: uuid.UUID | None
    title: str
    category: str
    start_time: time
    end_time: time
    latitude: float
    longitude: float
    is_fixed_time: bool
    requires_booking: bool
    booking_status: str

    model_config = {"from_attributes": True}


class ItineraryDayResponse(BaseModel):
    id: uuid.UUID
    day_number: int
    date: date
    title: str | None
    items: list[ItineraryItemResponse] = []

    model_config = {"from_attributes": True}


class TripCreateRequest(BaseModel):
    title: str
    start_date: date
    end_date: date
    party_size: int = 2
    corridor_name: str = "Colombo - Sigiriya - Kandy - Nuwara Eliya"


class TripResponse(BaseModel):
    id: uuid.UUID
    traveler_id: uuid.UUID
    title: str
    start_date: date
    end_date: date
    party_size: int
    corridor_name: str
    status: str
    version: int
    days: list[ItineraryDayResponse] = []

    model_config = {"from_attributes": True}


class ReadinessCheckItem(BaseModel):
    category: str
    severity: str  # "READY", "ACTION_NEEDED", "ATTENTION", "INFO"
    title: str
    description: str
    is_blocking: bool = False


class TripReadinessResponse(BaseModel):
    trip_id: uuid.UUID
    trip_title: str
    overall_status: str  # "READY", "ACTION_NEEDED", "ATTENTION"
    checks: list[ReadinessCheckItem]
    confirmed_items_count: int
    pending_items_count: int
    total_items_count: int
