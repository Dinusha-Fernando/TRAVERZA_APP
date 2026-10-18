import uuid
from datetime import date, time
from typing import List, Optional
from sqlalchemy import Boolean, Date, Float, ForeignKey, Integer, String, Time
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base, TimestampMixin, UUIDMixin


class Trip(Base, UUIDMixin, TimestampMixin):
    """Parent trip orchestrator tying together days, items, quotes, and bookings."""

    __tablename__ = "trips"

    traveler_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    start_date: Mapped[date] = mapped_column(Date, nullable=False)
    end_date: Mapped[date] = mapped_column(Date, nullable=False)
    party_size: Mapped[int] = mapped_column(Integer, default=2, nullable=False)
    corridor_name: Mapped[str] = mapped_column(String(100), default="Colombo - Sigiriya - Kandy - Nuwara Eliya")
    
    # Status: 'DRAFT', 'QUOTED', 'REQUEST_SUBMITTED', 'PARTIALLY_CONFIRMED', 'CONFIRMED', 'ACTIVE', 'COMPLETED'
    status: Mapped[str] = mapped_column(String(50), default="DRAFT", nullable=False)
    version: Mapped[int] = mapped_column(Integer, default=1, nullable=False)

    days: Mapped[List["ItineraryDay"]] = relationship(
        "ItineraryDay", back_populates="trip", cascade="all, delete-orphan", order_by="ItineraryDay.day_number"
    )


class ItineraryDay(Base, UUIDMixin, TimestampMixin):
    __tablename__ = "itinerary_days"

    trip_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("trips.id", ondelete="CASCADE"), nullable=False, index=True
    )
    day_number: Mapped[int] = mapped_column(Integer, nullable=False)
    date: Mapped[date] = mapped_column(Date, nullable=False)
    title: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)

    trip: Mapped["Trip"] = relationship("Trip", back_populates="days")
    items: Mapped[List["ItineraryItem"]] = relationship(
        "ItineraryItem", back_populates="day", cascade="all, delete-orphan", order_by="ItineraryItem.start_time"
    )


class ItineraryItem(Base, UUIDMixin, TimestampMixin):
    __tablename__ = "itinerary_items"

    day_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("itinerary_days.id", ondelete="CASCADE"), nullable=False, index=True
    )
    listing_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        UUID(as_uuid=True), ForeignKey("listings.id", ondelete="SET NULL"), nullable=True
    )
    place_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        UUID(as_uuid=True), ForeignKey("places.id", ondelete="SET NULL"), nullable=True
    )
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    category: Mapped[str] = mapped_column(String(50), nullable=False)  # 'TRANSFER', 'STAY', 'ACTIVITY', 'FLIGHT'
    start_time: Mapped[time] = mapped_column(Time, nullable=False)
    end_time: Mapped[time] = mapped_column(Time, nullable=False)
    latitude: Mapped[float] = mapped_column(Float, nullable=False)
    longitude: Mapped[float] = mapped_column(Float, nullable=False)
    is_fixed_time: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    requires_booking: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    booking_status: Mapped[str] = mapped_column(String(50), default="NONE", nullable=False)

    day: Mapped["ItineraryDay"] = relationship("ItineraryDay", back_populates="items")
