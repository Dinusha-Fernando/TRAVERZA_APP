import uuid
from datetime import datetime
from typing import Any
from pydantic import BaseModel, Field


class ProvinceResponse(BaseModel):
    id: str
    slug: str
    name: str
    name_si: str
    name_ta: str
    capital: str
    description: str
    signature_landscapes: str
    display_order: int
    district_count: int = 0
    published_places_count: int = 0


class DistrictSummary(BaseModel):
    id: str
    province_id: str
    slug: str
    name: str
    name_si: str
    name_ta: str
    capital: str
    latitude: float
    longitude: float
    known_for: str
    is_verified: bool
    place_count: int = 0


class DistrictSpecialityResponse(BaseModel):
    id: uuid.UUID
    district_id: str
    theme_group: str
    title: str
    description: str
    evidence_source: str


class DestinationSummary(BaseModel):
    id: uuid.UUID
    slug: str
    name: str
    name_si: str
    name_ta: str
    place_type: str
    category: str
    district_id: str
    province_id: str
    latitude: float
    longitude: float
    summary: str
    dwell_duration_mins: int
    access_state: str
    review_status: str
    photo_url: str


class DestinationDetailResponse(BaseModel):
    id: uuid.UUID
    slug: str
    province_id: str
    district_id: str
    name: str
    name_si: str
    name_ta: str
    place_type: str
    category: str
    latitude: float
    longitude: float
    coordinate_precision: str
    summary: str
    story: str
    dwell_duration_mins: int
    opening_hours_text: str
    fee_info_text: str
    access_state: str
    terrain_notes: str
    safety_notes: str
    is_family_friendly: bool
    accessibility_notes: str
    evidence_source: str
    last_verified_at: datetime
    review_status: str
    photo_url: str
    photo_attribution: str
    nearby_destinations: list[DestinationSummary] = []
    nearby_services: list[dict[str, Any]] = []


class DistrictOverviewResponse(BaseModel):
    district: DistrictSummary
    province_name: str
    specialities: list[DistrictSpecialityResponse]
    destinations: list[DestinationSummary]
    coverage_status: str = "Verified essentials available"


class CuratedCollectionResponse(BaseModel):
    slug: str
    title: str
    subtitle: str
    theme: str
    cover_image: str
    editorial_note: str
    place_slugs: list[str] = []


class ContributionCreate(BaseModel):
    place_name: str = Field(..., min_length=2, max_length=150)
    district_id: str = Field(..., min_length=2, max_length=30)
    contributor_name: str = Field(..., min_length=2, max_length=100)
    contributor_contact: str = Field(..., min_length=4, max_length=100)
    submission_type: str = Field(default="CORRECTION")
    details: str = Field(..., min_length=10)
    evidence_url: str = Field(..., min_length=3)


class ContributionResponse(BaseModel):
    id: uuid.UUID
    place_name: str
    district_id: str
    contributor_name: str
    submission_type: str
    details: str
    evidence_url: str
    status: str
    moderation_notes: str
    created_at: datetime
    reviewed_at: datetime | None = None


class DistrictDayPlanRequest(BaseModel):
    district_id: str
    available_hours: int = Field(default=8, ge=2, le=14)
    interests: list[str] = Field(default_factory=lambda: ["HERITAGE", "NATURE"])
    walking_tolerance: str = Field(default="MODERATE")  # LOW, MODERATE, HIGH
    transport_mode: str = Field(default="PRIVATE_VEHICLE")  # PRIVATE_VEHICLE, PUBLIC_TRANSIT, TUKTUK


class DistrictDayPlanResponse(BaseModel):
    district_id: str
    district_name: str
    total_duration_mins: int
    feasibility_status: str  # FEASIBLE, WARNING_TIGHT_BUFFER, UNFEASIBLE
    stops: list[dict[str, Any]]
    route_polyline: list[list[float]] = []
    tripgraph_validation_notes: list[str] = []
