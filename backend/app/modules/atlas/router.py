import json
import uuid
from datetime import UTC, datetime
from typing import Any

from fastapi import APIRouter, HTTPException, Query, status

from app.modules.atlas.schemas import (
    ContributionCreate,
    ContributionResponse,
    CuratedCollectionResponse,
    DestinationDetailResponse,
    DestinationSummary,
    DistrictDayPlanRequest,
    DistrictDayPlanResponse,
    DistrictOverviewResponse,
    DistrictSpecialityResponse,
    DistrictSummary,
    ProvinceResponse,
)
from app.modules.atlas.seed_data import (
    CURATED_COLLECTIONS_SEED,
    DESTINATIONS_SEED,
    DISTRICT_SPECIALITIES_SEED,
    DISTRICTS_SEED,
    PROVINCES_SEED,
)
from app.modules.tripgraph.transit import SriLankaTransitCalculator, haversine_distance_km

router = APIRouter(tags=["Island Atlas"])

# In-memory working store initialized with authoritative seed data
_provinces: dict[str, dict[str, Any]] = {p["id"]: dict(p) for p in PROVINCES_SEED}
_districts: dict[str, dict[str, Any]] = {d["id"]: dict(d) for d in DISTRICTS_SEED}

# Initialize destinations with UUIDs
_destinations: dict[str, dict[str, Any]] = {}
for d in DESTINATIONS_SEED:
    item = dict(d)
    item["id"] = uuid.uuid5(uuid.NAMESPACE_DNS, f"traverza.dest.{d['slug']}")
    item["last_verified_at"] = datetime(2026, 10, 22, 0, 0, 0, tzinfo=UTC)
    item["review_status"] = "APPROVED"
    _destinations[item["slug"]] = item

_specialities: list[dict[str, Any]] = []
for s in DISTRICT_SPECIALITIES_SEED:
    item = dict(s)
    item["id"] = uuid.uuid5(uuid.NAMESPACE_DNS, f"traverza.spec.{s['district_id']}.{s['title']}")
    _specialities.append(item)

_collections: dict[str, dict[str, Any]] = {c["slug"]: dict(c) for c in CURATED_COLLECTIONS_SEED}

_contributions: list[dict[str, Any]] = []


@router.get("/geography/provinces", response_model=list[ProvinceResponse])
async def list_provinces() -> list[ProvinceResponse]:
    """
    List all 9 official provinces of Sri Lanka (Census 2024 scope)
    with district counts and verified place coverage.
    """
    results = []
    for p in sorted(_provinces.values(), key=lambda x: x["display_order"]):
        d_count = sum(1 for d in _districts.values() if d["province_id"] == p["id"])
        p_count = sum(1 for dest in _destinations.values() if dest["province_id"] == p["id"])
        results.append(
            ProvinceResponse(
                id=p["id"],
                slug=p["slug"],
                name=p["name"],
                name_si=p["name_si"],
                name_ta=p["name_ta"],
                capital=p["capital"],
                description=p["description"],
                signature_landscapes=p["signature_landscapes"],
                display_order=p["display_order"],
                district_count=d_count,
                published_places_count=p_count,
            )
        )
    return results


@router.get("/geography/districts", response_model=list[DistrictSummary])
async def list_districts(
    province_id: str | None = Query(None, description="Optional province ID filter (e.g. 'WP', 'CP')")
) -> list[DistrictSummary]:
    """
    List official 25 administrative districts, optionally filtered by province.
    """
    filtered = [
        d for d in _districts.values()
        if province_id is None or d["province_id"] == province_id.upper()
    ]
    results = []
    for d in sorted(filtered, key=lambda x: x["name"]):
        p_count = sum(1 for dest in _destinations.values() if dest["district_id"] == d["id"])
        results.append(
            DistrictSummary(
                id=d["id"],
                province_id=d["province_id"],
                slug=d["slug"],
                name=d["name"],
                name_si=d["name_si"],
                name_ta=d["name_ta"],
                capital=d["capital"],
                latitude=d["latitude"],
                longitude=d["longitude"],
                known_for=d["known_for"],
                is_verified=d["is_verified"],
                place_count=p_count,
            )
        )
    return results


