import copy
import uuid
from datetime import datetime, timedelta, timezone
from typing import Any, Dict, List, Optional, Set
from fastapi import WebSocket

from app.modules.messenger.models import ConversationType, MessageType
from app.modules.messenger.schemas import (
    ChatConversationCreate,
    ChatMessageCreate,
    ChatMessageResponse,
)


class MessengerService:
    """Manages conversations, messages, idempotency, and real-time WebSocket fan-out."""

    def __init__(self):
        self._conversations: dict[str, dict[str, Any]] = {}
        self._messages: dict[str, List[dict[str, Any]]] = {}  # conv_id -> list of messages
        self._idempotency_map: dict[str, str] = {}  # client_message_id -> message_id
        self._active_connections: dict[str, Set[WebSocket]] = {}  # conv_id -> active WebSockets
        self._seed_initial_conversations()

    def _seed_initial_conversations(self):
        conv1_id = "cv100000-0000-0000-0000-000000000001"
        conv2_id = "cv100000-0000-0000-0000-000000000002"
        conv3_id = "cv100000-0000-0000-0000-000000000003"

        # Conversation 1: Provider Inquiry with Sigiriya Eco Villa
        self._conversations[conv1_id] = {
            "id": conv1_id,
            "conversation_type": "PROVIDER_INQUIRY",
            "title": "Sigiriya Eco Villa · Inquiry #INQ-8902",
            "related_provider_id": "p1000000-0000-0000-0000-000000000001",
            "related_trip_id": "t1000000-0000-0000-0000-000000000001",
            "created_by": "u1000000-0000-0000-0000-000000000001",
            "last_message_text": "We have prepared the garden cottage for your 18:30 check-in.",
            "last_message_at": datetime.now(timezone.utc) - timedelta(minutes=25),
            "unread_count": 1,
            "participants": [
                {
                    "user_id": "u1000000-0000-0000-0000-000000000001",
                    "user_name": "Dinusha (Traveller)",
                    "user_role": "TRAVELLER",
                    "unread_count": 1,
                    "has_accepted_request": True,
                },
                {
                    "user_id": "u1000000-0000-0000-0000-000000000008",
                    "user_name": "Sigiriya Eco Villa Reservations",
                    "user_role": "PROVIDER",
                    "unread_count": 0,
                    "has_accepted_request": True,
                },
            ],
        }

        self._messages[conv1_id] = [
            {
                "id": "msg10000-0000-0000-0000-000000000001",
                "conversation_id": conv1_id,
                "sender_id": "u1000000-0000-0000-0000-000000000001",
                "sender_name": "Dinusha",
                "client_message_id": "cli-101",
                "message_type": "PROVIDER_QUOTE_REQUEST",
                "text_content": "Booking inquiry for 2 nights starting tomorrow.",
                "payload_data": {
                    "service_name": "Sigiriya Water Garden Eco Villa",
                    "proposed_date": "2026-10-23 to 2026-10-25",
                    "guests_count": 2,
                    "estimated_lkr": 38000,
                    "booking_status": "PROVIDER_CONFIRMED",
                },
                "created_at": datetime.now(timezone.utc) - timedelta(hours=2),
            },
            {
                "id": "msg10000-0000-0000-0000-000000000002",
                "conversation_id": conv1_id,
                "sender_id": "u1000000-0000-0000-0000-000000000008",
                "sender_name": "Sigiriya Eco Villa Reservations",
                "client_message_id": "cli-102",
                "message_type": "TEXT",
                "text_content": "Ayubowan! We have prepared the garden cottage for your 18:30 check-in. Dinner can be served on your private terrace.",
                "payload_data": None,
                "created_at": datetime.now(timezone.utc) - timedelta(minutes=25),
            },
        ]

        # Conversation 2: Direct Guide Inquiry with Duminda Bandara
        self._conversations[conv2_id] = {
            "id": conv2_id,
            "conversation_type": "DIRECT",
            "title": "Duminda Bandara (Licensed Guide)",
            "related_provider_id": None,
            "related_trip_id": None,
            "created_by": "u1000000-0000-0000-0000-000000000001",
            "last_message_text": "Meeting at Sigiriya south entrance at 06:15 AM sharp.",
            "last_message_at": datetime.now(timezone.utc) - timedelta(hours=1),
            "unread_count": 0,
            "participants": [
                {
                    "user_id": "u1000000-0000-0000-0000-000000000001",
                    "user_name": "Dinusha (Traveller)",
                    "user_role": "TRAVELLER",
                    "unread_count": 0,
                    "has_accepted_request": True,
                },
                {
                    "user_id": "u1000000-0000-0000-0000-000000000002",
                    "user_name": "Duminda Bandara",
                    "user_role": "GUIDE",
                    "unread_count": 0,
                    "has_accepted_request": True,
                },
            ],
        }

        self._messages[conv2_id] = [
            {
                "id": "msg10000-0000-0000-0000-000000000003",
                "conversation_id": conv2_id,
                "sender_id": "u1000000-0000-0000-0000-000000000002",
                "sender_name": "Duminda Bandara",
                "client_message_id": "cli-103",
                "message_type": "PLACE_SNIPPET",
                "text_content": "Here is the meeting landmark for tomorrow's dawn climb.",
                "payload_data": {
                    "destination_name": "Sigiriya Ancient Citadel & Lion Rock",
                    "district_name": "Matale District",
                    "photo_url": "https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?auto=format&fit=crop&w=600&q=80",
                    "summary": "UNESCO 5th-century sky fortress built by King Kasyapa.",
                },
                "created_at": datetime.now(timezone.utc) - timedelta(hours=3),
            },
            {
                "id": "msg10000-0000-0000-0000-000000000004",
                "conversation_id": conv2_id,
                "sender_id": "u1000000-0000-0000-0000-000000000002",
                "sender_name": "Duminda Bandara",
                "client_message_id": "cli-104",
                "message_type": "TEXT",
                "text_content": "Meeting at Sigiriya south entrance at 06:15 AM sharp. I will carry the official archaeological badges.",
                "payload_data": None,
                "created_at": datetime.now(timezone.utc) - timedelta(hours=1),
            },
        ]

        # Conversation 3: Trip Group
        self._conversations[conv3_id] = {
            "id": conv3_id,
            "conversation_type": "TRIP_GROUP",
            "title": "Ceylon Cultural Triangle 2026",
            "related_provider_id": None,
            "related_trip_id": "t1000000-0000-0000-0000-000000000001",
            "created_by": "u1000000-0000-0000-0000-000000000001",
            "last_message_text": "Added Dambulla Cave Temples to Day 2 afternoon itinerary.",
            "last_message_at": datetime.now(timezone.utc) - timedelta(hours=4),
            "unread_count": 0,
            "participants": [
                {
                    "user_id": "u1000000-0000-0000-0000-000000000001",
                    "user_name": "Dinusha",
                    "user_role": "TRIP_LEAD",
                    "unread_count": 0,
                    "has_accepted_request": True,
                },
                {
                    "user_id": "u1000000-0000-0000-0000-000000000003",
                    "user_name": "Rohan Senanayake",
                    "user_role": "COMPANION",
                    "unread_count": 0,
                    "has_accepted_request": True,
                },
            ],
        }

        self._messages[conv3_id] = [
            {
                "id": "msg10000-0000-0000-0000-000000000005",
                "conversation_id": conv3_id,
                "sender_id": "u1000000-0000-0000-0000-000000000001",
                "sender_name": "Dinusha",
                "client_message_id": "cli-105",
                "message_type": "TEXT",
                "text_content": "Added Dambulla Cave Temples to Day 2 afternoon itinerary. TripGraph confirmed 25m transit buffer from Sigiriya.",
                "payload_data": None,
                "created_at": datetime.now(timezone.utc) - timedelta(hours=4),
            }
        ]

        # Conversation 4: District Lounge - Ella & Uva Travellers Lounge
        conv4_id = "cv100000-0000-0000-0000-000000000004"
        self._conversations[conv4_id] = {
            "id": conv4_id,
            "conversation_type": "DISTRICT_LOUNGE",
            "title": "Ella & Uva Travellers Lounge",
            "related_provider_id": None,
            "related_trip_id": None,
            "district_name": "Badulla / Ella",
            "member_count": 342,
            "created_by": "u1000000-0000-0000-0000-000000000001",
            "last_message_text": "Watch the blue train crossing through the tea valley!",
            "last_message_at": datetime.now(timezone.utc) - timedelta(minutes=15),
            "unread_count": 2,
            "participants": [
                {
                    "user_id": "u1000000-0000-0000-0000-000000000001",
                    "user_name": "Dinusha (Traveller)",
                    "user_role": "TRAVELLER",
                    "unread_count": 2,
                    "has_accepted_request": True,
                },
                {
                    "user_id": "u1000000-0000-0000-0000-000000000005",
                    "user_name": "Elena Rostova",
                    "user_role": "TRAVELLER",
                    "unread_count": 0,
                    "has_accepted_request": True,
                },
                {
                    "user_id": "u1000000-0000-0000-0000-000000000006",
                    "user_name": "Markus Weber",
                    "user_role": "CREATOR",
                    "unread_count": 0,
                    "has_accepted_request": True,
                },
            ],
        }

        self._messages[conv4_id] = [
            {
                "id": "msg10000-0000-0000-0000-000000000006",
                "conversation_id": conv4_id,
                "sender_id": "u1000000-0000-0000-0000-000000000006",
                "sender_name": "Markus Weber",
                "client_message_id": "cli-106",
                "message_type": "PHOTO",
                "text_content": "Golden sunrise over the Nine Arch viaduct this morning! Completely quiet before 07:00 AM.",
                "payload_data": {
                    "media_url": "https://images.unsplash.com/photo-1589308078059-be1415eab4c3?auto=format&fit=crop&w=800&q=80",
                    "media_type": "image",
                    "caption": "Nine Arch Bridge at sunrise",
                },
                "created_at": datetime.now(timezone.utc) - timedelta(hours=1),
            },
            {
                "id": "msg10000-0000-0000-0000-000000000007",
                "conversation_id": conv4_id,
                "sender_id": "u1000000-0000-0000-0000-000000000005",
                "sender_name": "Elena Rostova",
                "client_message_id": "cli-107",
                "message_type": "VIDEO",
                "text_content": "Watch the blue train crossing through the tea valley!",
                "payload_data": {
                    "media_url": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
                    "media_type": "video",
                    "duration_seconds": 18,
                    "thumbnail_url": "https://images.unsplash.com/photo-1589308078059-be1415eab4c3?auto=format&fit=crop&w=800&q=80",
                    "caption": "Blue express train clearing Nine Arch viaduct",
                },
                "created_at": datetime.now(timezone.utc) - timedelta(minutes=15),
            },
        ]

        # Conversation 5: District Lounge - Sigiriya & Cultural Triangle Hub
        conv5_id = "cv100000-0000-0000-0000-000000000005"
        self._conversations[conv5_id] = {
            "id": conv5_id,
            "conversation_type": "DISTRICT_LOUNGE",
            "title": "Sigiriya & Cultural Triangle Hub",
            "related_provider_id": None,
            "related_trip_id": None,
            "district_name": "Matale / Sigiriya",
            "member_count": 516,
            "created_by": "u1000000-0000-0000-0000-000000000001",
            "last_message_text": "Pidurangala sunrise climb: recommend starting at 05:15 AM from north temple.",
            "last_message_at": datetime.now(timezone.utc) - timedelta(minutes=40),
            "unread_count": 1,
            "participants": [
                {
                    "user_id": "u1000000-0000-0000-0000-000000000001",
                    "user_name": "Dinusha (Traveller)",
                    "user_role": "TRAVELLER",
                    "unread_count": 1,
                    "has_accepted_request": True,
                },
            ],
        }

        self._messages[conv5_id] = [
            {
                "id": "msg10000-0000-0000-0000-000000000008",
                "conversation_id": conv5_id,
                "sender_id": "u1000000-0000-0000-0000-000000000002",
                "sender_name": "Duminda Bandara",
                "client_message_id": "cli-108",
                "message_type": "PLACE_SNIPPET",
                "text_content": "Pidurangala sunrise climb: recommend starting at 05:15 AM from north temple.",
                "payload_data": {
                    "destination_name": "Pidurangala Rock Sanctuary",
                    "district_name": "Matale District",
                    "photo_url": "https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?auto=format&fit=crop&w=600&q=80",
                    "summary": "Panoramic granite peak directly facing Sigiriya Lion Rock fortress.",
                },
                "created_at": datetime.now(timezone.utc) - timedelta(minutes=40),
            },
        ]

        # Conversation 6: Direct Chat with Fellow Creator - Ayesha De Silva
        conv6_id = "cv100000-0000-0000-0000-000000000006"
        self._conversations[conv6_id] = {
            "id": conv6_id,
            "conversation_type": "DIRECT",
            "title": "Ayesha De Silva (Travel Creator)",
            "related_provider_id": None,
            "related_trip_id": None,
            "district_name": "Galle / Coast",
            "member_count": 2,
            "created_by": "u1000000-0000-0000-0000-000000000001",
            "last_message_text": "Here is the photo of the sunset ramparts from Pedlar Street!",
            "last_message_at": datetime.now(timezone.utc) - timedelta(hours=2),
            "unread_count": 0,
            "participants": [
                {
                    "user_id": "u1000000-0000-0000-0000-000000000001",
                    "user_name": "Dinusha",
                    "user_role": "TRAVELLER",
                    "unread_count": 0,
                    "has_accepted_request": True,
                },
                {
                    "user_id": "u1000000-0000-0000-0000-000000000007",
                    "user_name": "Ayesha De Silva",
                    "user_role": "CREATOR",
                    "unread_count": 0,
                    "has_accepted_request": True,
                },
            ],
        }

        self._messages[conv6_id] = [
            {
                "id": "msg10000-0000-0000-0000-000000000009",
                "conversation_id": conv6_id,
                "sender_id": "u1000000-0000-0000-0000-000000000007",
                "sender_name": "Ayesha De Silva",
                "client_message_id": "cli-109",
                "message_type": "PHOTO",
                "text_content": "Here is the photo of the sunset ramparts from Pedlar Street!",
                "payload_data": {
                    "media_url": "https://images.unsplash.com/photo-1552465011-b4e21bf6e79a?auto=format&fit=crop&w=800&q=80",
                    "media_type": "image",
                    "caption": "Galle Fort Lighthouse & Ramparts",
                },
                "created_at": datetime.now(timezone.utc) - timedelta(hours=2),
            },
        ]

    def get_user_conversations(self, user_id: str) -> List[dict[str, Any]]:
        return list(self._conversations.values())

    def get_conversation(self, conv_id: str) -> Optional[dict[str, Any]]:
        return self._conversations.get(str(conv_id))

    def get_messages(self, conv_id: str, limit: int = 50, offset: int = 0) -> List[dict[str, Any]]:
        msgs = self._messages.get(str(conv_id), [])
        return msgs[offset : offset + limit]

    def send_message(
        self,
        conv_id: str,
        sender_id: str,
        sender_name: str,
        payload: ChatMessageCreate,
    ) -> dict[str, Any]:
        conv_id_str = str(conv_id)
        conv = self._conversations.get(conv_id_str)
        if not conv:
            raise ValueError(f"Conversation {conv_id} not found")

        # Idempotency check: if client_message_id was already processed, return existing message
        if payload.client_message_id in self._idempotency_map:
            existing_msg_id = self._idempotency_map[payload.client_message_id]
            for m in self._messages.get(conv_id_str, []):
                if m["id"] == existing_msg_id:
                    return m

        msg_id = str(uuid.uuid4())
        new_msg = {
            "id": msg_id,
            "conversation_id": conv_id_str,
            "sender_id": str(sender_id),
            "sender_name": sender_name,
            "client_message_id": payload.client_message_id,
            "message_type": payload.message_type.value,
            "text_content": payload.text_content,
            "payload_data": payload.payload_data,
            "created_at": datetime.now(timezone.utc),
        }

        self._messages.setdefault(conv_id_str, []).append(new_msg)
        self._idempotency_map[payload.client_message_id] = msg_id

        # Update conversation meta
        conv["last_message_text"] = payload.text_content
        conv["last_message_at"] = new_msg["created_at"]

        return new_msg

    def create_conversation(
        self,
        creator_id: str,
        creator_name: str,
        payload: ChatConversationCreate,
    ) -> dict[str, Any]:
        conv_id = str(uuid.uuid4())
        now = datetime.now(timezone.utc)

        participants = [
            {
                "user_id": str(creator_id),
                "user_name": creator_name,
                "user_role": "TRAVELLER",
                "unread_count": 0,
                "has_accepted_request": True,
            }
        ]

        if payload.recipient_user_id:
            participants.append(
                {
                    "user_id": str(payload.recipient_user_id),
                    "user_name": payload.recipient_user_name or "Recipient",
                    "user_role": "PROVIDER" if payload.conversation_type == ConversationType.PROVIDER_INQUIRY else "TRAVELLER",
                    "unread_count": 1,
                    "has_accepted_request": True,
                }
            )

        new_conv = {
            "id": conv_id,
            "conversation_type": payload.conversation_type.value,
            "title": payload.title,
            "related_provider_id": str(payload.related_provider_id) if payload.related_provider_id else None,
            "related_trip_id": str(payload.related_trip_id) if payload.related_trip_id else None,
            "created_by": str(creator_id),
            "last_message_text": payload.initial_message or "Conversation created",
            "last_message_at": now,
            "unread_count": 0,
            "participants": participants,
        }

        self._conversations[conv_id] = new_conv
        self._messages[conv_id] = []

        if payload.initial_message:
            msg_payload = ChatMessageCreate(
                client_message_id=str(uuid.uuid4()),
                message_type=MessageType.TEXT,
                text_content=payload.initial_message,
                payload_data=None,
            )
            self.send_message(conv_id, creator_id, creator_name, msg_payload)

        if payload.initial_place_snippet:
            snippet_payload = ChatMessageCreate(
                client_message_id=str(uuid.uuid4()),
                message_type=MessageType.PLACE_SNIPPET,
                text_content=f"Inquiring about {payload.initial_place_snippet.destination_name}",
                payload_data=payload.initial_place_snippet.model_dump(),
            )
            self.send_message(conv_id, creator_id, creator_name, snippet_payload)

        if payload.initial_media:
            m_type = MessageType.VIDEO if payload.initial_media.media_type == "video" else MessageType.PHOTO
            media_payload = ChatMessageCreate(
                client_message_id=str(uuid.uuid4()),
                message_type=m_type,
                text_content=payload.initial_media.caption or ("Shared a video" if m_type == MessageType.VIDEO else "Shared a photo"),
                payload_data=payload.initial_media.model_dump(),
            )
            self.send_message(conv_id, creator_id, creator_name, media_payload)

        return new_conv

    def update_read_cursor(self, conv_id: str, user_id: str, message_id: str):
        conv = self._conversations.get(str(conv_id))
        if conv:
            conv["unread_count"] = 0
            for p in conv.get("participants", []):
                if str(p["user_id"]) == str(user_id):
                    p["unread_count"] = 0


# Singleton instance
messenger_service = MessengerService()
