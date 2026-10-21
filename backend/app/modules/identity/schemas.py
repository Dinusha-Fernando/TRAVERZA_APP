import uuid

from pydantic import BaseModel, EmailStr, Field


class UserRegisterRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8)
    full_name: str
    phone_number: str | None = None


class UserUpdateRequest(BaseModel):
    full_name: str | None = None
    phone_number: str | None = None


class UserLoginRequest(BaseModel):
    email: EmailStr
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    expires_in: int
    user_id: uuid.UUID
    email: str
    full_name: str
    roles: list[str] = []
    organizations: list[uuid.UUID] = []


class UserResponse(BaseModel):
    id: uuid.UUID
    email: EmailStr
    full_name: str
    phone_number: str | None
    is_active: bool
    is_staff: bool
    staff_role: str | None

    model_config = {"from_attributes": True}


class OrganizationCreateRequest(BaseModel):
    name: str
    legal_name: str
    business_reg_no: str | None = None
    sltda_license_no: str | None = None
    category: str
    contact_email: EmailStr
    contact_phone: str


class OrganizationResponse(BaseModel):
    id: uuid.UUID
    name: str
    legal_name: str
    category: str
    is_verified: bool
    business_reg_no: str | None
    sltda_license_no: str | None
    contact_email: EmailStr
    contact_phone: str

    model_config = {"from_attributes": True}


class ProviderDocumentUploadRequest(BaseModel):
    document_type: str  # 'BUSINESS_REGISTRATION', 'SLTDA_TOURISM_LICENSE', etc.
    document_number: str | None = None
    file_name: str
    file_url: str
    expiry_date: str | None = None


class ProviderDocumentResponse(BaseModel):
    id: uuid.UUID
    organization_id: uuid.UUID
    document_type: str
    document_number: str | None
    file_name: str
    file_url: str
    expiry_date: str | None
    status: str
    reviewer_notes: str | None
    reviewed_at: str | None

    model_config = {"from_attributes": True}


class ProviderVerificationDecisionRequest(BaseModel):
    decision: str  # 'APPROVE', 'REJECT'
    reason: str
    sltda_license_verified: bool = True

