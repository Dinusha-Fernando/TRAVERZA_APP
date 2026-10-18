import uuid
from datetime import datetime, timedelta, timezone
import pytest
from app.core.errors import ForbiddenException, QuoteExpiredException
from app.core.security import TenantContext
from app.modules.trips.models import ItineraryItem
from app.modules.trips.router import derive_trip_status


@pytest.mark.asyncio
async def test_tenant_context_denies_cross_tenant_access():
    """Gate 2: Provider A cannot access Provider B resources."""
    provider_a_org_id = uuid.uuid4()
    provider_b_org_id = uuid.uuid4()

    # User belongs only to Provider A
    token_payload = {
        "sub": str(uuid.uuid4()),
        "role": "PROVIDER",
        "org_ids": [str(provider_a_org_id)],
    }

    tenant_guard = TenantContext()

    # Accessing Provider A succeeds
    resolved_org = await tenant_guard(
        token_payload=token_payload,
        x_organization_id=str(provider_a_org_id),
        db=None,
    )
    assert resolved_org == provider_a_org_id

    # Accessing Provider B raises ForbiddenException
    with pytest.raises(ForbiddenException):
        await tenant_guard(
            token_payload=token_payload,
            x_organization_id=str(provider_b_org_id),
            db=None,
        )


def test_truthful_trip_readiness_gate_6():
    """Gate 6: Partial confirmation is explicit; never claims fully CONFIRMED."""
    day_id = uuid.uuid4()

    # 1. Trip with 1 Confirmed and 1 Request Submitted
    item1 = ItineraryItem(
        day_id=day_id,
        title="Boutique Stay",
        category="STAY",
        start_time=datetime.min.time(),
        end_time=datetime.min.time(),
        latitude=7.2,
        longitude=80.6,
        requires_booking=True,
        booking_status="CONFIRMED",
    )
    item2 = ItineraryItem(
        day_id=day_id,
        title="Sigiriya Chauffeur Transfer",
        category="TRANSFER",
        start_time=datetime.min.time(),
        end_time=datetime.min.time(),
        latitude=7.9,
        longitude=80.7,
        requires_booking=True,
        booking_status="REQUEST_SUBMITTED",
    )

    status = derive_trip_status([item1, item2])
    assert status == "PARTIALLY_CONFIRMED"
    assert status != "CONFIRMED"

    # 2. Both confirmed
    item2.booking_status = "CONFIRMED"
    status_fully_confirmed = derive_trip_status([item1, item2])
    assert status_fully_confirmed == "CONFIRMED"
