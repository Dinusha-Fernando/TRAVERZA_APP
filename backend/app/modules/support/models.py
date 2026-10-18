import uuid
from typing import Optional
from sqlalchemy import ForeignKey, String, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base, TimestampMixin, UUIDMixin


class SupportCase(Base, UUIDMixin, TimestampMixin):
    """Customer or provider exception case requiring operations resolution."""

    __tablename__ = "support_cases"

    trip_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        UUID(as_uuid=True), ForeignKey("trips.id", ondelete="SET NULL"), nullable=True, index=True
    )
    booking_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        UUID(as_uuid=True), ForeignKey("service_bookings.id", ondelete="SET NULL"), nullable=True, index=True
    )
    reported_by_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False)
    assigned_staff_id: Mapped[Optional[uuid.UUID]] = mapped_column(UUID(as_uuid=True), nullable=True)
    
    # Severity: 'LOW', 'MEDIUM', 'HIGH', 'CRITICAL'
    severity: Mapped[str] = mapped_column(String(20), default="MEDIUM", nullable=False)
    # Status: 'OPEN', 'TRIAGED', 'INVESTIGATING', 'RESOLVED', 'CLOSED'
    status: Mapped[str] = mapped_column(String(50), default="OPEN", nullable=False, index=True)
    category: Mapped[str] = mapped_column(String(50), nullable=False)  # 'MISSED_PICKUP', 'PROVIDER_CANCEL', 'PAYMENT_ISSUE'
    summary: Mapped[str] = mapped_column(String(255), nullable=False)
    description: Mapped[str] = mapped_column(Text, nullable=False)
    resolution_notes: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
