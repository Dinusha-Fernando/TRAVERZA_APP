import uuid
from datetime import UTC, datetime

from sqlalchemy import Boolean, DateTime, ForeignKey, String, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base, TimestampMixin, UUIDMixin


class UserNotification(Base, UUIDMixin, TimestampMixin):
    """
    Authoritative, persistent operational notification delivered to travellers and providers.
    """

    __tablename__ = "user_notifications"

    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    body: Mapped[str] = mapped_column(Text, nullable=False)

    # Category: 'SAFETY', 'BOOKING', 'TRIP', 'OFFERS'
    category: Mapped[str] = mapped_column(String(50), default="TRIP", nullable=False, index=True)

    # Priority: 'low', 'medium', 'high', 'critical'
    priority: Mapped[str] = mapped_column(String(20), default="medium", nullable=False)

    is_read: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False, index=True)

    # Navigation / Deeplink Action
    action_route: Mapped[str | None] = mapped_column(String(100), nullable=True)
    action_label: Mapped[str | None] = mapped_column(String(100), nullable=True)
    meta_json: Mapped[str | None] = mapped_column(Text, nullable=True)


class DevicePushToken(Base, UUIDMixin, TimestampMixin):
    """
    Registered mobile/web push notification token (FCM or APNs).
    """

    __tablename__ = "device_push_tokens"

    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    token: Mapped[str] = mapped_column(String(500), unique=True, nullable=False, index=True)
    platform: Mapped[str] = mapped_column(String(20), default="FCM", nullable=False)  # 'FCM', 'APNS', 'WEB'
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    last_seen_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(UTC), nullable=False
    )
