import json
import logging
import uuid
from datetime import UTC, datetime
from typing import Any, Optional

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.errors import ForbiddenException, NotFoundException, TraverzaException
from app.core.security import get_current_user_token, hash_password
from app.modules.admin.schemas import (
    AdminBookingOverrideRequest,
    AdminBookingResponse,
    AdminBroadcastRequest,
    AdminDestinationCreateRequest,
    AdminDestinationResponse,
    AdminDestinationUpdateRequest,
    AdminListingCreateRequest,
    AdminListingResponse,
    AdminListingUpdateRequest,
    AdminOrgCreateRequest,
    AdminOrgResponse,
    AdminOrgUpdateRequest,
    AdminPackageCreateRequest,
    AdminPackageUpdateRequest,
    AdminPlaceCreateRequest,
    AdminPlaceResponse,
    AdminPlaceUpdateRequest,
    AdminPlatformTelemetryResponse,
    AdminUserCreateRequest,
    AdminUserResponse,
    AdminUserUpdateRequest,
)
from app.modules.audit.models import AuditEvent
from app.modules.autopilot.models import DisruptionEvent
from app.modules.bookings.models import BookingEvent, ServiceBooking
from app.modules.catalogue.models import Destination, Listing, Place
from app.modules.identity.models import Organization, OrganizationMembership, User
from app.modules.notifications.models import UserNotification
from app.modules.packages.models import Package
from app.modules.packages.schemas import PackageResponse
from app.modules.payments.models import LedgerAccount, LedgerEntry
from app.modules.support.models import SupportCase
from app.modules.trips.models import Trip

logger = logging.getLogger("traverza.admin")
router = APIRouter(prefix="/admin", tags=["Admin Master Control Plane"])


def require_super_admin(token_payload: dict[str, Any] = Depends(get_current_user_token)) -> dict[str, Any]:
    """Strict RBAC gate requiring SUPER_ADMIN role."""
    role = token_payload.get("role")
    if role != "SUPER_ADMIN":
        raise ForbiddenException("Administrative privileges required: SUPER_ADMIN role only")
    return token_payload


async def log_admin_action(
    db: AsyncSession,
    actor_id: uuid.UUID,
    action: str,
    resource_type: str,
    resource_id: uuid.UUID | str,
    reason: str,
    details: dict[str, Any] | None = None,
    actor_email: str = "admin@traverza.lk",
) -> None:
    """Emits an immutable audit trail event for every administrative mutation."""
    event = AuditEvent(
        actor_id=actor_id,
        actor_email=actor_email,
        actor_role="SUPER_ADMIN",
        action=action,
        resource_type=resource_type,
        resource_id=str(resource_id),
        previous_state=None,
        new_state=json.dumps(details or {}) if details else None,
        reason=reason,
    )
    db.add(event)


# ==========================================
# 1. Platform Telemetry & KPI Overview
# ==========================================
@router.get("/telemetry", response_model=AdminPlatformTelemetryResponse)
async def get_platform_telemetry(
    admin: dict[str, Any] = Depends(require_super_admin),
    db: AsyncSession = Depends(get_db),
):
    """Real-time platform telemetry, Gross Booking Value, and health KPIs."""
    user_cnt = (await db.execute(select(func.count(User.id)))).scalar() or 0
    org_cnt = (await db.execute(select(func.count(Organization.id)))).scalar() or 0
    trip_cnt = (await db.execute(select(func.count(Trip.id)))).scalar() or 0
    booking_cnt = (await db.execute(select(func.count(ServiceBooking.id)))).scalar() or 0

    # Financial sums
    gbv_minor = (await db.execute(select(func.sum(ServiceBooking.amount_minor)))).scalar() or 0
    escrow_minor = (
        await db.execute(
            select(func.sum(ServiceBooking.amount_minor)).where(
                ServiceBooking.status.in_(["CONFIRMED", "PROVIDER_ACCEPTED"])
            )
        )
    ).scalar() or 0

    exceptions_cnt = (
        await db.execute(select(func.count(SupportCase.id)).where(SupportCase.status == "OPEN"))
    ).scalar() or 0
    disruptions_cnt = (
        await db.execute(select(func.count(DisruptionEvent.id)).where(DisruptionEvent.status == "DETECTED"))
    ).scalar() or 0

    return AdminPlatformTelemetryResponse(
        total_users=user_cnt,
        total_providers=org_cnt,
        total_trips=trip_cnt,
        total_bookings=booking_cnt,
        gross_booking_value_lkr=gbv_minor / 100.0,
        escrow_held_lkr=escrow_minor / 100.0,
        open_exceptions_count=exceptions_cnt,
        active_disruptions_count=disruptions_cnt,
        system_status="ALL_SYSTEMS_OPERATIONAL",
    )


