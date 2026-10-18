import uuid
from typing import Optional
from sqlalchemy import Boolean, Float, ForeignKey, Integer, String, Text
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base, TimestampMixin, UUIDMixin


class Destination(Base, UUIDMixin, TimestampMixin):
    """Broad geographic area or hub (e.g. Kandy, Sigiriya, Nuwara Eliya)."""

    __tablename__ = "destinations"

    name: Mapped[str] = mapped_column(String(100), unique=True, nullable=False)
    slug: Mapped[str] = mapped_column(String(100), unique=True, index=True, nullable=False)
    province: Mapped[str] = mapped_column(String(100), nullable=False)
    corridor_name: Mapped[str] = mapped_column(String(100), default="Colombo - Sigiriya - Kandy - Nuwara Eliya", index=True)
    description: Mapped[str] = mapped_column(Text, nullable=False)
    latitude: Mapped[float] = mapped_column(Float, nullable=False)
    longitude: Mapped[float] = mapped_column(Float, nullable=False)


class Place(Base, UUIDMixin, TimestampMixin):
    """Specific point of interest, attraction, or station (e.g. Temple of the Tooth)."""

    __tablename__ = "places"

    destination_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("destinations.id", ondelete="CASCADE"), nullable=False
    )
    name: Mapped[str] = mapped_column(String(200), nullable=False)
    slug: Mapped[str] = mapped_column(String(200), unique=True, index=True, nullable=False)
    category: Mapped[str] = mapped_column(String(50), nullable=False)  # 'CULTURAL', 'NATURE', 'HISTORIC', 'SCENIC'
    description: Mapped[str] = mapped_column(Text, nullable=False)
    latitude: Mapped[float] = mapped_column(Float, nullable=False)
    longitude: Mapped[float] = mapped_column(Float, nullable=False)
    altitude_meters: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    recommended_duration_minutes: Mapped[int] = mapped_column(Integer, default=120)
    opening_time_str: Mapped[Optional[str]] = mapped_column(String(5), default="08:00")
    closing_time_str: Mapped[Optional[str]] = mapped_column(String(5), default="18:00")


class Listing(Base, UUIDMixin, TimestampMixin):
    """Service offered by a verified provider organization."""

    __tablename__ = "listings"

    organization_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("organizations.id", ondelete="CASCADE"), nullable=False, index=True
    )
    destination_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        UUID(as_uuid=True), ForeignKey("destinations.id", ondelete="SET NULL"), nullable=True
    )
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    category: Mapped[str] = mapped_column(String(50), nullable=False)  # 'STAY', 'TRANSFER', 'GUIDE', 'ACTIVITY'
    description: Mapped[str] = mapped_column(Text, nullable=False)
    base_price_minor: Mapped[int] = mapped_column(Integer, nullable=False)  # e.g., 1500000 = LKR 15,000.00
    currency: Mapped[str] = mapped_column(String(3), default="LKR", nullable=False)
    is_published: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    manual_availability_only: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    cancellation_policy: Mapped[str] = mapped_column(String(50), default="STANDARD_48H")
