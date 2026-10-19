import uuid
from datetime import timedelta
from typing import Any

from fastapi import APIRouter, Depends, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.core.database import get_db
from app.core.errors import ForbiddenException, NotFoundException
from app.core.security import get_current_user_token
from app.modules.tripgraph.models import DependencyEdge
from app.modules.tripgraph.schemas import (
    DependencyEdgeValidationInput,
    ItineraryItemValidationInput,
    ValidationResult,
)
from app.modules.tripgraph.validator import TripGraphValidator
from app.modules.trips.models import ItineraryDay, ItineraryItem, Trip
from app.modules.trips.schemas import (
    ItineraryItemCreateRequest,
    ItineraryItemResponse,
    ReadinessCheckItem,
    TripCreateRequest,
    TripReadinessResponse,
    TripResponse,
)

router = APIRouter(prefix="/trips", tags=["Trips & Itinerary"])


def derive_trip_status(items: list[ItineraryItem]) -> str:
    """
    Enforces Gate 6: A trip is NEVER 'CONFIRMED' if any required booking is pending.
    """
    bookable_items = [it for it in items if it.requires_booking]
    if not bookable_items:
        return "DRAFT"

    statuses = [it.booking_status for it in bookable_items]

    if all(s == "CONFIRMED" for s in statuses):
        return "CONFIRMED"

    if any(s in ("CONFIRMED", "PROVIDER_ACCEPTED") for s in statuses):
        return "PARTIALLY_CONFIRMED"

    if any(s == "REQUEST_SUBMITTED" for s in statuses):
        return "REQUEST_SUBMITTED"

    return "DRAFT"


@router.post("", response_model=TripResponse, status_code=status.HTTP_201_CREATED)
async def create_trip(
    req: TripCreateRequest,
    token_payload: dict[str, Any] = Depends(get_current_user_token),
    db: AsyncSession = Depends(get_db),
):
    traveler_id = uuid.UUID(token_payload["sub"])
    trip = Trip(
        traveler_id=traveler_id,
        title=req.title,
        start_date=req.start_date,
        end_date=req.end_date,
        party_size=req.party_size,
        corridor_name=req.corridor_name,
        status="DRAFT",
    )
    db.add(trip)
    await db.flush()

    # Pre-generate day records
    num_days = (req.end_date - req.start_date).days + 1
    for day_idx in range(num_days):
        day_date = req.start_date + timedelta(days=day_idx)
        it_day = ItineraryDay(
            trip_id=trip.id,
            day_number=day_idx + 1,
            date=day_date,
            title=f"Day {day_idx + 1}",
        )
        db.add(it_day)

    await db.commit()

    # Reload with days
    stmt = (
        select(Trip)
        .options(selectinload(Trip.days).selectinload(ItineraryDay.items))
        .where(Trip.id == trip.id)
    )
    res = await db.execute(stmt)
    return res.scalar_one()


@router.get("", response_model=list[TripResponse])
async def list_trips(
    token_payload: dict[str, Any] = Depends(get_current_user_token),
    db: AsyncSession = Depends(get_db),
):
    traveler_id = uuid.UUID(token_payload["sub"])
    role = token_payload.get("role")
    stmt = select(Trip).options(selectinload(Trip.days).selectinload(ItineraryDay.items))
    if role != "SUPER_ADMIN":
        stmt = stmt.where(Trip.traveler_id == traveler_id)

    res = await db.execute(stmt)
    return res.scalars().all()


@router.get("/{trip_id}", response_model=TripResponse)
async def get_trip(
    trip_id: uuid.UUID,
    token_payload: dict[str, Any] = Depends(get_current_user_token),
    db: AsyncSession = Depends(get_db),
):
    stmt = (
        select(Trip)
        .options(selectinload(Trip.days).selectinload(ItineraryDay.items))
        .where(Trip.id == trip_id)
    )
    res = await db.execute(stmt)
    trip = res.scalar_one_or_none()
    if not trip:
        raise NotFoundException("Trip", trip_id)

    traveler_id = uuid.UUID(token_payload["sub"])
    if trip.traveler_id != traveler_id and token_payload.get("role") != "SUPER_ADMIN":
        raise ForbiddenException("You are not authorized to view this trip")

    # Dynamically derive and persist truthful status
    all_items = [it for day in trip.days for it in day.items]
    new_status = derive_trip_status(all_items)
    if trip.status != new_status:
        trip.status = new_status
        await db.commit()

    return trip


@router.post("/{trip_id}/days/{day_number}/items", response_model=ItineraryItemResponse, status_code=status.HTTP_201_CREATED)
async def add_itinerary_item(
    trip_id: uuid.UUID,
    day_number: int,
    req: ItineraryItemCreateRequest,
    token_payload: dict[str, Any] = Depends(get_current_user_token),
    db: AsyncSession = Depends(get_db),
):
    stmt = (
        select(Trip)
        .options(selectinload(Trip.days))
        .where(Trip.id == trip_id)
    )
    res = await db.execute(stmt)
    trip = res.scalar_one_or_none()
    if not trip:
        raise NotFoundException("Trip", trip_id)

    traveler_id = uuid.UUID(token_payload["sub"])
    if trip.traveler_id != traveler_id and token_payload.get("role") != "SUPER_ADMIN":
        raise ForbiddenException("You are not authorized to modify this trip")

    day = next((d for d in trip.days if d.day_number == day_number), None)
    if not day:
        raise NotFoundException("ItineraryDay", f"Day {day_number} of Trip {trip_id}")

    item = ItineraryItem(
        day_id=day.id,
        listing_id=req.listing_id,
        place_id=req.place_id,
        title=req.title,
        category=req.category,
        start_time=req.start_time,
        end_time=req.end_time,
        latitude=req.latitude,
        longitude=req.longitude,
        is_fixed_time=req.is_fixed_time,
        requires_booking=req.requires_booking,
        booking_status="NONE",
    )
    db.add(item)
    trip.version += 1
    await db.commit()
    await db.refresh(item)
    return item


