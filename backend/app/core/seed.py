import asyncio
import uuid
from datetime import UTC, date, datetime, time, timedelta

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
    # 1. Create Core Platform Accounts
    admin = User(
        email="admin@traverza.lk",
        hashed_password=hash_password("TraverzaAdmin2026!"),
        full_name="Nirosha Senanayake",
        phone_number="+94771234567",
        is_staff=True,
        staff_role="SUPER_ADMIN",
        mfa_enabled=True,
    )
    db.add(admin)

    traveler = User(
        email="dinusha.uk@example.com",
        hashed_password=hash_password("TravelerPass2026!"),
        full_name="Dinusha & Family",
        phone_number="+447911123456",
        is_staff=False,
    )
    db.add(traveler)

    provider_chauffeur_user = User(
        email="fleet@ceylonchauffeurs.lk",
        hashed_password=hash_password("ChauffeurGuild2026!"),
        full_name="Lalith Jayasuriya",
        phone_number="+94712348899",
        is_staff=False,
    )
    db.add(provider_chauffeur_user)

    provider_hotel_user = User(
        email="reservations@watergardensigiriya.lk",
        hashed_password=hash_password("SigiriyaEco2026!"),
        full_name="Anura Bandara",
        phone_number="+94776543210",
        is_staff=False,
    )
    db.add(provider_hotel_user)

    provider_guide_user = User(
        email="guild@kandyanheritage.lk",
        hashed_password=hash_password("KandyGuide2026!"),
        full_name="Sunil Rathnayake",
        phone_number="+94789991122",
        is_staff=False,
    )
    db.add(provider_guide_user)
    await db.flush()

    # 2. Provider Organizations (Curated Pilot Corridor)
    org_chauffeur = Organization(
        name="Ceylon Chauffeurs Guild (Pvt) Ltd",
        legal_name="Ceylon Chauffeur Fleet Operations PVT LTD",
        business_reg_no="PV-0029104",
        sltda_license_no="SLTDA/CG/2026/102",
        category="TRANSPORT",
        is_verified=True,
        contact_email="dispatch@ceylonchauffeurs.lk",
        contact_phone="+94112890123",
    )
    db.add(org_chauffeur)

    org_hotel = Organization(
        name="Boutique Heritage Stays (Pvt) Ltd",
        legal_name="Boutique Heritage Hotels & Eco Villas PVT LTD",
        business_reg_no="PV-0018442",
        sltda_license_no="SLTDA/SQ/2026/089",
        category="STAYS",
        is_verified=True,
        contact_email="reservations@watergardensigiriya.lk",
        contact_phone="+94662288001",
    )
    db.add(org_hotel)

    org_guide = Organization(
        name="Cultural Heritage Guide Guild",
        legal_name="Central Cultural Triangle Licensed Guides Association",
        business_reg_no="PV-0033109",
        sltda_license_no="SLTDA/GD/2026/044",
        category="GUIDE",
        is_verified=True,
        contact_email="guild@kandyanheritage.lk",
        contact_phone="+94812233445",
    )
    db.add(org_guide)
    await db.flush()

    # Memberships
    db.add(OrganizationMembership(user_id=provider_chauffeur_user.id, organization_id=org_chauffeur.id, role="OWNER"))
    db.add(OrganizationMembership(user_id=provider_hotel_user.id, organization_id=org_hotel.id, role="OWNER"))
    db.add(OrganizationMembership(user_id=provider_guide_user.id, organization_id=org_guide.id, role="OWNER"))

    # Provider Documents
    db.add(ProviderDocument(
        organization_id=org_chauffeur.id,
        document_type="SLTDA_TOURISM_LICENSE",
        document_number="SLTDA/CG/2026/102",
        file_name="sltda_chauffeur_license_2026.pdf",
        file_url="https://storage.traverza.lk/verified-docs/chauffeur-2026.pdf",
        expiry_date="2027-12-31",
        status="APPROVED",
        reviewer_notes="Verified against SLTDA Tourism App registry directory",
        reviewed_at="2026-10-18T10:00:00Z",
    ))
    db.add(ProviderDocument(
        organization_id=org_hotel.id,
        document_type="BUSINESS_REGISTRATION",
        document_number="PV-0018442",
        file_name="br_heritage_stays_certified.pdf",
        file_url="https://storage.traverza.lk/verified-docs/br_heritage.pdf",
        expiry_date="2030-01-01",
        status="APPROVED",
        reviewer_notes="Registrar of Companies corporate verification confirmed",
        reviewed_at="2026-10-18T10:30:00Z",
    ))

    # 3. Pilot Corridor Destinations
    dest_colombo = Destination(
        name="Colombo & Katunayake (CMB)",
        slug="colombo-katunayake",
        province="Western Province",
        corridor_name="Colombo - Sigiriya - Kandy - Nuwara Eliya",
        description="International air gateway, coastal expressway interchange, and luxury transit hub.",
        latitude=7.1808,
        longitude=79.8841,
    )
    db.add(dest_colombo)

    dest_sigiriya = Destination(
        name="Sigiriya & Dambulla",
        slug="sigiriya-dambulla",
        province="Central Province",
        corridor_name="Colombo - Sigiriya - Kandy - Nuwara Eliya",
        description="The UNESCO Cultural Triangle gateway featuring ancient royal citadels and cave monasteries.",
        latitude=7.9570,
        longitude=80.7603,
    )
    db.add(dest_sigiriya)

    dest_kandy = Destination(
        name="Kandy Sacred City",
        slug="kandy",
        province="Central Province",
        corridor_name="Colombo - Sigiriya - Kandy - Nuwara Eliya",
        description="The historic royal hill capital home to the Temple of the Sacred Tooth Relic.",
        latitude=7.2936,
        longitude=80.6413,
    )
    db.add(dest_kandy)

    dest_nuwara_eliya = Destination(
        name="Nuwara Eliya (Tea Highlands)",
        slug="nuwara-eliya",
        province="Central Province",
        corridor_name="Colombo - Sigiriya - Kandy - Nuwara Eliya",
        description="Highland hill station, tea plantations, and cool mountain trails at 1,868m elevation.",
        latitude=6.9497,
        longitude=80.7891,
    )
    db.add(dest_nuwara_eliya)
    await db.flush()

    # 4. Points of Interest (Places)
    place_cmb = Place(
        destination_id=dest_colombo.id,
        name="Bandaranaike International Airport (CMB)",
        slug="bandaranaike-international-airport",
        category="HISTORIC",
        description="Main international aviation hub for Sri Lanka.",
        latitude=7.1808,
        longitude=79.8841,
        altitude_meters=8,
        recommended_duration_minutes=60,
        opening_time_str="00:00",
        closing_time_str="23:59",
    )
    db.add(place_cmb)

    place_sigiriya_rock = Place(
        destination_id=dest_sigiriya.id,
        name="Sigiriya Lion Rock Fortress",
        slug="sigiriya-rock-fortress",
        category="CULTURAL",
        description="5th-century royal palace citadel atop a 200-meter sheer volcanic column.",
        latitude=7.9570,
        longitude=80.7603,
        altitude_meters=349,
        recommended_duration_minutes=180,
        opening_time_str="06:30",
        closing_time_str="18:00",
    )
    db.add(place_sigiriya_rock)

    place_tooth_relic = Place(
        destination_id=dest_kandy.id,
        name="Temple of the Sacred Tooth Relic (Sri Dalada Maligawa)",
        slug="temple-of-the-tooth",
        category="CULTURAL",
        description="Venerated Buddhist temple within the royal palace complex of Kandy.",
        latitude=7.2936,
        longitude=80.6413,
        altitude_meters=500,
        recommended_duration_minutes=120,
        opening_time_str="05:30",
        closing_time_str="20:00",
    )
    db.add(place_tooth_relic)

    place_tea_estate = Place(
        destination_id=dest_nuwara_eliya.id,
        name="Pedro Tea Estate & Lover's Leap",
        slug="pedro-tea-estate",
        category="NATURE",
        description="Historic 1885 tea plantation producing premium Ceylon high-grown black tea.",
        latitude=6.9530,
        longitude=80.8050,
        altitude_meters=1850,
        recommended_duration_minutes=150,
        opening_time_str="08:00",
        closing_time_str="17:00",
    )
    db.add(place_tea_estate)
    await db.flush()

    # 5. Published Service Listings
    listing_transfer_cmb = Listing(
        organization_id=org_chauffeur.id,
        destination_id=dest_colombo.id,
        title="Airport to Sigiriya Private Chauffeur Guide (Fleet #LK-402)",
        category="TRANSFER",
        description="Premium air-conditioned Toyota Prado/KDH with English-speaking SLTDA licensed chauffeur guide.",
        base_price_minor=1850000,  # LKR 18,500.00
        currency="LKR",
        is_published=True,
        manual_availability_only=False,
        cancellation_policy="FREE_CANCELLATION_24H",
    )
    db.add(listing_transfer_cmb)

    listing_hotel_sigiriya = Listing(
        organization_id=org_hotel.id,
        destination_id=dest_sigiriya.id,
        title="Sigiriya Water Garden Eco Villa (Deluxe Chalet)",
        category="STAY",
        description="Eco-luxury water villa overlooking Sigiriya rock fortress with private plunge pool and organic breakfast.",
        base_price_minor=3800000,  # LKR 38,000.00
        currency="LKR",
        is_published=True,
        manual_availability_only=True,
        cancellation_policy="STANDARD_48H",
    )
    db.add(listing_hotel_sigiriya)

    listing_guide_sigiriya = Listing(
        organization_id=org_guide.id,
        destination_id=dest_sigiriya.id,
        title="Sigiriya Rock Fortress Guided Archaeological Ascent",
        category="ACTIVITY",
        description="Expert certified archaeologist walkthrough of the water gardens, mirror wall, and summit ruins.",
        base_price_minor=1200000,  # LKR 12,000.00
        currency="LKR",
        is_published=True,
        manual_availability_only=False,
        cancellation_policy="FREE_CANCELLATION_24H",
    )
    db.add(listing_guide_sigiriya)

    listing_guide_kandy = Listing(
        organization_id=org_guide.id,
        destination_id=dest_kandy.id,
        title="Temple of the Sacred Tooth Relic Guided Walking Tour",
        category="ACTIVITY",
        description="Evening puja ceremony walkthrough with licensed central guild cultural guide.",
        base_price_minor=950000,  # LKR 9,500.00
        currency="LKR",
        is_published=True,
        manual_availability_only=True,
        cancellation_policy="STANDARD_48H",
    )
    db.add(listing_guide_kandy)
    await db.flush()

    # 6. Sample Trip Canvas ("Colombo to Cultural Highlands - 3-Day Journey")
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

    # Day 1 Items
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
    db.add(DependencyEdge(
        trip_id=trip.id,
        source_item_id=item1_flight.id,
        target_item_id=item2_transfer.id,
        dependency_type="FLIGHT_ARRIVAL_TO_TRANSFER",
        min_buffer_minutes=30,
        description="Luggage recovery and customs clearance buffer",
    ))
    db.add(DependencyEdge(
        trip_id=trip.id,
        source_item_id=item2_transfer.id,
        target_item_id=item3_ascent.id,
        dependency_type="TRANSFER_TO_ACTIVITY",
        min_buffer_minutes=45,
        description="Rest and gear preparation before fortress climb",
    ))

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
    acc_cash = LedgerAccount(code="GATEWAY_CASH", name="Gateway Cash Account (Asset)", type="ASSET")
    acc_escrow = LedgerAccount(code="PLATFORM_ESCROW", name="Customer Escrow Funds (Liability)", type="LIABILITY")
    acc_revenue = LedgerAccount(code="COMMISSION_REVENUE", name="Marketplace Commission (Revenue)", type="REVENUE")
    acc_payable = LedgerAccount(code="PROVIDER_PAYABLE", name="Provider Payout Balance (Liability)", type="LIABILITY")
    db.add_all([acc_cash, acc_escrow, acc_revenue, acc_payable])
    await db.flush()

    tx_id = uuid.uuid4()
    entry1 = LedgerEntry(
        transaction_id=tx_id,
        account_id=acc_cash.id,
        booking_id=booking1.id,
        debit_minor=1850000,
        credit_minor=0,
        currency="LKR",
        memo="Card payment capture for Chauffeur Transfer",
    )
    entry2 = LedgerEntry(
        transaction_id=tx_id,
        account_id=acc_escrow.id,
        booking_id=booking1.id,
        debit_minor=0,
        credit_minor=1850000,
        currency="LKR",
        memo="Escrow liability held pending tour completion",
    )
    db.add_all([entry1, entry2])

    # 9. Audit Event
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
