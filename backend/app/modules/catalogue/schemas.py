import uuid

from pydantic import BaseModel


class DestinationResponse(BaseModel):
    id: uuid.UUID
    name: str
    slug: str
    province: str
    corridor_name: str
    description: str
    latitude: float
    longitude: float

    model_config = {"from_attributes": True}


class PlaceResponse(BaseModel):
    id: uuid.UUID
    destination_id: uuid.UUID
    name: str
    slug: str
    category: str
    description: str
    latitude: float
    longitude: float
    altitude_meters: int | None
    recommended_duration_minutes: int
    opening_time_str: str | None
    closing_time_str: str | None

    model_config = {"from_attributes": True}


class ListingResponse(BaseModel):
    id: uuid.UUID
    organization_id: uuid.UUID
    destination_id: uuid.UUID | None
    title: str
    category: str
    description: str
    base_price_minor: int
    currency: str
    is_published: bool
    manual_availability_only: bool
    cancellation_policy: str

    model_config = {"from_attributes": True}


class ListingCreateRequest(BaseModel):
    destination_id: uuid.UUID | None = None
    title: str
    category: str
    description: str
    base_price_minor: int
    currency: str = "LKR"
    cancellation_policy: str = "STANDARD_48H"
