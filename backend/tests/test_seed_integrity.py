import pytest
from sqlalchemy import func, select

from app.core.seed import seed_database
from app.modules.catalogue.models import Destination, Listing, Place
from app.modules.identity.models import Organization, User
from app.modules.support.models import SupportCase
from app.modules.trips.models import Trip


@pytest.mark.asyncio
async def test_seed_database_integrity(test_db):
    """Verify that seed_database executes cleanly and populates all tables with correct relationships."""
    await seed_database(test_db)

    # 1. Verify Users & Orgs
    user_count = (await test_db.execute(select(func.count(User.id)))).scalar()
    assert user_count >= 5

    org_count = (await test_db.execute(select(func.count(Organization.id)))).scalar()
    assert org_count == 3

    # 2. Verify Corridor Destinations & Listings
    dest_count = (await test_db.execute(select(func.count(Destination.id)))).scalar()
    assert dest_count == 4

    place_count = (await test_db.execute(select(func.count(Place.id)))).scalar()
    assert place_count == 4

    listing_count = (await test_db.execute(select(func.count(Listing.id)))).scalar()
    assert listing_count == 4

    # 3. Verify Trip Canvas
    trip = (await test_db.execute(select(Trip))).scalars().first()
    assert trip is not None
    assert trip.status == "PARTIALLY_CONFIRMED"
    assert "Cultural Highlands" in trip.title

    # 4. Verify Exception Desk
    case_count = (await test_db.execute(select(func.count(SupportCase.id)))).scalar()
    assert case_count == 3
