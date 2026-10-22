import uuid
from datetime import UTC, datetime

from sqlalchemy import Boolean, DateTime, Float, ForeignKey, Integer, String, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base, TimestampMixin, UUIDMixin


class Province(Base, TimestampMixin):
    """
    Official 9 Provinces of Sri Lanka.
    Adheres to the Census of Population and Housing 2024 hierarchy.
    """

    __tablename__ = "atlas_provinces"

    id: Mapped[str] = mapped_column(String(10), primary_key=True)  # e.g., 'WP', 'CP', 'SP'
    slug: Mapped[str] = mapped_column(String(50), unique=True, nullable=False, index=True)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    name_si: Mapped[str] = mapped_column(String(100), nullable=False)
    name_ta: Mapped[str] = mapped_column(String(100), nullable=False)
    capital: Mapped[str] = mapped_column(String(100), nullable=False)
    description: Mapped[str] = mapped_column(Text, nullable=False)
    signature_landscapes: Mapped[str] = mapped_column(String(255), nullable=False)
    display_order: Mapped[int] = mapped_column(Integer, default=0, nullable=False)

    districts = relationship("District", back_populates="province", cascade="all, delete-orphan")
    destinations = relationship("DestinationPlace", back_populates="province")


class District(Base, TimestampMixin):
    """
    Official 25 Administrative Districts of Sri Lanka (Census 2024 scope).
    """

    __tablename__ = "atlas_districts"

    id: Mapped[str] = mapped_column(String(30), primary_key=True)  # e.g., 'colombo', 'kandy'
    province_id: Mapped[str] = mapped_column(String(10), ForeignKey("atlas_provinces.id", ondelete="CASCADE"), nullable=False, index=True)
    slug: Mapped[str] = mapped_column(String(50), unique=True, nullable=False, index=True)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    name_si: Mapped[str] = mapped_column(String(100), nullable=False)
    name_ta: Mapped[str] = mapped_column(String(100), nullable=False)
    capital: Mapped[str] = mapped_column(String(100), nullable=False)
    latitude: Mapped[float] = mapped_column(Float, nullable=False)
    longitude: Mapped[float] = mapped_column(Float, nullable=False)
    story: Mapped[str] = mapped_column(Text, nullable=False)
    known_for: Mapped[str] = mapped_column(String(255), nullable=False)
    is_verified: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)

    province = relationship("Province", back_populates="districts")
    destinations = relationship("DestinationPlace", back_populates="district", cascade="all, delete-orphan")
    specialities = relationship("DistrictSpeciality", back_populates="district", cascade="all, delete-orphan")


class DestinationPlace(Base, UUIDMixin, TimestampMixin):
    """
    A verified destination profile within the TRAVERZA Island Atlas.
    """

    __tablename__ = "atlas_destinations"

    slug: Mapped[str] = mapped_column(String(100), unique=True, nullable=False, index=True)
    province_id: Mapped[str] = mapped_column(String(10), ForeignKey("atlas_provinces.id"), nullable=False, index=True)
    district_id: Mapped[str] = mapped_column(String(30), ForeignKey("atlas_districts.id"), nullable=False, index=True)

    name: Mapped[str] = mapped_column(String(150), nullable=False)
    name_si: Mapped[str] = mapped_column(String(150), nullable=False)
    name_ta: Mapped[str] = mapped_column(String(150), nullable=False)

    # Place classification: 'iconic', 'locally_loved', 'emerging', 'seasonal'
    place_type: Mapped[str] = mapped_column(String(50), default="iconic", nullable=False, index=True)
    # Category: 'HERITAGE', 'NATURE', 'BEACH', 'WILDLIFE', 'CRAFT_FOOD', 'SACRED', 'OUTDOOR'
    category: Mapped[str] = mapped_column(String(50), nullable=False, index=True)

    latitude: Mapped[float] = mapped_column(Float, nullable=False)
    longitude: Mapped[float] = mapped_column(Float, nullable=False)
    coordinate_precision: Mapped[str] = mapped_column(String(30), default="EXACT", nullable=False)  # EXACT, APPROXIMATE, RESTRICTED

    summary: Mapped[str] = mapped_column(String(255), nullable=False)
    story: Mapped[str] = mapped_column(Text, nullable=False)
    dwell_duration_mins: Mapped[int] = mapped_column(Integer, default=90, nullable=False)

    # Practical visitor details
    opening_hours_text: Mapped[str] = mapped_column(String(150), default="Dawn to dusk", nullable=False)
    fee_info_text: Mapped[str] = mapped_column(String(150), default="Free public access", nullable=False)
    access_state: Mapped[str] = mapped_column(String(30), default="OPEN", nullable=False)  # OPEN, SEASONAL, RESTRICTED, UNKNOWN

    terrain_notes: Mapped[str] = mapped_column(String(255), default="Paved access", nullable=False)
    safety_notes: Mapped[str] = mapped_column(String(255), default="Standard precautions", nullable=False)
    is_family_friendly: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    accessibility_notes: Mapped[str] = mapped_column(String(255), default="Partially accessible", nullable=False)

    # Evidence & Trust lifecycle
    evidence_source: Mapped[str] = mapped_column(String(255), nullable=False)
    last_verified_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(UTC), nullable=False)
    review_status: Mapped[str] = mapped_column(String(30), default="APPROVED", nullable=False, index=True)  # APPROVED, NEEDS_VERIFICATION, STALE

    photo_url: Mapped[str] = mapped_column(String(255), nullable=False)
    photo_attribution: Mapped[str] = mapped_column(String(150), default="TRAVERZA Verified Field Audit", nullable=False)

    province = relationship("Province", back_populates="destinations")
    district = relationship("District", back_populates="destinations")