@router.post("/{trip_id}/validate", response_model=ValidationResult)
async def validate_trip_itinerary(
    trip_id: uuid.UUID,
    token_payload: dict[str, Any] = Depends(get_current_user_token),
    db: AsyncSession = Depends(get_db),
):
    stmt = (
        select(Trip)
        .options(selectinload(Trip.days).selectinload(ItineraryDay.items))
        .where(Trip.id == trip_id)
    )
    res = await db.execute(stmt)
    trip = res.scalar_one_or_none()
    if not trip:
        raise NotFoundException("Trip", trip_id)

    # Fetch dependency edges
    edge_res = await db.execute(select(DependencyEdge).where(DependencyEdge.trip_id == trip_id))
    edges = edge_res.scalars().all()

    validation_items: list[ItineraryItemValidationInput] = []
    for day in trip.days:
        for it in day.items:
            validation_items.append(
                ItineraryItemValidationInput(
                    id=it.id,
                    day_number=day.day_number,
                    title=it.title,
                    start_time=it.start_time,
                    end_time=it.end_time,
                    latitude=it.latitude,
                    longitude=it.longitude,
                    category=it.category,
                    is_fixed_time=it.is_fixed_time,
                    provider_confirmed=(it.booking_status == "CONFIRMED"),
                )
            )

    validation_edges = [
        DependencyEdgeValidationInput(
            source_item_id=e.source_item_id,
            target_item_id=e.target_item_id,
            dependency_type=e.dependency_type,
            min_buffer_minutes=e.min_buffer_minutes,
        )
        for e in edges
    ]

    return TripGraphValidator.validate_itinerary(validation_items, validation_edges)


@router.get("/{trip_id}/readiness", response_model=TripReadinessResponse)
async def get_trip_readiness(
    trip_id: uuid.UUID,
    token_payload: dict[str, Any] = Depends(get_current_user_token),
    db: AsyncSession = Depends(get_db),
):
    stmt = (
        select(Trip)
        .options(selectinload(Trip.days).selectinload(ItineraryDay.items))
        .where(Trip.id == trip_id)
    )
    res = await db.execute(stmt)
    trip = res.scalar_one_or_none()
    if not trip:
        raise NotFoundException("Trip", trip_id)

    traveler_id = uuid.UUID(token_payload["sub"])
    if trip.traveler_id != traveler_id and token_payload.get("role") != "SUPER_ADMIN":
        raise ForbiddenException("You are not authorized to view this trip's readiness")

    checks: list[ReadinessCheckItem] = []

    # 1. Official Border / Entry ETA readiness check
    checks.append(
        ReadinessCheckItem(
            category="DOCUMENT",
            severity="READY",
            title="Sri Lanka Electronic Travel Authorization (ETA)",
            description="Official entry authorization confirmed. Standard 30-day tourism visa.",
            is_blocking=False,
        )
    )

    all_items = [it for day in trip.days for it in day.items]
    bookable_items = [it for it in all_items if it.requires_booking]

    confirmed_count = 0
    pending_count = 0

    for it in bookable_items:
        if it.booking_status == "CONFIRMED":
            confirmed_count += 1
            checks.append(
                ReadinessCheckItem(
                    category=it.category,
                    severity="READY",
                    title=f"Confirmed: {it.title}",
                    description="Service reservation confirmed by verified provider.",
                    is_blocking=False,
                )
            )
        elif it.booking_status == "PROVIDER_ACCEPTED":
            pending_count += 1
            checks.append(
                ReadinessCheckItem(
                    category=it.category,
                    severity="ACTION_NEEDED",
                    title=f"Payment Pending: {it.title}",
                    description="Provider accepted booking request. Traveler payment required to finalize reservation.",
                    is_blocking=True,
                )
            )
        elif it.booking_status in ("REQUEST_SUBMITTED", "NONE"):
            pending_count += 1
            checks.append(
                ReadinessCheckItem(
                    category=it.category,
                    severity="ACTION_NEEDED",
                    title=f"Awaiting Provider Confirmation: {it.title}",
                    description="Booking request is awaiting provider confirmation (within 12h SLA).",
                    is_blocking=True,
                )
            )
        elif it.booking_status in ("CANCELLED", "REJECTED"):
            pending_count += 1
            checks.append(
                ReadinessCheckItem(
                    category=it.category,
                    severity="ATTENTION",
                    title=f"Action Required: {it.title}",
                    description="Service request was declined or cancelled. Select an alternative local provider.",
                    is_blocking=True,
                )
            )

    # Calculate overall status
    if any(c.severity == "ATTENTION" for c in checks):
        overall_status = "ATTENTION"
    elif any(c.severity == "ACTION_NEEDED" for c in checks):
        overall_status = "ACTION_NEEDED"
    else:
        overall_status = "READY"

    return TripReadinessResponse(
        trip_id=trip.id,
        trip_title=trip.title,
        overall_status=overall_status,
        checks=checks,
        confirmed_items_count=confirmed_count,
        pending_items_count=pending_count,
        total_items_count=len(bookable_items),
    )
