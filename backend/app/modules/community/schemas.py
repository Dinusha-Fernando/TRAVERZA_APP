from datetime import datetime

from pydantic import BaseModel, Field

from app.modules.community.models import (
    AuthorBadge,
    ModerationStatus,
    PostType,
    ReactionType,
    ReportReason,
    ReportStatus,
)


class PostMediaResponse(BaseModel):
    id: str
    media_url: str
    thumbnail_url: str | None = None
    media_type: str = "IMAGE"
    alt_text: str | None = None
    sort_order: int = 0
    width: int | None = None
    height: int | None = None


class PostCommentResponse(BaseModel):
    id: str
    post_id: str
    author_id: str
    author_name: str
    author_avatar_url: str | None = None
    author_badge: AuthorBadge
    comment_text: str
    is_accepted_answer: bool = False
    helpful_votes: int = 0
    created_at: datetime


class PostCommentCreate(BaseModel):
    comment_text: str = Field(..., min_length=1, max_length=1000)


class CommunityPostResponse(BaseModel):
    id: str
    author_id: str
    author_name: str
    author_avatar_url: str | None = None
    author_badge: AuthorBadge
    author_badge_detail: str | None = None

    post_type: PostType
    caption: str

    district_id: str
    district_name: str
    province_id: str
    destination_id: str | None = None
    destination_slug: str | None = None
    destination_name: str | None = None

    trust_label: str
    observed_at: datetime | None = None
    expires_at: datetime | None = None
    is_stale: bool = False
    freshness_label: str = "Active"

    moderation_status: ModerationStatus

    helpful_count: int = 0
    like_count: int = 0
    comment_count: int = 0
    save_count: int = 0
    is_question_resolved: bool = False

    created_at: datetime
    media: list[PostMediaResponse] = []
    comments: list[PostCommentResponse] = []


class CommunityPostCreate(BaseModel):
    post_type: PostType = PostType.PHOTO
    caption: str = Field(..., min_length=5, max_length=2000)
    district_id: str
    destination_id: str | None = None
    destination_name: str | None = None
    media_urls: list[str] = []
    observed_at: datetime | None = None
    expiry_hours: int | None = Field(None, ge=1, le=72)


class PostReactionRequest(BaseModel):
    reaction_type: ReactionType


class PostReactionResponse(BaseModel):
    post_id: str
    reaction_type: ReactionType
    action: str  # "ADDED" or "REMOVED"
    current_counts: dict[str, int]


class ContentReportRequest(BaseModel):
    post_id: str | None = None
    comment_id: str | None = None
    reason: ReportReason
    description: str | None = None


class ContentReportResponse(BaseModel):
    id: str
    post_id: str | None = None
    reporter_name: str
    reason: ReportReason
    status: ReportStatus
    created_at: datetime


class PlaceSignalResponse(BaseModel):
    destination_id: str | None = None
    destination_name: str
    district_name: str
    recent_notes_count: int
    unanswered_questions_count: int
    active_field_reports_count: int
    latest_observation: str | None = None
    latest_observed_at: datetime | None = None
    trail_or_road_status: str = "NORMAL"
    crowd_level: str = "MODERATE"
    freshness_status: str = "FRESH"


class ItineraryAdditionValidationRequest(BaseModel):
    post_id: str
    destination_id: str
    trip_id: str | None = None
    target_day_number: int = 1
    requested_start_hour: int = 10  # 10:00 AM default
    dwell_duration_mins: int | None = None


class ItineraryAdditionValidationResponse(BaseModel):
    is_feasible: bool
    destination_name: str
    proposed_day_number: int
    proposed_start_time: str
    proposed_end_time: str
    road_buffer_mins: int
    transit_duration_mins: int
    conflicts: list[str] = []
    recommendation: str