# ==========================================
# 2. Users & RBAC Control
# ==========================================
@router.get("/users", response_model=list[AdminUserResponse])
async def list_admin_users(
    search: Optional[str] = None,
    role: Optional[str] = None,
    is_active: Optional[bool] = None,
    limit: int = Query(50, ge=1, le=200),
    offset: int = Query(0, ge=0),
    admin: dict[str, Any] = Depends(require_super_admin),
    db: AsyncSession = Depends(get_db),
):
    query = select(User).order_by(User.created_at.desc())
    if role:
        query = query.where(User.staff_role == role if role == "SUPER_ADMIN" else User.staff_role != "SUPER_ADMIN")
    if is_active is not None:
        query = query.where(User.is_active == is_active)
    if search:
        query = query.where(User.email.ilike(f"%{search}%") | User.full_name.ilike(f"%{search}%"))

    res = await db.execute(query.limit(limit).offset(offset))
    users = res.scalars().all()
    return [
        AdminUserResponse(
            id=u.id,
            email=u.email,
            full_name=u.full_name,
            phone_number=u.phone_number,
            role=u.staff_role or "TRAVELER",
            is_active=u.is_active,
            is_verified=getattr(u, "is_verified", True),
            created_at=u.created_at,
        )
        for u in users
    ]


@router.post("/users", response_model=AdminUserResponse, status_code=status.HTTP_201_CREATED)
async def create_admin_user(
    req: AdminUserCreateRequest,
    admin: dict[str, Any] = Depends(require_super_admin),
    db: AsyncSession = Depends(get_db),
):
    existing = await db.execute(select(User).where(User.email == req.email))
    if existing.scalar_one_or_none():
        raise TraverzaException("USER_EXISTS", f"Email '{req.email}' already exists", status_code=409)

    user = User(
        email=req.email,
        hashed_password=hash_password(req.password),
        full_name=req.full_name,
        phone_number=req.phone_number,
        is_staff=req.role == "SUPER_ADMIN",
        staff_role=req.role if req.role == "SUPER_ADMIN" else None,
        is_active=req.is_active,
    )
    db.add(user)
    await db.flush()

    await log_admin_action(
        db=db,
        actor_id=uuid.UUID(admin["sub"]),
        action="USER_CREATED",
        resource_type="User",
        resource_id=user.id,
        reason=f"Administrator created user with role {req.role}",
    )
    await db.commit()
    await db.refresh(user)

    return AdminUserResponse(
        id=user.id,
        email=user.email,
        full_name=user.full_name,
        phone_number=user.phone_number,
        role=user.staff_role or req.role,
        is_active=user.is_active,
        is_verified=True,
        created_at=user.created_at,
    )


