import json
import uuid
from typing import Any, List
from fastapi import APIRouter, Depends, HTTPException, Query, WebSocket, WebSocketDisconnect, status

from app.core.security import get_current_user_token
from app.modules.messenger.schemas import (
    ChatConversationCreate,
    ChatConversationSummaryResponse,
    ChatMessageCreate,
    ChatMessageResponse,
    ReadCursorUpdate,
)
from app.modules.messenger.service import messenger_service

router = APIRouter(prefix="/messenger", tags=["Travel Messenger"])


@router.get("/conversations", response_model=List[ChatConversationSummaryResponse])
async def list_conversations(
    token_payload: dict[str, Any] = Depends(get_current_user_token),
):
    user_id = token_payload.get("sub", "")
    return messenger_service.get_user_conversations(user_id)


@router.post("/conversations", response_model=ChatConversationSummaryResponse, status_code=status.HTTP_201_CREATED)
async def create_conversation(
    payload: ChatConversationCreate,
    token_payload: dict[str, Any] = Depends(get_current_user_token),
):
    creator_id = token_payload.get("sub", str(uuid.uuid4()))
    creator_name = token_payload.get("email", "Traveller").split("@")[0].capitalize()

    conv = messenger_service.create_conversation(creator_id, creator_name, payload)
    return conv


@router.get("/conversations/{conv_id}/messages", response_model=List[ChatMessageResponse])
async def get_messages(
    conv_id: str,
    limit: int = Query(50, ge=1, le=100),
    offset: int = Query(0, ge=0),
    token_payload: dict[str, Any] = Depends(get_current_user_token),
):
    conv = messenger_service.get_conversation(str(conv_id))
    if not conv:
        raise HTTPException(status_code=404, detail="Conversation not found")
    return messenger_service.get_messages(str(conv_id), limit=limit, offset=offset)


@router.post("/conversations/{conv_id}/messages", response_model=ChatMessageResponse, status_code=status.HTTP_201_CREATED)
async def send_message(
    conv_id: str,
    payload: ChatMessageCreate,
    token_payload: dict[str, Any] = Depends(get_current_user_token),
):
    sender_id = token_payload.get("sub", str(uuid.uuid4()))
    sender_name = token_payload.get("email", "Traveller").split("@")[0].capitalize()

    try:
        msg = messenger_service.send_message(str(conv_id), sender_id, sender_name, payload)
        return msg
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))


@router.post("/conversations/{conv_id}/read-cursor")
async def update_read_cursor(
    conv_id: str,
    payload: ReadCursorUpdate,
    token_payload: dict[str, Any] = Depends(get_current_user_token),
):
    user_id = token_payload.get("sub", "")
    messenger_service.update_read_cursor(str(conv_id), user_id, str(payload.last_read_message_id))
    return {"status": "SUCCESS"}


@router.websocket("/ws")
async def messenger_websocket(websocket: WebSocket):
    """
    Schema-validated WebSocket connection for live travel messaging.
    """
    await websocket.accept()
    try:
        while True:
            data = await websocket.receive_text()
            cmd = json.loads(data)
            cmd_type = cmd.get("type")

            if cmd_type == "message.send":
                conv_id = cmd.get("conversation_id")
                client_msg_id = cmd.get("client_message_id")
                text = cmd.get("text", "")
                sender_name = cmd.get("sender_name", "Traveller")
                sender_id = cmd.get("sender_id", str(uuid.uuid4()))

                if conv_id and client_msg_id:
                    msg_create = ChatMessageCreate(
                        client_message_id=client_msg_id,
                        text_content=text,
                    )
                    saved = messenger_service.send_message(conv_id, sender_id, sender_name, msg_create)

                    ack = {
                        "type": "message.accepted",
                        "conversation_id": conv_id,
                        "client_message_id": client_msg_id,
                        "message_id": saved["id"],
                        "created_at": saved["created_at"].isoformat() if hasattr(saved["created_at"], "isoformat") else str(saved["created_at"]),
                    }
                    await websocket.send_text(json.dumps(ack))

            elif cmd_type == "ping":
                await websocket.send_text(json.dumps({"type": "pong"}))

    except WebSocketDisconnect:
        pass
