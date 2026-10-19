from typing import Any

from fastapi import APIRouter, Depends, Query
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.security import get_current_user_token
from app.modules.audit.models import AuditEvent
from app.modules.audit.schemas import AuditEventResponse

router = APIRouter(prefix="/audit", tags=["Audit & Compliance"])


@router.get("/events", response_model=list[AuditEventResponse])
async def list_audit_events(
    action: str | None = Query(None),
    resource_type: str | None = Query(None),
    limit: int = Query(50, le=200),
    token_payload: dict[str, Any] = Depends(get_current_user_token),
    db: AsyncSession = Depends(get_db),
):
    query = select(AuditEvent).order_by(AuditEvent.created_at.desc()).limit(limit)
    if action:
        query = query.where(AuditEvent.action == action)
    if resource_type:
        query = query.where(AuditEvent.resource_type == resource_type)

    res = await db.execute(query)
    return res.scalars().all()