@router.put("/users/{user_id}", response_model=AdminUserResponse)
async def update_admin_user(
    user_id: uuid.UUID,
    req: AdminUserUpdateRequest,
    admin: dict[str, Any] = Depends(require_super_admin),
    db: AsyncSession = Depends(get_db),
):
    user = await db.get(User, user_id)
    if not user:
        raise NotFoundException("User", user_id)

    if req.full_name is not None:
        user.full_name = req.full_name
    if req.phone_number is not None:
        user.phone_number = req.phone_number
    if req.is_active is not None:
        user.is_active = req.is_active
    if req.role is not None:
        user.staff_role = req.role if req.role == "SUPER_ADMIN" else None
        user.is_staff = req.role == "SUPER_ADMIN"
    if req.password:
        user.hashed_password = hash_password(req.password)

    await log_admin_action(
        db=db,
        actor_id=uuid.UUID(admin["sub"]),
        action="USER_UPDATED",
        resource_type="User",
        resource_id=user.id,
        reason="Administrator modified user profile and credentials",
    )
    await db.commit()
    await db.refresh(user)

    return AdminUserResponse(
        id=user.id,
        email=user.email,
        full_name=user.full_name,
        phone_number=user.phone_number,
        role=user.staff_role or "TRAVELER",
        is_active=user.is_active,
        is_verified=True,
        created_at=user.created_at,
    )


@router.delete("/users/{user_id}", status_code=status.HTTP_200_OK)
async def delete_admin_user(
    user_id: uuid.UUID,
    admin: dict[str, Any] = Depends(require_super_admin),
    db: AsyncSession = Depends(get_db),
):
    user = await db.get(User, user_id)
    if not user:
        raise NotFoundException("User", user_id)

    user.is_active = False
    await log_admin_action(
        db=db,
        actor_id=uuid.UUID(admin["sub"]),
        action="USER_DEACTIVATED",
        resource_type="User",
        resource_id=user.id,
        reason="Administrator deactivated user account",
    )
    await db.commit()
    return {"status": "DEACTIVATED", "user_id": str(user_id)}


# ==========================================
# 3. Provider Organizations CRUD
# ==========================================
@router.get("/organizations", response_model=list[AdminOrgResponse])
async def list_admin_organizations(
    category: Optional[str] = None,
    is_verified: Optional[bool] = None,
    admin: dict[str, Any] = Depends(require_super_admin),
    db: AsyncSession = Depends(get_db),
):
    query = select(Organization).order_by(Organization.created_at.desc())
    if category:
        query = query.where(Organization.category == category)
    if is_verified is not None:
        query = query.where(Organization.is_verified == is_verified)

    res = await db.execute(query)
    return res.scalars().all()


@router.post("/organizations", response_model=AdminOrgResponse, status_code=status.HTTP_201_CREATED)
async def create_admin_organization(
    req: AdminOrgCreateRequest,
    admin: dict[str, Any] = Depends(require_super_admin),
    db: AsyncSession = Depends(get_db),
):
    org = Organization(
        name=req.name,
        legal_name=req.legal_name,
        business_reg_no=req.business_reg_no,
        sltda_license_no=req.sltda_license_no,
        category=req.category,
        contact_email=req.contact_email,
        contact_phone=req.contact_phone,
        is_verified=req.is_verified,
    )
    db.add(org)
    await db.flush()

    await log_admin_action(
        db=db,
        actor_id=uuid.UUID(admin["sub"]),
        action="ORGANIZATION_CREATED",
        resource_type="Organization",
        resource_id=org.id,
        reason=f"Administrator registered provider org: {req.name}",
    )
    await db.commit()
    await db.refresh(org)
    return org


@router.put("/organizations/{org_id}", response_model=AdminOrgResponse)
async def update_admin_organization(
    org_id: uuid.UUID,
    req: AdminOrgUpdateRequest,
    admin: dict[str, Any] = Depends(require_super_admin),
    db: AsyncSession = Depends(get_db),
):
    org = await db.get(Organization, org_id)
    if not org:
        raise NotFoundException("Organization", org_id)

    if req.name is not None:
        org.name = req.name
    if req.legal_name is not None:
        org.legal_name = req.legal_name
    if req.business_reg_no is not None:
        org.business_reg_no = req.business_reg_no
    if req.sltda_license_no is not None:
        org.sltda_license_no = req.sltda_license_no
    if req.category is not None:
        org.category = req.category
    if req.contact_email is not None:
        org.contact_email = req.contact_email
    if req.contact_phone is not None:
        org.contact_phone = req.contact_phone
    if req.is_verified is not None:
        org.is_verified = req.is_verified

    await log_admin_action(
        db=db,
        actor_id=uuid.UUID(admin["sub"]),
        action="ORGANIZATION_UPDATED",
        resource_type="Organization",
        resource_id=org.id,
        reason="Administrator modified provider organization credentials",
    )
    await db.commit()
    await db.refresh(org)
    return org


