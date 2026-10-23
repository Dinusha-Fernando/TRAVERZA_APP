import uuid
from datetime import datetime
from typing import Any, Optional
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
    phone_number: Optional[str] = None
    role: str = Field("TRAVELER", description="'SUPER_ADMIN', 'OPERATOR', 'GUIDE', 'TRAVELER'")
    is_active: bool = True
    is_verified: bool = False


class AdminUserUpdateRequest(BaseModel):
    full_name: Optional[str] = None
    phone_number: Optional[str] = None
    role: Optional[str] = None
    is_active: Optional[bool] = None
    is_verified: Optional[bool] = None
    password: Optional[str] = None


class AdminUserResponse(BaseModel):
    id: uuid.UUID
    email: str
    full_name: str
    phone_number: Optional[str] = None
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
    business_reg_no: Optional[str] = None
    sltda_license_no: Optional[str] = None
    category: str = Field("TRANSPORT", description="'STAYS', 'TRANSPORT', 'GUIDE', 'ACTIVITY'")
    contact_email: EmailStr
    contact_phone: str
    is_verified: bool = False


class AdminOrgUpdateRequest(BaseModel):
    name: Optional[str] = None
    legal_name: Optional[str] = None
    business_reg_no: Optional[str] = None
    sltda_license_no: Optional[str] = None
    category: Optional[str] = None
    contact_email: Optional[EmailStr] = None
    contact_phone: Optional[str] = None
    is_verified: Optional[bool] = None


class AdminOrgResponse(BaseModel):
    id: uuid.UUID
    name: str
    legal_name: str
    business_reg_no: Optional[str] = None
    sltda_license_no: Optional[str] = None
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
    name: Optional[str] = None
    province: Optional[str] = None
    corridor_name: Optional[str] = None
    description: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None


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
    name: Optional[str] = None
    category: Optional[str] = None
    description: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    recommended_duration_minutes: Optional[int] = None
    opening_time_str: Optional[str] = None
    closing_time_str: Optional[str] = None


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
    opening_time_str: Optional[str] = "08:00"
    closing_time_str: Optional[str] = "18:00"
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


# ==========================================
# 5. Catalogue Listing Schemas
# ==========================================
class AdminListingCreateRequest(BaseModel):
    organization_id: uuid.UUID
    destination_id: Optional[uuid.UUID] = None
    title: str
    category: str = Field(..., description="'STAY', 'TRANSFER', 'GUIDE', 'ACTIVITY'")
    description: str
    base_price_minor: int
    currency: str = "LKR"
    is_published: bool = True
    cancellation_policy: str = "STANDARD_48H"


class AdminListingUpdateRequest(BaseModel):
    title: Optional[str] = None
    category: Optional[str] = None
    description: Optional[str] = None
    base_price_minor: Optional[int] = None
    currency: Optional[str] = None
    is_published: Optional[bool] = None
    cancellation_policy: Optional[str] = None


class AdminListingResponse(BaseModel):
    id: uuid.UUID
    organization_id: uuid.UUID
    destination_id: Optional[uuid.UUID] = None
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
    organization_id: Optional[uuid.UUID] = None
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
    sltda_license_no: Optional[str] = None


class AdminPackageUpdateRequest(BaseModel):
    title: Optional[str] = None
    summary: Optional[str] = None
    description: Optional[str] = None
    package_type: Optional[str] = None
    status: Optional[str] = None
    duration_days: Optional[int] = None
    duration_nights: Optional[int] = None
    price_basis: Optional[str] = None
    base_price_lkr: Optional[float] = None
    corridor_name: Optional[str] = None
    destinations: Optional[str] = None
    cover_image_url: Optional[str] = None
    inclusions: Optional[str] = None
    exclusions: Optional[str] = None
    cancellation_policy: Optional[str] = None
    is_verified: Optional[bool] = None
    sltda_license_no: Optional[str] = None


# ==========================================
# 7. Global Bookings Schemas
# ==========================================
class AdminBookingOverrideRequest(BaseModel):
    new_status: str = Field(..., description="'CONFIRMED', 'CANCELLED', 'PROVIDER_ACCEPTED', 'COMPLETED', 'EXCEPTION'")
    reason: str = Field(..., min_length=5, description="Mandatory reason logged to immutable audit trail")
    refund_amount_minor: Optional[int] = None


class AdminBookingResponse(BaseModel):
    id: uuid.UUID
    trip_id: uuid.UUID
    organization_id: uuid.UUID
    itinerary_item_id: uuid.UUID
    status: str
    amount_minor: int
    currency: str
    voucher_code: Optional[str] = None
    payment_reference: Optional[str] = None
    cancellation_reason: Optional[str] = None
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
    corridor_name: Optional[str] = None
    action_route: Optional[str] = "plan"
    action_label: Optional[str] = "View Alert"
