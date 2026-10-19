import uuid
from datetime import datetime

from pydantic import BaseModel


class SupportCaseCreateRequest(BaseModel):
    trip_id: uuid.UUID | None = None
    booking_id: uuid.UUID | None = None
    category: str
    severity: str = "MEDIUM"  # 'LOW', 'MEDIUM', 'HIGH', 'CRITICAL'
    summary: str
    description: str


class SupportCaseResolveRequest(BaseModel):
    resolution_notes: str
    status: str = "RESOLVED"  # 'RESOLVED', 'CLOSED'


class SupportCaseResponse(BaseModel):
    id: uuid.UUID
    trip_id: uuid.UUID | None
    booking_id: uuid.UUID | None
    reported_by_id: uuid.UUID
    assigned_staff_id: uuid.UUID | None
    severity: str
    status: str
    category: str
    summary: str
    description: str
    resolution_notes: str | None
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}
