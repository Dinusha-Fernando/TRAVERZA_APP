import enum
import uuid
from datetime import datetime
from typing import Optional

from sqlalchemy import (
    Boolean,
    Column,
    DateTime,
    Enum,
    Float,
    ForeignKey,
    Index,
    Integer,
    String,
    Table,
    Text,
)
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship

from app.core.database import Base


class PostType(str, enum.Enum):
    PHOTO = "PHOTO"
    CAROUSEL = "CAROUSEL"
    QUESTION = "QUESTION"
    FIELD_REPORT = "FIELD_REPORT"
    LOCAL_NOTE = "LOCAL_NOTE"


class ModerationStatus(str, enum.Enum):
    DRAFT = "DRAFT"
    PROCESSING = "PROCESSING"
    APPROVED = "APPROVED"
    FLAGGED = "FLAGGED"
    REJECTED = "REJECTED"
    REMOVED = "REMOVED"


class AuthorBadge(str, enum.Enum):
    VERIFIED_VISITOR = "VERIFIED_VISITOR"
    LICENSED_GUIDE = "LICENSED_GUIDE"
    VERIFIED_PROVIDER = "VERIFIED_PROVIDER"
    COMMUNITY_EXPERT = "COMMUNITY_EXPERT"
    TRAVELLER = "TRAVELLER"


class ReactionType(str, enum.Enum):
    HELPFUL = "HELPFUL"
    LIKE = "LIKE"
    LOVE = "LOVE"
    SAVED = "SAVED"


class ReportReason(str, enum.Enum):
    SPAM_OR_SCAM = "SPAM_OR_SCAM"
    HARASSMENT = "HARASSMENT"
    DANGEROUS_ADVICE = "DANGEROUS_ADVICE"
    MISLEADING_LOCATION = "MISLEADING_LOCATION"
    TRESPASSING_OR_WILDLIFE_HARM = "TRESPASSING_OR_WILDLIFE_HARM"
    COPYRIGHT_OR_PRIVACY = "COPYRIGHT_OR_PRIVACY"
    OTHER = "OTHER"


class ReportStatus(str, enum.Enum):
    PENDING = "PENDING"
    INVESTIGATING = "INVESTIGATING"
    ACTION_TAKEN = "ACTION_TAKEN"
    DISMISSED = "DISMISSED"


class CommunityPost(Base):
    __tablename__ = "community_posts"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    author_id = Column(UUID(as_uuid=True), nullable=False, index=True)
    author_name = Column(String(100), nullable=False)
    author_avatar_url = Column(String(500), nullable=True)
    author_badge = Column(Enum(AuthorBadge), default=AuthorBadge.TRAVELLER, nullable=False)
    author_badge_detail = Column(String(150), nullable=True)

    post_type = Column(Enum(PostType), nullable=False, default=PostType.PHOTO)
    caption = Column(Text, nullable=False)

    # Island Atlas canonical tagging
    district_id = Column(String(50), nullable=False, index=True)
    district_name = Column(String(100), nullable=False)
    province_id = Column(String(50), nullable=False)
    destination_id = Column(UUID(as_uuid=True), nullable=True, index=True)
    destination_slug = Column(String(100), nullable=True)
    destination_name = Column(String(150), nullable=True)

    # Trust, provenance & freshness fields
    trust_label = Column(String(100), nullable=False, default="Community Observation")
    observed_at = Column(DateTime, nullable=True)
    expires_at = Column(DateTime, nullable=True)
    is_stale = Column(Boolean, default=False)

    # Moderation & lifecycle
    moderation_status = Column(Enum(ModerationStatus), default=ModerationStatus.APPROVED, nullable=False, index=True)
    moderation_notes = Column(Text, nullable=True)

    # Engagement counters (denormalized for fast feed sorting)
    helpful_count = Column(Integer, default=0)
    like_count = Column(Integer, default=0)
    comment_count = Column(Integer, default=0)
    save_count = Column(Integer, default=0)
    is_question_resolved = Column(Boolean, default=False)

    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    # Relationships
    media = relationship("PostMedia", back_populates="post", cascade="all, delete-orphan", order_by="PostMedia.sort_order")
    comments = relationship("PostComment", back_populates="post", cascade="all, delete-orphan", order_by="PostComment.created_at")
    reactions = relationship("PostReaction", back_populates="post", cascade="all, delete-orphan")


class PostMedia(Base):
    __tablename__ = "post_media"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    post_id = Column(UUID(as_uuid=True), ForeignKey("community_posts.id"), nullable=False, index=True)
    media_url = Column(String(500), nullable=False)
    thumbnail_url = Column(String(500), nullable=True)
    media_type = Column(String(20), default="IMAGE", nullable=False)
    alt_text = Column(String(250), nullable=True)
    sort_order = Column(Integer, default=0)
    width = Column(Integer, nullable=True)
    height = Column(Integer, nullable=True)

    post = relationship("CommunityPost", back_populates="media")


class PostComment(Base):
    __tablename__ = "post_comments"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    post_id = Column(UUID(as_uuid=True), ForeignKey("community_posts.id"), nullable=False, index=True)
    author_id = Column(UUID(as_uuid=True), nullable=False)
    author_name = Column(String(100), nullable=False)
    author_avatar_url = Column(String(500), nullable=True)
    author_badge = Column(Enum(AuthorBadge), default=AuthorBadge.TRAVELLER, nullable=False)

    comment_text = Column(Text, nullable=False)
    is_accepted_answer = Column(Boolean, default=False)
    helpful_votes = Column(Integer, default=0)

    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    post = relationship("CommunityPost", back_populates="comments")


class PostReaction(Base):
    __tablename__ = "post_reactions"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    post_id = Column(UUID(as_uuid=True), ForeignKey("community_posts.id"), nullable=False, index=True)
    user_id = Column(UUID(as_uuid=True), nullable=False, index=True)
    reaction_type = Column(Enum(ReactionType), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    post = relationship("CommunityPost", back_populates="reactions")


class ContentReport(Base):
    __tablename__ = "community_content_reports"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    post_id = Column(UUID(as_uuid=True), nullable=True, index=True)
    comment_id = Column(UUID(as_uuid=True), nullable=True)
    reporter_id = Column(UUID(as_uuid=True), nullable=False)
    reporter_name = Column(String(100), nullable=False)

    reason = Column(Enum(ReportReason), nullable=False)
    description = Column(Text, nullable=True)
    status = Column(Enum(ReportStatus), default=ReportStatus.PENDING, nullable=False, index=True)
    reviewer_notes = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)


class UserBlock(Base):
    __tablename__ = "community_user_blocks"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    blocker_id = Column(UUID(as_uuid=True), nullable=False, index=True)
    blocked_user_id = Column(UUID(as_uuid=True), nullable=False, index=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
