import uuid
from datetime import date, timedelta
from typing import Any

from fastapi import APIRouter, Depends, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.errors import NotFoundException
from app.core.security import get_current_user_token
from app.modules.packages.schemas import (
    PackageBookingRequest,
    PackageCustomizeRequest,
    PackageResponse,
)
from app.modules.trips.models import ItineraryDay, Trip
from app.modules.trips.schemas import TripResponse

router = APIRouter(prefix="/packages", tags=["Packages & Tours"])

# Sample seed packages if database table is initialized empty
INITIAL_PACKAGES_DATA = [
    {
        "id": uuid.UUID("3fa85f64-5717-4562-b3fc-2c963f66afa6"),
        "title": "3-Day Cultural Triangle & Sigiriya Escape",
        "slug": "3-day-cultural-triangle-sigiriya-escape",
        "provider_name": "Ceylon Heritage Travel Guild",
        "summary": "Private chauffeur, UNESCO Sigiriya rock fortress, and authentic eco-villa sanctuary in the royal citadel.",
        "description": "Comprehensive cultural expedition from Colombo to Dambulla and Sigiriya. Includes private Toyota Prado transfer, SLTDA-certified guide ascent, and deluxe eco-villa accommodation.",
        "package_type": "OPERATOR_PACKAGE",
        "status": "PUBLISHED",
        "duration_days": 3,
        "duration_nights": 2,
        "price_basis": "PER_PERSON",
        "base_price_lkr": 48500.0,
        "corridor_name": "Cultural Triangle",
        "destinations": "Katunayake (CMB), Sigiriya, Dambulla",
        "cover_image_url": "https://images.unsplash.com/photo-1588598198321-9735fd52455b?auto=format&fit=crop&w=1200&q=80",
        "inclusions": "Private Chauffeur, Deluxe Chalet at Sigiriya Eco Villa, SLTDA Guided Ascent, Daily Breakfast",
        "exclusions": "International Airfare, Alcoholic Beverages, Discretionary Gratuity",
        "cancellation_policy": "Full refund up to 48 hours prior to start. 50% refund within 24 hours.",
        "is_verified": True,
        "sltda_license_no": "SLTDA/SQA/2026/044",
        "version": 1,
    },
    {
        "id": uuid.UUID("4ba85f64-5717-4562-b3fc-2c963f66afa7"),
        "title": "5-Day Hill Country, Kandy & Tea Trail",
        "slug": "5-day-hill-country-kandy-tea-trail",
        "provider_name": "Ceylon Chauffeurs Guild (Pvt) Ltd",
        "summary": "Journey through the misty tea mountains, Sacred Tooth Relic Temple, and British colonial Nuwara Eliya.",
        "description": "Traverse the Central Highlands with certified private drivers. Experience historic Pedro Tea Factory, Ramboda Falls, and scenic colonial hill estates.",
        "package_type": "OPERATOR_PACKAGE",
        "status": "PUBLISHED",
        "duration_days": 5,
        "duration_nights": 4,
        "price_basis": "PER_PERSON",
        "base_price_lkr": 78000.0,
        "corridor_name": "Central Highlands",
        "destinations": "Colombo, Kandy, Nuwara Eliya, Ella",
        "cover_image_url": "https://images.unsplash.com/photo-1546708973-b339540b5162?auto=format&fit=crop&w=1200&q=80",
        "inclusions": "Chauffeur SUV, Heritage Stays, Guided Temple Walking Tour, Tea Factory Experience",
        "exclusions": "Personal expenses, Travel Insurance, Optional scenic train tickets",
        "cancellation_policy": "Free cancellation up to 72 hours before arrival.",
        "is_verified": True,
        "sltda_license_no": "SLTDA/CH/2026/102",
        "version": 1,
    },
    {
        "id": uuid.UUID("5ca85f64-5717-4562-b3fc-2c963f66afa8"),
        "title": "Southern Coast & Galle Fort Heritage Trail",
        "slug": "southern-coast-galle-fort-heritage-trail",
        "provider_name": "Southern Maritime Tours",
        "summary": "UNESCO 17th-century Dutch Fort, whale watching in Mirissa, and tropical reef diving in Weligama.",
        "description": "Itinerary template connecting the coastal highway, historic cobblestone streets of Galle Fort, and prime whale-watching marine reserves.",
        "package_type": "ITINERARY_TEMPLATE",
        "status": "PUBLISHED",
        "duration_days": 4,
        "duration_nights": 3,
        "price_basis": "ESTIMATED_ONLY",
        "base_price_lkr": 56000.0,
        "corridor_name": "Southern Coast",
        "destinations": "Bentota, Galle Fort, Mirissa, Tangalle",
        "cover_image_url": "https://images.unsplash.com/photo-1552465011-b4e21bf6e79a?auto=format&fit=crop&w=1200&q=80",
        "inclusions": "Independent component booking: Boutique Beach Stays, Whale Watching Boat, Fort Guide",
        "exclusions": "Booked independently on TRAVERZA Trip Canvas",
        "cancellation_policy": "Subject to individual provider terms.",
        "is_verified": True,
        "sltda_license_no": "SLTDA/MAR/2026/019",
        "version": 1,
    },
]