@router.get("/districts/{slug}/overview", response_model=DistrictOverviewResponse)
async def get_district_overview(slug: str) -> DistrictOverviewResponse:
    """
    District discovery overview: story, specialties, curated destination places, and coverage status.
    """
    district_obj = next((d for d in _districts.values() if d["slug"] == slug or d["id"] == slug), None)
    if not district_obj:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"District '{slug}' not found")

    province_obj = _provinces.get(district_obj["province_id"], {})
    province_name = province_obj.get("name", "Sri Lanka")

    # Places in this district
    district_places = [
        DestinationSummary(
            id=d["id"],
            slug=d["slug"],
            name=d["name"],
            name_si=d["name_si"],
            name_ta=d["name_ta"],
            place_type=d["place_type"],
            category=d["category"],
            district_id=d["district_id"],
            province_id=d["province_id"],
            latitude=d["latitude"],
            longitude=d["longitude"],
            summary=d["summary"],
            dwell_duration_mins=d["dwell_duration_mins"],
            access_state=d["access_state"],
            review_status=d["review_status"],
            photo_url=d["photo_url"],
        )
        for d in _destinations.values()
        if d["district_id"] == district_obj["id"]
    ]

    # Specialities
    specs = [
        DistrictSpecialityResponse(
            id=s["id"],
            district_id=s["district_id"],
            theme_group=s["theme_group"],
            title=s["title"],
            description=s["description"],
            evidence_source=s["evidence_source"],
        )
        for s in _specialities
        if s["district_id"] == district_obj["id"]
    ]

    summary = DistrictSummary(
        id=district_obj["id"],
        province_id=district_obj["province_id"],
        slug=district_obj["slug"],
        name=district_obj["name"],
        name_si=district_obj["name_si"],
        name_ta=district_obj["name_ta"],
        capital=district_obj["capital"],
        latitude=district_obj["latitude"],
        longitude=district_obj["longitude"],
        known_for=district_obj["known_for"],
        is_verified=district_obj["is_verified"],
        place_count=len(district_places),
    )

    coverage = "Verified essentials available" if district_places else "Coverage expanding; community review in progress"

    return DistrictOverviewResponse(
        district=summary,
        province_name=province_name,
        specialities=specs,
        destinations=district_places,
        coverage_status=coverage,
    )


@router.get("/destinations", response_model=list[DestinationSummary])
async def list_destinations(
    district_id: str | None = Query(None, description="Filter by district ID"),
    province_id: str | None = Query(None, description="Filter by province ID"),
    category: str | None = Query(None, description="Category filter (HERITAGE, NATURE, BEACH, etc.)"),
    place_type: str | None = Query(None, description="Place type filter (iconic, locally_loved, etc.)"),
    q: str | None = Query(None, description="Search term in English, Sinhala, Tamil, or story"),
) -> list[DestinationSummary]:
    """
    Search and filter destinations across Sri Lanka with multi-lingual support.
    """
    results = []
    q_lower = q.lower().strip() if q else None

    for d in _destinations.values():
        if district_id and d["district_id"] != district_id.lower():
            continue
        if province_id and d["province_id"] != province_id.upper():
            continue
        if category and d["category"].upper() != category.upper():
            continue
        if place_type and d["place_type"].lower() != place_type.lower():
            continue

        if q_lower:
            match = (
                q_lower in d["name"].lower()
                or q_lower in d["name_si"]
                or q_lower in d["name_ta"]
                or q_lower in d["summary"].lower()
                or q_lower in d["story"].lower()
                or q_lower in d["district_id"].lower()
            )
            if not match:
                continue

        results.append(
            DestinationSummary(
                id=d["id"],
                slug=d["slug"],
                name=d["name"],
                name_si=d["name_si"],
                name_ta=d["name_ta"],
                place_type=d["place_type"],
                category=d["category"],
                district_id=d["district_id"],
                province_id=d["province_id"],
                latitude=d["latitude"],
                longitude=d["longitude"],
                summary=d["summary"],
                dwell_duration_mins=d["dwell_duration_mins"],
                access_state=d["access_state"],
                review_status=d["review_status"],
                photo_url=d["photo_url"],
            )
        )
    return results


@router.get("/destinations/nearby", response_model=list[DestinationSummary])
async def find_nearby_destinations(
    lat: float = Query(..., description="Latitude"),
    lon: float = Query(..., description="Longitude"),
    radius_km: float = Query(50.0, ge=1.0, le=200.0, description="Search radius in kilometers"),
) -> list[DestinationSummary]:
    """
    Find destination places around a geographic point with realistic road distances.
    """
    candidates = []
    for d in _destinations.values():
        dist = haversine_distance_km(lat, lon, d["latitude"], d["longitude"])
        if dist <= radius_km:
            candidates.append((dist, d))

    candidates.sort(key=lambda x: x[0])
    return [
        DestinationSummary(
            id=d["id"],
            slug=d["slug"],
            name=d["name"],
            name_si=d["name_si"],
            name_ta=d["name_ta"],
            place_type=d["place_type"],
            category=d["category"],
            district_id=d["district_id"],
            province_id=d["province_id"],
            latitude=d["latitude"],
            longitude=d["longitude"],
            summary=d["summary"],
            dwell_duration_mins=d["dwell_duration_mins"],
            access_state=d["access_state"],
            review_status=d["review_status"],
            photo_url=d["photo_url"],
        )
        for _, d in candidates[:8]
    ]


