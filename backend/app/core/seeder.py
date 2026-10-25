import asyncio
import json
import logging

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import async_session_maker
from app.core.security import hash_password
from app.modules.atlas.models import (
    CuratedCollection,
    DestinationPlace,
    District,
    DistrictSpeciality,
    Province,
)
from app.modules.atlas.seed_data import (
    CURATED_COLLECTIONS_SEED,
    DESTINATIONS_SEED,
    DISTRICT_SPECIALITIES_SEED,
    DISTRICTS_SEED,
    PROVINCES_SEED,
)
from app.modules.catalogue.models import Destination
from app.modules.identity.models import Organization, OrganizationMembership, User
from app.modules.packages.models import Package
from app.modules.packages.router import INITIAL_PACKAGES_DATA
from app.modules.payments.models import LedgerAccount

logger = logging.getLogger("traverza.seeder")


async def seed_ledger_accounts(session: AsyncSession) -> None:
    """Idempotently seeds platform double-entry chart of accounts."""
    accounts = [
        {"code": "GATEWAY_CASH", "name": "PayHere / Gateway Cash Clearing", "type": "ASSET"},
        {"code": "PLATFORM_ESCROW", "name": "Customer Escrow Holding Liability", "type": "LIABILITY"},
        {"code": "PLATFORM_REVENUE", "name": "TRAVERZA Commission Revenue", "type": "REVENUE"},
        {"code": "PROVIDER_PAYABLE", "name": "Provider Settlement Payable", "type": "LIABILITY"},
        {"code": "REFUND_CLEARING", "name": "Traveller Refund In-Transit", "type": "ASSET"},
    ]
    for acc_data in accounts:
        stmt = select(LedgerAccount).where(LedgerAccount.code == acc_data["code"])
        res = await session.execute(stmt)
        if not res.scalar_one_or_none():
            session.add(LedgerAccount(**acc_data))
            logger.info(f"Seeded Ledger Account: {acc_data['code']}")


async def seed_atlas_geography(session: AsyncSession) -> None:
    """Idempotently seeds 9 provinces, 25 districts, places, and curated collections."""
    # 1. Provinces
    for p_data in PROVINCES_SEED:
        stmt = select(Province).where(Province.id == p_data["id"])
        res = await session.execute(stmt)
        if not res.scalar_one_or_none():
            province = Province(**p_data)
            session.add(province)
            logger.info(f"Seeded Province: {p_data['name']} ({p_data['id']})")
    await session.flush()

    # 2. Districts
    for d_data in DISTRICTS_SEED:
        stmt = select(District).where(District.id == d_data["id"])
        res = await session.execute(stmt)
        if not res.scalar_one_or_none():
            district = District(**d_data)
            session.add(district)
            logger.info(f"Seeded District: {d_data['name']} ({d_data['id']})")
    await session.flush()

    # 3. Destination Places
    for place_data in DESTINATIONS_SEED:
        stmt = select(DestinationPlace).where(DestinationPlace.slug == place_data["slug"])
        res = await session.execute(stmt)
        if not res.scalar_one_or_none():
            dest = DestinationPlace(
                slug=place_data["slug"],
                province_id=place_data["province_id"],
                district_id=place_data["district_id"],
                name=place_data["name"],
                name_si=place_data["name_si"],
                name_ta=place_data["name_ta"],
                place_type=place_data.get("place_type", "iconic"),
                category=place_data["category"],
                latitude=place_data["latitude"],
                longitude=place_data["longitude"],
                summary=place_data["summary"],
                story=place_data["story"],
                dwell_duration_mins=place_data.get("dwell_duration_mins", 90),
                opening_hours_text=place_data.get("opening_hours_text", "Dawn to dusk"),
                fee_info_text=place_data.get("fee_info_text", "Free public access"),
                access_state=place_data.get("access_state", "OPEN"),
                terrain_notes=place_data.get("terrain_notes", "Paved access"),
                safety_notes=place_data.get("safety_notes", "Standard precautions"),
                is_family_friendly=place_data.get("is_family_friendly", True),
                accessibility_notes=place_data.get("accessibility_notes", "Partially accessible"),
                evidence_source=place_data.get("evidence_source", "SLTDA Certified Registry"),
                photo_url=place_data["photo_url"],
                photo_attribution=place_data.get("photo_attribution", "TRAVERZA Verified Field Audit"),
                review_status="APPROVED",
            )
            session.add(dest)
            logger.info(f"Seeded Destination Place: {place_data['name']}")
    await session.flush()

    # 4. District Specialities
    for spec_data in DISTRICT_SPECIALITIES_SEED:
        stmt = select(DistrictSpeciality).where(
            DistrictSpeciality.district_id == spec_data["district_id"],
            DistrictSpeciality.title == spec_data["title"],
        )
        res = await session.execute(stmt)
        if not res.scalar_one_or_none():
            spec = DistrictSpeciality(**spec_data)
            session.add(spec)
    await session.flush()

    # 5. Curated Collections
    for coll_data in CURATED_COLLECTIONS_SEED:
        stmt = select(CuratedCollection).where(CuratedCollection.slug == coll_data["slug"])
        res = await session.execute(stmt)
        if not res.scalar_one_or_none():
            raw_slugs = coll_data.get("place_slugs_json") or coll_data.get("place_slugs") or []
            place_slugs_str = raw_slugs if isinstance(raw_slugs, str) else json.dumps(raw_slugs)
            coll = CuratedCollection(
                slug=coll_data["slug"],
                title=coll_data["title"],
                subtitle=coll_data["subtitle"],
                theme=coll_data["theme"],
                cover_image=coll_data["cover_image"],
                editorial_note=coll_data["editorial_note"],
                place_slugs_json=place_slugs_str,
            )
            session.add(coll)
            logger.info(f"Seeded Collection: {coll_data['title']}")
    await session.flush()


