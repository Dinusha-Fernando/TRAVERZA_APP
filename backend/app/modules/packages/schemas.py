import uuid

from pydantic import BaseModel


class PackageBase(BaseModel):
    title: str
    summary: str
    description: str
    package_type: str = "OPERATOR_PACKAGE"  # 'OPERATOR_PACKAGE' vs 'ITINERARY_TEMPLATE'
    duration_days: int = 3
    duration_nights: int = 2
    price_basis: str = "PER_PERSON"
    base_price_lkr: float
    corridor_name: str = "Cultural Triangle & Highlands"
    destinations: str = "Colombo, Sigiriya, Kandy, Nuwara Eliya"
    cover_image_url: str
    inclusions: str = "Boutique Stays, Chauffeur Prado, Guide Guild, Breakfast"
    exclusions: str = "International Flights, Personal Tips"
    cancellation_policy: str = "Free cancellation up to 48 hours before arrival"


class PackageCreateRequest(PackageBase):
    slug: str
    organization_id: uuid.UUID | None = None
    provider_name: str = "Verified Ceylon Operator"
    sltda_license_no: str | None = "SLTDA/SQA/2026/044"


class PackageResponse(PackageBase):
    id: uuid.UUID
    slug: str
    provider_name: str
    status: str
    is_verified: bool
    sltda_license_no: str | None = None
    version: int

    model_config = {"from_attributes": True}


class PackageCustomizeRequest(BaseModel):
    trip_title: str | None = None
    start_date: str = "2026-10-24"
    party_size: int = 2


class PackageBookingRequest(BaseModel):
    package_id: uuid.UUID
    preferred_start_date: str
    party_size: int = 2
    contact_phone: str
    special_requests: str | None = None


class PackageReviewDecisionRequest(BaseModel):
    decision: str  # 'APPROVED', 'CHANGES_REQUESTED', 'REJECTED', 'SUSPENDED'
    reason: str
    reviewer_notes: str | None = None