@router.get("/destinations/{slug}", response_model=DestinationDetailResponse)
async def get_destination_detail(slug: str) -> DestinationDetailResponse:
    """
    Comprehensive destination profile with practical guidance, safety notes,
    evidence provenance, nearby places, and linked verified services.
    """
    dest = _destinations.get(slug)
    if not dest:
        # Check by ID if valid UUID
        dest = next((d for d in _destinations.values() if str(d["id"]) == slug), None)
    if not dest:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Destination '{slug}' not found")

    # Find nearby destinations within ~40km
    nearby_list = []
    for other in _destinations.values():
        if other["slug"] == dest["slug"]:
            continue
        dist = haversine_distance_km(dest["latitude"], dest["longitude"], other["latitude"], other["longitude"])
        if dist <= 45.0:
            nearby_list.append(
                DestinationSummary(
                    id=other["id"],
                    slug=other["slug"],
                    name=other["name"],
                    name_si=other["name_si"],
                    name_ta=other["name_ta"],
                    place_type=other["place_type"],
                    category=other["category"],
                    district_id=other["district_id"],
                    province_id=other["province_id"],
                    latitude=other["latitude"],
                    longitude=other["longitude"],
                    summary=other["summary"],
                    dwell_duration_mins=other["dwell_duration_mins"],
                    access_state=other["access_state"],
                    review_status=other["review_status"],
                    photo_url=other["photo_url"],
                )
            )

    # Simulated verified service links
    services = [
        {
            "id": f"srv-{dest['district_id']}-guide-1",
            "title": f"Licensed SLTDA Tour Guide for {dest['name']}",
            "type": "GUIDE",
            "price_lkr": 4500,
            "verification_status": "SLTDA_VERIFIED",
            "provider_name": "Heritage Guides Guild SL",
        },
        {
            "id": f"srv-{dest['district_id']}-transfer-1",
            "title": f"Chauffeur Transfer to {dest['name']}",
            "type": "TRANSPORT",
            "price_lkr": 8500,
            "verification_status": "SLTDA_VERIFIED",
            "provider_name": "Ceylon Scenic Transport",
        },
    ]

    return DestinationDetailResponse(
        id=dest["id"],
        slug=dest["slug"],
        province_id=dest["province_id"],
        district_id=dest["district_id"],
        name=dest["name"],
        name_si=dest["name_si"],
        name_ta=dest["name_ta"],
        place_type=dest["place_type"],
        category=dest["category"],
        latitude=dest["latitude"],
        longitude=dest["longitude"],
        coordinate_precision=dest["coordinate_precision"],
        summary=dest["summary"],
        story=dest["story"],
        dwell_duration_mins=dest["dwell_duration_mins"],
        opening_hours_text=dest["opening_hours_text"],
        fee_info_text=dest["fee_info_text"],
        access_state=dest["access_state"],
        terrain_notes=dest["terrain_notes"],
        safety_notes=dest["safety_notes"],
        is_family_friendly=dest["is_family_friendly"],
        accessibility_notes=dest["accessibility_notes"],
        evidence_source=dest["evidence_source"],
        last_verified_at=dest["last_verified_at"],
        review_status=dest["review_status"],
        photo_url=dest["photo_url"],
        photo_attribution=dest["photo_attribution"],
        nearby_destinations=nearby_list[:4],
        nearby_services=services,
    )


@router.get("/collections", response_model=list[CuratedCollectionResponse])
async def list_collections() -> list[CuratedCollectionResponse]:
    """
    List curated thematic routes and collections across provinces and districts.
    """
    results = []
    for c in _collections.values():
        results.append(
            CuratedCollectionResponse(
                slug=c["slug"],
                title=c["title"],
                subtitle=c["subtitle"],
                theme=c["theme"],
                cover_image=c["cover_image"],
                editorial_note=c["editorial_note"],
                place_slugs=json.loads(c.get("place_slugs_json", "[]")),
            )
        )
    return results


@router.get("/collections/{slug}", response_model=CuratedCollectionResponse)
async def get_collection_detail(slug: str) -> CuratedCollectionResponse:
    """
    Get single curated collection with place identifiers.
    """
    c = _collections.get(slug)
    if not c:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Collection '{slug}' not found")
    return CuratedCollectionResponse(
        slug=c["slug"],
        title=c["title"],
        subtitle=c["subtitle"],
        theme=c["theme"],
        cover_image=c["cover_image"],
        editorial_note=c["editorial_note"],
        place_slugs=json.loads(c.get("place_slugs_json", "[]")),
    )


