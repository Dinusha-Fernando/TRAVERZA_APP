import json
import uuid
from datetime import datetime
from typing import Any

from pydantic import BaseModel, ConfigDict, Field


class DisruptionEventCreate(BaseModel):
    trip_id: uuid.UUID
    event_type: str = Field(..., description="FLIGHT_DELAY, WEATHER_ROAD_DISRUPTION, DRIVER_CANCEL, PROVIDER_UNRESPONSIVE, VENUE_OVERLAP")
    severity: str = Field("MEDIUM", description="INFO, LOW, MEDIUM, HIGH, CRITICAL")
    source: str = Field(..., description="Verified feed or reporting entity, e.g. 'SRILANKAN_AIRLINES_FEED'")
    summary: str
    details: dict[str, Any] = Field(default_factory=dict)
    idempotency_key: str
    delay_minutes: int | None = None


class DisruptionEventResponse(BaseModel):
    id: uuid.UUID
    trip_id: uuid.UUID
    event_type: str
    severity: str
    source: str
    observed_at: datetime
    valid_until: datetime | None = None
    freshness_seconds: int = 0
    summary: str
    details: dict[str, Any] = Field(default_factory=dict)
    status: str
    idempotency_key: str
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)

    @classmethod
    def from_orm_model(cls, obj: Any) -> "DisruptionEventResponse":
        try:
            details_dict = json.loads(obj.details_json) if obj.details_json else {}
        except Exception:
            details_dict = {}

        return cls(
            id=obj.id,
            trip_id=obj.trip_id,
            event_type=obj.event_type,
            severity=obj.severity,
            source=obj.source,
            observed_at=obj.observed_at,
            valid_until=obj.valid_until,
            freshness_seconds=obj.freshness_seconds,
            summary=obj.summary,
            details=details_dict,
            status=obj.status,
            idempotency_key=obj.idempotency_key,
            created_at=obj.created_at,
        )


class AutopilotProposalResponse(BaseModel):
    id: uuid.UUID
    trip_id: uuid.UUID
    disruption_event_id: uuid.UUID
    title: str
    explanation: str
    timing_delta_minutes: int
    cost_delta_minor: int
    cost_delta_lkr: float
    currency: str
    confidence_score: float
    proposed_actions: list[dict[str, Any]]
    requires_authorization: bool
    authorization_status: str
    authorized_by_id: uuid.UUID | None = None
    authorized_at: datetime | None = None
    execution_notes: str | None = None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)

    @classmethod
    def from_orm_model(cls, obj: Any) -> "AutopilotProposalResponse":
        try:
            actions_list = json.loads(obj.proposed_actions_json) if obj.proposed_actions_json else []
        except Exception:
            actions_list = []

        return cls(
            id=obj.id,
            trip_id=obj.trip_id,
            disruption_event_id=obj.disruption_event_id,
            title=obj.title,
            explanation=obj.explanation,
            timing_delta_minutes=obj.timing_delta_minutes,
            cost_delta_minor=obj.cost_delta_minor,
            cost_delta_lkr=round(obj.cost_delta_minor / 100.0, 2),
            currency=obj.currency,
            confidence_score=obj.confidence_score,
            proposed_actions=actions_list,
            requires_authorization=obj.requires_authorization,
            authorization_status=obj.authorization_status,
            authorized_by_id=obj.authorized_by_id,
            authorized_at=obj.authorized_at,
            execution_notes=obj.execution_notes,
            created_at=obj.created_at,
        )


class ProposalAuthorizationRequest(BaseModel):
    decision: str = Field(..., description="'APPROVE' or 'REJECT'")
    rejection_reason: str | None = None


class AutopilotRunResult(BaseModel):
    trip_id: uuid.UUID
    disruption_event: DisruptionEventResponse
    assessment_summary: str
    affected_items_count: int
    proposals_generated: list[AutopilotProposalResponse]
