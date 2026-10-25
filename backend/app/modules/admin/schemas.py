import uuid
from datetime import datetime

from pydantic import BaseModel, ConfigDict, EmailStr, Field


# ==========================================
# 1. Platform Telemetry & KPI Schemas
# ==========================================
class AdminPlatformTelemetryResponse(BaseModel):
    total_users: int
    total_providers: int
    total_trips: int
    total_bookings: int
    gross_booking_value_lkr: float
    escrow_held_lkr: float
    open_exceptions_count: int
    active_disruptions_count: int
    system_status: str = "ALL_SYSTEMS_OPERATIONAL"


# ==========================================
# 2. Users & Access Control (RBAC) Schemas
# ==========================================
class AdminUserCreateRequest(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=8)
    full_name: str
    phone_number: str | None = None
    role: str = Field("TRAVELER", description="'SUPER_ADMIN', 'OPERATOR', 'GUIDE', 'TRAVELER'")
    is_active: bool = True
    is_verified: bool = False


class AdminUserUpdateRequest(BaseModel):
    full_name: str | None = None
    phone_number: str | None = None
    role: str | None = None
    is_active: bool | None = None
    is_verified: bool | None = None
    password: str | None = None


class AdminUserResponse(BaseModel):
    id: uuid.UUID
    email: str
    full_name: str
    phone_number: str | None = None
    role: str
    is_active: bool
    is_verified: bool
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


# ==========================================
# 3. Provider Organization Schemas
# ==========================================
class AdminOrgCreateRequest(BaseModel):
    name: str
    legal_name: str
    business_reg_no: str | None = None
    sltda_license_no: str | None = None
    category: str = Field("TRANSPORT", description="'STAYS', 'TRANSPORT', 'GUIDE', 'ACTIVITY'")
    contact_email: EmailStr
    contact_phone: str
    is_verified: bool = False


class AdminOrgUpdateRequest(BaseModel):
    name: str | None = None
    legal_name: str | None = None
    business_reg_no: str | None = None
    sltda_license_no: str | None = None
    category: str | None = None
    contact_email: EmailStr | None = None
    contact_phone: str | None = None
    is_verified: bool | None = None


class AdminOrgResponse(BaseModel):
    id: uuid.UUID
    name: str
    legal_name: str
    business_reg_no: str | None = None
    sltda_license_no: str | None = None
    category: str
    is_verified: bool
    contact_email: str
    contact_phone: str
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


# ==========================================
# 4. Destination & Place Schemas
# ==========================================
class AdminDestinationCreateRequest(BaseModel):
    name: str
    slug: str
    province: str
    corridor_name: str = "Colombo - Sigiriya - Kandy - Nuwara Eliya"
    description: str
    latitude: float
    longitude: float


class AdminDestinationUpdateRequest(BaseModel):
    name: str | None = None
    province: str | None = None
    corridor_name: str | None = None
    description: str | None = None
    latitude: float | None = None
    longitude: float | None = None


class AdminDestinationResponse(BaseModel):
    id: uuid.UUID
    name: str
    slug: str
    province: str
    corridor_name: str
    description: str
    latitude: float
    longitude: float
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class AdminPlaceCreateRequest(BaseModel):
    destination_id: uuid.UUID
    name: str
    slug: str
    category: str = "CULTURAL"
    description: str
    latitude: float
    longitude: float
    recommended_duration_minutes: int = 120
    opening_time_str: str = "08:00"
    closing_time_str: str = "18:00"


class AdminPlaceUpdateRequest(BaseModel):
    name: str | None = None
    category: str | None = None
    description: str | None = None
    latitude: float | None = None
    longitude: float | None = None
    recommended_duration_minutes: int | None = None
    opening_time_str: str | None = None
    closing_time_str: str | None = None


