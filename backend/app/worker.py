import asyncio
import logging
from datetime import UTC, datetime

from celery import Celery
from sqlalchemy import func, select

from app.core.config import settings
from app.core.database import async_session_maker
from app.modules.bookings.models import BookingEvent, ServiceBooking
from app.modules.payments.models import LedgerEntry

logger = logging.getLogger("traverza.worker")

celery_app = Celery(
    "traverza_worker",
    broker=settings.CELERY_BROKER_URL,
    backend=settings.CELERY_RESULT_BACKEND,
)

celery_app.conf.update(
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="Asia/Colombo",
    enable_utc=True,
    task_routes={
        "app.worker.expire_stale_booking_requests": {"queue": "bookings"},
        "app.worker.dispatch_notification": {"queue": "notifications"},
        "app.worker.daily_financial_ledger_check": {"queue": "finance"},
    },
)


@celery_app.task(name="app.worker.dispatch_notification", bind=True, max_retries=3)
def dispatch_notification(self, recipient_email: str, subject: str, message: str, meta: dict = None):
    """Dispatches durable operational notifications to travellers and providers."""
    try:
        logger.info(f"Dispatching notification to {recipient_email} - Subject: {subject}")
        # In development/sandbox: logs to mailpit or simulated console
        return {"status": "sent", "recipient": recipient_email, "timestamp": datetime.now(UTC).isoformat()}
    except Exception as exc:
        logger.error(f"Failed to dispatch notification to {recipient_email}: {exc}")
        raise self.retry(exc=exc, countdown=60) from exc


@celery_app.task(name="app.worker.expire_stale_booking_requests")
def expire_stale_booking_requests():
    """Sweeps booking requests past their 12h deadline and transitions them to EXPIRED."""
    async def _sweep():
        async with async_session_maker() as session:
            now_utc = datetime.now(UTC)
            stmt = select(ServiceBooking).where(
                ServiceBooking.status == "REQUEST_SUBMITTED",
                ServiceBooking.response_deadline_at < now_utc,
            )
            result = await session.execute(stmt)
            expired_bookings = result.scalars().all()
            count = 0
            for b in expired_bookings:
                b.status = "EXPIRED"
                event = BookingEvent(
                    booking_id=b.id,
                    from_status="REQUEST_SUBMITTED",
                    to_status="EXPIRED",
                    actor_id=b.organization_id,
                    actor_role="SYSTEM_WORKER",
                    reason="Provider response window exceeded 12-hour deadline",
                )
                session.add(event)
                count += 1
            await session.commit()
            return count

    return asyncio.run(_sweep())


@celery_app.task(name="app.worker.daily_financial_ledger_check")
def daily_financial_ledger_check():
    """Audits double-entry ledger invariant: sum(debit) == sum(credit) for every transaction."""
    async def _audit():
        async with async_session_maker() as session:
            stmt = (
                select(
                    LedgerEntry.transaction_id,
                    func.sum(LedgerEntry.debit_minor).label("total_debit"),
                    func.sum(LedgerEntry.credit_minor).label("total_credit"),
                )
                .group_by(LedgerEntry.transaction_id)
                .having(func.sum(LedgerEntry.debit_minor) != func.sum(LedgerEntry.credit_minor))
            )
            discrepancies = (await session.execute(stmt)).all()
            if discrepancies:
                logger.critical(f"FATAL: Ledger balance violation detected in transactions: {discrepancies}")
                return {"balanced": False, "violations": len(discrepancies)}
            return {"balanced": True, "violations": 0}

    return asyncio.run(_audit())
