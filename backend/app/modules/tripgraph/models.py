import uuid
from typing import Optional
from sqlalchemy import ForeignKey, Integer, String
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base, TimestampMixin, UUIDMixin


class DependencyEdge(Base, UUIDMixin, TimestampMixin):
    """Represents a dependency between two itinerary items in a TripGraph."""

    __tablename__ = "dependency_edges"

    trip_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("trips.id", ondelete="CASCADE"), nullable=False, index=True
    )
    source_item_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("itinerary_items.id", ondelete="CASCADE"), nullable=False
    )
    target_item_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("itinerary_items.id", ondelete="CASCADE"), nullable=False
    )
    dependency_type: Mapped[str] = mapped_column(
        String(50), nullable=False
    )  # 'FLIGHT_ARRIVAL_TO_TRANSFER', 'TRANSFER_TO_CHECKIN', 'CHECKIN_TO_ACTIVITY'
    min_buffer_minutes: Mapped[int] = mapped_column(Integer, default=30, nullable=False)
    description: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