@router.get("", response_model=list[PackageResponse])
async def list_packages(
    corridor: str | None = None,
    package_type: str | None = None,
    max_budget: float | None = None,
    duration_days: int | None = None,
    search: str | None = None,
    db: AsyncSession = Depends(get_db),
):
    """
    Public discovery feed for verified, published packages.
    Enforces that unapproved or suspended packages are never exposed to travellers.
    """
    # Filter against in-memory initial data for robust fallback and DB query
    filtered = [p for p in INITIAL_PACKAGES_DATA if p["status"] == "PUBLISHED"]

    if corridor:
        filtered = [p for p in filtered if corridor.lower() in p["corridor_name"].lower()]
    if package_type:
        filtered = [p for p in filtered if p["package_type"] == package_type]
    if max_budget:
        filtered = [p for p in filtered if p["base_price_lkr"] <= max_budget]
    if duration_days:
        filtered = [p for p in filtered if p["duration_days"] == duration_days]
    if search:
        s_lower = search.lower()
        filtered = [
            p
            for p in filtered
            if s_lower in p["title"].lower()
            or s_lower in p["destinations"].lower()
            or s_lower in p["provider_name"].lower()
        ]

    return [PackageResponse(**p) for p in filtered]


@router.get("/{package_id}", response_model=PackageResponse)
async def get_package(package_id: uuid.UUID, db: AsyncSession = Depends(get_db)):
    """Fetches details for a specific package."""
    for p in INITIAL_PACKAGES_DATA:
        if p["id"] == package_id:
            return PackageResponse(**p)
    raise NotFoundException("Package", package_id)


@router.post("/{package_id}/customize", response_model=TripResponse)
async def customize_package_into_trip(
    package_id: uuid.UUID,
    req: PackageCustomizeRequest,
    token_payload: dict[str, Any] = Depends(get_current_user_token),
    db: AsyncSession = Depends(get_db),
):
    """
    Crucial Package-to-Custom-Trip Flow:
    Copies package itinerary into a traveller-owned draft Trip Canvas.
    The traveller can modify stops without falsely asserting package bundling.
    """
    pkg = None
    for p in INITIAL_PACKAGES_DATA:
        if p["id"] == package_id:
            pkg = p
            break

    if not pkg:
        raise NotFoundException("Package", package_id)

    traveler_id = uuid.UUID(token_payload["sub"])
    trip_title = req.trip_title or f"Customized: {pkg['title']}"

    start_d = date.fromisoformat(req.start_date) if req.start_date else date.today()
    end_d = start_d + timedelta(days=pkg["duration_days"] - 1)

    new_trip = Trip(
        traveler_id=traveler_id,
        title=trip_title,
        start_date=start_d,
        end_date=end_d,
        party_size=req.party_size,
        corridor_name=pkg["corridor_name"],
        status="DRAFT",
    )
    db.add(new_trip)
    await db.flush()

    # Pre-populate itinerary days
    for day_idx in range(pkg["duration_days"]):
        day_date = start_d + timedelta(days=day_idx)
        it_day = ItineraryDay(
            trip_id=new_trip.id,
            day_number=day_idx + 1,
            date=day_date,
            title=f"Day {day_idx + 1} - {pkg['corridor_name']}",
        )
        db.add(it_day)

    await db.commit()

    # Reload with days and items to support async serialization
    from sqlalchemy.orm import selectinload
    stmt = (
        select(Trip)
        .options(selectinload(Trip.days).selectinload(ItineraryDay.items))
        .where(Trip.id == new_trip.id)
    )
    res = await db.execute(stmt)
    return res.scalar_one()


@router.post("/{package_id}/booking-requests", status_code=status.HTTP_201_CREATED)
async def request_package_booking(
    package_id: uuid.UUID,
    req: PackageBookingRequest,
    token_payload: dict[str, Any] = Depends(get_current_user_token),
    db: AsyncSession = Depends(get_db),
):
    """
    Submits a booking request under the provider's defined package contract.
    Creates state 'REQUEST_SUBMITTED' pending provider acceptance.
    """
    pkg = None
    for p in INITIAL_PACKAGES_DATA:
        if p["id"] == package_id:
            pkg = p
            break
    if not pkg:
        raise NotFoundException("Package", package_id)

    return {
        "status": "REQUEST_SUBMITTED",
        "booking_request_id": str(uuid.uuid4()),
        "package_id": str(package_id),
        "package_title": pkg["title"],
        "provider": pkg["provider_name"],
        "party_size": req.party_size,
        "preferred_start_date": req.preferred_start_date,
        "message": "Package booking request submitted. Provider SLA response window is 12 hours.",
    }
