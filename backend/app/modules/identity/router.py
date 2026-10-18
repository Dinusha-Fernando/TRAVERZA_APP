import uuid
from typing import Any, Dict
from fastapi import APIRouter, Depends, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.core.config import settings
from app.core.database import get_db
from app.core.errors import TraverzaException, UnauthorizedException
from app.core.security import create_access_token, get_current_user_token, hash_password, verify_password
from app.modules.identity.models import Organization, OrganizationMembership, User
from app.modules.identity.schemas import (
    OrganizationCreateRequest,
    OrganizationResponse,
    TokenResponse,
    UserLoginRequest,
    UserRegisterRequest,
    UserResponse,
)

router = APIRouter(prefix="/auth", tags=["Authentication & Identity"])


@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def register(req: UserRegisterRequest, db: AsyncSession = Depends(get_db)):
    existing = await db.execute(select(User).where(User.email == req.email))
    if existing.scalar_one_or_none():
        raise TraverzaException(
            code="USER_EXISTS",
            message=f"An account with email '{req.email}' already exists",
            status_code=status.HTTP_409_CONFLICT,
        )

    user = User(
        email=req.email,
        hashed_password=hash_password(req.password),
        full_name=req.full_name,
        phone_number=req.phone_number,
    )
    db.add(user)
    await db.commit()
    await db.refresh(user)
    return user


@router.post("/login", response_model=TokenResponse)
async def login(req: UserLoginRequest, db: AsyncSession = Depends(get_db)):
    stmt = (
        select(User)
        .options(selectinload(User.memberships))
        .where(User.email == req.email)
    )
    result = await db.execute(stmt)
    user = result.scalar_one_or_none()

    if not user or not verify_password(req.password, user.hashed_password):
        raise UnauthorizedException("Invalid email or password")

    if not user.is_active:
        raise UnauthorizedException("Account has been deactivated")

    org_ids = [m.organization_id for m in user.memberships]
    roles = [user.staff_role] if user.staff_role else ["TRAVELER"]

    token = create_access_token(
        subject=str(user.id),
        extra_claims={
            "email": user.email,
            "role": user.staff_role or "TRAVELER",
            "org_ids": [str(o) for o in org_ids],
        },
    )

    return TokenResponse(
        access_token=token,
        expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
        user_id=user.id,
        email=user.email,
        full_name=user.full_name,
        roles=roles,
        organizations=org_ids,
    )


@router.get("/me", response_model=UserResponse)
async def get_me(
    token_payload: Dict[str, Any] = Depends(get_current_user_token),
    db: AsyncSession = Depends(get_db),
):
    user_id = uuid.UUID(token_payload["sub"])
    user = await db.get(User, user_id)
    if not user:
        raise UnauthorizedException("User not found")
    return user


@router.post("/organizations", response_model=OrganizationResponse, status_code=status.HTTP_201_CREATED)
async def create_organization(
    req: OrganizationCreateRequest,
    token_payload: Dict[str, Any] = Depends(get_current_user_token),
    db: AsyncSession = Depends(get_db),
):
    user_id = uuid.UUID(token_payload["sub"])
    org = Organization(
        name=req.name,
        legal_name=req.legal_name,
        business_reg_no=req.business_reg_no,
        sltda_license_no=req.sltda_license_no,
        category=req.category,
        contact_email=req.contact_email,
        contact_phone=req.contact_phone,
    )
    db.add(org)
    await db.flush()

    membership = OrganizationMembership(
        user_id=user_id,
        organization_id=org.id,
        role="OWNER",
    )
    db.add(membership)
    await db.commit()
    await db.refresh(org)
    return org
