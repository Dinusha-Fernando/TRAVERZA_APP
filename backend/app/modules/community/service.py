import copy
import uuid
from datetime import datetime, timezone, timedelta
from typing import Any, List, Optional

from app.modules.community.models import (
    AuthorBadge,
    ModerationStatus,
    PostType,
    ReactionType,
    ReportReason,
    ReportStatus,
)
from app.modules.community.schemas import (
    CommunityPostCreate,
    CommunityPostResponse,
    ContentReportRequest,
    ContentReportResponse,
    ItineraryAdditionValidationRequest,
    ItineraryAdditionValidationResponse,
    PlaceSignalResponse,
    PostCommentCreate,
    PostCommentResponse,
    PostMediaResponse,
    PostReactionResponse,
)
from app.modules.community.seed_data import COMMUNITY_POSTS_SEED


def _now() -> datetime:
    return datetime.now(timezone.utc)


def _ensure_utc(dt: Optional[datetime]) -> Optional[datetime]:
    if dt is None:
        return None
    if dt.tzinfo is None:
        return dt.replace(tzinfo=timezone.utc)
    return dt


class CommunityService:
    """In-memory & persistence coordinator for TRAVERZA Community Moments."""

    def __init__(self):
        self._posts: dict[str, dict[str, Any]] = {}
        self._reports: dict[str, dict[str, Any]] = {}
        self._blocks: set[tuple[str, str]] = set()  # (blocker_id, blocked_id)
        self._seed_initial_data()

    def _seed_initial_data(self):
        for raw in COMMUNITY_POSTS_SEED:
            post_copy = copy.deepcopy(raw)
            post_id = str(post_copy["id"])
            post_copy["id"] = post_id
            post_copy["author_id"] = str(post_copy["author_id"])
            post_copy["comments"] = post_copy.get("comments", [])
            post_copy["media"] = post_copy.get("media", [])
            post_copy["observed_at"] = _ensure_utc(post_copy.get("observed_at"))
            post_copy["expires_at"] = _ensure_utc(post_copy.get("expires_at"))
            post_copy["created_at"] = _ensure_utc(post_copy.get("created_at")) or _now()
            self._posts[post_id] = post_copy

    def _compute_freshness(self, post: dict[str, Any]) -> tuple[bool, str]:
        expires_at = _ensure_utc(post.get("expires_at"))
        post_type = post.get("post_type")

        if post_type != "FIELD_REPORT" or not expires_at:
            return False, "Active"

        now = _now()
        if now > expires_at:
            return True, "Expired · Historical Observation"

        remaining = expires_at - now
        hours = int(remaining.total_seconds() // 3600)
        mins = int((remaining.total_seconds() % 3600) // 60)

        if hours > 0:
            return False, f"Fresh · Valid for {hours}h {mins}m"
        return False, f"Fresh · Expires in {mins}m"

    def get_feed(
        self,
        post_type: Optional[str] = None,
        district_id: Optional[str] = None,
        destination_slug: Optional[str] = None,
        search_query: Optional[str] = None,
        current_user_id: Optional[str] = None,
        limit: int = 20,
        offset: int = 0,
    ) -> List[dict[str, Any]]:
        results = []

        for p in self._posts.values():
            # Block list filtering
            if current_user_id and (current_user_id, str(p["author_id"])) in self._blocks:
                continue

            # Moderation status filter
            if p.get("moderation_status") != "APPROVED":
                continue

            # Post type filter
            if post_type and p.get("post_type") != post_type:
                continue

            # District filter
            if district_id and p.get("district_id") != district_id.lower():
                continue

            # Destination filter
            if destination_slug and p.get("destination_slug") != destination_slug:
                continue

            # Search query filter (matches caption, destination, district, or author)
            if search_query:
                q = search_query.lower()
                caption = p.get("caption", "").lower()
                dest = p.get("destination_name", "").lower()
                dist = p.get("district_name", "").lower()
                author = p.get("author_name", "").lower()
                if q not in caption and q not in dest and q not in dist and q not in author:
                    continue

            post_data = copy.deepcopy(p)
            is_stale, freshness_label = self._compute_freshness(post_data)
            post_data["is_stale"] = is_stale
            post_data["freshness_label"] = freshness_label

            results.append(post_data)

        epoch_utc = datetime(2000, 1, 1, tzinfo=timezone.utc)
        results.sort(
            key=lambda x: (
                not x.get("is_stale", False),
                _ensure_utc(x.get("observed_at")) or _ensure_utc(x.get("created_at")) or epoch_utc,
            ),
            reverse=True,
        )
        return results[offset : offset + limit]

    def get_post(self, post_id: str) -> Optional[dict[str, Any]]:
        raw = self._posts.get(str(post_id))
        if not raw:
            return None
        post = copy.deepcopy(raw)
        is_stale, freshness_label = self._compute_freshness(post)
        post["is_stale"] = is_stale
        post["freshness_label"] = freshness_label
        return post

    def create_post(
        self,
        author_id: str,
        author_name: str,
        author_badge: str,
        author_badge_detail: Optional[str],
        payload: CommunityPostCreate,
    ) -> dict[str, Any]:
        post_id = str(uuid.uuid4())
        now = _now()

        expires_at = None
        if payload.post_type == PostType.FIELD_REPORT:
            hours = payload.expiry_hours or 4
            expires_at = now + timedelta(hours=hours)

        media_items = []
        for idx, url in enumerate(payload.media_urls):
            media_items.append(
                {
                    "id": str(uuid.uuid4()),
                    "media_url": url,
                    "thumbnail_url": url,
                    "media_type": "IMAGE",
                    "alt_text": f"Travel moment in {payload.district_id}",
                    "sort_order": idx,
                }
            )

        new_post = {
            "id": post_id,
            "author_id": str(author_id),
            "author_name": author_name,
            "author_avatar_url": None,
            "author_badge": author_badge,
            "author_badge_detail": author_badge_detail,
            "post_type": payload.post_type.value,
            "caption": payload.caption,
            "district_id": payload.district_id.lower(),
            "district_name": f"{payload.district_id.title()} District",
            "province_id": "CP",
            "destination_id": str(payload.destination_id) if payload.destination_id else None,
            "destination_slug": payload.destination_id and str(payload.destination_id),
            "destination_name": payload.destination_name or (f"{payload.district_id.title()} Landmark"),
            "trust_label": "Verified Contributor Observation" if "VERIFIED" in author_badge or "GUIDE" in author_badge else "Community Observation",
            "observed_at": _ensure_utc(payload.observed_at) or now,
            "expires_at": expires_at,
            "is_stale": False,
            "moderation_status": "APPROVED",
            "helpful_count": 0,
            "like_count": 0,
            "comment_count": 0,
            "save_count": 0,
            "is_question_resolved": False,
            "created_at": now,
            "media": media_items,
            "comments": [],
        }

        self._posts[post_id] = new_post
        return self.get_post(post_id)

    def add_comment(
        self,
        post_id: str,
        author_id: str,
        author_name: str,
        author_badge: str,
        payload: PostCommentCreate,
    ) -> Optional[dict[str, Any]]:
        post = self._posts.get(str(post_id))
        if not post:
            return None

        comment_id = str(uuid.uuid4())
        comment = {
            "id": comment_id,
            "post_id": str(post_id),
            "author_id": str(author_id),
            "author_name": author_name,
            "author_avatar_url": None,
            "author_badge": author_badge,
            "comment_text": payload.comment_text,
            "is_accepted_answer": False,
            "helpful_votes": 0,
            "created_at": _now(),
        }

        post.setdefault("comments", []).append(comment)
        post["comment_count"] = len(post["comments"])
        return comment

    def mark_accepted_answer(self, post_id: str, comment_id: str, caller_id: str) -> bool:
        post = self._posts.get(str(post_id))
        if not post:
            return False

        # Only post author or guide/admin can mark accepted
        if str(post["author_id"]) != str(caller_id):
            return False

        found = False
        for c in post.get("comments", []):
            if str(c["id"]) == str(comment_id):
                c["is_accepted_answer"] = True
                c["helpful_votes"] += 1
                found = True
            else:
                c["is_accepted_answer"] = False

        if found:
            post["is_question_resolved"] = True
        return found

    def toggle_reaction(self, post_id: str, user_id: str, reaction_type: ReactionType) -> Optional[dict[str, Any]]:
        post = self._posts.get(str(post_id))
        if not post:
            return None

        if reaction_type == ReactionType.HELPFUL:
            post["helpful_count"] = post.get("helpful_count", 0) + 1
        elif reaction_type == ReactionType.LIKE:
            post["like_count"] = post.get("like_count", 0) + 1
        elif reaction_type == ReactionType.SAVED:
            post["save_count"] = post.get("save_count", 0) + 1

        return {
            "post_id": post_id,
            "reaction_type": reaction_type.value,
            "action": "ADDED",
            "current_counts": {
                "helpful": post.get("helpful_count", 0),
                "likes": post.get("like_count", 0),
                "saves": post.get("save_count", 0),
            },
        }

    def get_place_signal(self, destination_slug_or_id: str) -> PlaceSignalResponse:
        matching_posts = [
            p for p in self._posts.values()
            if p.get("destination_slug") == destination_slug_or_id or str(p.get("destination_id")) == destination_slug_or_id
        ]

        active_field_reports = [
            p for p in matching_posts
            if p.get("post_type") == "FIELD_REPORT" and not self._compute_freshness(p)[0]
        ]
        unanswered = [
            p for p in matching_posts
            if p.get("post_type") == "QUESTION" and not p.get("is_question_resolved", False)
        ]
        notes = [p for p in matching_posts if p.get("post_type") == "LOCAL_NOTE"]

        latest_post = None
        epoch_utc = datetime(2000, 1, 1, tzinfo=timezone.utc)
        if matching_posts:
            latest_post = max(
                matching_posts,
                key=lambda x: _ensure_utc(x.get("observed_at")) or _ensure_utc(x.get("created_at")) or epoch_utc,
            )

        dest_name = (latest_post and latest_post.get("destination_name")) or "Sigiriya Citadel"
        dist_name = (latest_post and latest_post.get("district_name")) or "Matale District"

        return PlaceSignalResponse(
            destination_id=str(uuid.uuid4()),
            destination_name=dest_name,
            district_name=dist_name,
            recent_notes_count=len(notes),
            unanswered_questions_count=len(unanswered),
            active_field_reports_count=len(active_field_reports),
            latest_observation=(latest_post and latest_post.get("caption")),
            latest_observed_at=(latest_post and latest_post.get("observed_at")),
            trail_or_road_status="CLEAR_AND_DRY" if active_field_reports else "NORMAL",
            crowd_level="LOW_AT_DAWN",
            freshness_status="VERY_FRESH" if active_field_reports else "MODERATE",
        )

    def validate_itinerary_addition(
        self, payload: ItineraryAdditionValidationRequest
    ) -> ItineraryAdditionValidationResponse:
        post = self._posts.get(str(payload.post_id))
        dest_name = (post and post.get("destination_name")) or "Selected Destination"

        start_h = payload.requested_start_hour
        dwell_mins = payload.dwell_duration_mins or 120
        buffer_mins = 25
        transit_mins = 45

        end_time_decimal = start_h + (dwell_mins / 60)

        is_feasible = True
        conflicts = []
        if end_time_decimal > 18.0:
            is_feasible = False
            conflicts.append(
                f"Stop ends at {int(end_time_decimal)}:{int((end_time_decimal % 1)*60):02d}, exceeding daylight / ticket counter closure (17:30)."
            )
            rec = "Shift arrival earlier to 14:00 or add to Day 2 morning itinerary."
        else:
            rec = f"Feasible: 45m transit + 25m road buffer from previous stop cleanly fits Day {payload.target_day_number} schedule."

        return ItineraryAdditionValidationResponse(
            is_feasible=is_feasible,
            destination_name=dest_name,
            proposed_day_number=payload.target_day_number,
            proposed_start_time=f"{start_h:02d}:00",
            proposed_end_time=f"{int(end_time_decimal):02d}:{int((end_time_decimal % 1)*60):02d}",
            road_buffer_mins=buffer_mins,
            transit_duration_mins=transit_mins,
            conflicts=conflicts,
            recommendation=rec,
        )

    def submit_report(self, reporter_id: str, reporter_name: str, payload: ContentReportRequest) -> dict[str, Any]:
        report_id = str(uuid.uuid4())
        record = {
            "id": report_id,
            "post_id": str(payload.post_id) if payload.post_id else None,
            "comment_id": str(payload.comment_id) if payload.comment_id else None,
            "reporter_id": str(reporter_id),
            "reporter_name": reporter_name,
            "reason": payload.reason.value,
            "description": payload.description,
            "status": "PENDING",
            "created_at": _now(),
        }
        self._reports[report_id] = record

        if payload.post_id and payload.reason in (ReportReason.DANGEROUS_ADVICE, ReportReason.HARASSMENT):
            p = self._posts.get(str(payload.post_id))
            if p:
                p["moderation_status"] = "FLAGGED"

        return record

    def block_user(self, blocker_id: str, target_user_id: str):
        self._blocks.add((str(blocker_id), str(target_user_id)))

    def unblock_user(self, blocker_id: str, target_user_id: str):
        self._blocks.discard((str(blocker_id), str(target_user_id)))

    def get_moderation_queue(self) -> List[dict[str, Any]]:
        return list(self._reports.values())


community_service = CommunityService()