@router.delete("/organizations/{org_id}", status_code=status.HTTP_200_OK)
async def delete_admin_organization(
    org_id: uuid.UUID,
    admin: dict[str, Any] = Depends(require_super_admin),
    db: AsyncSession = Depends(get_db),
):
    org = await db.get(Organization, org_id)
    if not org:
        raise NotFoundException("Organization", org_id)

    org.is_verified = False
    await log_admin_action(
        db=db,
        actor_id=uuid.UUID(admin["sub"]),
        action="ORGANIZATION_DEACTIVATED",
        resource_type="Organization",
        resource_id=org.id,
        reason="Administrator revoked provider verification",
    )
    await db.commit()
    return {"status": "DEACTIVATED", "organization_id": str(org_id)}


# ==========================================
# 4. Destinations & Places CRUD
# ==========================================
@router.get("/destinations", response_model=list[AdminDestinationResponse])
async def list_admin_destinations(
    corridor: Optional[str] = None,
    admin: dict[str, Any] = Depends(require_super_admin),
    db: AsyncSession = Depends(get_db),
):
    query = select(Destination).order_by(Destination.name)
    if corridor:
        query = query.where(Destination.corridor_name.ilike(f"%{corridor}%"))
    res = await db.execute(query)
    return res.scalars().all()


@router.post("/destinations", response_model=AdminDestinationResponse, status_code=status.HTTP_201_CREATED)
async def create_admin_destination(
    req: AdminDestinationCreateRequest,
    admin: dict[str, Any] = Depends(require_super_admin),
    db: AsyncSession = Depends(get_db),
):
    dest = Destination(
        name=req.name,
        slug=req.slug,
        province=req.province,
        corridor_name=req.corridor_name,
        description=req.description,
        latitude=req.latitude,
        longitude=req.longitude,
    )
    db.add(dest)
    await db.flush()

    await log_admin_action(
        db=db,
        actor_id=uuid.UUID(admin["sub"]),
        action="DESTINATION_CREATED",
        resource_type="Destination",
        resource_id=dest.id,
        reason=f"Administrator added new destination: {req.name}",
    )
    await db.commit()
    await db.refresh(dest)
    return dest


@router.put("/destinations/{dest_id}", response_model=AdminDestinationResponse)
async def update_admin_destination(
    dest_id: uuid.UUID,
    req: AdminDestinationUpdateRequest,
    admin: dict[str, Any] = Depends(require_super_admin),
    db: AsyncSession = Depends(get_db),
):
    dest = await db.get(Destination, dest_id)
    if not dest:
        raise NotFoundException("Destination", dest_id)

    if req.name is not None:
        dest.name = req.name
    if req.province is not None:
        dest.province = req.province
    if req.corridor_name is not None:
        dest.corridor_name = req.corridor_name
    if req.description is not None:
        dest.description = req.description
    if req.latitude is not None:
        dest.latitude = req.latitude
    if req.longitude is not None:
        dest.longitude = req.longitude

    await log_admin_action(
        db=db,
        actor_id=uuid.UUID(admin["sub"]),
        action="DESTINATION_UPDATED",
        resource_type="Destination",
        resource_id=dest.id,
        reason="Administrator modified destination coordinates and details",
    )
    await db.commit()
    await db.refresh(dest)
    return dest