async def seed_pilot_marketplace(session: AsyncSession) -> None:
    """Seeds pilot corridor destinations, provider orgs, and packages."""
    # 1. Pilot Corridor Destinations & Places
    pilot_hubs = [
        {"name": "Colombo", "slug": "colombo", "province": "Western Province", "lat": 6.9271, "lon": 79.8612},
        {"name": "Sigiriya", "slug": "sigiriya", "province": "Central Province", "lat": 7.9570, "lon": 80.7603},
        {"name": "Kandy", "slug": "kandy", "province": "Central Province", "lat": 7.2906, "lon": 80.6337},
        {"name": "Nuwara Eliya", "slug": "nuwara-eliya", "province": "Central Province", "lat": 6.9497, "lon": 80.7891},
    ]
    dest_map = {}
    for hub in pilot_hubs:
        stmt = select(Destination).where(Destination.slug == hub["slug"])
        res = await session.execute(stmt)
        dest = res.scalar_one_or_none()
        if not dest:
            dest = Destination(
                name=hub["name"],
                slug=hub["slug"],
                province=hub["province"],
                corridor_name="Colombo - Sigiriya - Kandy - Nuwara Eliya",
                description=f"Key transit and cultural hub: {hub['name']}",
                latitude=hub["lat"],
                longitude=hub["lon"],
            )
            session.add(dest)
            await session.flush()
        dest_map[hub["slug"]] = dest

    # 2. Pilot Provider Organization
    org_stmt = select(Organization).where(Organization.name == "Ceylon Heritage Travel Guild")
    org_res = await session.execute(org_stmt)
    org = org_res.scalar_one_or_none()
    if not org:
        org = Organization(
            name="Ceylon Heritage Travel Guild",
            legal_name="Ceylon Heritage Travel Guild (Pvt) Ltd",
            business_reg_no="PV-LK-2026-9041",
            sltda_license_no="SLTDA/SQA/2026/044",
            category="TRANSPORT",
            is_verified=True,
            contact_email="operator@ceylonguild.lk",
            contact_phone="+94771234567",
        )
        session.add(org)
        await session.flush()

    # 3. Demo Admin & Provider Users
    admin_stmt = select(User).where(User.email == "admin@traverza.lk")
    if not (await session.execute(admin_stmt)).scalar_one_or_none():
        admin_user = User(
            email="admin@traverza.lk",
            hashed_password=hash_password("TraverzaAdmin2026!"),
            full_name="TRAVERZA Platform Governance",
            staff_role="SUPER_ADMIN",
            is_staff=True,
            is_active=True,
        )
        session.add(admin_user)
        logger.info("Seeded Super Admin: admin@traverza.lk")

    provider_stmt = select(User).where(User.email == "operator@ceylonguild.lk")
    if not (await session.execute(provider_stmt)).scalar_one_or_none():
        provider_user = User(
            email="operator@ceylonguild.lk",
            hashed_password=hash_password("CeylonOperator2026!"),
            full_name="Dinesh Jayawardene",
            phone_number="+94771234567",
            is_active=True,
        )
        session.add(provider_user)
        await session.flush()
        membership = OrganizationMembership(
            organization_id=org.id,
            user_id=provider_user.id,
            role="OWNER",
        )
        session.add(membership)
        logger.info("Seeded Provider Owner: operator@ceylonguild.lk")

    # 4. Operator Packages
    for pkg_data in INITIAL_PACKAGES_DATA:
        stmt = select(Package).where(Package.id == pkg_data["id"])
        if not (await session.execute(stmt)).scalar_one_or_none():
            pkg = Package(
                id=pkg_data["id"],
                organization_id=org.id,
                provider_name=pkg_data["provider_name"],
                title=pkg_data["title"],
                slug=pkg_data["slug"],
                summary=pkg_data["summary"],
                description=pkg_data["description"],
                package_type=pkg_data["package_type"],
                status=pkg_data["status"],
                duration_days=pkg_data["duration_days"],
                duration_nights=pkg_data["duration_nights"],
                price_basis=pkg_data["price_basis"],
                base_price_lkr=pkg_data["base_price_lkr"],
                corridor_name=pkg_data["corridor_name"],
                destinations=pkg_data["destinations"],
                cover_image_url=pkg_data["cover_image_url"],
                inclusions=pkg_data["inclusions"],
                exclusions=pkg_data["exclusions"],
                cancellation_policy=pkg_data["cancellation_policy"],
                is_verified=pkg_data["is_verified"],
                sltda_license_no=pkg_data["sltda_license_no"],
                version=pkg_data["version"],
            )
            session.add(pkg)
            logger.info(f"Seeded Package: {pkg_data['title']}")
    await session.flush()


async def seed_all() -> None:
    """Master idempotent seeder executing all seeding tasks."""
    logging.basicConfig(level=logging.INFO)
    logger.info("Starting TRAVERZA Master Database Seeder...")
    async with async_session_maker() as session:
        try:
            await seed_ledger_accounts(session)
            await seed_atlas_geography(session)
            await seed_pilot_marketplace(session)
            await session.commit()
            logger.info("✓ TRAVERZA Database successfully seeded with 0 errors!")
        except Exception as exc:
            await session.rollback()
            logger.error(f"Seeding failed: {exc}")
            raise


if __name__ == "__main__":
    asyncio.run(seed_all())
