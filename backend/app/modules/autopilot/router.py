import uuid
from typing import Any

from fastapi import APIRouter, Depends, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.core.database import get_db
from app.core.security import get_current_user_token
from app.modules.autopilot.engine import JourneyAutopilotEngine
from app.modules.autopilot.models import AutopilotProposal, DisruptionEvent
from app.modules.autopilot.schemas import (
    AutopilotProposalResponse,
    AutopilotRunResult,
    DisruptionEventCreate,
    DisruptionEventResponse,
    ProposalAuthorizationRequest,
)

router = APIRouter(prefix="/autopilot", tags=["Journey Autopilot (TRAVERZA 2.0)"])


@router.post("/events", response_model=AutopilotRunResult, status_code=status.HTTP_201_CREATED)
@router.post("/telemetry/ingest", response_model=AutopilotRunResult, status_code=status.HTTP_201_CREATED)
async def ingest_disruption_event(
    req: DisruptionEventCreate,
    token_payload: dict[str, Any] = Depends(get_current_user_token),
    db: AsyncSession = Depends(get_db),
):
    """
    Step 1 (Observe), Step 2 (Assess), & Step 3 (Propose):
    Consumes a verified disruption event from live telemetry (DMC weather, flight radar, driver dispatch),
    performs downstream impact assessment, and returns viable candidate proposals.
    """
    event = await JourneyAutopilotEngine.observe_disruption_event(db, req)
    proposals = await JourneyAutopilotEngine.assess_and_propose(db, event)
    await db.commit()

    return AutopilotRunResult(
        trip_id=event.trip_id,
        disruption_event=DisruptionEventResponse.from_orm_model(event),
        assessment_summary=f"Autopilot assessed {event.event_type} disruption ({event.severity}). Generated {len(proposals)} viable candidate proposal(s).",
        affected_items_count=1 if proposals else 0,
        proposals_generated=[AutopilotProposalResponse.from_orm_model(p) for p in proposals],
    )


@router.get("/trips/{trip_id}/events", response_model=list[DisruptionEventResponse])
async def list_trip_disruption_events(
    trip_id: uuid.UUID,
    token_payload: dict[str, Any] = Depends(get_current_user_token),
    db: AsyncSession = Depends(get_db),
):
    """Lists all disruption events recorded for a trip."""
    stmt = (
        select(DisruptionEvent)
        .where(DisruptionEvent.trip_id == trip_id)
        .order_by(DisruptionEvent.created_at.desc())
    )
    res = await db.execute(stmt)
    events = res.scalars().all()
    return [DisruptionEventResponse.from_orm_model(e) for e in events]


@router.get("/trips/{trip_id}/proposals", response_model=list[AutopilotProposalResponse])
async def list_trip_proposals(
    trip_id: uuid.UUID,
    token_payload: dict[str, Any] = Depends(get_current_user_token),
    db: AsyncSession = Depends(get_db),
):
    """Lists all active and historical Autopilot candidate proposals for a trip."""
    stmt = (
        select(AutopilotProposal)
        .where(AutopilotProposal.trip_id == trip_id)
        .order_by(AutopilotProposal.created_at.desc())
    )
    res = await db.execute(stmt)
    proposals = res.scalars().all()
    return [AutopilotProposalResponse.from_orm_model(p) for p in proposals]


@router.post("/proposals/{proposal_id}/authorize", response_model=AutopilotProposalResponse)
async def authorize_autopilot_proposal(
    proposal_id: uuid.UUID,
    req: ProposalAuthorizationRequest,
    token_payload: dict[str, Any] = Depends(get_current_user_token),
    db: AsyncSession = Depends(get_db),
):
    """
    Step 4 (Authorize), Step 5 (Execute), & Step 6 (Verify):
    Traveller or Operations authorized action. Executes proposal mutations idempotently
    and verifies with TripGraph to guarantee mathematical feasibility.
    """
    user_id = uuid.UUID(token_payload["sub"])
    proposal = await JourneyAutopilotEngine.execute_authorized_proposal(
        db=db,
        proposal_id=proposal_id,
        authorized_by_id=user_id,
        decision=req.decision,
        rejection_reason=req.rejection_reason,
    )
    return AutopilotProposalResponse.from_orm_model(proposal)
