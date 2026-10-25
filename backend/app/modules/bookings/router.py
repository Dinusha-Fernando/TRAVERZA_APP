import base64
import hashlib
import hmac
import json
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
    BookingItemSummary,
    BookingResponse,
    CancellationRequest,
    CancellationResponse,
    PaymentConfirmRequest,
    ProviderRespondRequest,
    QuoteCreateRequest,
    QuoteSnapshotResponse,
    TripBookingSummaryResponse,
)
from app.modules.catalogue.models import Listing
from app.modules.trips.models import ItineraryDay, ItineraryItem, Trip

router = APIRouter(tags=["Quotes & Bookings"])


def generate_signed_voucher_token(booking_id: uuid.UUID, traveler_id: uuid.UUID, amount_minor: int, currency: str) -> str:
    """Generates an offline-verifiable, HMAC-signed travel voucher token."""
    payload = {
        "booking_id": str(booking_id),
        "traveler_id": str(traveler_id),
        "amount_minor": amount_minor,
        "currency": currency,
        "issued_at": datetime.now(UTC).isoformat(),
        "issuer": "TRAVERZA_OPERATING_PLATFORM_SRI_LANKA",
        "jurisdiction": "LK_SLTDA_COMPLIANT",
    }
    dumped = json.dumps(payload, sort_keys=True)
    sig = hmac.new(b"traverza-secure-voucher-key-2026", dumped.encode(), hashlib.sha256).hexdigest()
    b64_payload = base64.urlsafe_b64encode(dumped.encode()).decode()
    return f"TRV.{b64_payload}.{sig[:16]}"



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


@router.get("/bookings/{booking_id}", response_model=BookingResponse)
async def get_booking(
    booking_id: uuid.UUID,
    token_payload: dict[str, Any] = Depends(get_current_user_token),
    db: AsyncSession = Depends(get_db),
):
    booking = await db.get(ServiceBooking, booking_id)
    if not booking:
        raise NotFoundException("ServiceBooking", booking_id)

    user_id = uuid.UUID(token_payload["sub"])
    role = token_payload.get("role")
    org_ids = [uuid.UUID(oid) for oid in token_payload.get("org_ids", [])]

    # Verify authorization: Must be trip owner, provider org member, or admin
    trip = await db.get(Trip, booking.trip_id)
    is_traveler = trip and trip.traveler_id == user_id
    is_provider = booking.organization_id in org_ids
    is_admin = role == "SUPER_ADMIN"

    if not (is_traveler or is_provider or is_admin):
        raise ForbiddenException("You are not authorized to view this booking")

    return booking


@router.get("/bookings", response_model=list[BookingResponse])
async def list_bookings(
    trip_id: uuid.UUID | None = None,
    token_payload: dict[str, Any] = Depends(get_current_user_token),
    db: AsyncSession = Depends(get_db),
):
    traveler_id = uuid.UUID(token_payload["sub"])
    role = token_payload.get("role")

    stmt = select(ServiceBooking).join(Trip, ServiceBooking.trip_id == Trip.id)
    if role != "SUPER_ADMIN":
        stmt = stmt.where(Trip.traveler_id == traveler_id)
    if trip_id:
        stmt = stmt.where(ServiceBooking.trip_id == trip_id)

    res = await db.execute(stmt)
    return res.scalars().all()


@router.get("/provider/bookings", response_model=list[BookingResponse])
async def list_provider_bookings(
    org_id: uuid.UUID = Depends(TenantContext()),
    token_payload: dict[str, Any] = Depends(get_current_user_token),
    db: AsyncSession = Depends(get_db),
):
    stmt = select(ServiceBooking).where(ServiceBooking.organization_id == org_id)
    res = await db.execute(stmt)
    return res.scalars().all()


