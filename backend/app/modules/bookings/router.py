import uuid
from datetime import UTC, datetime, timedelta
from typing import Any

from fastapi import APIRouter, Depends, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.errors import (
    ForbiddenException,
    NotFoundException,
    QuoteExpiredException,
    TraverzaException,
)
from app.core.security import TenantContext, get_current_user_token
from app.modules.bookings.models import BookingEvent, QuoteSnapshot, ServiceBooking
from app.modules.bookings.schemas import (
    BookingCreateRequest,
    BookingResponse,
    ProviderRespondRequest,
    QuoteCreateRequest,
    QuoteSnapshotResponse,
)
from app.modules.catalogue.models import Listing
from app.modules.trips.models import ItineraryItem, Trip

router = APIRouter(tags=["Quotes & Bookings"])


@router.post("/trips/{trip_id}/quotes", response_model=QuoteSnapshotResponse, status_code=status.HTTP_201_CREATED)
async def create_quote_snapshot(
    trip_id: uuid.UUID,
    req: QuoteCreateRequest,
    token_payload: dict[str, Any] = Depends(get_current_user_token),
    db: AsyncSession = Depends(get_db),
):
    listing = await db.get(Listing, req.listing_id)
    if not listing:
        raise NotFoundException("Listing", req.listing_id)

    expires_at = datetime.now(UTC) + timedelta(hours=req.validity_hours)

    quote = QuoteSnapshot(
        trip_id=trip_id,
        listing_id=listing.id,
        organization_id=listing.organization_id,
        amount_minor=listing.base_price_minor,
        currency=listing.currency,
        cancellation_terms=listing.cancellation_policy,
        expires_at=expires_at,
    )
    db.add(quote)
    await db.commit()
    await db.refresh(quote)
    return quote


@router.post("/bookings", response_model=BookingResponse, status_code=status.HTTP_201_CREATED)
async def create_booking_request(
    req: BookingCreateRequest,
    token_payload: dict[str, Any] = Depends(get_current_user_token),
    db: AsyncSession = Depends(get_db),
):
    traveler_id = uuid.UUID(token_payload["sub"])
    trip = await db.get(Trip, req.trip_id)
    if not trip or trip.traveler_id != traveler_id:
        raise ForbiddenException("Unauthorized trip access")

    # Gate 3: Check quote expiration
    quote = await db.get(QuoteSnapshot, req.quote_snapshot_id)
    if not quote:
        raise NotFoundException("QuoteSnapshot", req.quote_snapshot_id)

    now_utc = datetime.now(UTC)
    # Ensure timezone awareness for comparison
    quote_exp = quote.expires_at if quote.expires_at.tzinfo else quote.expires_at.replace(tzinfo=UTC)
    if now_utc > quote_exp:
        raise QuoteExpiredException(str(quote.id))

    item = await db.get(ItineraryItem, req.itinerary_item_id)
    if not item:
        raise NotFoundException("ItineraryItem", req.itinerary_item_id)

    # Check existing booking
    existing = await db.execute(
        select(ServiceBooking).where(ServiceBooking.itinerary_item_id == item.id)
    )
    if existing.scalar_one_or_none():
        raise TraverzaException(
            code="BOOKING_EXISTS",
            message="A booking already exists for this itinerary item",
            status_code=status.HTTP_409_CONFLICT,
        )

    deadline = now_utc + timedelta(hours=12)
    booking = ServiceBooking(
        trip_id=trip.id,
        organization_id=quote.organization_id,
        itinerary_item_id=item.id,
        quote_snapshot_id=quote.id,
        status="REQUEST_SUBMITTED",
        amount_minor=quote.amount_minor,
        currency=quote.currency,
        response_deadline_at=deadline,
    )
    db.add(booking)
    await db.flush()

    item.booking_status = "REQUEST_SUBMITTED"

    event = BookingEvent(
        booking_id=booking.id,
        from_status="NONE",
        to_status="REQUEST_SUBMITTED",
        actor_id=traveler_id,
        actor_role="TRAVELER",
        reason="Initial request submitted",
    )
    db.add(event)
    await db.commit()
    await db.refresh(booking)
    return booking


@router.post("/provider/bookings/{booking_id}/respond", response_model=BookingResponse)
async def provider_respond_to_booking(
    booking_id: uuid.UUID,
    req: ProviderRespondRequest,
    org_id: uuid.UUID = Depends(TenantContext()),
    token_payload: dict[str, Any] = Depends(get_current_user_token),
    db: AsyncSession = Depends(get_db),
):
    booking = await db.get(ServiceBooking, booking_id)
    if not booking:
        raise NotFoundException("ServiceBooking", booking_id)

    # Gate 2: Strict tenant boundary check
    if booking.organization_id != org_id:
        raise ForbiddenException("Cross-tenant access violation: Booking does not belong to your organization")

    user_id = uuid.UUID(token_payload["sub"])
    old_status = booking.status

    if req.action == "ACCEPT":
        booking.status = "PROVIDER_ACCEPTED"
        booking.confirmed_at = datetime.now(UTC)
    elif req.action == "DECLINE":
        booking.status = "CANCELLED"
        booking.cancellation_reason = req.reason or "Provider declined"
    else:
        raise TraverzaException("INVALID_ACTION", f"Unknown action '{req.action}'")

    # Update itinerary item status
    item = await db.get(ItineraryItem, booking.itinerary_item_id)
    if item:
        item.booking_status = booking.status

    event = BookingEvent(
        booking_id=booking.id,
        from_status=old_status,
        to_status=booking.status,
        actor_id=user_id,
        actor_role="PROVIDER",
        reason=req.reason,
    )
    db.add(event)
    await db.commit()
    await db.refresh(booking)
    return booking