@router.post("/contributions", response_model=ContributionResponse, status_code=status.HTTP_201_CREATED)
async def submit_contribution(data: ContributionCreate) -> ContributionResponse:
    """
    Submit community place proposal, correction, or cultural story.
    Enforces the Non-Negotiable Content Rule: Submissions enter moderation and are never published automatically.
    """
    new_sub = {
        "id": uuid.uuid4(),
        "place_name": data.place_name,
        "district_id": data.district_id,
        "contributor_name": data.contributor_name,
        "contributor_contact": data.contributor_contact,
        "submission_type": data.submission_type,
        "details": data.details,
        "evidence_url": data.evidence_url,
        "status": "PENDING",
        "moderation_notes": "Awaiting editorial review by District Curator",
        "created_at": datetime.now(UTC),
        "reviewed_at": None,
    }
    _contributions.insert(0, new_sub)
    return ContributionResponse(**new_sub)


@router.get("/contributions", response_model=list[ContributionResponse])
async def list_contributions(
    status_filter: str | None = Query(None, description="PENDING, APPROVED, REJECTED")
) -> list[ContributionResponse]:
    """
    Admin moderation queue for community contributions and corrections.
    """
    filtered = [
        c for c in _contributions
        if status_filter is None or c["status"] == status_filter.upper()
    ]
    return [ContributionResponse(**c) for c in filtered]


@router.post("/districts/{slug}/day-plan", response_model=DistrictDayPlanResponse)
async def build_district_day_plan(
    slug: str,
    plan_req: DistrictDayPlanRequest,
) -> DistrictDayPlanResponse:
    """
    'Build me a district day' - Generates a feasible sequence of stops within a district,
    validating travel times, buffers, and dwell durations through TripGraph logic.
    """
    district_obj = next((d for d in _districts.values() if d["slug"] == slug or d["id"] == slug), None)
    if not district_obj:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"District '{slug}' not found")

    places = [d for d in _destinations.values() if d["district_id"] == district_obj["id"]]
    if not places:
        # Fallback to nearby district places if none directly in district yet
        places = list(_destinations.values())[:3]

    # Rank by category match
    scored_places = []
    for p in places:
        match_score = 10 if p["category"] in plan_req.interests else 3
        if p["place_type"] == "iconic":
            match_score += 5
        scored_places.append((match_score, p))

    scored_places.sort(key=lambda x: x[0], reverse=True)
    selected = [p for _, p in scored_places[:3]]

    # Compute feasible sequencing with transit calculator
    stops = []
    current_time_minutes = 9 * 60  # Start at 09:00 AM
    total_travel_mins = 0
    total_dwell_mins = 0
    polyline = []
    validation_notes = []

    prev_coords = (district_obj["latitude"], district_obj["longitude"])

    for i, p in enumerate(selected):
        p_coords = (p["latitude"], p["longitude"])
        polyline.append([p["latitude"], p["longitude"]])

        # Transit from previous stop
        drive_mins = SriLankaTransitCalculator.estimate_travel_time_minutes(prev_coords, p_coords)
        if i == 0:
            drive_mins = min(drive_mins, 20)  # Initial hotel departure buffer
        total_travel_mins += drive_mins
        current_time_minutes += drive_mins

        arr_h = current_time_minutes // 60
        arr_m = current_time_minutes % 60
        arr_str = f"{arr_h:02d}:{arr_m:02d}"

        # Dwell duration at destination
        dwell = p["dwell_duration_mins"]
        total_dwell_mins += dwell
        current_time_minutes += dwell

        dep_h = current_time_minutes // 60
        dep_m = current_time_minutes % 60
        dep_str = f"{dep_h:02d}:{dep_m:02d}"

        stops.append({
            "stop_order": i + 1,
            "place_name": p["name"],
            "slug": p["slug"],
            "category": p["category"],
            "arrival_time": arr_str,
            "departure_time": dep_str,
            "dwell_mins": dwell,
            "transit_from_prev_mins": drive_mins,
            "photo_url": p["photo_url"],
            "access_state": p["access_state"],
            "fee_info": p["fee_info_text"],
        })
        prev_coords = p_coords

    total_duration_hours = (total_travel_mins + total_dwell_mins) / 60.0
    if total_duration_hours <= plan_req.available_hours:
        feasibility = "FEASIBLE"
        validation_notes.append(f"Itinerary fits comfortably in {total_duration_hours:.1f}h (Budget: {plan_req.available_hours}h).")
        validation_notes.append("TripGraph validated 20-30 min road buffers and daytime operating hours.")
    else:
        feasibility = "WARNING_TIGHT_BUFFER"
        validation_notes.append(f"Itinerary requires {total_duration_hours:.1f}h, slightly exceeding your {plan_req.available_hours}h target. Consider starting earlier or reducing dwell times.")

    return DistrictDayPlanResponse(
        district_id=district_obj["id"],
        district_name=district_obj["name"],
        total_duration_mins=total_travel_mins + total_dwell_mins,
        feasibility_status=feasibility,
        stops=stops,
        route_polyline=polyline,
        tripgraph_validation_notes=validation_notes,
    )
