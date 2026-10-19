import uuid
from datetime import datetime

from pydantic import BaseModel


class AuditEventResponse(BaseModel):
    id: uuid.UUID
    actor_id: uuid.UUID
    actor_email: str
    actor_role: str
    action: str
    resource_type: str
    resource_id: str
    previous_state: str | None
    new_state: str | None
    reason: str
    created_at: datetime

    model_config = {"from_attributes": True}
