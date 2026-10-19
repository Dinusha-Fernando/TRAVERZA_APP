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
