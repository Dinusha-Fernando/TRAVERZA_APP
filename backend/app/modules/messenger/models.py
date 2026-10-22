import enum
import uuid
from datetime import datetime
from typing import Optional

from sqlalchemy import (
    Boolean,
    Column,
    DateTime,
    Enum,
    ForeignKey,
    Integer,
    String,
    Table,
    Text,
)
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import relationship

from app.core.database import Base


class ConversationType(str, enum.Enum):
    DIRECT = "DIRECT"
    PROVIDER_INQUIRY = "PROVIDER_INQUIRY"
    TRIP_GROUP = "TRIP_GROUP"
    DISTRICT_LOUNGE = "DISTRICT_LOUNGE"
    COMMUNITY_TOPIC = "COMMUNITY_TOPIC"


class MessageType(str, enum.Enum):
    TEXT = "TEXT"
    PHOTO = "PHOTO"
    VIDEO = "VIDEO"
    PLACE_SNIPPET = "PLACE_SNIPPET"
    ITINERARY_SNIPPET = "ITINERARY_SNIPPET"
    PROVIDER_QUOTE_REQUEST = "PROVIDER_QUOTE_REQUEST"


class DeliveryStatus(str, enum.Enum):
    SENDING = "SENDING"
    SENT = "SENT"
    DELIVERED = "DELIVERED"
    READ = "READ"


class ChatConversation(Base):
    __tablename__ = "chat_conversations"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    conversation_type = Column(Enum(ConversationType), default=ConversationType.DIRECT, nullable=False)
    title = Column(String(200), nullable=False)

    # Contextual links
    related_provider_id = Column(UUID(as_uuid=True), nullable=True)
    related_trip_id = Column(UUID(as_uuid=True), nullable=True)
    related_destination_id = Column(UUID(as_uuid=True), nullable=True)

    created_by = Column(UUID(as_uuid=True), nullable=False)
    last_message_text = Column(String(500), nullable=True)
    last_message_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    participants = relationship("ConversationParticipant", back_populates="conversation", cascade="all, delete-orphan")
    messages = relationship("ChatMessage", back_populates="conversation", cascade="all, delete-orphan", order_by="ChatMessage.created_at")


class ConversationParticipant(Base):
    __tablename__ = "chat_participants"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    conversation_id = Column(UUID(as_uuid=True), ForeignKey("chat_conversations.id"), nullable=False, index=True)
    user_id = Column(UUID(as_uuid=True), nullable=False, index=True)
    user_name = Column(String(100), nullable=False)
    user_role = Column(String(50), default="TRAVELLER", nullable=False)

    last_read_message_id = Column(UUID(as_uuid=True), nullable=True)
    unread_count = Column(Integer, default=0)
    has_accepted_request = Column(Boolean, default=True)

    conversation = relationship("ChatConversation", back_populates="participants")


class ChatMessage(Base):
    __tablename__ = "chat_messages"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    conversation_id = Column(UUID(as_uuid=True), ForeignKey("chat_conversations.id"), nullable=False, index=True)
    sender_id = Column(UUID(as_uuid=True), nullable=False, index=True)
    sender_name = Column(String(100), nullable=False)
    client_message_id = Column(String(100), nullable=False, index=True)  # Idempotency nonce

    message_type = Column(Enum(MessageType), default=MessageType.TEXT, nullable=False)
    text_content = Column(Text, nullable=False)
    payload_data = Column(JSONB, nullable=True)  # Typed place/itinerary/quote card

    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    conversation = relationship("ChatConversation", back_populates="messages")
