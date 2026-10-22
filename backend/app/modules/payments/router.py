import json
import uuid
from typing import Any

from fastapi import APIRouter, Depends, Header, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.errors import NotFoundException, TraverzaException
from app.core.security import get_current_user_token
from app.modules.bookings.models import ServiceBooking
from app.modules.payments.models import (
    LedgerAccount,
    LedgerEntry,
    PaymentIntent,
    WebhookEvent,
)
from app.modules.payments.schemas import (
    PaymentIntentCreateRequest,
    PaymentIntentResponse,
    WebhookPayload,
)
from app.modules.trips.models import ItineraryItem, Trip

router = APIRouter(prefix="/payments", tags=["Payments & Ledger"])


@router.post("/intents", response_model=PaymentIntentResponse, status_code=status.HTTP_201_CREATED)
async def create_payment_intent(
    req: PaymentIntentCreateRequest,
    token_payload: dict[str, Any] = Depends(get_current_user_token),
    db: AsyncSession = Depends(get_db),
):
    # Check idempotency
    existing = await db.execute(
        select(PaymentIntent).where(PaymentIntent.idempotency_key == req.idempotency_key)
    )
    pi = existing.scalar_one_or_none()
    if pi:
        return pi

    trip = await db.get(Trip, req.trip_id)
    if not trip:
        raise NotFoundException("Trip", req.trip_id)

    # Calculate total of accepted bookings
    stmt = select(ServiceBooking).where(
        ServiceBooking.trip_id == trip.id,
        ServiceBooking.status == "PROVIDER_ACCEPTED",
    )
    bookings_res = await db.execute(stmt)
    accepted_bookings = bookings_res.scalars().all()

    if not accepted_bookings:
        raise TraverzaException(
            code="NO_PAYABLE_SERVICES",
            message="No provider-accepted bookings found to pay for",
            status_code=status.HTTP_400_BAD_REQUEST,
        )

    total_amount = sum(b.amount_minor for b in accepted_bookings)
    ref = f"pay_{uuid.uuid4().hex[:12]}"

    pi = PaymentIntent(
        trip_id=trip.id,
        gateway_name="SANDBOX",
        gateway_reference=ref,
        amount_minor=total_amount,
        currency="LKR",
        status="CREATED",
        idempotency_key=req.idempotency_key,
    )
    db.add(pi)
    await db.commit()
    await db.refresh(pi)
    return pi


@router.post("/webhooks/{gateway}")
async def receive_payment_webhook(
    gateway: str,
    payload: WebhookPayload,
    x_signature: str = Header(default="sandbox_valid_sig"),
    db: AsyncSession = Depends(get_db),
):
    """
    Gate 5: Webhook Idempotency & Replay Defense.
    Deduplicates incoming webhooks by event_id in the database.
    """
    # 1. Check for duplicate event_id
    stmt = select(WebhookEvent).where(WebhookEvent.gateway_event_id == payload.event_id)
    existing_event = (await db.execute(stmt)).scalar_one_or_none()
    if existing_event:
        return {
            "status": "duplicate_ignored",
            "message": "Webhook already processed. No duplicate ledger entries created.",
            "event_id": payload.event_id,
        }

    # 2. Record raw webhook event
    event = WebhookEvent(
        gateway=gateway,
        gateway_event_id=payload.event_id,
        payload_json=json.dumps(payload.model_dump()),
        is_processed=True,
    )
    db.add(event)

    # 3. Locate payment intent
    pi_stmt = select(PaymentIntent).where(
        PaymentIntent.gateway_reference == payload.gateway_reference
    )
    pi = (await db.execute(pi_stmt)).scalar_one_or_none()
    if not pi:
        await db.commit()
        return {"status": "unmatched_reference", "reference": payload.gateway_reference}

    if payload.event_type == "PAYMENT_CAPTURED":
        pi.status = "CAPTURED"

        # Update all accepted bookings to CONFIRMED
        b_stmt = select(ServiceBooking).where(
            ServiceBooking.trip_id == pi.trip_id,
            ServiceBooking.status == "PROVIDER_ACCEPTED",
        )
        bookings = (await db.execute(b_stmt)).scalars().all()
        for b in bookings:
            b.status = "CONFIRMED"
            item = await db.get(ItineraryItem, b.itinerary_item_id)
            if item:
                item.booking_status = "CONFIRMED"

        # Double-entry ledger entry
        # Debit: Cash in transit / Gateway (Asset)
        # Credit: Platform Escrow / Customer Funds (Liability)
        tx_id = uuid.uuid4()

        # Ensure default accounts exist
        cash_acc = (await db.execute(select(LedgerAccount).where(LedgerAccount.code == "GATEWAY_CASH"))).scalar_one_or_none()
        if not cash_acc:
            cash_acc = LedgerAccount(code="GATEWAY_CASH", name="Gateway Cash Account", type="ASSET")
            db.add(cash_acc)
            await db.flush()

        escrow_acc = (await db.execute(select(LedgerAccount).where(LedgerAccount.code == "PLATFORM_ESCROW"))).scalar_one_or_none()
        if not escrow_acc:
            escrow_acc = LedgerAccount(code="PLATFORM_ESCROW", name="Customer Escrow Liability", type="LIABILITY")
            db.add(escrow_acc)
            await db.flush()

        entry_debit = LedgerEntry(
            transaction_id=tx_id,
            account_id=cash_acc.id,
            debit_minor=payload.amount_minor,
            credit_minor=0,
            currency=payload.currency,
            memo=f"Capture from {payload.gateway_reference}",
        )
        entry_credit = LedgerEntry(
            transaction_id=tx_id,
            account_id=escrow_acc.id,
            debit_minor=0,
            credit_minor=payload.amount_minor,
            currency=payload.currency,
            memo=f"Escrow liability for Trip {pi.trip_id}",
        )
        db.add(entry_debit)
        db.add(entry_credit)

    await db.commit()
    return {"status": "processed", "event_id": payload.event_id}


