import uuid
from datetime import datetime, time, timezone
from typing import Any, Dict, List, Optional
from pydantic import BaseModel, Field


class HardError(BaseModel):
    code: str
    message: str
    affected_item_ids: List[uuid.UUID] = []
    details: Dict[str, Any] = {}


class WarningItem(BaseModel):
    code: str
    message: str
    affected_item_ids: List[uuid.UUID] = []
    source: str = "SYSTEM_ESTIMATE"
    details: Dict[str, Any] = {}


class ValidationResult(BaseModel):
    is_valid: bool
    hard_errors: List[HardError] = []
    warnings: List[WarningItem] = []
    evaluated_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
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
    opening_time: Optional[time] = None
    closing_time: Optional[time] = None


class DependencyEdgeValidationInput(BaseModel):
    source_item_id: uuid.UUID
    target_item_id: uuid.UUID
    dependency_type: str
    min_buffer_minutes: int = 30
