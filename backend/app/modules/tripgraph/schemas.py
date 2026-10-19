import uuid
from datetime import UTC, datetime, time
from typing import Any

from pydantic import BaseModel, Field


class HardError(BaseModel):
    code: str
    message: str
    affected_item_ids: list[uuid.UUID] = []
    details: dict[str, Any] = {}


class WarningItem(BaseModel):
    code: str
    message: str
    affected_item_ids: list[uuid.UUID] = []
    source: str = "SYSTEM_ESTIMATE"
    details: dict[str, Any] = {}


class ValidationResult(BaseModel):
    is_valid: bool
    hard_errors: list[HardError] = []
    warnings: list[WarningItem] = []
    evaluated_at: datetime = Field(default_factory=lambda: datetime.now(UTC))
    summary: str


class ItineraryItemValidationInput(BaseModel):
    id: uuid.UUID
    day_number: int
    title: str
    start_time: time
    end_time: time
    latitude: float
    longitude: float
    category: str  # 'FLIGHT', 'TRANSFER', 'STAY', 'ACTIVITY', 'DINING'
    is_fixed_time: bool = True
    provider_confirmed: bool = False
    opening_time: time | None = None
    closing_time: time | None = None


class DependencyEdgeValidationInput(BaseModel):
    source_item_id: uuid.UUID
    target_item_id: uuid.UUID
    dependency_type: str
    min_buffer_minutes: int = 30