@router.post("/bookings/{booking_id}/confirm-payment", response_model=BookingResponse)
async def confirm_booking_payment(
    booking_id: uuid.UUID,
    req: PaymentConfirmRequest,
    token_payload: dict[str, Any] = Depends(get_current_user_token),
    db: AsyncSession = Depends(get_db),
):
    """
    Authoritative state transition from PROVIDER_ACCEPTED / REQUEST_SUBMITTED to CONFIRMED.
    Generates cryptographic offline QR voucher code and signs token.
    """
    booking = await db.get(ServiceBooking, booking_id)
    if not booking:
        raise NotFoundException("ServiceBooking", booking_id)

    user_id = uuid.UUID(token_payload["sub"])
    role = token_payload.get("role")
    trip = await db.get(Trip, booking.trip_id)
    if not (trip and (trip.traveler_id == user_id or role == "SUPER_ADMIN")):
        raise ForbiddenException("Unauthorized to confirm payment for this booking")

    if booking.status not in ("PROVIDER_ACCEPTED", "REQUEST_SUBMITTED"):
        raise TraverzaException(
            code="INVALID_STATE_TRANSITION",
            message=f"Cannot confirm payment for booking in state '{booking.status}'",
            status_code=status.HTTP_400_BAD_REQUEST,
        )

    old_status = booking.status
    now_utc = datetime.now(UTC)

    booking.status = "CONFIRMED"
    booking.confirmed_at = now_utc
    booking.payment_reference = req.payment_reference
    booking.voucher_code = f"VOUCH-LK-{booking.id.hex[:8].upper()}"
    booking.signed_voucher_token = generate_signed_voucher_token(
        booking.id, user_id, booking.amount_minor, booking.currency
    )

    # Update corresponding itinerary item
    item = await db.get(ItineraryItem, booking.itinerary_item_id)
    if item:
        item.booking_status = "CONFIRMED"

    event = BookingEvent(
        booking_id=booking.id,
        from_status=old_status,
        to_status="CONFIRMED",
        actor_id=user_id,
        actor_role="TRAVELER",
        reason=f"Payment confirmed via {req.payment_method}. Ref: {req.payment_reference}",
    )
    db.add(event)
    await db.commit()
    await db.refresh(booking)
    return booking


@router.post("/bookings/{booking_id}/cancel", response_model=CancellationResponse)
async def cancel_booking(
    booking_id: uuid.UUID,
    req: CancellationRequest,
    token_payload: dict[str, Any] = Depends(get_current_user_token),
    db: AsyncSession = Depends(get_db),
):
    """
    Authoritatively cancels a booking, evaluates refund policy, and updates itinerary item.
    """
    booking = await db.get(ServiceBooking, booking_id)
    if not booking:
        raise NotFoundException("ServiceBooking", booking_id)

    user_id = uuid.UUID(token_payload["sub"])
    role = token_payload.get("role")
    org_ids = [uuid.UUID(oid) for oid in token_payload.get("org_ids", [])]

    trip = await db.get(Trip, booking.trip_id)
    is_traveler = trip and trip.traveler_id == user_id
    is_provider = booking.organization_id in org_ids
    is_admin = role == "SUPER_ADMIN"

    if not (is_traveler or is_provider or is_admin):
        raise ForbiddenException("Unauthorized to cancel this booking")

    if booking.status in ("CANCELLED", "COMPLETED"):
        raise TraverzaException(
            code="CANNOT_CANCEL",
            message=f"Booking is already in terminal state '{booking.status}'",
            status_code=status.HTTP_400_BAD_REQUEST,
        )

    # Evaluate cancellation policy
    quote = await db.get(QuoteSnapshot, booking.quote_snapshot_id)
    terms = (quote.cancellation_terms if quote else "FLEXIBLE").upper()

    if "FLEXIBLE" in terms:
        fee_minor = int(booking.amount_minor * 0.10)  # 10% processing fee
    elif "MODERATE" in terms:
        fee_minor = int(booking.amount_minor * 0.25)
    elif "STRICT" in terms:
        fee_minor = int(booking.amount_minor * 0.50)
    else:
        fee_minor = int(booking.amount_minor * 0.15)

    refund_minor = max(0, booking.amount_minor - fee_minor)
    old_status = booking.status
    now_utc = datetime.now(UTC)

    booking.status = "CANCELLED"
    booking.cancellation_reason = req.reason
    booking.refund_amount_minor = refund_minor

    # Update itinerary item
    item = await db.get(ItineraryItem, booking.itinerary_item_id)
    if item:
        item.booking_status = "CANCELLED"

    event = BookingEvent(
        booking_id=booking.id,
        from_status=old_status,
        to_status="CANCELLED",
        actor_id=user_id,
        actor_role="PROVIDER" if is_provider else "TRAVELER",
        reason=f"Cancelled: {req.reason}. Refund calculated: {refund_minor} {booking.currency}",
    )
    db.add(event)
    await db.commit()
    await db.refresh(booking)

    return CancellationResponse(
        booking_id=booking.id,
        status="CANCELLED",
        cancellation_terms=terms,
        cancellation_reason=req.reason,
        amount_minor=booking.amount_minor,
        refund_amount_minor=refund_minor,
        cancellation_fee_minor=fee_minor,
        currency=booking.currency,
        cancelled_at=now_utc,
    )


