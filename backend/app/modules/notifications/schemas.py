from typing import Any
from pydantic import BaseModel, Field


class NotificationItem(BaseModel):
    id: str
    title: str
    body: str
    category: str = Field(..., description="'SAFETY', 'BOOKING', 'TRIP', 'OFFERS'")
    timestamp: str
    is_read: bool = False
    action_route: str | None = None
    action_label: str | None = None
    priority: str = "medium"


class NotificationBroadcastRequest(BaseModel):
    recipient_email: str
    subject: str
    message: str
    category: str = "BOOKING"
    action_route: str | None = None
    action_label: str | None = None
    meta: dict[str, Any] | None = None


class NotificationBroadcastResponse(BaseModel):
    status: str
    recipient: str
    subject: str
    dispatched_at: str
    task_id: str | None = None
