import uuid
from typing import Optional
from sqlalchemy import BigInteger, ForeignKey, String, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base, TimestampMixin, UUIDMixin


class PaymentIntent(Base, UUIDMixin, TimestampMixin):
    """Payment record tracking gateway interactions."""

    __tablename__ = "payment_intents"

    trip_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("trips.id", ondelete="CASCADE"), nullable=False, index=True
    )
    gateway_name: Mapped[str] = mapped_column(String(50), default="SANDBOX", nullable=False)
    gateway_reference: Mapped[str] = mapped_column(String(100), unique=True, index=True, nullable=False)
    amount_minor: Mapped[int] = mapped_column(BigInteger, nullable=False)
    currency: Mapped[str] = mapped_column(String(3), default="LKR", nullable=False)
    
    # Status: 'CREATED', 'AUTHORIZED', 'CAPTURED', 'FAILED', 'REFUNDED'
    status: Mapped[str] = mapped_column(String(50), default="CREATED", nullable=False)
    idempotency_key: Mapped[str] = mapped_column(String(100), unique=True, index=True, nullable=False)


class WebhookEvent(Base, UUIDMixin, TimestampMixin):
    """Stores raw inbound webhook events to guarantee idempotency and replay defense."""

    __tablename__ = "webhook_events"

    gateway: Mapped[str] = mapped_column(String(50), nullable=False)
    gateway_event_id: Mapped[str] = mapped_column(String(100), unique=True, index=True, nullable=False)
    payload_json: Mapped[str] = mapped_column(Text, nullable=False)
    is_processed: Mapped[bool] = mapped_column(default=False, nullable=False)


class LedgerAccount(Base, UUIDMixin, TimestampMixin):
    """Chart of accounts for the platform double-entry ledger."""

    __tablename__ = "ledger_accounts"

    code: Mapped[str] = mapped_column(String(50), unique=True, index=True, nullable=False)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    type: Mapped[str] = mapped_column(String(20), nullable=False)  # 'ASSET', 'LIABILITY', 'REVENUE', 'EXPENSE'


class LedgerEntry(Base, UUIDMixin, TimestampMixin):
    """Immutable double-entry journal lines."""

    __tablename__ = "ledger_entries"

    transaction_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), index=True, nullable=False)
    account_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("ledger_accounts.id", ondelete="RESTRICT"), nullable=False
    )
    booking_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        UUID(as_uuid=True), ForeignKey("service_bookings.id", ondelete="RESTRICT"), nullable=True
    )
    debit_minor: Mapped[int] = mapped_column(BigInteger, default=0, nullable=False)
    credit_minor: Mapped[int] = mapped_column(BigInteger, default=0, nullable=False)
    currency: Mapped[str] = mapped_column(String(3), default="LKR", nullable=False)
    memo: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