@router.delete("/destinations/{dest_id}", status_code=status.HTTP_200_OK)
async def delete_admin_destination(
    dest_id: uuid.UUID,
    admin: dict[str, Any] = Depends(require_super_admin),
    db: AsyncSession = Depends(get_db),
):
    dest = await db.get(Destination, dest_id)
    if not dest:
        raise NotFoundException("Destination", dest_id)

    await db.delete(dest)
    await log_admin_action(
        db=db,
        actor_id=uuid.UUID(admin["sub"]),
        action="DESTINATION_DELETED",
        resource_type="Destination",
        resource_id=dest_id,
        reason=f"Administrator deleted destination: {dest.name}",
    )
    await db.commit()
    return {"status": "DELETED", "destination_id": str(dest_id)}


# ==========================================
# 5. Catalogue Listings CRUD
# ==========================================
@router.get("/listings", response_model=list[AdminListingResponse])
async def list_admin_listings(
    category: Optional[str] = None,
    org_id: Optional[uuid.UUID] = None,
    admin: dict[str, Any] = Depends(require_super_admin),
    db: AsyncSession = Depends(get_db),
):
    query = select(Listing).order_by(Listing.created_at.desc())
    if category:
        query = query.where(Listing.category == category)
    if org_id:
        query = query.where(Listing.organization_id == org_id)

    res = await db.execute(query)
    return res.scalars().all()


@router.post("/listings", response_model=AdminListingResponse, status_code=status.HTTP_201_CREATED)
async def create_admin_listing(
    req: AdminListingCreateRequest,
    admin: dict[str, Any] = Depends(require_super_admin),
    db: AsyncSession = Depends(get_db),
):
    listing = Listing(
        organization_id=req.organization_id,
        destination_id=req.destination_id,
        title=req.title,
        category=req.category,
        description=req.description,
        base_price_minor=req.base_price_minor,
        currency=req.currency,
        is_published=req.is_published,
        cancellation_policy=req.cancellation_policy,
    )
    db.add(listing)
    await db.flush()

    await log_admin_action(
        db=db,
        actor_id=uuid.UUID(admin["sub"]),
        action="LISTING_CREATED",
        resource_type="Listing",
        resource_id=listing.id,
        reason=f"Administrator created listing: {req.title}",
    )
    await db.commit()
    await db.refresh(listing)
    return listing


@router.put("/listings/{listing_id}", response_model=AdminListingResponse)
async def update_admin_listing(
    listing_id: uuid.UUID,
    req: AdminListingUpdateRequest,
    admin: dict[str, Any] = Depends(require_super_admin),
    db: AsyncSession = Depends(get_db),
):
    listing = await db.get(Listing, listing_id)
    if not listing:
        raise NotFoundException("Listing", listing_id)

    if req.title is not None:
        listing.title = req.title
    if req.category is not None:
        listing.category = req.category
    if req.description is not None:
        listing.description = req.description
    if req.base_price_minor is not None:
        listing.base_price_minor = req.base_price_minor
    if req.currency is not None:
        listing.currency = req.currency
    if req.is_published is not None:
        listing.is_published = req.is_published
    if req.cancellation_policy is not None:
        listing.cancellation_policy = req.cancellation_policy

    await log_admin_action(
        db=db,
        actor_id=uuid.UUID(admin["sub"]),
        action="LISTING_UPDATED",
        resource_type="Listing",
        resource_id=listing.id,
        reason="Administrator modified listing parameters",
    )
    await db.commit()
    await db.refresh(listing)
    return listing


@router.delete("/listings/{listing_id}", status_code=status.HTTP_200_OK)
async def delete_admin_listing(
    listing_id: uuid.UUID,
    admin: dict[str, Any] = Depends(require_super_admin),
    db: AsyncSession = Depends(get_db),
):
    listing = await db.get(Listing, listing_id)
    if not listing:
        raise NotFoundException("Listing", listing_id)

    await db.delete(listing)
    await log_admin_action(
        db=db,
        actor_id=uuid.UUID(admin["sub"]),
        action="LISTING_DELETED",
        resource_type="Listing",
        resource_id=listing_id,
        reason=f"Administrator removed listing: {listing.title}",
    )
    await db.commit()
    return {"status": "DELETED", "listing_id": str(listing_id)}


