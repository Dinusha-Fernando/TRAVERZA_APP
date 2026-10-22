from datetime import datetime
from typing import Any, List, Optional
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
    thumbnail_url: Optional[str] = None
    media_type: str = "IMAGE"
    alt_text: Optional[str] = None
    sort_order: int = 0
    width: Optional[int] = None
    height: Optional[int] = None


class PostCommentResponse(BaseModel):
    id: str
    post_id: str
    author_id: str
    author_name: str
    author_avatar_url: Optional[str] = None
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
    author_avatar_url: Optional[str] = None
    author_badge: AuthorBadge
    author_badge_detail: Optional[str] = None

    post_type: PostType
    caption: str

    district_id: str
    district_name: str
    province_id: str
    destination_id: Optional[str] = None
    destination_slug: Optional[str] = None
    destination_name: Optional[str] = None

    trust_label: str
    observed_at: Optional[datetime] = None
    expires_at: Optional[datetime] = None
    is_stale: bool = False
    freshness_label: str = "Active"

    moderation_status: ModerationStatus

    helpful_count: int = 0
    like_count: int = 0
    comment_count: int = 0
    save_count: int = 0
    is_question_resolved: bool = False

    created_at: datetime
    media: List[PostMediaResponse] = []
    comments: List[PostCommentResponse] = []


class CommunityPostCreate(BaseModel):
    post_type: PostType = PostType.PHOTO
    caption: str = Field(..., min_length=5, max_length=2000)
    district_id: str
    destination_id: Optional[str] = None
    destination_name: Optional[str] = None
    media_urls: List[str] = []
    observed_at: Optional[datetime] = None
    expiry_hours: Optional[int] = Field(None, ge=1, le=72)


class PostReactionRequest(BaseModel):
    reaction_type: ReactionType


class PostReactionResponse(BaseModel):
    post_id: str
    reaction_type: ReactionType
    action: str  # "ADDED" or "REMOVED"
    current_counts: dict[str, int]


class ContentReportRequest(BaseModel):
    post_id: Optional[str] = None
    comment_id: Optional[str] = None
    reason: ReportReason
    description: Optional[str] = None


class ContentReportResponse(BaseModel):
    id: str
    post_id: Optional[str] = None
    reporter_name: str
    reason: ReportReason
    status: ReportStatus
    created_at: datetime


class PlaceSignalResponse(BaseModel):
    destination_id: Optional[str] = None
    destination_name: str
    district_name: str
    recent_notes_count: int
    unanswered_questions_count: int
    active_field_reports_count: int
    latest_observation: Optional[str] = None
    latest_observed_at: Optional[datetime] = None
    trail_or_road_status: str = "NORMAL"
    crowd_level: str = "MODERATE"
    freshness_status: str = "FRESH"


class ItineraryAdditionValidationRequest(BaseModel):
    post_id: str
    destination_id: str
    trip_id: Optional[str] = None
    target_day_number: int = 1
    requested_start_hour: int = 10  # 10:00 AM default
    dwell_duration_mins: Optional[int] = None


class ItineraryAdditionValidationResponse(BaseModel):
    is_feasible: bool
    destination_name: str
    proposed_day_number: int
    proposed_start_time: str
    proposed_end_time: str
    road_buffer_mins: int
    transit_duration_mins: int
    conflicts: List[str] = []
    recommendation: str
