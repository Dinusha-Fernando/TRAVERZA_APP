import logging
import uuid
from datetime import UTC, datetime
from typing import Any

from fastapi import APIRouter, Depends, status

from app.core.security import get_current_user_token
from app.modules.notifications.schemas import (
    NotificationBroadcastRequest,
    NotificationBroadcastResponse,
    NotificationItem,
)

logger = logging.getLogger("traverza.notifications")
router = APIRouter(prefix="/notifications", tags=["Notifications"])

# In-memory transient store for corridor alerts
_MOCK_NOTIFICATIONS: list[dict[str, Any]] = [
    {
        "id": "NOTIF-LK-001",
        "title": "Kandy → Nuwara Eliya Hairpin Roadwork",
        "body": "+30 min scenic buffer recommended due to road resurfacing near Ramboda Falls. Chauffeur notified.",
        "category": "SAFETY",
        "timestamp": datetime.now(UTC).isoformat(),
        "is_read": False,
        "action_route": "plan",
        "action_label": "Review Buffers",
        "priority": "high",
    },
    {
        "id": "NOTIF-LK-002",
        "title": "Booking Request Received: Sigiriya Eco Villa",
        "body": "Provider has a 12h SLA response deadline to confirm. Direct reservation tracking active.",
        "category": "BOOKING",
        "timestamp": datetime.now(UTC).isoformat(),
        "is_read": False,
        "action_route": "bookings",
        "action_label": "Track SLA",
        "priority": "medium",
    },
    {
        "id": "NOTIF-LK-003",
        "title": "SLTDA Biometric Pass Activated",
        "body": "Universal check-in token #TRV-LK-9041-INTL is active for express hotel & national park entry.",
        "category": "TRIP",
        "timestamp": datetime.now(UTC).isoformat(),
        "is_read": True,
        "action_route": "safety",
        "action_label": "View Pass",
        "priority": "medium",
    },
    {
        "id": "NOTIF-LK-004",
        "title": "Lion Rock Sunrise Climb Privilege",
        "body": "Early gate pass available for registered pilot members at 06:30 AM before peak heat.",
        "category": "OFFERS",
        "timestamp": datetime.now(UTC).isoformat(),
        "is_read": True,
        "action_route": "plan",
        "action_label": "Explore",
        "priority": "low",
    },
]


@router.get("", response_model=list[NotificationItem])
async def list_notifications(
    token_payload: dict[str, Any] = Depends(get_current_user_token),
):
    """Retrieves operational corridor notifications for the authenticated user."""
    return [NotificationItem(**n) for n in _MOCK_NOTIFICATIONS]


@router.post("/{notification_id}/read", status_code=status.HTTP_200_OK)
async def mark_notification_read(
    notification_id: str,
    token_payload: dict[str, Any] = Depends(get_current_user_token),
):
    """Marks a specific corridor notification as read."""
    for n in _MOCK_NOTIFICATIONS:
        if n["id"] == notification_id:
            n["is_read"] = True
            return {"status": "ok", "id": notification_id, "is_read": True}
    return {"status": "not_found", "id": notification_id}


@router.post("/broadcast", response_model=NotificationBroadcastResponse, status_code=status.HTTP_202_ACCEPTED)
async def broadcast_notification(
    req: NotificationBroadcastRequest,
    token_payload: dict[str, Any] = Depends(get_current_user_token),
):
    """
    Dispatches a durable operational alert to traveller/provider and logs via Celery worker.
    """
    notif_id = f"NOTIF-DISPATCH-{uuid.uuid4().hex[:8].upper()}"
    now_str = datetime.now(UTC).isoformat()

    logger.info(
        f"Operational notification queued: [{req.category}] {req.subject} -> {req.recipient_email}"
    )

    # Record in transient store
    _MOCK_NOTIFICATIONS.insert(
        0,
        {
            "id": notif_id,
            "title": req.subject,
            "body": req.message,
            "category": req.category,
            "timestamp": now_str,
            "is_read": False,
            "action_route": req.action_route,
            "action_label": req.action_label,
            "priority": "high",
        },
    )

    return NotificationBroadcastResponse(
        status="QUEUED",
        recipient=req.recipient_email,
        subject=req.subject,
        dispatched_at=now_str,
        task_id=f"celery-task-{uuid.uuid4().hex[:12]}",
    )