# ==========================================
# 6. Global Bookings & State Override
# ==========================================
@router.get("/bookings", response_model=list[AdminBookingResponse])
async def list_admin_bookings(
    trip_id: Optional[uuid.UUID] = None,
    status_filter: Optional[str] = None,
    limit: int = Query(50, ge=1, le=200),
    admin: dict[str, Any] = Depends(require_super_admin),
    db: AsyncSession = Depends(get_db),
):
    query = select(ServiceBooking).order_by(ServiceBooking.created_at.desc())
    if trip_id:
        query = query.where(ServiceBooking.trip_id == trip_id)
    if status_filter:
        query = query.where(ServiceBooking.status == status_filter)

    res = await db.execute(query.limit(limit))
    return res.scalars().all()


@router.put("/bookings/{booking_id}/override", response_model=AdminBookingResponse)
async def override_admin_booking_status(
    booking_id: uuid.UUID,
    req: AdminBookingOverrideRequest,
    admin: dict[str, Any] = Depends(require_super_admin),
    db: AsyncSession = Depends(get_db),
):
    """
    Authoritative Administrative Override:
    Allows platform supervisors to override booking states during disputes
    or extreme force majeure while recording mandatory audit reasons.
    """
    booking = await db.get(ServiceBooking, booking_id)
    if not booking:
        raise NotFoundException("ServiceBooking", booking_id)

    old_status = booking.status
    booking.status = req.new_status

    if req.refund_amount_minor is not None:
        booking.refund_amount_minor = req.refund_amount_minor
    if req.new_status == "CANCELLED":
        booking.cancellation_reason = req.reason

    # Add booking state event
    event = BookingEvent(
        booking_id=booking.id,
        from_status=old_status,
        to_status=req.new_status,
        actor_id=uuid.UUID(admin["sub"]),
        actor_role="SUPER_ADMIN",
        reason=f"Admin Override: {req.reason}",
    )
    db.add(event)

    await log_admin_action(
        db=db,
        actor_id=uuid.UUID(admin["sub"]),
        action="BOOKING_STATUS_OVERRIDDEN",
        resource_type="ServiceBooking",
        resource_id=booking.id,
        reason=req.reason,
        details={"from_status": old_status, "to_status": req.new_status},
    )
    await db.commit()
    await db.refresh(booking)
    return booking


# ==========================================
# 7. System Broadcast Dispatcher
# ==========================================
@router.post("/broadcast", status_code=status.HTTP_201_CREATED)
async def dispatch_system_broadcast(
    req: AdminBroadcastRequest,
    admin: dict[str, Any] = Depends(require_super_admin),
    db: AsyncSession = Depends(get_db),
):
    """
    Dispatches a high-priority system broadcast push notification to all users or
    filtered corridor travellers.
    """
    users_stmt = select(User.id).where(User.is_active == True)
    user_ids = (await db.execute(users_stmt)).scalars().all()

    created_cnt = 0
    for uid in user_ids:
        notif = UserNotification(
            user_id=uid,
            title=req.title,
            body=req.body,
            category=req.category,
            priority=req.priority,
            action_route=req.action_route,
            action_label=req.action_label,
            meta_json=json.dumps({"corridor": req.corridor_name or "ALL_SRI_LANKA"}),
        )
        db.add(notif)
        created_cnt += 1

    await log_admin_action(
        db=db,
        actor_id=uuid.UUID(admin["sub"]),
        action="BROADCAST_DISPATCHED",
        resource_type="Notification",
        resource_id=uuid.uuid4(),
        reason=f"Admin broadcast: {req.title} dispatched to {created_cnt} users",
    )
    await db.commit()

    return {
        "status": "DISPATCHED",
        "recipients_count": created_cnt,
        "title": req.title,
        "priority": req.priority,
        "dispatched_at": datetime.now(UTC).isoformat(),
    }
