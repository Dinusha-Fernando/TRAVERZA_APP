import uuid

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.security import TenantContext
from app.modules.catalogue.models import Destination, Listing, Place
from app.modules.catalogue.schemas import (
    DestinationResponse,
    ListingCreateRequest,
    ListingResponse,
    PlaceResponse,
)

router = APIRouter(prefix="/catalogue", tags=["Catalogue & Discovery"])


@router.get("/destinations", response_model=list[DestinationResponse])
async def list_destinations(
    corridor: str | None = Query(None),
    db: AsyncSession = Depends(get_db),
):
    query = select(Destination)
    if corridor:
        query = query.where(Destination.corridor_name == corridor)
    result = await db.execute(query)
    return result.scalars().all()


@router.get("/destinations/{slug_or_id}", response_model=DestinationResponse)
async def get_destination(
    slug_or_id: str,
    db: AsyncSession = Depends(get_db),
):
    try:
        dest_uuid = uuid.UUID(slug_or_id)
        stmt = select(Destination).where(Destination.id == dest_uuid)
    except ValueError:
        stmt = select(Destination).where(Destination.slug == slug_or_id)

    result = await db.execute(stmt)
    dest = result.scalar_one_or_none()
    if not dest:
        from app.core.errors import NotFoundException
        raise NotFoundException("Destination", slug_or_id)
    return dest


@router.get("/destinations/{destination_id}/places", response_model=list[PlaceResponse])
async def list_places_by_destination(
    destination_id: uuid.UUID,
    db: AsyncSession = Depends(get_db),
):
    query = select(Place).where(Place.destination_id == destination_id)
    result = await db.execute(query)
    return result.scalars().all()


@router.get("/listings", response_model=list[ListingResponse])
async def list_published_listings(
    category: str | None = Query(None),
    destination_id: uuid.UUID | None = Query(None),
    db: AsyncSession = Depends(get_db),
):
    query = select(Listing).where(Listing.is_published.is_(True))
    if category:
        query = query.where(Listing.category == category)
    if destination_id:
        query = query.where(Listing.destination_id == destination_id)

    result = await db.execute(query)
    return result.scalars().all()


@router.get("/listings/{listing_id}", response_model=ListingResponse)
async def get_listing(
    listing_id: uuid.UUID,
    db: AsyncSession = Depends(get_db),
):
    listing = await db.get(Listing, listing_id)
    if not listing:
        from app.core.errors import NotFoundException
        raise NotFoundException("Listing", listing_id)
    return listing


# Provider-scoped listing management
@router.post("/provider/listings", response_model=ListingResponse, status_code=status.HTTP_201_CREATED)
async def create_provider_listing(
    req: ListingCreateRequest,
    org_id: uuid.UUID = Depends(TenantContext()),
    db: AsyncSession = Depends(get_db),
):
    listing = Listing(
        organization_id=org_id,
        destination_id=req.destination_id,
        title=req.title,
        category=req.category,
        description=req.description,
        base_price_minor=req.base_price_minor,
        currency=req.currency,
        cancellation_policy=req.cancellation_policy,
        is_published=False,  # Moderation gate
    )
    db.add(listing)
    await db.commit()
    await db.refresh(listing)
    return listing