class DistrictSpeciality(Base, UUIDMixin, TimestampMixin):
    """
    Thematic specialty facets for a district (food, craft, history, nature, agriculture, events).
    """

    __tablename__ = "atlas_district_specialities"

    district_id: Mapped[str] = mapped_column(String(30), ForeignKey("atlas_districts.id", ondelete="CASCADE"), nullable=False, index=True)
    # LANDSCAPE_NATURE, HISTORY_HERITAGE, FOOD_AGRICULTURE, ARTS_CRAFTS, LOCAL_EXPERIENCES, SEASONAL_EVENTS
    theme_group: Mapped[str] = mapped_column(String(50), nullable=False, index=True)
    title: Mapped[str] = mapped_column(String(100), nullable=False)
    description: Mapped[str] = mapped_column(Text, nullable=False)
    evidence_source: Mapped[str] = mapped_column(String(255), nullable=False)

    district = relationship("District", back_populates="specialities")


class CuratedCollection(Base, TimestampMixin):
    """
    Curated thematic travel routes across provinces and districts.
    """

    __tablename__ = "atlas_collections"

    slug: Mapped[str] = mapped_column(String(50), primary_key=True)
    title: Mapped[str] = mapped_column(String(100), nullable=False)
    subtitle: Mapped[str] = mapped_column(String(255), nullable=False)
    theme: Mapped[str] = mapped_column(String(50), nullable=False)
    cover_image: Mapped[str] = mapped_column(String(255), nullable=False)
    editorial_note: Mapped[str] = mapped_column(Text, nullable=False)
    place_slugs_json: Mapped[str] = mapped_column(Text, default="[]", nullable=False)


class Contribution(Base, UUIDMixin, TimestampMixin):
    """
    Moderated community/local guide submission for a place or correction.
    """

    __tablename__ = "atlas_contributions"

    place_name: Mapped[str] = mapped_column(String(150), nullable=False)
    district_id: Mapped[str] = mapped_column(String(30), nullable=False, index=True)
    contributor_name: Mapped[str] = mapped_column(String(100), nullable=False)
    contributor_contact: Mapped[str] = mapped_column(String(100), nullable=False)
    # NEW_PLACE, CORRECTION, STORY
    submission_type: Mapped[str] = mapped_column(String(30), default="CORRECTION", nullable=False)
    details: Mapped[str] = mapped_column(Text, nullable=False)
    evidence_url: Mapped[str] = mapped_column(String(255), nullable=False)
    # PENDING, APPROVED, REJECTED
    status: Mapped[str] = mapped_column(String(30), default="PENDING", nullable=False, index=True)
    moderation_notes: Mapped[str] = mapped_column(String(255), default="", nullable=False)
    reviewed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
