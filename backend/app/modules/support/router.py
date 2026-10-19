import uuid
from typing import Any

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.errors import NotFoundException
from app.core.security import get_current_user_token
from app.modules.support.models import SupportCase
from app.modules.support.schemas import (
    SupportCaseCreateRequest,
    SupportCaseResolveRequest,
    SupportCaseResponse,
)

router = APIRouter(prefix="/support", tags=["Support & Exception Desk"])


@router.get("/cases", response_model=list[SupportCaseResponse])
async def list_support_cases(
    status_filter: str | None = Query(None, alias="status"),
    severity: str | None = Query(None),
    token_payload: dict[str, Any] = Depends(get_current_user_token),
    db: AsyncSession = Depends(get_db),
):
    query = select(SupportCase).order_by(SupportCase.created_at.desc())
    if status_filter:
        query = query.where(SupportCase.status == status_filter)
    if severity:
        query = query.where(SupportCase.severity == severity)

    res = await db.execute(query)
    return res.scalars().all()


@router.get("/cases/{case_id}", response_model=SupportCaseResponse)
async def get_support_case(
    case_id: uuid.UUID,
    token_payload: dict[str, Any] = Depends(get_current_user_token),
    db: AsyncSession = Depends(get_db),
):
    case = await db.get(SupportCase, case_id)
    if not case:
        raise NotFoundException("SupportCase", case_id)
    return case


@router.post("/cases", response_model=SupportCaseResponse, status_code=status.HTTP_201_CREATED)
async def create_support_case(
    req: SupportCaseCreateRequest,
    token_payload: dict[str, Any] = Depends(get_current_user_token),
    db: AsyncSession = Depends(get_db),
):
    user_id = uuid.UUID(token_payload["sub"])
    case = SupportCase(
        trip_id=req.trip_id,
        booking_id=req.booking_id,
        reported_by_id=user_id,
        category=req.category,
        severity=req.severity,
        summary=req.summary,
        description=req.description,
        status="OPEN",
    )
    db.add(case)
    await db.commit()
    await db.refresh(case)
    return case


@router.patch("/cases/{case_id}/resolve", response_model=SupportCaseResponse)
async def resolve_support_case(
    case_id: uuid.UUID,
    req: SupportCaseResolveRequest,
    token_payload: dict[str, Any] = Depends(get_current_user_token),
    db: AsyncSession = Depends(get_db),
):
    case = await db.get(SupportCase, case_id)
    if not case:
        raise NotFoundException("SupportCase", case_id)

    case.status = req.status
    case.resolution_notes = req.resolution_notes
    await db.commit()
    await db.refresh(case)
    return case
