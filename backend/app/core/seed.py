import asyncio
import uuid
from datetime import UTC, date, datetime, time, timedelta

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import async_session_maker
from app.core.security import hash_password
from app.modules.audit.models import AuditEvent
from app.modules.bookings.models import QuoteSnapshot, ServiceBooking
from app.modules.catalogue.models import Destination, Listing, Place
from app.modules.identity.models import Organization, OrganizationMembership, ProviderDocument, User
from app.modules.payments.models import LedgerAccount, LedgerEntry
from app.modules.support.models import SupportCase
from app.modules.tripgraph.models import DependencyEdge
from app.modules.trips.models import ItineraryDay, ItineraryItem, Trip


async def seed_database(db: AsyncSession):
    # Helper functions for idempotency
    async def get_or_create_user(email: str, **kwargs) -> User:
        stmt = select(User).where(User.email == email)
        res = await db.execute(stmt)
        user = res.scalar_one_or_none()
        if not user:
            user = User(email=email, **kwargs)
            db.add(user)
            await db.flush()
        return user

    async def get_or_create_org(name: str, **kwargs) -> Organization:
        stmt = select(Organization).where(Organization.name == name)
        res = await db.execute(stmt)
        org = res.scalar_one_or_none()
        if not org:
            org = Organization(name=name, **kwargs)
            db.add(org)
            await db.flush()
        return org

    async def get_or_create_dest(slug: str, name: str, **kwargs) -> Destination:
        stmt = select(Destination).where((Destination.slug == slug) | (Destination.name == name))
        res = await db.execute(stmt)
        dest = res.scalar_one_or_none()
        if not dest:
            dest = Destination(slug=slug, name=name, **kwargs)
            db.add(dest)
            await db.flush()
        return dest

    async def get_or_create_place(slug: str, **kwargs) -> Place:
        stmt = select(Place).where(Place.slug == slug)
        res = await db.execute(stmt)
        place = res.scalar_one_or_none()
        if not place:
            place = Place(slug=slug, **kwargs)
            db.add(place)
            await db.flush()
        return place

    async def get_or_create_listing(org_id: uuid.UUID, title: str, **kwargs) -> Listing:
        stmt = select(Listing).where(Listing.organization_id == org_id, Listing.title == title)
        res = await db.execute(stmt)
        listing = res.scalar_one_or_none()
        if not listing:
            listing = Listing(organization_id=org_id, title=title, **kwargs)
            db.add(listing)
            await db.flush()
        return listing

    async def get_or_create_account(code: str, **kwargs) -> LedgerAccount:
        stmt = select(LedgerAccount).where(LedgerAccount.code == code)
        res = await db.execute(stmt)
        acc = res.scalar_one_or_none()
        if not acc:
            acc = LedgerAccount(code=code, **kwargs)
            db.add(acc)
            await db.flush()
        return acc

    # 1. Create Core Platform Accounts
    admin = await get_or_create_user(
        "admin@traverza.lk",
        hashed_password=hash_password("TraverzaAdmin2026!"),
        full_name="Nirosha Senanayake",
        phone_number="+94771234567",
        is_staff=True,
        staff_role="SUPER_ADMIN",
        mfa_enabled=True,
    )

    traveler = await get_or_create_user(
        "dinusha.uk@example.com",
        hashed_password=hash_password("TravelerPass2026!"),
        full_name="Dinusha & Family",
        phone_number="+447911123456",
        is_staff=False,
    )

    provider_chauffeur_user = await get_or_create_user(
        "fleet@ceylonchauffeurs.lk",
        hashed_password=hash_password("ChauffeurGuild2026!"),
        full_name="Lalith Jayasuriya",
        phone_number="+94712348899",
        is_staff=False,
    )

    provider_hotel_user = await get_or_create_user(
        "reservations@watergardensigiriya.lk",
        hashed_password=hash_password("SigiriyaEco2026!"),
        full_name="Anura Bandara",
        phone_number="+94776543210",
        is_staff=False,
    )

    provider_guide_user = await get_or_create_user(
        "guild@kandyanheritage.lk",
        hashed_password=hash_password("KandyGuide2026!"),
        full_name="Sunil Rathnayake",
        phone_number="+94789991122",
        is_staff=False,
    )

    # 2. Provider Organizations (Curated Pilot Corridor)
    org_chauffeur = await get_or_create_org(
        "Ceylon Chauffeurs Guild (Pvt) Ltd",
        legal_name="Ceylon Chauffeur Fleet Operations PVT LTD",
        business_reg_no="PV-0029104",
        sltda_license_no="SLTDA/CG/2026/102",
        category="TRANSPORT",
        is_verified=True,
        contact_email="dispatch@ceylonchauffeurs.lk",
        contact_phone="+94112890123",
    )

    org_hotel = await get_or_create_org(
        "Boutique Heritage Stays (Pvt) Ltd",
        legal_name="Boutique Heritage Hotels & Eco Villas PVT LTD",
        business_reg_no="PV-0018442",
        sltda_license_no="SLTDA/SQ/2026/089",
        category="STAYS",
        is_verified=True,
        contact_email="reservations@watergardensigiriya.lk",
        contact_phone="+94662288001",
    )

    org_guide = await get_or_create_org(
        "Cultural Heritage Guide Guild",
        legal_name="Central Cultural Triangle Licensed Guides Association",
        business_reg_no="PV-0033109",
        sltda_license_no="SLTDA/GD/2026/044",
        category="GUIDE",
        is_verified=True,
        contact_email="guild@kandyanheritage.lk",
        contact_phone="+94812233445",
    )

    # Memberships (idempotent check)
    for u_id, o_id in [
        (provider_chauffeur_user.id, org_chauffeur.id),
        (provider_hotel_user.id, org_hotel.id),
        (provider_guide_user.id, org_guide.id),
    ]:
        stmt = select(OrganizationMembership).where(
            OrganizationMembership.user_id == u_id, OrganizationMembership.organization_id == o_id
        )
        if not (await db.execute(stmt)).scalar_one_or_none():
            db.add(OrganizationMembership(user_id=u_id, organization_id=o_id, role="OWNER"))

    # Provider Documents (idempotent check)
    doc_stmt = select(ProviderDocument).where(ProviderDocument.organization_id == org_chauffeur.id)
    if not (await db.execute(doc_stmt)).scalar_one_or_none():
        db.add(
            ProviderDocument(
                organization_id=org_chauffeur.id,
                document_type="SLTDA_TOURISM_LICENSE",
                document_number="SLTDA/CG/2026/102",
                file_name="sltda_chauffeur_license_2026.pdf",
                file_url="https://storage.traverza.lk/verified-docs/chauffeur-2026.pdf",
                expiry_date="2027-12-31",
                status="APPROVED",
                reviewer_notes="Verified against SLTDA Tourism App registry directory",
                reviewed_at="2026-10-18T10:00:00Z",
            )
        )
        db.add(
            ProviderDocument(
                organization_id=org_hotel.id,
                document_type="BUSINESS_REGISTRATION",
                document_number="PV-0018442",
                file_name="br_heritage_stays_certified.pdf",
                file_url="https://storage.traverza.lk/verified-docs/br_heritage.pdf",
                expiry_date="2030-01-01",
                status="APPROVED",
                reviewer_notes="Registrar of Companies corporate verification confirmed",
                reviewed_at="2026-10-18T10:30:00Z",
            )
        )

    # 3. Pilot Corridor Destinations
    dest_colombo = await get_or_create_dest(
        slug="colombo-katunayake",
        name="Colombo & Katunayake (CMB)",
        province="Western Province",
        corridor_name="Colombo - Sigiriya - Kandy - Nuwara Eliya",
        description="International air gateway, coastal expressway interchange, and luxury transit hub.",
        latitude=7.1808,
        longitude=79.8841,
    )

    dest_sigiriya = await get_or_create_dest(
        slug="sigiriya-dambulla",
        name="Sigiriya & Dambulla",
        province="Central Province",
        corridor_name="Colombo - Sigiriya - Kandy - Nuwara Eliya",
        description="The UNESCO Cultural Triangle gateway featuring ancient royal citadels and cave monasteries.",
        latitude=7.9570,
        longitude=80.7603,
    )

    dest_kandy = await get_or_create_dest(
        slug="kandy",
        name="Kandy Sacred City",
        province="Central Province",
        corridor_name="Colombo - Sigiriya - Kandy - Nuwara Eliya",
        description="The historic royal hill capital home to the Temple of the Sacred Tooth Relic.",
        latitude=7.2936,
        longitude=80.6413,
    )

    dest_nuwara_eliya = await get_or_create_dest(
        slug="nuwara-eliya",
        name="Nuwara Eliya (Tea Highlands)",
        province="Central Province",
        corridor_name="Colombo - Sigiriya - Kandy - Nuwara Eliya",
        description="Highland hill station, tea plantations, and cool mountain trails at 1,868m elevation.",
        latitude=6.9497,
        longitude=80.7891,
    )

    # 4. Points of Interest (Places)
    place_cmb = await get_or_create_place(
        slug="bandaranaike-international-airport",
        destination_id=dest_colombo.id,
        name="Bandaranaike International Airport (CMB)",
        category="HISTORIC",
        description="Main international aviation hub for Sri Lanka.",
        latitude=7.1808,
        longitude=79.8841,
        altitude_meters=8,
        recommended_duration_minutes=60,
        opening_time_str="00:00",
        closing_time_str="23:59",
    )

    place_sigiriya_rock = await get_or_create_place(
        slug="sigiriya-rock-fortress",
        destination_id=dest_sigiriya.id,
        name="Sigiriya Lion Rock Fortress",
        category="CULTURAL",
        description="5th-century royal palace citadel atop a 200-meter sheer volcanic column.",
        latitude=7.9570,
        longitude=80.7603,
        altitude_meters=349,
        recommended_duration_minutes=180,
        opening_time_str="06:30",
        closing_time_str="18:00",
    )

    await get_or_create_place(
        slug="temple-of-the-tooth",
        destination_id=dest_kandy.id,
        name="Temple of the Sacred Tooth Relic (Sri Dalada Maligawa)",
        category="CULTURAL",
        description="Venerated Buddhist temple within the royal palace complex of Kandy.",
        latitude=7.2936,
        longitude=80.6413,
        altitude_meters=500,
        recommended_duration_minutes=120,
        opening_time_str="05:30",
        closing_time_str="20:00",
    )

    await get_or_create_place(
        slug="pedro-tea-estate",
        destination_id=dest_nuwara_eliya.id,
        name="Pedro Tea Estate & Lover's Leap",
        category="NATURE",
        description="Historic 1885 tea plantation producing premium Ceylon high-grown black tea.",
        latitude=6.9530,
        longitude=80.8050,
        altitude_meters=1850,
        recommended_duration_minutes=150,
        opening_time_str="08:00",
        closing_time_str="17:00",
    )

    # 5. Published Service Listings
    listing_transfer_cmb = await get_or_create_listing(
        org_chauffeur.id,
        "Airport to Sigiriya Private Chauffeur Guide (Fleet #LK-402)",
        destination_id=dest_colombo.id,
        category="TRANSFER",
        description="Premium air-conditioned Toyota Prado/KDH with English-speaking SLTDA licensed chauffeur guide.",
        base_price_minor=1850000,
        currency="LKR",
        is_published=True,
        manual_availability_only=False,
        cancellation_policy="FREE_CANCELLATION_24H",
    )

    listing_hotel_sigiriya = await get_or_create_listing(
        org_hotel.id,
        "Sigiriya Water Garden Eco Villa (Deluxe Chalet)",
        destination_id=dest_sigiriya.id,
        category="STAY",
        description="Eco-luxury water villa overlooking Sigiriya rock fortress with private plunge pool and organic breakfast.",
        base_price_minor=3800000,
        currency="LKR",
        is_published=True,
        manual_availability_only=True,
        cancellation_policy="STANDARD_48H",
    )

    listing_guide_sigiriya = await get_or_create_listing(
        org_guide.id,
        "Sigiriya Rock Fortress Guided Archaeological Ascent",
        destination_id=dest_sigiriya.id,
        category="ACTIVITY",
        description="Expert certified archaeologist walkthrough of the water gardens, mirror wall, and summit ruins.",
        base_price_minor=1200000,
        currency="LKR",
        is_published=True,
        manual_availability_only=False,
        cancellation_policy="FREE_CANCELLATION_24H",
    )

    await get_or_create_listing(
        org_guide.id,
        "Temple of the Sacred Tooth Relic Guided Walking Tour",
        destination_id=dest_kandy.id,
        category="ACTIVITY",
        description="Evening puja ceremony walkthrough with licensed central guild cultural guide.",
        base_price_minor=950000,
        currency="LKR",
        is_published=True,
        manual_availability_only=True,
        cancellation_policy="STANDARD_48H",
    )

    # 6. Sample Trip Canvas ("Colombo to Cultural Highlands - 3-Day Journey")
    trip_stmt = select(Trip).where(Trip.traveler_id == traveler.id, Trip.title == "Colombo to Cultural Highlands (3-Day Journey)")
    trip = (await db.execute(trip_stmt)).scalar_one_or_none()
    if not trip:
        trip = Trip(
            traveler_id=traveler.id,
            title="Colombo to Cultural Highlands (3-Day Journey)",
            start_date=date(2026, 10, 24),
            end_date=date(2026, 10, 26),
            party_size=2,
            corridor_name="Colombo - Sigiriya - Kandy - Nuwara Eliya",
            status="PARTIALLY_CONFIRMED",
        )
        db.add(trip)
        await db.flush()

        day1 = ItineraryDay(trip_id=trip.id, day_number=1, date=date(2026, 10, 24), title="Arrival & Cultural Gateway")
        day2 = ItineraryDay(trip_id=trip.id, day_number=2, date=date(2026, 10, 25), title="Highland Sacred City")
        day3 = ItineraryDay(trip_id=trip.id, day_number=3, date=date(2026, 10, 26), title="Tea Estates & Mountain Trails")
        db.add_all([day1, day2, day3])
        await db.flush()

        item1_flight = ItineraryItem(
            day_id=day1.id,
            place_id=place_cmb.id,
            title="Bandaranaike Intl Airport (CMB) Arrival",
            category="FLIGHT",
            start_time=time(9, 0),
            end_time=time(10, 0),
            latitude=7.1808,
            longitude=79.8841,
            is_fixed_time=True,
            requires_booking=False,
            booking_status="NONE",
        )
        item2_transfer = ItineraryItem(
            day_id=day1.id,
            listing_id=listing_transfer_cmb.id,
            title="Chauffeur Transfer to Sigiriya Cultural Triangle",
            category="TRANSFER",
            start_time=time(10, 30),
            end_time=time(14, 0),
            latitude=7.9570,
            longitude=80.7603,
            is_fixed_time=True,
            requires_booking=True,
            booking_status="CONFIRMED",
        )
        item3_ascent = ItineraryItem(
            day_id=day1.id,
            listing_id=listing_guide_sigiriya.id,
            place_id=place_sigiriya_rock.id,
            title="Sigiriya Rock Fortress Guided Ascent",
            category="ACTIVITY",
            start_time=time(15, 0),
            end_time=time(17, 30),
            latitude=7.9570,
            longitude=80.7603,
            is_fixed_time=True,
            requires_booking=True,
            booking_status="CONFIRMED",
        )
        item4_stay = ItineraryItem(
            day_id=day1.id,
            listing_id=listing_hotel_sigiriya.id,
            title="Sigiriya Water Garden Eco Villa",
            category="STAY",
            start_time=time(18, 30),
            end_time=time(20, 0),
            latitude=7.9570,
            longitude=80.7603,
            is_fixed_time=False,
            requires_booking=True,
            booking_status="REQUEST_SUBMITTED",
        )
        db.add_all([item1_flight, item2_transfer, item3_ascent, item4_stay])
        await db.flush()

        # Dependency Edges
        db.add(
            DependencyEdge(
                trip_id=trip.id,
                source_item_id=item1_flight.id,
                target_item_id=item2_transfer.id,
                dependency_type="FLIGHT_ARRIVAL_TO_TRANSFER",
                min_buffer_minutes=30,
                description="Luggage recovery and customs clearance buffer",
            )
        )
        db.add(
            DependencyEdge(
                trip_id=trip.id,
                source_item_id=item2_transfer.id,
                target_item_id=item3_ascent.id,
                dependency_type="TRANSFER_TO_ACTIVITY",
                min_buffer_minutes=45,
                description="Rest and gear preparation before fortress climb",
            )
        )

        # Quote Snapshot & Bookings
        quote_transfer = QuoteSnapshot(
            trip_id=trip.id,
            listing_id=listing_transfer_cmb.id,
            organization_id=org_chauffeur.id,
            amount_minor=1850000,
            currency="LKR",
            cancellation_terms="FREE_CANCELLATION_24H",
            expires_at=datetime.now(UTC) + timedelta(days=2),
        )
        quote_hotel = QuoteSnapshot(
            trip_id=trip.id,
            listing_id=listing_hotel_sigiriya.id,
            organization_id=org_hotel.id,
            amount_minor=3800000,
            currency="LKR",
            cancellation_terms="STANDARD_48H",
            expires_at=datetime.now(UTC) + timedelta(hours=11),
        )
        quote_ascent = QuoteSnapshot(
            trip_id=trip.id,
            listing_id=listing_guide_sigiriya.id,
            organization_id=org_guide.id,
            amount_minor=1200000,
            currency="LKR",
            cancellation_terms="FREE_CANCELLATION_24H",
            expires_at=datetime.now(UTC) + timedelta(days=2),
        )
        db.add_all([quote_transfer, quote_hotel, quote_ascent])
        await db.flush()

        booking1 = ServiceBooking(
            trip_id=trip.id,
            organization_id=org_chauffeur.id,
            itinerary_item_id=item2_transfer.id,
            quote_snapshot_id=quote_transfer.id,
            status="CONFIRMED",
            amount_minor=1850000,
            currency="LKR",
            response_deadline_at=datetime.now(UTC) + timedelta(days=1),
            confirmed_at=datetime.now(UTC) - timedelta(hours=2),
        )
        booking2 = ServiceBooking(
            trip_id=trip.id,
            organization_id=org_guide.id,
            itinerary_item_id=item3_ascent.id,
            quote_snapshot_id=quote_ascent.id,
            status="CONFIRMED",
            amount_minor=1200000,
            currency="LKR",
            response_deadline_at=datetime.now(UTC) + timedelta(days=1),
            confirmed_at=datetime.now(UTC) - timedelta(hours=1),
        )
        booking3 = ServiceBooking(
            trip_id=trip.id,
            organization_id=org_hotel.id,
            itinerary_item_id=item4_stay.id,
            quote_snapshot_id=quote_hotel.id,
            status="REQUEST_SUBMITTED",
            amount_minor=3800000,
            currency="LKR",
            response_deadline_at=datetime.now(UTC) + timedelta(hours=11),
        )
        db.add_all([booking1, booking2, booking3])
        await db.flush()

        # 7. Operations Desk Support Cases
        case1 = SupportCase(
            trip_id=trip.id,
            booking_id=booking1.id,
            reported_by_id=admin.id,
            severity="CRITICAL",
            category="PROVIDER_CANCEL",
            summary="Chauffeur Guide (Fleet #LK-102) breakdown before CMB pickup",
            description="Vehicle mechanical issue reported 3h 15m prior to Katunayake arrival. Requires emergency fleet backup dispatch from Negombo depot.",
            status="OPEN",
        )
        case2 = SupportCase(
            trip_id=trip.id,
            booking_id=booking3.id,
            reported_by_id=traveler.id,
            severity="HIGH",
            category="UNCONFIRMED_NEAR_TERM",
            summary="Sigiriya Eco Villa unresponded with 1h remaining on quote window",
            description="Provider has not responded to manual reservation request. Operator follow-up via WhatsApp hotline triggered.",
            status="INVESTIGATING",
        )
        case3 = SupportCase(
            trip_id=trip.id,
            reported_by_id=admin.id,
            severity="MEDIUM",
            category="GATEWAY_MISMATCH",
            summary="PayHere sandbox webhook variance held in suspense account",
            description="Webhook received for LKR 12,500 but invoice indicates LKR 12,000. Discrepancy held in platform suspense account.",
            status="OPEN",
        )
        db.add_all([case1, case2, case3])

    # 8. Chart of Accounts & Immutable Ledger
    acc_cash = await get_or_create_account("GATEWAY_CASH", name="Gateway Cash Account (Asset)", type="ASSET")
    acc_escrow = await get_or_create_account("PLATFORM_ESCROW", name="Customer Escrow Funds (Liability)", type="LIABILITY")
    await get_or_create_account("COMMISSION_REVENUE", name="Marketplace Commission (Revenue)", type="REVENUE")
    await get_or_create_account("PROVIDER_PAYABLE", name="Provider Payout Balance (Liability)", type="LIABILITY")

    ledger_stmt = select(LedgerEntry).where(LedgerEntry.memo == "Card payment capture for Chauffeur Transfer")
    if not (await db.execute(ledger_stmt)).scalar_one_or_none():
        tx_id = uuid.uuid4()
        entry1 = LedgerEntry(
            transaction_id=tx_id,
            account_id=acc_cash.id,
            debit_minor=1850000,
            credit_minor=0,
            currency="LKR",
            memo="Card payment capture for Chauffeur Transfer",
        )
        entry2 = LedgerEntry(
            transaction_id=tx_id,
            account_id=acc_escrow.id,
            debit_minor=0,
            credit_minor=1850000,
            currency="LKR",
            memo="Escrow liability held pending tour completion",
        )
        db.add_all([entry1, entry2])

    # 9. Audit Event
    audit_stmt = select(AuditEvent).where(AuditEvent.action == "SEED_CORRIDOR_INITIALIZATION")
    if not (await db.execute(audit_stmt)).scalar_one_or_none():
        audit = AuditEvent(
            actor_id=admin.id,
            actor_email="admin@traverza.lk",
            actor_role="SUPER_ADMIN",
            action="SEED_CORRIDOR_INITIALIZATION",
            resource_type="CORRIDOR",
            resource_id="Colombo-Sigiriya-Kandy-NuwaraEliya",
            reason="Baseline system deployment & SLTDA corridor pilot seed",
        )
        db.add(audit)

    await db.commit()
    print(">>> TRAVERZA Seed Completed Successfully! 1 Corridor, 4 Destinations, 4 Providers, 1 TripCanvas, 3 Cases.")


async def main():
    async with async_session_maker() as session:
        await seed_database(session)


if __name__ == "__main__":
    asyncio.run(main())