@router.get("/trips/{trip_id}/booking-summary", response_model=TripBookingSummaryResponse)
async def get_trip_booking_summary(
    trip_id: uuid.UUID,
    token_payload: dict[str, Any] = Depends(get_current_user_token),
    db: AsyncSession = Depends(get_db),
):
    """
    Authoritative trip-level booking status aggregation across all component services.
    Enforces that partial confirmations (e.g. 2 of 3) are never marked as fully CONFIRMED.
    """
    trip = await db.get(Trip, trip_id)
    if not trip:
        raise NotFoundException("Trip", trip_id)

    user_id = uuid.UUID(token_payload["sub"])
    role = token_payload.get("role")
    if not (trip.traveler_id == user_id or role == "SUPER_ADMIN"):
        raise ForbiddenException("Unauthorized to view this trip's booking summary")

    # Fetch all itinerary items for this trip
    days_stmt = select(ItineraryDay).where(ItineraryDay.trip_id == trip_id)
    days_res = await db.execute(days_stmt)
    days = days_res.scalars().all()
    day_ids = [d.id for d in days]

    bookable_items: list[ItineraryItem] = []
    if day_ids:
        items_stmt = select(ItineraryItem).where(
            ItineraryItem.day_id.in_(day_ids),
            ItineraryItem.requires_booking.is_(True),
        )
        items_res = await db.execute(items_stmt)
        bookable_items = list(items_res.scalars().all())

    # Fetch corresponding ServiceBookings
    bookings_stmt = select(ServiceBooking).where(ServiceBooking.trip_id == trip_id)
    bookings_res = await db.execute(bookings_stmt)
    bookings_map = {b.itinerary_item_id: b for b in bookings_res.scalars().all()}

    item_summaries: list[BookingItemSummary] = []
    for it in bookable_items:
        b = bookings_map.get(it.id)
        item_summaries.append(
            BookingItemSummary(
                booking_id=b.id if b else uuid.uuid4(),
                itinerary_item_id=it.id,
                title=it.title,
                category=it.category,
                status=b.status if b else it.booking_status,
                amount_minor=b.amount_minor if b else 0,
                currency=b.currency if b else "LKR",
                voucher_code=b.voucher_code if b else None,
                response_deadline_at=b.response_deadline_at if b else None,
            )
        )

    total_bookable = len(bookable_items)
    requested_cnt = sum(1 for it in item_summaries if it.status == "REQUEST_SUBMITTED")
    accepted_cnt = sum(1 for it in item_summaries if it.status == "PROVIDER_ACCEPTED")
    confirmed_cnt = sum(1 for it in item_summaries if it.status == "CONFIRMED")
    cancelled_cnt = sum(1 for it in item_summaries if it.status == "CANCELLED")

    confirmed_minor = sum(b.amount_minor for b in bookings_map.values() if b.status == "CONFIRMED")

    # Derive authoritative overall status
    if total_bookable > 0 and confirmed_cnt == total_bookable:
        overall_status = "CONFIRMED"
    elif confirmed_cnt > 0 or accepted_cnt > 0:
        overall_status = "PARTIALLY_CONFIRMED"
    elif requested_cnt > 0:
        overall_status = "REQUEST_SUBMITTED"
    else:
        overall_status = "DRAFT"

    return TripBookingSummaryResponse(
        trip_id=trip.id,
        overall_status=overall_status,
        total_bookable_items=total_bookable,
        requested_count=requested_cnt,
        accepted_count=accepted_cnt,
        confirmed_count=confirmed_cnt,
        cancelled_count=cancelled_cnt,
        total_committed_lkr=confirmed_minor / 100.0,
        items=item_summaries,
    )


