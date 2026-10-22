from datetime import datetime
from typing import Any, Dict, List, Optional
from pydantic import BaseModel, Field

from app.modules.messenger.models import ConversationType, MessageType


class PlaceSnippetPayload(BaseModel):
    destination_id: Optional[str] = None
    destination_name: str
    district_name: str
    photo_url: Optional[str] = None
    summary: Optional[str] = None


class ProviderQuotePayload(BaseModel):
    service_name: str
    proposed_date: str
    guests_count: int = 2
    estimated_lkr: Optional[int] = None
    booking_status: str = "INQUIRY_OPEN"


class MediaAttachmentPayload(BaseModel):
    media_url: str
    media_type: str = "image"  # "image" or "video"
    caption: Optional[str] = None
    duration_seconds: Optional[int] = None
    thumbnail_url: Optional[str] = None


class ChatMessageResponse(BaseModel):
    id: str
    conversation_id: str
    sender_id: str
    sender_name: str
    client_message_id: str
    message_type: MessageType
    text_content: str
    payload_data: Optional[Dict[str, Any]] = None
    created_at: datetime


class ChatMessageCreate(BaseModel):
    client_message_id: str = Field(..., description="Client idempotency UUID")
    message_type: MessageType = MessageType.TEXT
    text_content: str = Field(..., min_length=1, max_length=2000)
    payload_data: Optional[Dict[str, Any]] = None


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
    related_provider_id: Optional[str] = None
    related_trip_id: Optional[str] = None
    district_name: Optional[str] = None
    member_count: Optional[int] = None
    last_message_text: Optional[str] = None
    last_message_at: datetime
    unread_count: int = 0
    participants: List[ConversationParticipantResponse] = []


class ChatConversationCreate(BaseModel):
    conversation_type: ConversationType = ConversationType.DIRECT
    title: str
    recipient_user_id: Optional[str] = None
    recipient_user_name: Optional[str] = None
    related_provider_id: Optional[str] = None
    related_trip_id: Optional[str] = None
    district_name: Optional[str] = None
    initial_message: Optional[str] = None
    initial_place_snippet: Optional[PlaceSnippetPayload] = None
    initial_quote_request: Optional[ProviderQuotePayload] = None
    initial_media: Optional[MediaAttachmentPayload] = None


class ReadCursorUpdate(BaseModel):
    last_read_message_id: str
