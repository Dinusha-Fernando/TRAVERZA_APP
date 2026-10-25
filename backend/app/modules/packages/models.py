import uuid

from sqlalchemy import Boolean, Float, ForeignKey, Integer, String, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base, TimestampMixin, UUIDMixin


class Package(Base, UUIDMixin, TimestampMixin):
    """
    Curated Operator Package or Itinerary Template.
    Distinguishes Type 1 (Operator Package with single contract) from
    Type 2 (Itinerary Template / route inspiration with independent services).
    """

    __tablename__ = "packages"

    organization_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("organizations.id", ondelete="SET NULL"), nullable=True, index=True
    )
    provider_name: Mapped[str] = mapped_column(String(255), nullable=False, default="Verified Ceylon Operator")
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    slug: Mapped[str] = mapped_column(String(255), unique=True, index=True, nullable=False)
    summary: Mapped[str] = mapped_column(String(500), nullable=False)
    description: Mapped[str] = mapped_column(Text, nullable=False)

    # 'OPERATOR_PACKAGE' vs 'ITINERARY_TEMPLATE'
    package_type: Mapped[str] = mapped_column(String(50), default="OPERATOR_PACKAGE", nullable=False)

    # Publication states: 'DRAFT', 'SUBMITTED_FOR_REVIEW', 'IN_REVIEW', 'CHANGES_REQUESTED', 'APPROVED', 'PUBLISHED', 'SUSPENDED'
    status: Mapped[str] = mapped_column(String(50), default="PUBLISHED", nullable=False, index=True)

    duration_days: Mapped[int] = mapped_column(Integer, nullable=False, default=3)
    duration_nights: Mapped[int] = mapped_column(Integer, nullable=False, default=2)

    # Price basis: 'PER_PERSON', 'PER_VEHICLE', 'TOTAL_PACKAGE', 'ESTIMATED_ONLY'
    price_basis: Mapped[str] = mapped_column(String(50), default="PER_PERSON", nullable=False)
    base_price_lkr: Mapped[float] = mapped_column(Float, nullable=False, default=45000.0)

    corridor_name: Mapped[str] = mapped_column(String(100), default="Cultural Triangle & Highlands", index=True)
    destinations: Mapped[str] = mapped_column(String(500), default="Colombo, Sigiriya, Kandy, Nuwara Eliya")
    cover_image_url: Mapped[str] = mapped_column(String(500), nullable=False)

    inclusions: Mapped[str] = mapped_column(String(1000), default="Boutique Stays, Chauffeur Prado, Guide Guild, Breakfast")
    exclusions: Mapped[str] = mapped_column(String(1000), default="International Flights, Personal Tips, Alcoholic Drinks")
    cancellation_policy: Mapped[str] = mapped_column(String(500), default="Free cancellation up to 48 hours before start date")

    is_verified: Mapped[bool] = mapped_column(Boolean, default=True)
    sltda_license_no: Mapped[str | None] = mapped_column(String(100), default="SLTDA/SQA/2026/044", nullable=True)
    version: Mapped[int] = mapped_column(Integer, default=1, nullable=False)


class PackageReviewCase(Base, UUIDMixin, TimestampMixin):
    """Admin review case for package publication workflow."""

    __tablename__ = "package_review_cases"

    package_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("packages.id", ondelete="CASCADE"), nullable=False, index=True
    )
    status: Mapped[str] = mapped_column(String(50), default="PENDING", nullable=False)
    reviewer_email: Mapped[str | None] = mapped_column(String(255), nullable=True)
    admin_notes: Mapped[str | None] = mapped_column(Text, nullable=True)
    provider_notes: Mapped[str | None] = mapped_column(Text, nullable=True)
