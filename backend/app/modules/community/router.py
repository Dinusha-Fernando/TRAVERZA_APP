import uuid
from typing import Any, List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status

from app.core.security import get_current_user_token
from app.modules.community.models import AuthorBadge, PostType, ReactionType
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
    PostReactionRequest,
    PostReactionResponse,
)
from app.modules.community.service import community_service

router = APIRouter(prefix="/community", tags=["Community Moments & Travel Pulse"])


@router.get("/feed", response_model=List[CommunityPostResponse])
async def get_community_feed(
    post_type: Optional[PostType] = None,
    district_id: Optional[str] = None,
    destination_slug: Optional[str] = None,
    search: Optional[str] = None,
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
):
    """
    Retrieve paginated travel moments, Q&A, and field reports.
    """
    posts = community_service.get_feed(
        post_type=post_type.value if post_type else None,
        district_id=district_id,
        destination_slug=destination_slug,
        search_query=search,
        limit=limit,
        offset=offset,
    )
    return posts


@router.get("/posts/{post_id}", response_model=CommunityPostResponse)
async def get_post_detail(post_id: str):
    post = community_service.get_post(str(post_id))
    if not post:
        raise HTTPException(status_code=404, detail="Community post not found")
    return post


@router.post("/posts", response_model=CommunityPostResponse, status_code=status.HTTP_201_CREATED)
async def create_post(
    payload: CommunityPostCreate,
    token_payload: dict[str, Any] = Depends(get_current_user_token),
):
    """
    Create a new post tagged to a canonical district and landmark.
    """
    author_id = token_payload.get("sub", str(uuid.uuid4()))
    author_name = token_payload.get("email", "Traveller").split("@")[0].capitalize()
    role = token_payload.get("role", "TRAVELLER")

    author_badge = "LICENSED_GUIDE" if role == "GUIDE" else "VERIFIED_PROVIDER" if role == "PROVIDER" else "TRAVELLER"

    created = community_service.create_post(
        author_id=author_id,
        author_name=author_name,
        author_badge=author_badge,
        author_badge_detail=None,
        payload=payload,
    )
    return created


@router.post("/posts/{post_id}/comments", response_model=PostCommentResponse)
async def add_post_comment(
    post_id: str,
    payload: PostCommentCreate,
    token_payload: dict[str, Any] = Depends(get_current_user_token),
):
    author_id = token_payload.get("sub", str(uuid.uuid4()))
    author_name = token_payload.get("email", "Traveller").split("@")[0].capitalize()
    role = token_payload.get("role", "TRAVELLER")
    author_badge = "LICENSED_GUIDE" if role == "GUIDE" else "TRAVELLER"

    comment = community_service.add_comment(
        post_id=str(post_id),
        author_id=author_id,
        author_name=author_name,
        author_badge=author_badge,
        payload=payload,
    )
    if not comment:
        raise HTTPException(status_code=404, detail="Post not found")
    return comment


@router.post("/posts/{post_id}/comments/{comment_id}/accept")
async def mark_accepted_answer(
    post_id: str,
    comment_id: str,
    token_payload: dict[str, Any] = Depends(get_current_user_token),
):
    caller_id = token_payload.get("sub", "")
    success = community_service.mark_accepted_answer(str(post_id), str(comment_id), caller_id)
    if not success:
        raise HTTPException(status_code=400, detail="Cannot mark comment as accepted. Check permissions.")
    return {"status": "SUCCESS", "message": "Answer marked as accepted"}


@router.post("/posts/{post_id}/reactions", response_model=PostReactionResponse)
async def toggle_reaction(
    post_id: str,
    payload: PostReactionRequest,
    token_payload: dict[str, Any] = Depends(get_current_user_token),
):
    user_id = token_payload.get("sub", str(uuid.uuid4()))
    resp = community_service.toggle_reaction(str(post_id), str(user_id), payload.reaction_type)
    if not resp:
        raise HTTPException(status_code=404, detail="Post not found")
    return resp


@router.get("/destinations/{slug}/signal", response_model=PlaceSignalResponse)
async def get_destination_place_signal(slug: str):
    """
    Summarize recent visitor notes, fresh field reports, and crowd status for a destination.
    """
    return community_service.get_place_signal(slug)


@router.post("/itinerary-add/validate", response_model=ItineraryAdditionValidationResponse)
async def validate_itinerary_addition(
    payload: ItineraryAdditionValidationRequest,
    token_payload: dict[str, Any] = Depends(get_current_user_token),
):
    """
    TripGraph feasibility validation: checks whether adding this destination fits the day.
    """
    return community_service.validate_itinerary_addition(payload)


@router.post("/reports", response_model=ContentReportResponse)
async def report_content(
    payload: ContentReportRequest,
    token_payload: dict[str, Any] = Depends(get_current_user_token),
):
    reporter_id = token_payload.get("sub", str(uuid.uuid4()))
    reporter_name = token_payload.get("email", "Traveller").split("@")[0].capitalize()

    rep = community_service.submit_report(reporter_id, reporter_name, payload)
    return rep


@router.post("/blocks/{user_id}")
async def block_user(
    user_id: str,
    token_payload: dict[str, Any] = Depends(get_current_user_token),
):
    blocker_id = token_payload.get("sub", "")
    community_service.block_user(blocker_id, str(user_id))
    return {"status": "BLOCKED", "target_user_id": str(user_id)}


@router.get("/moderation/queue")
async def get_moderation_queue(
    token_payload: dict[str, Any] = Depends(get_current_user_token),
):
    return community_service.get_moderation_queue()
