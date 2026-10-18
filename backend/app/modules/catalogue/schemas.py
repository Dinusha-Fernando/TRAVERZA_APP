import uuid
from typing import List, Optional
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
    altitude_meters: Optional[int]
    recommended_duration_minutes: int
    opening_time_str: Optional[str]
    closing_time_str: Optional[str]

    model_config = {"from_attributes": True}


class ListingResponse(BaseModel):
    id: uuid.UUID
    organization_id: uuid.UUID
    destination_id: Optional[uuid.UUID]
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
    destination_id: Optional[uuid.UUID] = None
    title: str
    category: str
    description: str
    base_price_minor: int
    currency: str = "LKR"
    cancellation_policy: str = "STANDARD_48H"
