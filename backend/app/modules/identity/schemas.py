import uuid
from typing import List, Optional
from pydantic import BaseModel, EmailStr, Field


class UserRegisterRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8)
    full_name: str
    phone_number: Optional[str] = None


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
    roles: List[str] = []
    organizations: List[uuid.UUID] = []


class UserResponse(BaseModel):
    id: uuid.UUID
    email: EmailStr
    full_name: str
    phone_number: Optional[str]
    is_active: bool
    is_staff: bool
    staff_role: Optional[str]

    model_config = {"from_attributes": True}


class OrganizationCreateRequest(BaseModel):
    name: str
    legal_name: str
    business_reg_no: Optional[str] = None
    sltda_license_no: Optional[str] = None
    category: str
    contact_email: EmailStr
    contact_phone: str


class OrganizationResponse(BaseModel):
    id: uuid.UUID
    name: str
    legal_name: str
    category: str
    is_verified: bool
    business_reg_no: Optional[str]
    sltda_license_no: Optional[str]

    model_config = {"from_attributes": True}