@router.post("/escrow/release/{booking_id}")
async def release_escrow_to_provider(
    booking_id: uuid.UUID,
    token_payload: dict[str, Any] = Depends(get_current_user_token),
    db: AsyncSession = Depends(get_db),
):
    """
    Authoritative Escrow Payout (Gate 5 Invariant):
    Releases held escrow funds to provider upon service completion.
    Double-entry accounting:
      Debit: PLATFORM_ESCROW (100% of GBV)
      Credit: PROVIDER_PAYABLE (90% provider net payable)
      Credit: PLATFORM_REVENUE (10% agreed platform commission)
    Guarantees sum(debit) == sum(credit).
    """
    booking = await db.get(ServiceBooking, booking_id)
    if not booking:
        raise NotFoundException("ServiceBooking", booking_id)

    role = token_payload.get("role")
    if role != "SUPER_ADMIN":
        raise TraverzaException(
            code="UNAUTHORIZED_ESCROW_RELEASE",
            message="Only authorized platform finance officers can release escrow funds",
            status_code=status.HTTP_403_FORBIDDEN,
        )

    if booking.status not in ("CONFIRMED", "COMPLETED"):
        raise TraverzaException(
            code="INVALID_BOOKING_STATE",
            message=f"Cannot release escrow for booking in state '{booking.status}'",
            status_code=status.HTTP_400_BAD_REQUEST,
        )

    # Calculate 10% platform commission and 90% provider payable
    total_minor = booking.amount_minor
    commission_minor = int(total_minor * 0.10)
    provider_minor = total_minor - commission_minor

    # Ensure accounts exist
    escrow_acc = (await db.execute(select(LedgerAccount).where(LedgerAccount.code == "PLATFORM_ESCROW"))).scalar_one_or_none()
    if not escrow_acc:
        escrow_acc = LedgerAccount(code="PLATFORM_ESCROW", name="Customer Escrow Liability", type="LIABILITY")
        db.add(escrow_acc)
        await db.flush()

    provider_acc = (await db.execute(select(LedgerAccount).where(LedgerAccount.code == "PROVIDER_PAYABLE"))).scalar_one_or_none()
    if not provider_acc:
        provider_acc = LedgerAccount(code="PROVIDER_PAYABLE", name="Provider Settlement Payable", type="LIABILITY")
        db.add(provider_acc)
        await db.flush()

    revenue_acc = (await db.execute(select(LedgerAccount).where(LedgerAccount.code == "PLATFORM_REVENUE"))).scalar_one_or_none()
    if not revenue_acc:
        revenue_acc = LedgerAccount(code="PLATFORM_REVENUE", name="Platform Commission Revenue", type="REVENUE")
        db.add(revenue_acc)
        await db.flush()

    tx_id = uuid.uuid4()
    # 1. Debit PLATFORM_ESCROW (Decreasing platform liability)
    entry_debit_escrow = LedgerEntry(
        transaction_id=tx_id,
        account_id=escrow_acc.id,
        debit_minor=total_minor,
        credit_minor=0,
        currency=booking.currency,
        memo=f"Escrow release for Booking {booking.id}",
    )
    # 2. Credit PROVIDER_PAYABLE (Payable to operator)
    entry_credit_provider = LedgerEntry(
        transaction_id=tx_id,
        account_id=provider_acc.id,
        debit_minor=0,
        credit_minor=provider_minor,
        currency=booking.currency,
        memo=f"Settlement payable for Org {booking.organization_id}",
    )
    # 3. Credit PLATFORM_REVENUE (10% commission revenue)
    entry_credit_revenue = LedgerEntry(
        transaction_id=tx_id,
        account_id=revenue_acc.id,
        debit_minor=0,
        credit_minor=commission_minor,
        currency=booking.currency,
        memo=f"10% Platform commission on Booking {booking.id}",
    )

    db.add(entry_debit_escrow)
    db.add(entry_credit_provider)
    db.add(entry_credit_revenue)

    booking.status = "COMPLETED"
    await db.commit()

    return {
        "status": "ESCROW_RELEASED",
        "booking_id": str(booking.id),
        "total_amount_minor": total_minor,
        "provider_payable_minor": provider_minor,
        "platform_commission_minor": commission_minor,
        "currency": booking.currency,
        "transaction_id": str(tx_id),
        "ledger_balanced": True,
    }
