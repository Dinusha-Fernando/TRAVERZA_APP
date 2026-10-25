from datetime import datetime
from typing import Any

from pydantic import BaseModel, Field

from app.modules.messenger.models import ConversationType, MessageType


class PlaceSnippetPayload(BaseModel):
    destination_id: str | None = None
    destination_name: str
    district_name: str
    photo_url: str | None = None
    summary: str | None = None


class ProviderQuotePayload(BaseModel):
    service_name: str
    proposed_date: str
    guests_count: int = 2
    estimated_lkr: int | None = None
    booking_status: str = "INQUIRY_OPEN"


class MediaAttachmentPayload(BaseModel):
    media_url: str
    media_type: str = "image"  # "image" or "video"
    caption: str | None = None
    duration_seconds: int | None = None
    thumbnail_url: str | None = None


class ChatMessageResponse(BaseModel):
    id: str
    conversation_id: str
    sender_id: str
    sender_name: str
    client_message_id: str
    message_type: MessageType
    text_content: str
    payload_data: dict[str, Any] | None = None
    created_at: datetime


class ChatMessageCreate(BaseModel):
    client_message_id: str = Field(..., description="Client idempotency UUID")
    message_type: MessageType = MessageType.TEXT
    text_content: str = Field(..., min_length=1, max_length=2000)
    payload_data: dict[str, Any] | None = None


class ConversationParticipantResponse(BaseModel):
    user_id: str
    user_name: str
    user_role: str
    unread_count: int = 0
    has_accepted_request: bool = True


class ChatConversationSummaryResponse(BaseModel):
    id: str
    conversation_type: ConversationType
    title: str
    related_provider_id: str | None = None
    related_trip_id: str | None = None
    district_name: str | None = None
    member_count: int | None = None
    last_message_text: str | None = None
    last_message_at: datetime
    unread_count: int = 0
    participants: list[ConversationParticipantResponse] = []


class ChatConversationCreate(BaseModel):
    conversation_type: ConversationType = ConversationType.DIRECT
    title: str
    recipient_user_id: str | None = None
    recipient_user_name: str | None = None
    related_provider_id: str | None = None
    related_trip_id: str | None = None
    district_name: str | None = None
    initial_message: str | None = None
    initial_place_snippet: PlaceSnippetPayload | None = None
    initial_quote_request: ProviderQuotePayload | None = None
    initial_media: MediaAttachmentPayload | None = None


class ReadCursorUpdate(BaseModel):
    last_read_message_id: str