class AdminPlaceResponse(BaseModel):
    id: uuid.UUID
    destination_id: uuid.UUID
    name: str
    slug: str
    category: str
    description: str
    latitude: float
    longitude: float
    recommended_duration_minutes: int
    opening_time_str: str | None = "08:00"
    closing_time_str: str | None = "18:00"
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


# ==========================================
# 5. Catalogue Listing Schemas
# ==========================================
class AdminListingCreateRequest(BaseModel):
    organization_id: uuid.UUID
    destination_id: uuid.UUID | None = None
    title: str
    category: str = Field(..., description="'STAY', 'TRANSFER', 'GUIDE', 'ACTIVITY'")
    description: str
    base_price_minor: int
    currency: str = "LKR"
    is_published: bool = True
    cancellation_policy: str = "STANDARD_48H"


class AdminListingUpdateRequest(BaseModel):
    title: str | None = None
    category: str | None = None
    description: str | None = None
    base_price_minor: int | None = None
    currency: str | None = None
    is_published: bool | None = None
    cancellation_policy: str | None = None


class AdminListingResponse(BaseModel):
    id: uuid.UUID
    organization_id: uuid.UUID
    destination_id: uuid.UUID | None = None
    title: str
    category: str
    description: str
    base_price_minor: int
    currency: str
    is_published: bool
    cancellation_policy: str
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


# ==========================================
# 6. Packages & Tours Schemas
# ==========================================
class AdminPackageCreateRequest(BaseModel):
    organization_id: uuid.UUID | None = None
    provider_name: str = "Verified Ceylon Operator"
    title: str
    slug: str
    summary: str
    description: str
    package_type: str = "OPERATOR_PACKAGE"
    status: str = "PUBLISHED"
    duration_days: int = 3
    duration_nights: int = 2
    price_basis: str = "PER_PERSON"
    base_price_lkr: float = 45000.0
    corridor_name: str = "Cultural Triangle & Highlands"
    destinations: str = "Colombo, Sigiriya, Kandy, Nuwara Eliya"
    cover_image_url: str
    inclusions: str
    exclusions: str
    cancellation_policy: str
    is_verified: bool = True
    sltda_license_no: str | None = None


class AdminPackageUpdateRequest(BaseModel):
    title: str | None = None
    summary: str | None = None
    description: str | None = None
    package_type: str | None = None
    status: str | None = None
    duration_days: int | None = None
    duration_nights: int | None = None
    price_basis: str | None = None
    base_price_lkr: float | None = None
    corridor_name: str | None = None
    destinations: str | None = None
    cover_image_url: str | None = None
    inclusions: str | None = None
    exclusions: str | None = None
    cancellation_policy: str | None = None
    is_verified: bool | None = None
    sltda_license_no: str | None = None


# ==========================================
# 7. Global Bookings Schemas
# ==========================================
class AdminBookingOverrideRequest(BaseModel):
    new_status: str = Field(..., description="'CONFIRMED', 'CANCELLED', 'PROVIDER_ACCEPTED', 'COMPLETED', 'EXCEPTION'")
    reason: str = Field(..., min_length=5, description="Mandatory reason logged to immutable audit trail")
    refund_amount_minor: int | None = None


class AdminBookingResponse(BaseModel):
    id: uuid.UUID
    trip_id: uuid.UUID
    organization_id: uuid.UUID
    itinerary_item_id: uuid.UUID
    status: str
    amount_minor: int
    currency: str
    voucher_code: str | None = None
    payment_reference: str | None = None
    cancellation_reason: str | None = None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


# ==========================================
# 8. Broadcast Dispatcher Schemas
# ==========================================
class AdminBroadcastRequest(BaseModel):
    title: str
    body: str
    category: str = Field("SAFETY", description="'SAFETY', 'BOOKING', 'TRIP', 'OFFERS'")
    priority: str = Field("high", description="'high', 'medium', 'low'")
    corridor_name: str | None = None
    action_route: str | None = "plan"
    action_label: str | None = "View Alert"
