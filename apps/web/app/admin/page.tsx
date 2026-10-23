'use client';

import { useState } from 'react';
import Image from 'next/image';
import Link from 'next/link';

// ==========================================
// 1. DATA CONTRACTS ACROSS 12 DOMAINS
// ==========================================

export type AdminDomainTab =
  | 'overview'
  | 'users'
  | 'providers'
  | 'atlas'
  | 'catalogue'
  | 'packages'
  | 'bookings'
  | 'finance'
  | 'autopilot'
  | 'community'
  | 'broadcast'
  | 'audit';

// Domain 2: Users
export interface UserItem {
  id: string;
  email: string;
  fullName: string;
  phone: string;
  role: 'SUPER_ADMIN' | 'OPERATOR' | 'GUIDE' | 'TRAVELER';
  isActive: boolean;
  isVerified: boolean;
  createdAt: string;
}

// Domain 3: Providers
export interface ProviderItem {
  id: string;
  name: string;
  legalName: string;
  category: 'TRANSPORT' | 'HOTEL' | 'GUIDE' | 'ACTIVITY';
  sltdaLicense: string;
  businessRegNo: string;
  contactEmail: string;
  contactPhone: string;
  isVerified: boolean;
  createdAt: string;
}

// Domain 4: Atlas (Destinations & Places)
export interface DestinationItem {
  id: string;
  name: string;
  slug: string;
  province: string;
  corridor: string;
  description: string;
  latitude: number;
  longitude: number;
  placesCount: number;
}

export interface PlaceItem {
  id: string;
  destinationId: string;
  destinationName: string;
  name: string;
  slug: string;
  category: 'CULTURAL' | 'NATURE' | 'BEACH' | 'RELIGIOUS';
  description: string;
  latitude: number;
  longitude: number;
  recommendedDurationMinutes: number;
  openingHours: string;
  ticketFeeLKR: number;
}

// Domain 5: Catalogue Listings
export interface ListingItem {
  id: string;
  title: string;
  providerName: string;
  category: 'STAY' | 'TRANSFER' | 'GUIDE' | 'ACTIVITY';
  destination: string;
  basePriceLKR: number;
  cancellationPolicy: 'STANDARD_48H' | 'STRICT_24H' | 'FLEXIBLE';
  isPublished: boolean;
}

// Domain 6: Packages
export interface PackageItem {
  id: string;
  title: string;
  providerOrg: string;
  type: 'OPERATOR_PACKAGE' | 'ITINERARY_TEMPLATE';
  priceLKR: number;
  corridor: string;
  durationDays: number;
  inclusions: string;
  exclusions: string;
  sltdaLicense: string;
  status: 'IN_REVIEW' | 'APPROVED' | 'CHANGES_REQUESTED' | 'REJECTED';
}

// Domain 7: Bookings
export interface BookingItem {
  id: string;
  tripRef: string;
  travelerName: string;
  travelerEmail: string;
  providerName: string;
  serviceTitle: string;
  amountLKR: number;
  paymentRef: string;
  voucherCode: string;
  status: 'CONFIRMED' | 'PROVIDER_ACCEPTED' | 'COMPLETED' | 'CANCELLED' | 'EXCEPTION';
  createdAt: string;
}

// Domain 8: Finance & Escrow
export interface EscrowPayoutItem {
  id: string;
  bookingId: string;
  providerName: string;
  totalAmountLKR: number;
  providerShareLKR: number; // 90%
  platformFeeLKR: number; // 10%
  status: 'HELD_IN_ESCROW' | 'RELEASED' | 'REFUNDED';
  tripCompletedAt: string;
}

// Domain 9: Autopilot
export interface AutopilotIncidentItem {
  id: string;
  tripId: string;
  eventType: 'FLIGHT_DELAY' | 'DRIVER_CANCEL' | 'WEATHER_DISRUPTION' | 'PROVIDER_TIMEOUT';
  source: string;
  observedAt: string;
  severity: 'CRITICAL' | 'HIGH' | 'MEDIUM';
  impactAssessment: string;
  proposedAction: string;
  costDeltaLKR: number;
  timingDeltaMinutes: number;
  backupProvider?: string;
  status: 'PENDING_AUTHORIZATION' | 'DISPATCHED' | 'REJECTED';
  tripGraphFeasibility: 'FEASIBLE' | 'RECHECK_REQUIRED' | 'INFEASIBLE';
}

// Domain 10: Community
export interface CommunityReportItem {
  id: string;
  targetType: 'POST' | 'COMMENT' | 'USER';
  reportedItemAuthor: string;
  reporterName: string;
  reason: 'SPAM' | 'HARASSMENT' | 'MISLEADING_ADVICE' | 'SAFETY_CONCERN' | 'FALSE_LOCATION';
  reportedAt: string;
  district: string;
  destination?: string;
  excerpt: string;
  status: 'PENDING' | 'APPROVED_SAFE' | 'FLAGGED' | 'REMOVED';
  moderatorNotes?: string;
}

// Domain 11: Broadcast
export interface BroadcastLogItem {
  id: string;
  title: string;
  body: string;
  category: 'SAFETY' | 'BOOKING' | 'TRIP' | 'OFFERS';
  priority: 'HIGH' | 'MEDIUM' | 'LOW';
  corridor: string;
  dispatchedAt: string;
  dispatchedBy: string;
  recipientCount: number;
}

// Domain 12: Audit Trail
export interface AuditLogItem {
  id: string;
  timestamp: string;
  actorEmail: string;
  actorRole: string;
  action: string;
  resourceType: string;
  resourceId: string;
  reason: string;
  stateDelta?: string;
}

// ==========================================
// 2. INITIAL DATA REPOSITORIES
// ==========================================

const INITIAL_USERS: UserItem[] = [
  {
    id: 'usr-001',
    email: 'admin@traverza.lk',
    fullName: 'Platform Super Administrator',
    phone: '+94 11 234 5678',
    role: 'SUPER_ADMIN',
    isActive: true,
    isVerified: true,
    createdAt: '2026-01-15 08:00 UTC',
  },
  {
    id: 'usr-002',
    email: 'ops@ceylonchauf.lk',
    fullName: 'Roshan Wickramasinghe',
    phone: '+94 77 987 6543',
    role: 'OPERATOR',
    isActive: true,
    isVerified: true,
    createdAt: '2026-02-10 11:20 UTC',
  },
  {
    id: 'usr-003',
    email: 'sunil.guide@srilanka.travel',
    fullName: 'Sunil Senanayake',
    phone: '+94 71 223 3445',
    role: 'GUIDE',
    isActive: true,
    isVerified: true,
    createdAt: '2026-03-01 14:15 UTC',
  },
  {
    id: 'usr-004',
    email: 'sarah.miller@example.co.uk',
    fullName: 'Sarah Miller',
    phone: '+44 7700 900123',
    role: 'TRAVELER',
    isActive: true,
    isVerified: false,
    createdAt: '2026-10-18 09:30 UTC',
  },
];

const INITIAL_PROVIDERS: ProviderItem[] = [
  {
    id: 'org-001',
    name: 'Ceylon Chauffeurs Guild (Pvt) Ltd',
    legalName: 'Ceylon Chauffeurs Guild Private Limited',
    category: 'TRANSPORT',
    sltdaLicense: 'SLTDA/CG/2026/102',
    businessRegNo: 'PV-98234-WP',
    contactEmail: 'fleet@ceylonchauf.lk',
    contactPhone: '+94 11 245 8899',
    isVerified: true,
    createdAt: '2026-01-20 09:00 UTC',
  },
  {
    id: 'org-002',
    name: 'Wild Ceylon Safaris & Expeditions',
    legalName: 'Wild Ceylon Eco Travels (Pvt) Ltd',
    category: 'ACTIVITY',
    sltdaLicense: 'SLTDA/SQA/2026/108',
    businessRegNo: 'PV-10492-NCP',
    contactEmail: 'safari@wildceylon.lk',
    contactPhone: '+94 66 228 9011',
    isVerified: true,
    createdAt: '2026-02-14 10:45 UTC',
  },
  {
    id: 'org-003',
    name: 'Kandy Heritage Walking Guild',
    legalName: 'Kandy Archaeological Guides Association',
    category: 'GUIDE',
    sltdaLicense: 'SLTDA/GD/2026/044',
    businessRegNo: 'AS-872-CP',
    contactEmail: 'tours@kandyheritage.lk',
    contactPhone: '+94 81 223 4455',
    isVerified: false,
    createdAt: '2026-10-19 12:10 UTC',
  },
  {
    id: 'org-004',
    name: 'Heritance Tea Factory Resort',
    legalName: 'Aitken Spence Hotel Holdings PLC',
    category: 'HOTEL',
    sltdaLicense: 'SLTDA/HTL/2026/012',
    businessRegNo: 'PQ-4921',
    contactEmail: 'reservations@heritanceteafactory.lk',
    contactPhone: '+94 52 555 5000',
    isVerified: true,
    createdAt: '2026-01-10 08:30 UTC',
  },
];

const INITIAL_DESTINATIONS: DestinationItem[] = [
  {
    id: 'dest-001',
    name: 'Sigiriya Ancient Rock Fortress',
    slug: 'sigiriya-ancient-rock',
    province: 'Central Province',
    corridor: 'Colombo - Sigiriya - Kandy - Nuwara Eliya',
    description: '5th-century royal palace and fortress atop a 200m monolithic rock column.',
    latitude: 7.957,
    longitude: 80.7603,
    placesCount: 4,
  },
  {
    id: 'dest-002',
    name: 'Kandy Sacred Cultural Basin',
    slug: 'kandy-cultural-basin',
    province: 'Central Province',
    corridor: 'Colombo - Sigiriya - Kandy - Nuwara Eliya',
    description: 'Last royal capital of Sri Lanka, housing the sacred Temple of the Tooth Relic.',
    latitude: 7.2906,
    longitude: 80.6337,
    placesCount: 6,
  },
  {
    id: 'dest-003',
    name: 'Nuwara Eliya Tea Country Highlands',
    slug: 'nuwara-eliya-highlands',
    province: 'Central Province',
    corridor: 'Colombo - Sigiriya - Kandy - Nuwara Eliya',
    description: 'High-altitude emerald tea plantations, waterfalls, and cool mountain climate.',
    latitude: 6.9497,
    longitude: 80.7891,
    placesCount: 5,
  },
  {
    id: 'dest-004',
    name: 'Galle Dutch Fortified Citadel',
    slug: 'galle-dutch-fort',
    province: 'Southern Province',
    corridor: 'Southern Coastal Corridor',
    description: 'UNESCO World Heritage 17th-century bastion fortress on the Indian Ocean.',
    latitude: 6.0535,
    longitude: 80.221,
    placesCount: 8,
  },
];

const INITIAL_PLACES: PlaceItem[] = [
  {
    id: 'plc-001',
    destinationId: 'dest-001',
    destinationName: 'Sigiriya Ancient Rock Fortress',
    name: 'Lion Rock Summit Citadel',
    slug: 'lion-rock-summit',
    category: 'CULTURAL',
    description: 'Upper royal quarters, mirror wall, and 5th-century water gardens.',
    latitude: 7.9569,
    longitude: 80.7597,
    recommendedDurationMinutes: 180,
    openingHours: '06:30 - 17:30',
    ticketFeeLKR: 11000,
  },
  {
    id: 'plc-002',
    destinationId: 'dest-001',
    destinationName: 'Sigiriya Ancient Rock Fortress',
    name: 'Pidurangala Sunset Viewpoint',
    slug: 'pidurangala-sunset-view',
    category: 'NATURE',
    description: 'Panoramic views overlooking the Sigiriya Lion Rock.',
    latitude: 7.9669,
    longitude: 80.7634,
    recommendedDurationMinutes: 120,
    openingHours: '05:00 - 18:30',
    ticketFeeLKR: 1000,
  },
  {
    id: 'plc-003',
    destinationId: 'dest-002',
    destinationName: 'Kandy Sacred Cultural Basin',
    name: 'Sri Dalada Maligawa (Temple of the Tooth)',
    slug: 'temple-of-the-tooth',
    category: 'RELIGIOUS',
    description: 'Sacred Buddhist temple sheltering the Relic of the tooth of the Buddha.',
    latitude: 7.2936,
    longitude: 80.6413,
    recommendedDurationMinutes: 90,
    openingHours: '05:30 - 20:00',
    ticketFeeLKR: 2000,
  },
];

const INITIAL_LISTINGS: ListingItem[] = [
  {
    id: 'lst-001',
    title: 'Executive Air-Conditioned Dual AC Van (1-6 Pax)',
    providerName: 'Ceylon Chauffeurs Guild (Pvt) Ltd',
    category: 'TRANSFER',
    destination: 'Colombo - Sigiriya Corridor',
    basePriceLKR: 28000,
    cancellationPolicy: 'STANDARD_48H',
    isPublished: true,
  },
  {
    id: 'lst-002',
    title: 'Sigiriya Forest Canopy Chalet with Mount View',
    providerName: 'Wild Ceylon Safaris & Expeditions',
    category: 'STAY',
    destination: 'Sigiriya Ancient Rock Fortress',
    basePriceLKR: 36000,
    cancellationPolicy: 'STANDARD_48H',
    isPublished: true,
  },
  {
    id: 'lst-003',
    title: 'Kandy Royal Heritage Walking Exploration with SLTDA Guide',
    providerName: 'Kandy Heritage Walking Guild',
    category: 'GUIDE',
    destination: 'Kandy Sacred Cultural Basin',
    basePriceLKR: 8500,
    cancellationPolicy: 'FLEXIBLE',
    isPublished: true,
  },
  {
    id: 'lst-004',
    title: 'Minneriya National Park Elephant Gathering Jeep Safari',
    providerName: 'Wild Ceylon Safaris & Expeditions',
    category: 'ACTIVITY',
    destination: 'Sigiriya Ancient Rock Fortress',
    basePriceLKR: 22000,
    cancellationPolicy: 'STRICT_24H',
    isPublished: true,
  },
];

const INITIAL_PACKAGES: PackageItem[] = [
  {
    id: 'pkg-001',
    title: '4-Day Heritage & Minneriya Safari Tour',
    providerOrg: 'Wild Ceylon Safaris & Expeditions',
    type: 'OPERATOR_PACKAGE',
    priceLKR: 94000,
    corridor: 'Sigiriya · Polonnaruwa · Minneriya',
    durationDays: 4,
    inclusions: '3 Nights Hotel, Private AC Van, Safari Jeep, SLTDA Guide',
    exclusions: 'Personal expenses, international flights',
    sltdaLicense: 'SLTDA/SQA/2026/108',
    status: 'IN_REVIEW',
  },
  {
    id: 'pkg-002',
    title: '3-Day Cultural Triangle Signature Escape',
    providerOrg: 'Ceylon Heritage Travel Guild',
    type: 'OPERATOR_PACKAGE',
    priceLKR: 68500,
    corridor: 'Colombo · Sigiriya · Kandy · Nuwara Eliya',
    durationDays: 3,
    inclusions: '2 Nights Heritage Chalet, Chauffeur Guide, Museum Passes',
    exclusions: 'Beverages, tips',
    sltdaLicense: 'SLTDA/SQA/2026/044',
    status: 'APPROVED',
  },
];

const INITIAL_BOOKINGS: BookingItem[] = [
  {
    id: 'bk-001',
    tripRef: 'TRIP-LK-2026-8902',
    travelerName: 'Sarah Miller',
    travelerEmail: 'sarah.miller@example.co.uk',
    providerName: 'Ceylon Chauffeurs Guild (Pvt) Ltd',
    serviceTitle: 'Executive Air-Conditioned Van (CMB -> Sigiriya)',
    amountLKR: 28000,
    paymentRef: 'PH-TXN-998124',
    voucherCode: 'VCH-TRV-8902-1',
    status: 'PROVIDER_ACCEPTED',
    createdAt: '2026-10-21 14:20 UTC',
  },
  {
    id: 'bk-002',
    tripRef: 'TRIP-LK-2026-8902',
    travelerName: 'Sarah Miller',
    travelerEmail: 'sarah.miller@example.co.uk',
    providerName: 'Wild Ceylon Safaris & Expeditions',
    serviceTitle: 'Sigiriya Forest Canopy Chalet (2 Nights)',
    amountLKR: 72000,
    paymentRef: 'PH-TXN-998125',
    voucherCode: 'VCH-TRV-8902-2',
    status: 'CONFIRMED',
    createdAt: '2026-10-21 14:22 UTC',
  },
  {
    id: 'bk-003',
    tripRef: 'TRIP-LK-2026-9041',
    travelerName: 'Dinusha Fernando',
    travelerEmail: 'dinusha@example.com',
    providerName: 'Kandy Heritage Walking Guild',
    serviceTitle: 'Temple of the Tooth Guided Discovery',
    amountLKR: 8500,
    paymentRef: 'PH-TXN-998004',
    voucherCode: 'VCH-TRV-9041-1',
    status: 'COMPLETED',
    createdAt: '2026-10-19 08:15 UTC',
  },
];

const INITIAL_ESCROW_PAYOUTS: EscrowPayoutItem[] = [
  {
    id: 'esc-001',
    bookingId: 'bk-003',
    providerName: 'Kandy Heritage Walking Guild',
    totalAmountLKR: 8500,
    providerShareLKR: 7650, // 90%
    platformFeeLKR: 850, // 10%
    status: 'HELD_IN_ESCROW',
    tripCompletedAt: '2026-10-20 17:00 UTC',
  },
  {
    id: 'esc-002',
    bookingId: 'bk-002',
    providerName: 'Ceylon Chauffeurs Guild (Pvt) Ltd',
    totalAmountLKR: 32000,
    providerShareLKR: 28800, // 90%
    platformFeeLKR: 3200, // 10%
    status: 'RELEASED',
    tripCompletedAt: '2026-10-18 12:30 UTC',
  },
];

const INITIAL_AUTOPILOT_INCIDENTS: AutopilotIncidentItem[] = [
  {
    id: 'AP-INC-901',
    tripId: 'TRIP-LK-2026-8902',
    eventType: 'DRIVER_CANCEL',
    source: 'IoT Vehicle Telemetry & Emergency SOS',
    observedAt: '4 minutes ago',
    severity: 'CRITICAL',
    impactAssessment:
      'Chauffeur Van (Fleet #LK-102) transmission breakdown on A1 Highway near Warakapola. 3h 15m remaining until CMB Airport arrival.',
    proposedAction:
      'Auto-dispatch verified standby chauffeur from Negombo Fleet Hub. Recalculate CMB pickup with 15m buffer.',
    costDeltaLKR: 0,
    timingDeltaMinutes: 15,
    backupProvider: 'Ceylon Chauffeurs Guild (Fleet #LK-214 · SLTDA/CG/2026/102)',
    status: 'PENDING_AUTHORIZATION',
    tripGraphFeasibility: 'FEASIBLE',
  },
  {
    id: 'AP-INC-902',
    tripId: 'TRIP-LK-2026-8902',
    eventType: 'FLIGHT_DELAY',
    source: 'AviationStack Live Radar (UL-504)',
    observedAt: '16 minutes ago',
    severity: 'HIGH',
    impactAssessment:
      'UL-504 delayed by +90m. Landing shifted from 14:30 to 16:00. Sigiriya sunset hike cutoff (17:30) at risk of gate closure.',
    proposedAction:
      'Shift airport transfer pickup to 16:30. Reschedule Sigiriya Rock ascent to Day 2 sunrise (06:30) and swap Day 1 evening with Minneriya sunset drive.',
    costDeltaLKR: 0,
    timingDeltaMinutes: 90,
    backupProvider: 'Sigiriya Cultural Guide Guild (SLTDA/GD/2026/044)',
    status: 'PENDING_AUTHORIZATION',
    tripGraphFeasibility: 'FEASIBLE',
  },
  {
    id: 'AP-INC-903',
    tripId: 'TRIP-LK-2026-9041',
    eventType: 'WEATHER_DISRUPTION',
    source: 'Sri Lanka Disaster Management Centre (SL-DMCC)',
    observedAt: '28 minutes ago',
    severity: 'MEDIUM',
    impactAssessment:
      'Heavy monsoon rainfall advisory on A5 Highway (Ramboda Pass). Nuwara Eliya mountain pass vehicle speed restricted to 25 km/h.',
    proposedAction:
      'Re-route via Hatton/Gampola corridor (+22 km, +35m duration) avoiding active mudslide advisory zone.',
    costDeltaLKR: 3500,
    timingDeltaMinutes: 35,
    status: 'PENDING_AUTHORIZATION',
    tripGraphFeasibility: 'FEASIBLE',
  },
];

const INITIAL_COMMUNITY_REPORTS: CommunityReportItem[] = [
  {
    id: 'REP-701',
    targetType: 'POST',
    reportedItemAuthor: 'AdventureTravelGuy_99',
    reporterName: 'Duminda Bandara (Licensed Guide)',
    reason: 'MISLEADING_ADVICE',
    reportedAt: '24 mins ago',
    district: 'Matale',
    destination: 'Knuckles Mountain Range',
    excerpt:
      'Claims that Riverston Mini World’s End trail is open for unattended midnight camping without forestry department permits.',
    status: 'PENDING',
  },
  {
    id: 'REP-702',
    targetType: 'COMMENT',
    reportedItemAuthor: 'CheapTours_Colombo',
    reporterName: 'Ayesha De Silva',
    reason: 'SPAM',
    reportedAt: '1h 10m ago',
    district: 'Galle',
    destination: 'Galle Dutch Fort',
    excerpt:
      'Repeatedly pasting external WhatsApp phone numbers claiming unverified whale watching discounts.',
    status: 'PENDING',
  },
];

const INITIAL_BROADCASTS: BroadcastLogItem[] = [
  {
    id: 'BC-001',
    title: 'A5 Highway (Ramboda Pass) Extreme Rainfall Precaution',
    body: 'Drivers and self-drive travelers advised to use caution along A5 due to slippery turns. Standby rescue vans active.',
    category: 'SAFETY',
    priority: 'HIGH',
    corridor: 'Kandy - Nuwara Eliya Highlands',
    dispatchedAt: '2026-10-22 04:30 UTC',
    dispatchedBy: 'admin@traverza.lk',
    recipientCount: 342,
  },
  {
    id: 'BC-002',
    title: 'Poya Day Temple Etiquette & Opening Windows',
    body: 'Reminder: Sacred cultural sites require white attire or covered shoulders/knees. Temple of the Tooth hours extended.',
    category: 'TRIP',
    priority: 'MEDIUM',
    corridor: 'Islandwide',
    dispatchedAt: '2026-10-20 02:00 UTC',
    dispatchedBy: 'admin@traverza.lk',
    recipientCount: 1250,
  },
];

const INITIAL_AUDIT_LOGS: AuditLogItem[] = [
  {
    id: 'AUD-001',
    timestamp: '2026-10-22 06:15 UTC',
    actorEmail: 'admin@traverza.lk',
    actorRole: 'SUPER_ADMIN',
    action: 'ORGANIZATION_VERIFY',
    resourceType: 'Organization',
    resourceId: 'org-001',
    reason: 'SLTDA registry match confirmed for SLTDA/CG/2026/102',
    stateDelta: '{"is_verified": true}',
  },
  {
    id: 'AUD-002',
    timestamp: '2026-10-22 05:40 UTC',
    actorEmail: 'admin@traverza.lk',
    actorRole: 'SUPER_ADMIN',
    action: 'BOOKING_STATE_OVERRIDE',
    resourceType: 'Booking',
    resourceId: 'bk-001',
    reason: 'Provider confirmed via phone emergency hotline',
    stateDelta: '{"status": "PROVIDER_ACCEPTED"}',
  },
  {
    id: 'AUD-003',
    timestamp: '2026-10-22 04:30 UTC',
    actorEmail: 'admin@traverza.lk',
    actorRole: 'SUPER_ADMIN',
    action: 'BROADCAST_DISPATCHED',
    resourceType: 'Notification',
    resourceId: 'BC-001',
    reason: 'High-priority weather precaution alert pushed to 342 recipients',
    stateDelta: '{"priority": "HIGH", "category": "SAFETY"}',
  },
];

const FIXED_SYSTEM_TIME = '2026-10-23 05:45 UTC';

// ==========================================
// 3. MASTER OPERATIONS DESK COMPONENT
// ==========================================

export default function AdminOpsPage() {
  // Navigation & UI state
  const [adminTab, setAdminTab] = useState<AdminDomainTab>('overview');
  const [notification, setNotification] = useState<string | null>(null);
  const [searchQuery, setSearchQuery] = useState('');

  // Core Data States
  const [users, setUsers] = useState<UserItem[]>(INITIAL_USERS);
  const [providers, setProviders] = useState<ProviderItem[]>(INITIAL_PROVIDERS);
  const [destinations, setDestinations] = useState<DestinationItem[]>(INITIAL_DESTINATIONS);
  const [places, setPlaces] = useState<PlaceItem[]>(INITIAL_PLACES);
  const [listings, setListings] = useState<ListingItem[]>(INITIAL_LISTINGS);
  const [packages, setPackages] = useState<PackageItem[]>(INITIAL_PACKAGES);
  const [bookings, setBookings] = useState<BookingItem[]>(INITIAL_BOOKINGS);
  const [escrowPayouts, setEscrowPayouts] = useState<EscrowPayoutItem[]>(INITIAL_ESCROW_PAYOUTS);
  const [autopilotIncidents, setAutopilotIncidents] = useState<AutopilotIncidentItem[]>(INITIAL_AUTOPILOT_INCIDENTS);
  const [communityReports, setCommunityReports] = useState<CommunityReportItem[]>(INITIAL_COMMUNITY_REPORTS);
  const [broadcasts, setBroadcasts] = useState<BroadcastLogItem[]>(INITIAL_BROADCASTS);
  const [auditLogs, setAuditLogs] = useState<AuditLogItem[]>(INITIAL_AUDIT_LOGS);

  // Modals state
  const [showAddUserModal, setShowAddUserModal] = useState(false);
  const [showEditUserModal, setShowEditUserModal] = useState<UserItem | null>(null);

  const [showAddProviderModal, setShowAddProviderModal] = useState(false);
  const [showEditProviderModal, setShowEditProviderModal] = useState<ProviderItem | null>(null);

  const [showAddDestModal, setShowAddDestModal] = useState(false);
  const [showEditDestModal, setShowEditDestModal] = useState<DestinationItem | null>(null);

  const [showAddPlaceModal, setShowAddPlaceModal] = useState(false);
  const [showAddListingModal, setShowAddListingModal] = useState(false);
  const [showAddPackageModal, setShowAddPackageModal] = useState(false);

  const [showBookingOverrideModal, setShowBookingOverrideModal] = useState<BookingItem | null>(null);
  const [overrideStatus, setOverrideStatus] = useState<BookingItem['status']>('CONFIRMED');
  const [overrideReason, setOverrideReason] = useState('');

  const [showBroadcastModal, setShowBroadcastModal] = useState(false);
  const [broadcastTitle, setBroadcastTitle] = useState('');
  const [broadcastBody, setBroadcastBody] = useState('');
  const [broadcastCategory, setBroadcastCategory] = useState<'SAFETY' | 'BOOKING' | 'TRIP' | 'OFFERS'>('SAFETY');
  const [broadcastPriority, setBroadcastPriority] = useState<'HIGH' | 'MEDIUM' | 'LOW'>('HIGH');
  const [broadcastCorridor, setBroadcastCorridor] = useState('Islandwide');

  // Trigger Notification Toast and record Immutable Audit Event
  const recordAudit = (action: string, resourceType: string, resourceId: string, reason: string, delta?: string) => {
    setAuditLogs((prev) => [
      {
        id: `AUD-${(prev.length + 1).toString().padStart(3, '0')}`,
        timestamp: FIXED_SYSTEM_TIME,
        actorEmail: 'admin@traverza.lk',
        actorRole: 'SUPER_ADMIN',
        action,
        resourceType,
        resourceId,
        reason,
        stateDelta: delta,
      },
      ...prev,
    ]);
    setNotification(`[AUDIT LOGGED] ${action}: ${reason}`);
    setTimeout(() => setNotification(null), 5000);
  };

  // Escrow Calculations
  const totalGBV = bookings.reduce((sum, b) => sum + b.amountLKR, 0);
  const totalEscrowHeld = escrowPayouts
    .filter((e) => e.status === 'HELD_IN_ESCROW')
    .reduce((sum, e) => sum + e.totalAmountLKR, 0);
  const totalPlatformRevenueEarned = escrowPayouts
    .filter((e) => e.status === 'RELEASED')
    .reduce((sum, e) => sum + e.platformFeeLKR, 0);

  // Escrow Release Execution (Gate 5 Double-Entry invariant)
  const handleReleaseEscrow = (payoutId: string) => {
    const item = escrowPayouts.find((p) => p.id === payoutId);
    if (!item) return;

    setEscrowPayouts((prev) =>
      prev.map((p) => (p.id === payoutId ? { ...p, status: 'RELEASED' } : p))
    );

    recordAudit(
      'ESCROW_RELEASE_EXECUTED',
      'EscrowLedger',
      payoutId,
      `Released LKR ${item.totalAmountLKR.toLocaleString()}: 90% (LKR ${item.providerShareLKR.toLocaleString()}) to ${item.providerName}, 10% (LKR ${item.platformFeeLKR.toLocaleString()}) to Platform Revenue`,
      JSON.stringify({
        debit: 'PLATFORM_ESCROW',
        credit_provider: item.providerShareLKR,
        credit_platform: item.platformFeeLKR,
      })
    );
  };

  // Booking State Override Handler
  const handleExecuteBookingOverride = () => {
    if (!showBookingOverrideModal || !overrideReason.trim()) return;

    const bookingId = showBookingOverrideModal.id;
    const oldStatus = showBookingOverrideModal.status;

    setBookings((prev) =>
      prev.map((b) => (b.id === bookingId ? { ...b, status: overrideStatus } : b))
    );

    recordAudit(
      'BOOKING_STATE_OVERRIDE',
      'Booking',
      bookingId,
      overrideReason.trim(),
      JSON.stringify({ from: oldStatus, to: overrideStatus })
    );

    setShowBookingOverrideModal(null);
    setOverrideReason('');
  };

  // Broadcast Dispatch Handler
  const handleDispatchBroadcast = () => {
    if (!broadcastTitle.trim() || !broadcastBody.trim()) return;

    const newBc: BroadcastLogItem = {
      id: `BC-${(broadcasts.length + 1).toString().padStart(3, '0')}`,
      title: broadcastTitle,
      body: broadcastBody,
      category: broadcastCategory,
      priority: broadcastPriority,
      corridor: broadcastCorridor,
      dispatchedAt: FIXED_SYSTEM_TIME,
      dispatchedBy: 'admin@traverza.lk',
      recipientCount: broadcastCorridor === 'Islandwide' ? 1450 : 280,
    };

    setBroadcasts((prev) => [newBc, ...prev]);

    recordAudit(
      'BROADCAST_DISPATCHED',
      'NotificationCenter',
      newBc.id,
      `Pushed ${broadcastPriority} priority alert to ${newBc.recipientCount} active travelers on corridor: ${broadcastCorridor}`,
      JSON.stringify({ title: broadcastTitle, category: broadcastCategory })
    );

    setShowBroadcastModal(false);
    setBroadcastTitle('');
    setBroadcastBody('');
  };

  // Autopilot Actions
  const handleAutopilotDecision = (id: string, decision: 'APPROVED' | 'REJECTED') => {
    setAutopilotIncidents((prev) =>
      prev.map((item) =>
        item.id === id
          ? { ...item, status: decision === 'APPROVED' ? 'DISPATCHED' : 'REJECTED' }
          : item
      )
    );

    recordAudit(
      decision === 'APPROVED' ? 'AUTOPILOT_PROPOSAL_DISPATCHED' : 'AUTOPILOT_PROPOSAL_REJECTED',
      'AutopilotIncident',
      id,
      decision === 'APPROVED'
        ? 'Backup vehicle/guide dispatched; real-time corridor itinerary rescheduled.'
        : 'Proposal rejected; human concierge dispatched for manual handling.'
    );
  };

  // Community Moderation Actions
  const handleCommunityDecision = (
    id: string,
    decision: 'APPROVED_SAFE' | 'FLAGGED' | 'REMOVED',
    note: string
  ) => {
    setCommunityReports((prev) =>
      prev.map((r) =>
        r.id === id ? { ...r, status: decision, moderatorNotes: note } : r
      )
    );

    recordAudit(
      `COMMUNITY_${decision}`,
      'CommunityPost',
      id,
      note,
      JSON.stringify({ decision })
    );
  };

  // Package Review Actions
  const handlePackageDecision = (
    id: string,
    decision: 'APPROVED' | 'CHANGES_REQUESTED' | 'REJECTED'
  ) => {
    setPackages((prev) =>
      prev.map((p) => (p.id === id ? { ...p, status: decision } : p))
    );

    recordAudit(
      `PACKAGE_${decision}`,
      'TourPackage',
      id,
      `Curated package marked as ${decision}`
    );
  };

  // Search filter helpers
  const query = searchQuery.trim().toLowerCase();
  const filteredUsers = query
    ? users.filter((u) => u.fullName.toLowerCase().includes(query) || u.email.toLowerCase().includes(query) || u.role.toLowerCase().includes(query))
    : users;
  const filteredProviders = query
    ? providers.filter((p) => p.name.toLowerCase().includes(query) || p.sltdaLicense.toLowerCase().includes(query) || p.category.toLowerCase().includes(query))
    : providers;
  const filteredDestinations = query
    ? destinations.filter((d) => d.name.toLowerCase().includes(query) || d.province.toLowerCase().includes(query))
    : destinations;
  const filteredListings = query
    ? listings.filter((l) => l.title.toLowerCase().includes(query) || l.providerName.toLowerCase().includes(query) || l.category.toLowerCase().includes(query))
    : listings;
  const filteredBookings = query
    ? bookings.filter((b) => b.id.toLowerCase().includes(query) || b.travelerName.toLowerCase().includes(query) || b.status.toLowerCase().includes(query))
    : bookings;
  const filteredAuditLogs = query
    ? auditLogs.filter((a) => a.action.toLowerCase().includes(query) || a.actorEmail.toLowerCase().includes(query) || a.reason.toLowerCase().includes(query))
    : auditLogs;

  return (
    <div style={{ maxWidth: '1440px', margin: '0 auto', padding: '32px 24px', minHeight: '100vh' }}>
      {/* ============================================================== */}
      {/* MASTER TOP BANNER & OPERATIONAL COMMAND STATUS */}
      {/* ============================================================== */}
      <div
        style={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          marginBottom: '28px',
          flexWrap: 'wrap',
          gap: '20px',
          background: 'linear-gradient(135deg, rgba(7, 59, 92, 0.95) 0%, rgba(8, 126, 139, 0.85) 100%)',
          padding: '24px 32px',
          borderRadius: 'var(--radius-md)',
          border: '1px solid rgba(34, 184, 207, 0.3)',
          boxShadow: '0 12px 36px rgba(7, 59, 92, 0.25)',
          color: '#ffffff',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '20px' }}>
          <Image
            src="/traverza-logo.jpg"
            alt="TRAVERZA Logo"
            width={64}
            height={64}
            style={{
              borderRadius: '16px',
              objectFit: 'cover',
              boxShadow: '0 8px 24px rgba(0, 0, 0, 0.3)',
              border: '2px solid rgba(255, 255, 255, 0.4)',
            }}
          />
          <div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
              <h1 style={{ fontSize: '1.9rem', color: '#ffffff', margin: 0, fontWeight: 800 }}>
                TRAVERZA Master Operations Console
              </h1>
              <span
                style={{
                  background: 'rgba(52, 211, 153, 0.2)',
                  border: '1px solid #34d399',
                  color: '#34d399',
                  padding: '4px 10px',
                  borderRadius: '999px',
                  fontSize: '0.75rem',
                  fontWeight: 700,
                  letterSpacing: '0.05em',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '6px',
                }}
              >
                <span
                  style={{
                    width: '8px',
                    height: '8px',
                    borderRadius: '50%',
                    background: '#34d399',
                    display: 'inline-block',
                  }}
                />
                LIVE PRODUCTION • SUPER_ADMIN
              </span>
            </div>
            <p style={{ margin: '6px 0 0 0', fontSize: '0.88rem', color: '#e0f2fe' }}>
              Authoritative command plane: Full CRUD control, SLTDA registry verification, corridor autopilot, and financial clearing.
            </p>
          </div>
        </div>

        <div style={{ display: 'flex', gap: '12px', alignItems: 'center' }}>
          <button
            onClick={() => setShowBroadcastModal(true)}
            className="btn"
            style={{
              background: 'rgba(239, 68, 68, 0.9)',
              color: '#fff',
              fontSize: '0.85rem',
              fontWeight: 700,
              display: 'flex',
              alignItems: 'center',
              gap: '6px',
            }}
          >
            📢 Send Corridor Broadcast
          </button>
          <Link
            href="/plan"
            className="btn btn-secondary"
            style={{ background: 'rgba(255,255,255,0.15)', color: '#fff', fontSize: '0.85rem' }}
          >
            View Traveler View
          </Link>
        </div>
      </div>

      {/* Notification Toast */}
      {notification && (
        <div
          style={{
            padding: '14px 20px',
            marginBottom: '24px',
            borderRadius: 'var(--radius-sm)',
            background: 'rgba(8, 126, 139, 0.15)',
            border: '1px solid var(--color-secondary)',
            color: 'var(--color-primary)',
            fontSize: '0.92rem',
            fontWeight: 600,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            boxShadow: 'var(--shadow-sm)',
          }}
        >
          <span>{notification}</span>
          <button
            onClick={() => setNotification(null)}
            style={{ background: 'none', border: 'none', cursor: 'pointer', fontWeight: 800 }}
          >
            ✕
          </button>
        </div>
      )}

      {/* ============================================================== */}
      {/* 12-DOMAIN MASTER NAVIGATION TABS */}
      {/* ============================================================== */}
      <div
        style={{
          display: 'flex',
          gap: '8px',
          overflowX: 'auto',
          paddingBottom: '12px',
          marginBottom: '28px',
          borderBottom: '1px solid var(--color-border)',
        }}
      >
        {[
          { key: 'overview', label: '📊 Overview & KPIs', count: null },
          { key: 'users', label: '👥 Users & RBAC', count: users.length },
          { key: 'providers', label: '🏢 SLTDA Providers', count: providers.filter((p) => !p.isVerified).length },
          { key: 'atlas', label: '🧭 Sri Lanka Atlas', count: destinations.length },
          { key: 'catalogue', label: '📦 Services Catalogue', count: listings.length },
          { key: 'packages', label: '🗺️ Tour Packages', count: packages.filter((p) => p.status === 'IN_REVIEW').length },
          { key: 'bookings', label: '🎫 Global Bookings', count: bookings.length },
          { key: 'finance', label: '💳 Finance & Escrow', count: escrowPayouts.filter((p) => p.status === 'HELD_IN_ESCROW').length },
          { key: 'autopilot', label: '🚨 Autopilot Ops', count: autopilotIncidents.filter((i) => i.status === 'PENDING_AUTHORIZATION').length },
          { key: 'community', label: '🛡️ Moderation', count: communityReports.filter((r) => r.status === 'PENDING').length },
          { key: 'broadcast', label: '📢 Broadcasts', count: broadcasts.length },
          { key: 'audit', label: '📜 Audit Trail', count: auditLogs.length },
        ].map((tab) => {
          const isActive = adminTab === tab.key;
          return (
            <button
              key={tab.key}
              onClick={() => {
                setAdminTab(tab.key as AdminDomainTab);
                setSearchQuery('');
              }}
              style={{
                padding: '10px 16px',
                borderRadius: 'var(--radius-sm)',
                border: isActive ? '1px solid var(--color-primary)' : '1px solid var(--color-border)',
                background: isActive ? 'var(--color-primary)' : 'var(--color-surface)',
                color: isActive ? '#ffffff' : 'var(--color-text)',
                fontWeight: isActive ? 700 : 500,
                fontSize: '0.85rem',
                cursor: 'pointer',
                whiteSpace: 'nowrap',
                transition: 'all 0.15s ease',
                display: 'flex',
                alignItems: 'center',
                gap: '8px',
                boxShadow: isActive ? '0 4px 12px rgba(7, 59, 92, 0.15)' : 'none',
              }}
            >
              <span>{tab.label}</span>
              {tab.count !== null && tab.count > 0 && (
                <span
                  style={{
                    background: isActive ? 'rgba(255,255,255,0.25)' : 'var(--color-secondary)',
                    color: '#ffffff',
                    padding: '2px 7px',
                    borderRadius: '999px',
                    fontSize: '0.72rem',
                    fontWeight: 700,
                  }}
                >
                  {tab.count}
                </span>
              )}
            </button>
          );
        })}
      </div>

      {/* ============================================================== */}
      {/* TAB 1: OVERVIEW & TELEMETRY */}
      {/* ============================================================== */}
      {adminTab === 'overview' && (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '28px' }}>
          {/* KPI Stat Cards */}
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: '20px' }}>
            <div className="glass-panel" style={{ padding: '24px' }}>
              <div style={{ fontSize: '0.82rem', color: 'var(--text-muted)', fontWeight: 600 }}>GROSS BOOKING VALUE (GBV)</div>
              <div style={{ fontSize: '1.8rem', fontWeight: 800, color: 'var(--color-primary)', marginTop: '6px' }}>
                LKR {totalGBV.toLocaleString()}
              </div>
              <div style={{ fontSize: '0.78rem', color: '#059669', marginTop: '4px', fontWeight: 600 }}>↑ +14.8% vs last month</div>
            </div>

            <div className="glass-panel" style={{ padding: '24px' }}>
              <div style={{ fontSize: '0.82rem', color: 'var(--text-muted)', fontWeight: 600 }}>ESCROW HELD (GATEWAY SECURED)</div>
              <div style={{ fontSize: '1.8rem', fontWeight: 800, color: 'var(--color-secondary)', marginTop: '6px' }}>
                LKR {totalEscrowHeld.toLocaleString()}
              </div>
              <div style={{ fontSize: '0.78rem', color: 'var(--text-muted)', marginTop: '4px' }}>Double-Entry Verified</div>
            </div>

            <div className="glass-panel" style={{ padding: '24px' }}>
              <div style={{ fontSize: '0.82rem', color: 'var(--text-muted)', fontWeight: 600 }}>PLATFORM REVENUE (10% FEE)</div>
              <div style={{ fontSize: '1.8rem', fontWeight: 800, color: '#059669', marginTop: '6px' }}>
                LKR {totalPlatformRevenueEarned.toLocaleString()}
              </div>
              <div style={{ fontSize: '0.78rem', color: 'var(--text-muted)', marginTop: '4px' }}>Net fee on settled trips</div>
            </div>

            <div className="glass-panel" style={{ padding: '24px' }}>
              <div style={{ fontSize: '0.82rem', color: 'var(--text-muted)', fontWeight: 600 }}>ACTIVE USERS / PROVIDERS</div>
              <div style={{ fontSize: '1.8rem', fontWeight: 800, color: 'var(--color-text)', marginTop: '6px' }}>
                {users.length} / {providers.length}
              </div>
              <div style={{ fontSize: '0.78rem', color: 'var(--text-muted)', marginTop: '4px' }}>
                {providers.filter((p) => p.isVerified).length} SLTDA Verified
              </div>
            </div>

            <div className="glass-panel" style={{ padding: '24px' }}>
              <div style={{ fontSize: '0.82rem', color: 'var(--text-muted)', fontWeight: 600 }}>AUTOPILOT DISRUPTIONS</div>
              <div style={{ fontSize: '1.8rem', fontWeight: 800, color: 'var(--accent-ruby)', marginTop: '6px' }}>
                {autopilotIncidents.filter((i) => i.status === 'PENDING_AUTHORIZATION').length}
              </div>
              <div style={{ fontSize: '0.78rem', color: 'var(--accent-ruby)', marginTop: '4px', fontWeight: 600 }}>Requires authorization</div>
            </div>
          </div>

          {/* Real-time Corridor Health Grid */}
          <div className="glass-panel" style={{ padding: '28px' }}>
            <h2 style={{ fontSize: '1.25rem', marginBottom: '16px' }}>Active Sri Lanka Corridors Health Status</h2>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', gap: '16px' }}>
              {[
                { name: 'Colombo ↔ Kandy Expressway & A1', status: 'CLEAR / HIGH DEMAND', speed: '52 km/h avg', alerts: 0, tag: 'badge-emerald' },
                { name: 'Kandy ↔ Sigiriya Cultural Corridor', status: 'OPTIMAL CONDITIONS', speed: '48 km/h avg', alerts: 0, tag: 'badge-emerald' },
                { name: 'Kandy ↔ Nuwara Eliya (A5 Highway)', status: 'RAIN ADVISORY / SLOWDOWN', speed: '26 km/h avg', alerts: 1, tag: 'badge-amber' },
                { name: 'Southern Coastal Express (E01)', status: 'HIGH SPEED / OPTIMAL', speed: '98 km/h avg', alerts: 0, tag: 'badge-emerald' },
              ].map((c, i) => (
                <div key={i} style={{ padding: '16px', borderRadius: 'var(--radius-sm)', border: '1px solid var(--color-border)', background: '#fafbfc' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                    <strong style={{ fontSize: '0.95rem', color: 'var(--color-primary)' }}>{c.name}</strong>
                    <span className={`badge ${c.tag}`} style={{ fontSize: '0.7rem' }}>{c.status}</span>
                  </div>
                  <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: '12px', fontSize: '0.8rem', color: 'var(--text-muted)' }}>
                    <span>Flow: <strong>{c.speed}</strong></span>
                    <span>Active Alerts: <strong>{c.alerts}</strong></span>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* ============================================================== */}
      {/* TAB 2: USERS & ACCESS CONTROL (100% CRUD) */}
      {/* ============================================================== */}
      {adminTab === 'users' && (
        <div className="glass-panel" style={{ padding: '28px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px', flexWrap: 'wrap', gap: '12px' }}>
            <div>
              <h2 style={{ fontSize: '1.3rem' }}>User Directory & RBAC Security Master</h2>
              <p style={{ fontSize: '0.85rem', color: 'var(--text-muted)' }}>
                Manage traveler, operator, guide, and administrator roles with instant credential updates.
              </p>
            </div>
            <div style={{ display: 'flex', gap: '10px', alignItems: 'center' }}>
              <input
                type="text"
                placeholder="Search users..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                style={{ padding: '8px 12px', borderRadius: 'var(--radius-sm)', border: '1px solid var(--color-border)', fontSize: '0.85rem' }}
              />
              <button
                onClick={() => setShowAddUserModal(true)}
                className="btn btn-primary"
                style={{ fontSize: '0.85rem' }}
              >
                + Add New User
              </button>
            </div>
          </div>

          <div style={{ overflowX: 'auto' }}>
            <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left', fontSize: '0.88rem' }}>
              <thead>
                <tr style={{ borderBottom: '2px solid var(--color-border)', color: 'var(--text-muted)' }}>
                  <th style={{ padding: '12px 16px' }}>User / Email</th>
                  <th style={{ padding: '12px 16px' }}>Phone</th>
                  <th style={{ padding: '12px 16px' }}>Role</th>
                  <th style={{ padding: '12px 16px' }}>Status</th>
                  <th style={{ padding: '12px 16px' }}>Verified</th>
                  <th style={{ padding: '12px 16px' }}>Created</th>
                  <th style={{ padding: '12px 16px', textAlign: 'right' }}>Actions</th>
                </tr>
              </thead>
              <tbody>
                {filteredUsers.map((u) => (
                  <tr key={u.id} style={{ borderBottom: '1px solid var(--color-border)' }}>
                    <td style={{ padding: '14px 16px' }}>
                      <strong style={{ display: 'block', color: 'var(--color-primary)' }}>{u.fullName}</strong>
                      <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>{u.email}</span>
                    </td>
                    <td style={{ padding: '14px 16px', color: 'var(--text-muted)' }}>{u.phone}</td>
                    <td style={{ padding: '14px 16px' }}>
                      <span
                        className={`badge ${
                          u.role === 'SUPER_ADMIN'
                            ? 'badge-ruby'
                            : u.role === 'OPERATOR'
                            ? 'badge-sapphire'
                            : u.role === 'GUIDE'
                            ? 'badge-amber'
                            : 'badge-emerald'
                        }`}
                        style={{ fontSize: '0.72rem' }}
                      >
                        {u.role}
                      </span>
                    </td>
                    <td style={{ padding: '14px 16px' }}>
                      <span className={`badge ${u.isActive ? 'badge-emerald' : 'badge-ruby'}`} style={{ fontSize: '0.72rem' }}>
                        {u.isActive ? 'ACTIVE' : 'DEACTIVATED'}
                      </span>
                    </td>
                    <td style={{ padding: '14px 16px' }}>
                      {u.isVerified ? '✓ Verified' : '—'}
                    </td>
                    <td style={{ padding: '14px 16px', fontSize: '0.78rem', color: 'var(--text-muted)' }}>
                      {u.createdAt}
                    </td>
                    <td style={{ padding: '14px 16px', textAlign: 'right' }}>
                      <div style={{ display: 'flex', gap: '8px', justifyContent: 'flex-end' }}>
                        <button
                          onClick={() => setShowEditUserModal(u)}
                          className="btn btn-secondary"
                          style={{ padding: '4px 10px', fontSize: '0.75rem' }}
                        >
                          Edit
                        </button>
                        <button
                          onClick={() => {
                            const newActive = !u.isActive;
                            setUsers((prev) =>
                              prev.map((item) => (item.id === u.id ? { ...item, isActive: newActive } : item))
                            );
                            recordAudit(
                              newActive ? 'USER_ACTIVATED' : 'USER_DEACTIVATED',
                              'User',
                              u.id,
                              `User ${u.email} set to ${newActive ? 'Active' : 'Deactivated'}`
                            );
                          }}
                          className="btn btn-secondary"
                          style={{
                            padding: '4px 10px',
                            fontSize: '0.75rem',
                            color: u.isActive ? 'var(--accent-ruby)' : '#059669',
                          }}
                        >
                          {u.isActive ? 'Deactivate' : 'Activate'}
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* ============================================================== */}
      {/* TAB 3: SLTDA PROVIDERS REGISTRY (100% CRUD) */}
      {/* ============================================================== */}
      {adminTab === 'providers' && (
        <div className="glass-panel" style={{ padding: '28px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px', flexWrap: 'wrap', gap: '12px' }}>
            <div>
              <h2 style={{ fontSize: '1.3rem' }}>SLTDA Registered Provider Organizations</h2>
              <p style={{ fontSize: '0.85rem', color: 'var(--text-muted)' }}>
                Inspect business registrations, vehicle permits, and official SLTDA tourism licenses.
              </p>
            </div>
            <div style={{ display: 'flex', gap: '10px', alignItems: 'center' }}>
              <input
                type="text"
                placeholder="Search providers..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                style={{ padding: '8px 12px', borderRadius: 'var(--radius-sm)', border: '1px solid var(--color-border)', fontSize: '0.85rem' }}
              />
              <button
                onClick={() => setShowAddProviderModal(true)}
                className="btn btn-primary"
                style={{ fontSize: '0.85rem' }}
              >
                + Onboard Provider
              </button>
            </div>
          </div>

          <div style={{ overflowX: 'auto' }}>
            <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left', fontSize: '0.88rem' }}>
              <thead>
                <tr style={{ borderBottom: '2px solid var(--color-border)', color: 'var(--text-muted)' }}>
                  <th style={{ padding: '12px 16px' }}>Organization</th>
                  <th style={{ padding: '12px 16px' }}>Category</th>
                  <th style={{ padding: '12px 16px' }}>SLTDA License</th>
                  <th style={{ padding: '12px 16px' }}>Business Reg No</th>
                  <th style={{ padding: '12px 16px' }}>Contact</th>
                  <th style={{ padding: '12px 16px' }}>SLTDA Verified</th>
                  <th style={{ padding: '12px 16px', textAlign: 'right' }}>Actions</th>
                </tr>
              </thead>
              <tbody>
                {filteredProviders.map((p) => (
                  <tr key={p.id} style={{ borderBottom: '1px solid var(--color-border)' }}>
                    <td style={{ padding: '14px 16px' }}>
                      <strong style={{ display: 'block', color: 'var(--color-primary)' }}>{p.name}</strong>
                      <span style={{ fontSize: '0.78rem', color: 'var(--text-muted)' }}>{p.legalName}</span>
                    </td>
                    <td style={{ padding: '14px 16px' }}>
                      <span className="badge badge-sapphire" style={{ fontSize: '0.72rem' }}>
                        {p.category}
                      </span>
                    </td>
                    <td style={{ padding: '14px 16px', fontFamily: 'monospace', fontWeight: 600 }}>
                      {p.sltdaLicense}
                    </td>
                    <td style={{ padding: '14px 16px', color: 'var(--text-muted)' }}>{p.businessRegNo}</td>
                    <td style={{ padding: '14px 16px', fontSize: '0.8rem' }}>
                      <div>{p.contactEmail}</div>
                      <div style={{ color: 'var(--text-muted)' }}>{p.contactPhone}</div>
                    </td>
                    <td style={{ padding: '14px 16px' }}>
                      <span className={`badge ${p.isVerified ? 'badge-emerald' : 'badge-amber'}`} style={{ fontSize: '0.72rem' }}>
                        {p.isVerified ? 'VERIFIED' : 'PENDING'}
                      </span>
                    </td>
                    <td style={{ padding: '14px 16px', textAlign: 'right' }}>
                      <div style={{ display: 'flex', gap: '8px', justifyContent: 'flex-end' }}>
                        <button
                          onClick={() => {
                            const newStatus = !p.isVerified;
                            setProviders((prev) =>
                              prev.map((item) => (item.id === p.id ? { ...item, isVerified: newStatus } : item))
                            );
                            recordAudit(
                              newStatus ? 'PROVIDER_VERIFIED' : 'PROVIDER_UNVERIFIED',
                              'Organization',
                              p.id,
                              `SLTDA verification set to ${newStatus} for ${p.name}`
                            );
                          }}
                          className="btn btn-secondary"
                          style={{
                            padding: '4px 10px',
                            fontSize: '0.75rem',
                            color: p.isVerified ? 'var(--accent-ruby)' : '#059669',
                          }}
                        >
                          {p.isVerified ? 'Unverify' : '✓ Verify SLTDA'}
                        </button>
                        <button
                          onClick={() => setShowEditProviderModal(p)}
                          className="btn btn-secondary"
                          style={{ padding: '4px 10px', fontSize: '0.75rem' }}
                        >
                          Edit
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* ============================================================== */}
      {/* TAB 4: SRI LANKA ATLAS & DESTINATIONS (100% CRUD) */}
      {/* ============================================================== */}
      {adminTab === 'atlas' && (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '28px' }}>
          {/* Destinations Table */}
          <div className="glass-panel" style={{ padding: '28px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px', flexWrap: 'wrap', gap: '12px' }}>
              <div>
                <h2 style={{ fontSize: '1.3rem' }}>Island Atlas: Registered Destinations</h2>
                <p style={{ fontSize: '0.85rem', color: 'var(--text-muted)' }}>
                  Manage primary hubs, GPS coordinates, corridors, and travel zones across Sri Lanka.
                </p>
              </div>
              <div style={{ display: 'flex', gap: '10px', alignItems: 'center' }}>
                <input
                  type="text"
                  placeholder="Search destinations..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  style={{ padding: '8px 12px', borderRadius: 'var(--radius-sm)', border: '1px solid var(--color-border)', fontSize: '0.85rem' }}
                />
                <button
                  onClick={() => setShowAddDestModal(true)}
                  className="btn btn-primary"
                  style={{ fontSize: '0.85rem' }}
                >
                  + Add Destination
                </button>
              </div>
            </div>

            <div style={{ overflowX: 'auto' }}>
              <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left', fontSize: '0.88rem' }}>
                <thead>
                  <tr style={{ borderBottom: '2px solid var(--color-border)', color: 'var(--text-muted)' }}>
                    <th style={{ padding: '12px 16px' }}>Destination Name</th>
                    <th style={{ padding: '12px 16px' }}>Province</th>
                    <th style={{ padding: '12px 16px' }}>Corridor</th>
                    <th style={{ padding: '12px 16px' }}>GPS Coordinates</th>
                    <th style={{ padding: '12px 16px' }}>Places</th>
                    <th style={{ padding: '12px 16px', textAlign: 'right' }}>Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {filteredDestinations.map((d) => (
                    <tr key={d.id} style={{ borderBottom: '1px solid var(--color-border)' }}>
                      <td style={{ padding: '14px 16px' }}>
                        <strong style={{ color: 'var(--color-primary)' }}>{d.name}</strong>
                        <span style={{ fontSize: '0.78rem', color: 'var(--text-muted)', display: 'block' }}>{d.slug}</span>
                      </td>
                      <td style={{ padding: '14px 16px' }}>{d.province}</td>
                      <td style={{ padding: '14px 16px', fontSize: '0.82rem' }}>{d.corridor}</td>
                      <td style={{ padding: '14px 16px', fontFamily: 'monospace', fontSize: '0.8rem' }}>
                        {d.latitude.toFixed(4)}, {d.longitude.toFixed(4)}
                      </td>
                      <td style={{ padding: '14px 16px' }}>
                        <span className="badge badge-sapphire" style={{ fontSize: '0.72rem' }}>
                          {d.placesCount} Places
                        </span>
                      </td>
                      <td style={{ padding: '14px 16px', textAlign: 'right' }}>
                        <div style={{ display: 'flex', gap: '8px', justifyContent: 'flex-end' }}>
                          <button
                            onClick={() => setShowEditDestModal(d)}
                            className="btn btn-secondary"
                            style={{ padding: '4px 10px', fontSize: '0.75rem' }}
                          >
                            Edit
                          </button>
                          <button
                            onClick={() => {
                              setDestinations((prev) => prev.filter((item) => item.id !== d.id));
                              recordAudit('DESTINATION_DELETED', 'Destination', d.id, `Removed destination: ${d.name}`);
                            }}
                            className="btn btn-secondary"
                            style={{ padding: '4px 10px', fontSize: '0.75rem', color: 'var(--accent-ruby)' }}
                          >
                            Delete
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>

          {/* Places of Interest Table */}
          <div className="glass-panel" style={{ padding: '28px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px', flexWrap: 'wrap', gap: '12px' }}>
              <div>
                <h3 style={{ fontSize: '1.2rem' }}>Places of Interest (POIs & Attractions)</h3>
                <p style={{ fontSize: '0.82rem', color: 'var(--text-muted)' }}>
                  Accurate ticket tariffs, opening hours, and dwell times powering the Trip Graph algorithm.
                </p>
              </div>
              <button
                onClick={() => setShowAddPlaceModal(true)}
                className="btn btn-secondary"
                style={{ fontSize: '0.82rem' }}
              >
                + Add Place of Interest
              </button>
            </div>

            <div style={{ overflowX: 'auto' }}>
              <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left', fontSize: '0.85rem' }}>
                <thead>
                  <tr style={{ borderBottom: '2px solid var(--color-border)', color: 'var(--text-muted)' }}>
                    <th style={{ padding: '10px 14px' }}>Place Name</th>
                    <th style={{ padding: '10px 14px' }}>Destination Hub</th>
                    <th style={{ padding: '10px 14px' }}>Category</th>
                    <th style={{ padding: '10px 14px' }}>Opening Hours</th>
                    <th style={{ padding: '10px 14px' }}>Dwell Time</th>
                    <th style={{ padding: '10px 14px' }}>Ticket Fee (LKR)</th>
                    <th style={{ padding: '10px 14px', textAlign: 'right' }}>Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {places.map((plc) => (
                    <tr key={plc.id} style={{ borderBottom: '1px solid var(--color-border)' }}>
                      <td style={{ padding: '12px 14px' }}>
                        <strong>{plc.name}</strong>
                      </td>
                      <td style={{ padding: '12px 14px', color: 'var(--text-muted)' }}>{plc.destinationName}</td>
                      <td style={{ padding: '12px 14px' }}>
                        <span className="badge badge-sapphire" style={{ fontSize: '0.7rem' }}>{plc.category}</span>
                      </td>
                      <td style={{ padding: '12px 14px' }}>{plc.openingHours}</td>
                      <td style={{ padding: '12px 14px' }}>{plc.recommendedDurationMinutes} mins</td>
                      <td style={{ padding: '12px 14px', fontWeight: 600 }}>LKR {plc.ticketFeeLKR.toLocaleString()}</td>
                      <td style={{ padding: '12px 14px', textAlign: 'right' }}>
                        <button
                          onClick={() => {
                            setPlaces((prev) => prev.filter((p) => p.id !== plc.id));
                            recordAudit('PLACE_DELETED', 'Place', plc.id, `Removed place: ${plc.name}`);
                          }}
                          className="btn btn-secondary"
                          style={{ padding: '3px 8px', fontSize: '0.72rem', color: 'var(--accent-ruby)' }}
                        >
                          Delete
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      )}

      {/* ============================================================== */}
      {/* TAB 5: CATALOGUE & SERVICES INVENTORY (100% CRUD) */}
      {/* ============================================================== */}
      {adminTab === 'catalogue' && (
        <div className="glass-panel" style={{ padding: '28px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px', flexWrap: 'wrap', gap: '12px' }}>
            <div>
              <h2 style={{ fontSize: '1.3rem' }}>Catalogue & Bookable Inventory</h2>
              <p style={{ fontSize: '0.85rem', color: 'var(--text-muted)' }}>
                Master rates, vehicle fleets, boutique stays, certified guides, and adventure activities.
              </p>
            </div>
            <div style={{ display: 'flex', gap: '10px', alignItems: 'center' }}>
              <input
                type="text"
                placeholder="Search listings..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                style={{ padding: '8px 12px', borderRadius: 'var(--radius-sm)', border: '1px solid var(--color-border)', fontSize: '0.85rem' }}
              />
              <button
                onClick={() => setShowAddListingModal(true)}
                className="btn btn-primary"
                style={{ fontSize: '0.85rem' }}
              >
                + Create Service Listing
              </button>
            </div>
          </div>

          <div style={{ overflowX: 'auto' }}>
            <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left', fontSize: '0.88rem' }}>
              <thead>
                <tr style={{ borderBottom: '2px solid var(--color-border)', color: 'var(--text-muted)' }}>
                  <th style={{ padding: '12px 16px' }}>Service Title</th>
                  <th style={{ padding: '12px 16px' }}>Provider</th>
                  <th style={{ padding: '12px 16px' }}>Category</th>
                  <th style={{ padding: '12px 16px' }}>Base Price (LKR)</th>
                  <th style={{ padding: '12px 16px' }}>Cancellation Policy</th>
                  <th style={{ padding: '12px 16px' }}>Status</th>
                  <th style={{ padding: '12px 16px', textAlign: 'right' }}>Actions</th>
                </tr>
              </thead>
              <tbody>
                {filteredListings.map((l) => (
                  <tr key={l.id} style={{ borderBottom: '1px solid var(--color-border)' }}>
                    <td style={{ padding: '14px 16px' }}>
                      <strong style={{ color: 'var(--color-primary)' }}>{l.title}</strong>
                      <span style={{ fontSize: '0.78rem', color: 'var(--text-muted)', display: 'block' }}>{l.destination}</span>
                    </td>
                    <td style={{ padding: '14px 16px', fontSize: '0.82rem' }}>{l.providerName}</td>
                    <td style={{ padding: '14px 16px' }}>
                      <span className="badge badge-sapphire" style={{ fontSize: '0.72rem' }}>{l.category}</span>
                    </td>
                    <td style={{ padding: '14px 16px', fontWeight: 700, color: 'var(--color-primary)' }}>
                      LKR {l.basePriceLKR.toLocaleString()}
                    </td>
                    <td style={{ padding: '14px 16px', fontSize: '0.8rem', color: 'var(--text-muted)' }}>
                      {l.cancellationPolicy}
                    </td>
                    <td style={{ padding: '14px 16px' }}>
                      <span className={`badge ${l.isPublished ? 'badge-emerald' : 'badge-amber'}`} style={{ fontSize: '0.72rem' }}>
                        {l.isPublished ? 'PUBLISHED' : 'DRAFT'}
                      </span>
                    </td>
                    <td style={{ padding: '14px 16px', textAlign: 'right' }}>
                      <div style={{ display: 'flex', gap: '8px', justifyContent: 'flex-end' }}>
                        <button
                          onClick={() => {
                            const newPub = !l.isPublished;
                            setListings((prev) =>
                              prev.map((item) => (item.id === l.id ? { ...item, isPublished: newPub } : item))
                            );
                            recordAudit(
                              newPub ? 'LISTING_PUBLISHED' : 'LISTING_UNPUBLISHED',
                              'CatalogueListing',
                              l.id,
                              `Listing ${l.title} status toggled to ${newPub ? 'Published' : 'Draft'}`
                            );
                          }}
                          className="btn btn-secondary"
                          style={{ padding: '4px 10px', fontSize: '0.75rem' }}
                        >
                          {l.isPublished ? 'Unpublish' : 'Publish'}
                        </button>
                        <button
                          onClick={() => {
                            setListings((prev) => prev.filter((item) => item.id !== l.id));
                            recordAudit('LISTING_DELETED', 'CatalogueListing', l.id, `Deleted listing: ${l.title}`);
                          }}
                          className="btn btn-secondary"
                          style={{ padding: '4px 10px', fontSize: '0.75rem', color: 'var(--accent-ruby)' }}
                        >
                          Delete
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* ============================================================== */}
      {/* TAB 6: TOUR PACKAGES & CURATION ENGINE */}
      {/* ============================================================== */}
      {adminTab === 'packages' && (
        <div className="glass-panel" style={{ padding: '28px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px', flexWrap: 'wrap', gap: '12px' }}>
            <div>
              <h2 style={{ fontSize: '1.3rem' }}>Curated Tour Packages & Templates</h2>
              <p style={{ fontSize: '0.85rem', color: 'var(--text-muted)' }}>
                Review, approve, or reject multi-day itineraries submitted by verified SLTDA operators.
              </p>
            </div>
            <button
              onClick={() => setShowAddPackageModal(true)}
              className="btn btn-primary"
              style={{ fontSize: '0.85rem' }}
            >
              + Create Curated Package
            </button>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
            {packages.map((pkg) => (
              <div
                key={pkg.id}
                style={{
                  padding: '20px',
                  borderRadius: 'var(--radius-sm)',
                  border: '1px solid var(--color-border)',
                  background: '#fafbfc',
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  flexWrap: 'wrap',
                  gap: '16px',
                }}
              >
                <div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                    <strong style={{ fontSize: '1.05rem', color: 'var(--color-primary)' }}>{pkg.title}</strong>
                    <span
                      className={`badge ${
                        pkg.status === 'APPROVED'
                          ? 'badge-emerald'
                          : pkg.status === 'CHANGES_REQUESTED'
                          ? 'badge-amber'
                          : pkg.status === 'REJECTED'
                          ? 'badge-ruby'
                          : 'badge-sapphire'
                      }`}
                      style={{ fontSize: '0.72rem' }}
                    >
                      {pkg.status}
                    </span>
                    <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>{pkg.durationDays} Days</span>
                  </div>
                  <div style={{ fontSize: '0.85rem', color: 'var(--text-muted)', marginTop: '4px' }}>
                    Operator: <strong>{pkg.providerOrg}</strong> • SLTDA: <code>{pkg.sltdaLicense}</code> • Corridor: <strong>{pkg.corridor}</strong>
                  </div>
                  <div style={{ fontSize: '0.82rem', color: 'var(--color-secondary)', marginTop: '6px' }}>
                    Includes: {pkg.inclusions}
                  </div>
                </div>

                <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
                  <div style={{ textAlign: 'right' }}>
                    <div style={{ fontSize: '0.78rem', color: 'var(--text-muted)' }}>PACKAGE PRICE</div>
                    <div style={{ fontSize: '1.25rem', fontWeight: 800, color: 'var(--color-primary)' }}>
                      LKR {pkg.priceLKR.toLocaleString()}
                    </div>
                  </div>

                  <div style={{ display: 'flex', gap: '8px' }}>
                    {pkg.status !== 'APPROVED' && (
                      <button
                        onClick={() => handlePackageDecision(pkg.id, 'APPROVED')}
                        className="btn btn-secondary"
                        style={{ padding: '6px 14px', fontSize: '0.8rem', color: '#059669', borderColor: '#059669' }}
                      >
                        ✓ Approve
                      </button>
                    )}
                    {pkg.status !== 'CHANGES_REQUESTED' && (
                      <button
                        onClick={() => handlePackageDecision(pkg.id, 'CHANGES_REQUESTED')}
                        className="btn btn-secondary"
                        style={{ padding: '6px 14px', fontSize: '0.8rem', color: 'var(--accent-amber)' }}
                      >
                        Request Changes
                      </button>
                    )}
                    {pkg.status !== 'REJECTED' && (
                      <button
                        onClick={() => handlePackageDecision(pkg.id, 'REJECTED')}
                        className="btn btn-secondary"
                        style={{ padding: '6px 14px', fontSize: '0.8rem', color: 'var(--accent-ruby)' }}
                      >
                        ✕ Reject
                      </button>
                    )}
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* ============================================================== */}
      {/* TAB 7: GLOBAL BOOKINGS & ITINERARY OVERSIGHT (ADMIN OVERRIDE) */}
      {/* ============================================================== */}
      {adminTab === 'bookings' && (
        <div className="glass-panel" style={{ padding: '28px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px', flexWrap: 'wrap', gap: '12px' }}>
            <div>
              <h2 style={{ fontSize: '1.3rem' }}>Global Bookings & Itinerary Oversight</h2>
              <p style={{ fontSize: '0.85rem', color: 'var(--text-muted)' }}>
                Platform-wide reservation ledger. Administrators can enforce state overrides with mandatory audit justifications.
              </p>
            </div>
            <div style={{ display: 'flex', gap: '10px', alignItems: 'center' }}>
              <input
                type="text"
                placeholder="Search bookings..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                style={{ padding: '8px 12px', borderRadius: 'var(--radius-sm)', border: '1px solid var(--color-border)', fontSize: '0.85rem' }}
              />
              <span className="badge badge-emerald">PayHere Connected</span>
            </div>
          </div>

          <div style={{ overflowX: 'auto' }}>
            <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left', fontSize: '0.88rem' }}>
              <thead>
                <tr style={{ borderBottom: '2px solid var(--color-border)', color: 'var(--text-muted)' }}>
                  <th style={{ padding: '12px 16px' }}>Booking / Trip Ref</th>
                  <th style={{ padding: '12px 16px' }}>Traveler</th>
                  <th style={{ padding: '12px 16px' }}>Provider Service</th>
                  <th style={{ padding: '12px 16px' }}>Amount (LKR)</th>
                  <th style={{ padding: '12px 16px' }}>Voucher / PayRef</th>
                  <th style={{ padding: '12px 16px' }}>Status</th>
                  <th style={{ padding: '12px 16px', textAlign: 'right' }}>Actions</th>
                </tr>
              </thead>
              <tbody>
                {filteredBookings.map((b) => (
                  <tr key={b.id} style={{ borderBottom: '1px solid var(--color-border)' }}>
                    <td style={{ padding: '14px 16px' }}>
                      <strong style={{ color: 'var(--color-primary)' }}>{b.id}</strong>
                      <span style={{ fontSize: '0.78rem', color: 'var(--text-muted)', display: 'block' }}>{b.tripRef}</span>
                    </td>
                    <td style={{ padding: '14px 16px' }}>
                      <strong>{b.travelerName}</strong>
                      <span style={{ fontSize: '0.78rem', color: 'var(--text-muted)', display: 'block' }}>{b.travelerEmail}</span>
                    </td>
                    <td style={{ padding: '14px 16px' }}>
                      <div style={{ fontWeight: 600 }}>{b.serviceTitle}</div>
                      <div style={{ fontSize: '0.78rem', color: 'var(--text-muted)' }}>{b.providerName}</div>
                    </td>
                    <td style={{ padding: '14px 16px', fontWeight: 800, color: 'var(--color-primary)' }}>
                      LKR {b.amountLKR.toLocaleString()}
                    </td>
                    <td style={{ padding: '14px 16px', fontSize: '0.8rem', fontFamily: 'monospace' }}>
                      <div>{b.voucherCode}</div>
                      <div style={{ color: 'var(--text-muted)' }}>{b.paymentRef}</div>
                    </td>
                    <td style={{ padding: '14px 16px' }}>
                      <span
                        className={`badge ${
                          b.status === 'CONFIRMED' || b.status === 'PROVIDER_ACCEPTED'
                            ? 'badge-emerald'
                            : b.status === 'COMPLETED'
                            ? 'badge-sapphire'
                            : 'badge-ruby'
                        }`}
                        style={{ fontSize: '0.72rem' }}
                      >
                        {b.status}
                      </span>
                    </td>
                    <td style={{ padding: '14px 16px', textAlign: 'right' }}>
                      <button
                        onClick={() => {
                          setShowBookingOverrideModal(b);
                          setOverrideStatus(b.status);
                          setOverrideReason('');
                        }}
                        className="btn btn-secondary"
                        style={{ padding: '4px 12px', fontSize: '0.75rem' }}
                      >
                        ⚙️ Override Status
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* ============================================================== */}
      {/* TAB 8: FINANCE, ESCROW & DOUBLE-ENTRY CLEARING */}
      {/* ============================================================== */}
      {adminTab === 'finance' && (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '28px' }}>
          {/* Double-Entry Ledger Summary Cards */}
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))', gap: '20px' }}>
            <div className="glass-panel" style={{ padding: '24px' }}>
              <div style={{ fontSize: '0.8rem', color: 'var(--text-muted)', fontWeight: 600 }}>PLATFORM_ESCROW (LIABILITY)</div>
              <div style={{ fontSize: '1.7rem', fontWeight: 800, color: 'var(--color-primary)', marginTop: '6px' }}>
                LKR {totalEscrowHeld.toLocaleString()}
              </div>
              <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)', marginTop: '4px' }}>Held until service delivery completion</div>
            </div>

            <div className="glass-panel" style={{ padding: '24px' }}>
              <div style={{ fontSize: '0.8rem', color: 'var(--text-muted)', fontWeight: 600 }}>PROVIDER_PAYABLE (90% CLEARING)</div>
              <div style={{ fontSize: '1.7rem', fontWeight: 800, color: 'var(--color-secondary)', marginTop: '6px' }}>
                LKR {(totalEscrowHeld * 0.9).toLocaleString()}
              </div>
              <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)', marginTop: '4px' }}>Net owed to providers upon completion</div>
            </div>

            <div className="glass-panel" style={{ padding: '24px' }}>
              <div style={{ fontSize: '0.8rem', color: 'var(--text-muted)', fontWeight: 600 }}>PLATFORM_REVENUE (10% COMMISSION)</div>
              <div style={{ fontSize: '1.7rem', fontWeight: 800, color: '#059669', marginTop: '6px' }}>
                LKR {(totalEscrowHeld * 0.1).toLocaleString()}
              </div>
              <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)', marginTop: '4px' }}>TRAVERZA platform commission</div>
            </div>

            <div className="glass-panel" style={{ padding: '24px' }}>
              <div style={{ fontSize: '0.8rem', color: 'var(--text-muted)', fontWeight: 600 }}>SUSPENSE / VARIANCE ACCOUNT</div>
              <div style={{ fontSize: '1.7rem', fontWeight: 800, color: 'var(--color-text)', marginTop: '6px' }}>
                LKR 0.00
              </div>
              <div style={{ fontSize: '0.75rem', color: '#059669', marginTop: '4px', fontWeight: 600 }}>✓ Zero Discrepancy Invariant</div>
            </div>
          </div>

          {/* Pending Payout Releases */}
          <div className="glass-panel" style={{ padding: '28px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
              <div>
                <h2 style={{ fontSize: '1.3rem' }}>Escrow Payout Releases (Gate 5 Invariant)</h2>
                <p style={{ fontSize: '0.85rem', color: 'var(--text-muted)' }}>
                  Rule: Debit PLATFORM_ESCROW = Credit PROVIDER_PAYABLE (90%) + Credit PLATFORM_REVENUE (10%).
                </p>
              </div>
            </div>

            <div style={{ overflowX: 'auto' }}>
              <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left', fontSize: '0.88rem' }}>
                <thead>
                  <tr style={{ borderBottom: '2px solid var(--color-border)', color: 'var(--text-muted)' }}>
                    <th style={{ padding: '12px 16px' }}>Payout ID</th>
                    <th style={{ padding: '12px 16px' }}>Booking Ref</th>
                    <th style={{ padding: '12px 16px' }}>Provider Organization</th>
                    <th style={{ padding: '12px 16px' }}>Total Escrow</th>
                    <th style={{ padding: '12px 16px' }}>Provider (90%)</th>
                    <th style={{ padding: '12px 16px' }}>Platform (10%)</th>
                    <th style={{ padding: '12px 16px' }}>Status</th>
                    <th style={{ padding: '12px 16px', textAlign: 'right' }}>Action</th>
                  </tr>
                </thead>
                <tbody>
                  {escrowPayouts.map((ep) => (
                    <tr key={ep.id} style={{ borderBottom: '1px solid var(--color-border)' }}>
                      <td style={{ padding: '14px 16px', fontFamily: 'monospace', fontWeight: 600 }}>{ep.id}</td>
                      <td style={{ padding: '14px 16px', color: 'var(--color-primary)' }}>{ep.bookingId}</td>
                      <td style={{ padding: '14px 16px' }}>{ep.providerName}</td>
                      <td style={{ padding: '14px 16px', fontWeight: 700 }}>LKR {ep.totalAmountLKR.toLocaleString()}</td>
                      <td style={{ padding: '14px 16px', color: '#059669', fontWeight: 700 }}>
                        LKR {ep.providerShareLKR.toLocaleString()}
                      </td>
                      <td style={{ padding: '14px 16px', color: 'var(--color-secondary)', fontWeight: 700 }}>
                        LKR {ep.platformFeeLKR.toLocaleString()}
                      </td>
                      <td style={{ padding: '14px 16px' }}>
                        <span className={`badge ${ep.status === 'RELEASED' ? 'badge-emerald' : 'badge-amber'}`} style={{ fontSize: '0.72rem' }}>
                          {ep.status}
                        </span>
                      </td>
                      <td style={{ padding: '14px 16px', textAlign: 'right' }}>
                        {ep.status === 'HELD_IN_ESCROW' ? (
                          <button
                            onClick={() => handleReleaseEscrow(ep.id)}
                            className="btn btn-primary"
                            style={{ padding: '4px 12px', fontSize: '0.75rem' }}
                          >
                            Trigger 90/10 Release
                          </button>
                        ) : (
                          <span style={{ fontSize: '0.8rem', color: '#059669', fontWeight: 600 }}>✓ Settled</span>
                        )}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      )}

      {/* ============================================================== */}
      {/* TAB 9: AUTOPILOT DISRUPTION DESK */}
      {/* ============================================================== */}
      {adminTab === 'autopilot' && (
        <div className="glass-panel" style={{ padding: '28px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px', flexWrap: 'wrap', gap: '12px' }}>
            <div>
              <h2 style={{ fontSize: '1.3rem' }}>Autopilot Live Incident Command</h2>
              <p style={{ fontSize: '0.85rem', color: 'var(--text-muted)' }}>
                Real-time incident detection via flight radar, vehicle telemetry, and disaster management feeds.
              </p>
            </div>
            <span className="badge badge-ruby">
              {autopilotIncidents.filter((i) => i.status === 'PENDING_AUTHORIZATION').length} Pending Authorizations
            </span>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
            {autopilotIncidents.map((inc) => (
              <div
                key={inc.id}
                style={{
                  padding: '20px',
                  borderRadius: 'var(--radius-sm)',
                  border: inc.severity === 'CRITICAL' ? '1px solid var(--accent-ruby)' : '1px solid var(--color-border)',
                  background: '#fafbfc',
                }}
              >
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: '12px' }}>
                  <div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                      <span
                        className={`badge ${
                          inc.severity === 'CRITICAL' ? 'badge-ruby' : inc.severity === 'HIGH' ? 'badge-amber' : 'badge-sapphire'
                        }`}
                        style={{ fontSize: '0.72rem' }}
                      >
                        {inc.severity}
                      </span>
                      <strong style={{ fontSize: '1.05rem', color: 'var(--color-primary)' }}>{inc.id}</strong>
                      <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>{inc.tripId}</span>
                      <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>• {inc.observedAt}</span>
                    </div>
                    <p style={{ margin: '8px 0', fontSize: '0.9rem', color: 'var(--color-text)' }}>
                      {inc.impactAssessment}
                    </p>
                    <div style={{ background: 'rgba(8, 126, 139, 0.08)', padding: '10px 14px', borderRadius: 'var(--radius-sm)', fontSize: '0.85rem' }}>
                      <strong style={{ color: 'var(--color-secondary)' }}>Proposed Autonomous Resolution: </strong>
                      {inc.proposedAction}
                    </div>
                  </div>

                  <div style={{ textAlign: 'right' }}>
                    <div style={{ fontSize: '0.78rem', color: 'var(--text-muted)' }}>TRIP GRAPH FEASIBILITY</div>
                    <span className="badge badge-emerald" style={{ fontSize: '0.75rem', marginTop: '4px' }}>
                      ✓ {inc.tripGraphFeasibility}
                    </span>
                  </div>
                </div>

                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: '16px', paddingTop: '12px', borderTop: '1px solid var(--color-border)' }}>
                  <div style={{ fontSize: '0.82rem', color: 'var(--text-muted)' }}>
                    Backup Resource: <strong>{inc.backupProvider || 'Self-Rerouting Guidance'}</strong>
                  </div>
                  {inc.status === 'PENDING_AUTHORIZATION' ? (
                    <div style={{ display: 'flex', gap: '8px' }}>
                      <button
                        onClick={() => handleAutopilotDecision(inc.id, 'APPROVED')}
                        className="btn btn-primary"
                        style={{ fontSize: '0.8rem', padding: '6px 14px' }}
                      >
                        ⚡ Authorize Dispatch
                      </button>
                      <button
                        onClick={() => handleAutopilotDecision(inc.id, 'REJECTED')}
                        className="btn btn-secondary"
                        style={{ fontSize: '0.8rem', padding: '6px 14px', color: 'var(--accent-ruby)' }}
                      >
                        Manual Override
                      </button>
                    </div>
                  ) : (
                    <span className="badge badge-emerald" style={{ fontSize: '0.78rem' }}>
                      {inc.status}
                    </span>
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* ============================================================== */}
      {/* TAB 10: COMMUNITY MODERATION DESK */}
      {/* ============================================================== */}
      {adminTab === 'community' && (
        <div className="glass-panel" style={{ padding: '28px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
            <div>
              <h2 style={{ fontSize: '1.3rem' }}>Community Moderation & Safety Desk</h2>
              <p style={{ fontSize: '0.85rem', color: 'var(--text-muted)' }}>
                Review reported posts, unverified travel claims, and commercial spam on the Community Pulse feed.
              </p>
            </div>
            <span className="badge badge-amber">
              {communityReports.filter((r) => r.status === 'PENDING').length} Pending Reports
            </span>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
            {communityReports.map((rep) => (
              <div
                key={rep.id}
                style={{
                  padding: '20px',
                  borderRadius: 'var(--radius-sm)',
                  border: '1px solid var(--color-border)',
                  background: '#fafbfc',
                }}
              >
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: '12px' }}>
                  <div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                      <strong style={{ color: 'var(--color-primary)' }}>{rep.id} · {rep.targetType}</strong>
                      <span className="badge badge-ruby" style={{ fontSize: '0.72rem' }}>{rep.reason}</span>
                      <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>Reported {rep.reportedAt}</span>
                    </div>
                    <div style={{ fontSize: '0.82rem', color: 'var(--text-muted)', marginTop: '4px' }}>
                      Author: <strong>{rep.reportedItemAuthor}</strong> • Reported by: <strong>{rep.reporterName}</strong>
                    </div>
                  </div>
                  <div style={{ fontSize: '0.82rem', color: 'var(--color-secondary)', fontWeight: 600 }}>
                    📍 {rep.destination || rep.district}
                  </div>
                </div>

                <div style={{ background: '#f1f5f9', padding: '12px', borderRadius: 'var(--radius-sm)', margin: '12px 0', borderLeft: '3px solid var(--accent-ruby)' }}>
                  <p style={{ margin: 0, fontSize: '0.88rem', color: 'var(--color-text)' }}>
                    &ldquo;{rep.excerpt}&rdquo;
                  </p>
                </div>

                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', paddingTop: '10px', borderTop: '1px solid var(--color-border)' }}>
                  <span style={{ fontSize: '0.78rem', color: 'var(--text-muted)' }}>Status: <strong>{rep.status}</strong></span>
                  {rep.status === 'PENDING' && (
                    <div style={{ display: 'flex', gap: '8px' }}>
                      <button
                        onClick={() => handleCommunityDecision(rep.id, 'APPROVED_SAFE', 'Content reviewed and marked compliant')}
                        className="btn btn-secondary"
                        style={{ fontSize: '0.78rem', padding: '4px 10px' }}
                      >
                        ✓ Keep Safe
                      </button>
                      <button
                        onClick={() => handleCommunityDecision(rep.id, 'FLAGGED', 'Flagged for local ranger safety confirmation')}
                        className="btn btn-secondary"
                        style={{ fontSize: '0.78rem', padding: '4px 10px', color: 'var(--accent-amber)' }}
                      >
                        ⚠️ Flag Warning
                      </button>
                      <button
                        onClick={() => handleCommunityDecision(rep.id, 'REMOVED', 'Removed for violating safety guidelines')}
                        className="btn btn-primary"
                        style={{ fontSize: '0.78rem', padding: '4px 10px', background: 'var(--accent-ruby)' }}
                      >
                        🗑️ Remove Post
                      </button>
                    </div>
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* ============================================================== */}
      {/* TAB 11: EMERGENCY & OPERATIONAL BROADCAST CENTER */}
      {/* ============================================================== */}
      {adminTab === 'broadcast' && (
        <div className="glass-panel" style={{ padding: '28px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px', flexWrap: 'wrap', gap: '12px' }}>
            <div>
              <h2 style={{ fontSize: '1.3rem' }}>Emergency & Operational Broadcast Center</h2>
              <p style={{ fontSize: '0.85rem', color: 'var(--text-muted)' }}>
                Dispatch critical travel alerts, weather warnings, and corridor updates directly to mobile notification vaults.
              </p>
            </div>
            <button
              onClick={() => setShowBroadcastModal(true)}
              className="btn btn-primary"
              style={{ fontSize: '0.85rem', background: 'var(--accent-ruby)' }}
            >
              📢 Compose New Broadcast
            </button>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
            {broadcasts.map((bc) => (
              <div
                key={bc.id}
                style={{
                  padding: '18px',
                  borderRadius: 'var(--radius-sm)',
                  border: '1px solid var(--color-border)',
                  background: '#fafbfc',
                }}
              >
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                  <div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                      <span className={`badge ${bc.priority === 'HIGH' ? 'badge-ruby' : 'badge-sapphire'}`} style={{ fontSize: '0.72rem' }}>
                        {bc.priority} PRIORITY
                      </span>
                      <strong style={{ fontSize: '1.02rem', color: 'var(--color-primary)' }}>{bc.title}</strong>
                      <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>• {bc.corridor}</span>
                    </div>
                    <p style={{ margin: '8px 0 4px 0', fontSize: '0.88rem', color: 'var(--color-text)' }}>{bc.body}</p>
                    <div style={{ fontSize: '0.78rem', color: 'var(--text-muted)' }}>
                      Dispatched {bc.dispatchedAt} by {bc.dispatchedBy} • Delivered to <strong>{bc.recipientCount}</strong> active travelers
                    </div>
                  </div>
                  <span className="badge badge-emerald" style={{ fontSize: '0.72rem' }}>SENT</span>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* ============================================================== */}
      {/* TAB 12: IMMUTABLE AUDIT TRAIL */}
      {/* ============================================================== */}
      {adminTab === 'audit' && (
        <div className="glass-panel" style={{ padding: '28px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px', flexWrap: 'wrap', gap: '12px' }}>
            <div>
              <h2 style={{ fontSize: '1.3rem' }}>Immutable Regulatory Audit Trail</h2>
              <p style={{ fontSize: '0.85rem', color: 'var(--text-muted)' }}>
                Tamper-evident log of all operational state overrides, financial releases, and administrative mutations.
              </p>
            </div>
            <div style={{ display: 'flex', gap: '10px', alignItems: 'center' }}>
              <input
                type="text"
                placeholder="Search audit trail..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                style={{ padding: '8px 12px', borderRadius: 'var(--radius-sm)', border: '1px solid var(--color-border)', fontSize: '0.85rem' }}
              />
              <span className="badge badge-sapphire">{auditLogs.length} Events Recorded</span>
            </div>
          </div>

          <div style={{ overflowX: 'auto' }}>
            <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left', fontSize: '0.85rem' }}>
              <thead>
                <tr style={{ borderBottom: '2px solid var(--color-border)', color: 'var(--text-muted)' }}>
                  <th style={{ padding: '10px 14px' }}>Timestamp (UTC)</th>
                  <th style={{ padding: '10px 14px' }}>Actor</th>
                  <th style={{ padding: '10px 14px' }}>Action</th>
                  <th style={{ padding: '10px 14px' }}>Resource</th>
                  <th style={{ padding: '10px 14px' }}>Reason / Regulatory Justification</th>
                  <th style={{ padding: '10px 14px' }}>Delta Snapshot</th>
                </tr>
              </thead>
              <tbody>
                {filteredAuditLogs.map((log) => (
                  <tr key={log.id} style={{ borderBottom: '1px solid var(--color-border)' }}>
                    <td style={{ padding: '12px 14px', fontFamily: 'monospace', fontSize: '0.78rem', whiteSpace: 'nowrap' }}>
                      {log.timestamp}
                    </td>
                    <td style={{ padding: '12px 14px' }}>
                      <strong>{log.actorEmail}</strong>
                      <span style={{ fontSize: '0.72rem', color: 'var(--text-muted)', display: 'block' }}>{log.actorRole}</span>
                    </td>
                    <td style={{ padding: '12px 14px' }}>
                      <span className="badge badge-sapphire" style={{ fontSize: '0.7rem' }}>{log.action}</span>
                    </td>
                    <td style={{ padding: '12px 14px', fontFamily: 'monospace', fontSize: '0.78rem' }}>
                      {log.resourceType}: {log.resourceId}
                    </td>
                    <td style={{ padding: '12px 14px', color: 'var(--color-text)' }}>{log.reason}</td>
                    <td style={{ padding: '12px 14px', fontFamily: 'monospace', fontSize: '0.75rem', color: 'var(--text-muted)' }}>
                      {log.stateDelta || '—'}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* ============================================================== */}
      {/* MODAL 1: ADD NEW USER */}
      {/* ============================================================== */}
      {showAddUserModal && (
        <div style={modalBackdropStyle}>
          <div className="glass-panel" style={modalContentStyle}>
            <h3 style={{ fontSize: '1.25rem', marginBottom: '16px' }}>Onboard New User to Platform</h3>
            <form
              onSubmit={(e) => {
                e.preventDefault();
                const form = e.target as HTMLFormElement;
                const email = (form.elements.namedItem('email') as HTMLInputElement).value;
                const fullName = (form.elements.namedItem('fullName') as HTMLInputElement).value;
                const phone = (form.elements.namedItem('phone') as HTMLInputElement).value;
                const role = (form.elements.namedItem('role') as HTMLSelectElement).value as UserItem['role'];

                const newUser: UserItem = {
                  id: `usr-${(users.length + 1).toString().padStart(3, '0')}`,
                  email,
                  fullName,
                  phone,
                  role,
                  isActive: true,
                  isVerified: role === 'SUPER_ADMIN',
                  createdAt: FIXED_SYSTEM_TIME,
                };

                setUsers((prev) => [newUser, ...prev]);
                recordAudit('USER_CREATED', 'User', newUser.id, `Created user ${email} with role ${role}`);
                setShowAddUserModal(false);
              }}
              style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}
            >
              <div>
                <label style={labelStyle}>Full Name</label>
                <input required name="fullName" placeholder="e.g. Priyantha Dissanayake" style={inputStyle} />
              </div>
              <div>
                <label style={labelStyle}>Email Address</label>
                <input required type="email" name="email" placeholder="priyantha@example.lk" style={inputStyle} />
              </div>
              <div>
                <label style={labelStyle}>Phone Number</label>
                <input required name="phone" placeholder="+94 77 123 4567" style={inputStyle} />
              </div>
              <div>
                <label style={labelStyle}>Assigned Role</label>
                <select name="role" style={inputStyle}>
                  <option value="TRAVELER">TRAVELER (Customer)</option>
                  <option value="GUIDE">GUIDE (SLTDA Tour Guide)</option>
                  <option value="OPERATOR">OPERATOR (Fleet / Hotel)</option>
                  <option value="SUPER_ADMIN">SUPER_ADMIN (Operations Desk)</option>
                </select>
              </div>
              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px', marginTop: '12px' }}>
                <button type="button" onClick={() => setShowAddUserModal(false)} className="btn btn-secondary">
                  Cancel
                </button>
                <button type="submit" className="btn btn-primary">
                  Create User
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* ============================================================== */}
      {/* MODAL 2: EDIT USER */}
      {/* ============================================================== */}
      {showEditUserModal && (
        <div style={modalBackdropStyle}>
          <div className="glass-panel" style={modalContentStyle}>
            <h3 style={{ fontSize: '1.25rem', marginBottom: '16px' }}>Edit User Attributes & Role</h3>
            <form
              onSubmit={(e) => {
                e.preventDefault();
                const form = e.target as HTMLFormElement;
                const fullName = (form.elements.namedItem('fullName') as HTMLInputElement).value;
                const phone = (form.elements.namedItem('phone') as HTMLInputElement).value;
                const role = (form.elements.namedItem('role') as HTMLSelectElement).value as UserItem['role'];

                setUsers((prev) =>
                  prev.map((u) => (u.id === showEditUserModal.id ? { ...u, fullName, phone, role } : u))
                );
                recordAudit('USER_UPDATED', 'User', showEditUserModal.id, `Updated role to ${role} and info for ${showEditUserModal.email}`);
                setShowEditUserModal(null);
              }}
              style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}
            >
              <div>
                <label style={labelStyle}>User Email (Read-Only)</label>
                <input disabled value={showEditUserModal.email} style={{ ...inputStyle, background: '#f1f5f9' }} />
              </div>
              <div>
                <label style={labelStyle}>Full Name</label>
                <input required name="fullName" defaultValue={showEditUserModal.fullName} style={inputStyle} />
              </div>
              <div>
                <label style={labelStyle}>Phone Number</label>
                <input required name="phone" defaultValue={showEditUserModal.phone} style={inputStyle} />
              </div>
              <div>
                <label style={labelStyle}>Role</label>
                <select name="role" defaultValue={showEditUserModal.role} style={inputStyle}>
                  <option value="TRAVELER">TRAVELER</option>
                  <option value="GUIDE">GUIDE</option>
                  <option value="OPERATOR">OPERATOR</option>
                  <option value="SUPER_ADMIN">SUPER_ADMIN</option>
                </select>
              </div>
              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px', marginTop: '12px' }}>
                <button type="button" onClick={() => setShowEditUserModal(null)} className="btn btn-secondary">
                  Cancel
                </button>
                <button type="submit" className="btn btn-primary">
                  Save Changes
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* ============================================================== */}
      {/* MODAL 3: ONBOARD PROVIDER */}
      {/* ============================================================== */}
      {showAddProviderModal && (
        <div style={modalBackdropStyle}>
          <div className="glass-panel" style={modalContentStyle}>
            <h3 style={{ fontSize: '1.25rem', marginBottom: '16px' }}>Onboard SLTDA Provider Organization</h3>
            <form
              onSubmit={(e) => {
                e.preventDefault();
                const form = e.target as HTMLFormElement;
                const name = (form.elements.namedItem('name') as HTMLInputElement).value;
                const legalName = (form.elements.namedItem('legalName') as HTMLInputElement).value;
                const category = (form.elements.namedItem('category') as HTMLSelectElement).value as ProviderItem['category'];
                const sltdaLicense = (form.elements.namedItem('sltdaLicense') as HTMLInputElement).value;
                const businessRegNo = (form.elements.namedItem('businessRegNo') as HTMLInputElement).value;
                const contactEmail = (form.elements.namedItem('contactEmail') as HTMLInputElement).value;
                const contactPhone = (form.elements.namedItem('contactPhone') as HTMLInputElement).value;

                const newOrg: ProviderItem = {
                  id: `org-${(providers.length + 1).toString().padStart(3, '0')}`,
                  name,
                  legalName,
                  category,
                  sltdaLicense,
                  businessRegNo,
                  contactEmail,
                  contactPhone,
                  isVerified: true,
                  createdAt: FIXED_SYSTEM_TIME,
                };

                setProviders((prev) => [newOrg, ...prev]);
                recordAudit('PROVIDER_ONBOARDED', 'Organization', newOrg.id, `Onboarded ${name} (License: ${sltdaLicense})`);
                setShowAddProviderModal(false);
              }}
              style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}
            >
              <div>
                <label style={labelStyle}>Trade Name</label>
                <input required name="name" placeholder="Ceylon Highland Chauffeurs" style={inputStyle} />
              </div>
              <div>
                <label style={labelStyle}>Legal Name</label>
                <input required name="legalName" placeholder="Highland Chauffeur Services (Pvt) Ltd" style={inputStyle} />
              </div>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
                <div>
                  <label style={labelStyle}>Category</label>
                  <select name="category" style={inputStyle}>
                    <option value="TRANSPORT">TRANSPORT</option>
                    <option value="HOTEL">HOTEL</option>
                    <option value="GUIDE">GUIDE</option>
                    <option value="ACTIVITY">ACTIVITY</option>
                  </select>
                </div>
                <div>
                  <label style={labelStyle}>SLTDA License No</label>
                  <input required name="sltdaLicense" placeholder="SLTDA/CG/2026/220" style={inputStyle} />
                </div>
              </div>
              <div>
                <label style={labelStyle}>Business Registration No</label>
                <input required name="businessRegNo" placeholder="PV-12345" style={inputStyle} />
              </div>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
                <div>
                  <label style={labelStyle}>Contact Email</label>
                  <input required type="email" name="contactEmail" placeholder="ops@provider.lk" style={inputStyle} />
                </div>
                <div>
                  <label style={labelStyle}>Contact Phone</label>
                  <input required name="contactPhone" placeholder="+94 11 233 4455" style={inputStyle} />
                </div>
              </div>
              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px', marginTop: '12px' }}>
                <button type="button" onClick={() => setShowAddProviderModal(false)} className="btn btn-secondary">
                  Cancel
                </button>
                <button type="submit" className="btn btn-primary">
                  Onboard & Verify
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* ============================================================== */}
      {/* MODAL 3B: EDIT PROVIDER */}
      {/* ============================================================== */}
      {showEditProviderModal && (
        <div style={modalBackdropStyle}>
          <div className="glass-panel" style={modalContentStyle}>
            <h3 style={{ fontSize: '1.25rem', marginBottom: '16px' }}>Edit Provider Organization</h3>
            <form
              onSubmit={(e) => {
                e.preventDefault();
                const form = e.target as HTMLFormElement;
                const name = (form.elements.namedItem('name') as HTMLInputElement).value;
                const legalName = (form.elements.namedItem('legalName') as HTMLInputElement).value;
                const contactEmail = (form.elements.namedItem('contactEmail') as HTMLInputElement).value;
                const contactPhone = (form.elements.namedItem('contactPhone') as HTMLInputElement).value;

                setProviders((prev) =>
                  prev.map((p) =>
                    p.id === showEditProviderModal.id ? { ...p, name, legalName, contactEmail, contactPhone } : p
                  )
                );
                recordAudit('PROVIDER_UPDATED', 'Organization', showEditProviderModal.id, `Updated details for ${name}`);
                setShowEditProviderModal(null);
              }}
              style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}
            >
              <div>
                <label style={labelStyle}>Trade Name</label>
                <input required name="name" defaultValue={showEditProviderModal.name} style={inputStyle} />
              </div>
              <div>
                <label style={labelStyle}>Legal Name</label>
                <input required name="legalName" defaultValue={showEditProviderModal.legalName} style={inputStyle} />
              </div>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
                <div>
                  <label style={labelStyle}>Contact Email</label>
                  <input required type="email" name="contactEmail" defaultValue={showEditProviderModal.contactEmail} style={inputStyle} />
                </div>
                <div>
                  <label style={labelStyle}>Contact Phone</label>
                  <input required name="contactPhone" defaultValue={showEditProviderModal.contactPhone} style={inputStyle} />
                </div>
              </div>
              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px', marginTop: '12px' }}>
                <button type="button" onClick={() => setShowEditProviderModal(null)} className="btn btn-secondary">
                  Cancel
                </button>
                <button type="submit" className="btn btn-primary">
                  Save Changes
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* ============================================================== */}
      {/* MODAL 4: ADD DESTINATION */}
      {/* ============================================================== */}
      {showAddDestModal && (
        <div style={modalBackdropStyle}>
          <div className="glass-panel" style={modalContentStyle}>
            <h3 style={{ fontSize: '1.25rem', marginBottom: '16px' }}>Add Island Atlas Destination Hub</h3>
            <form
              onSubmit={(e) => {
                e.preventDefault();
                const form = e.target as HTMLFormElement;
                const name = (form.elements.namedItem('name') as HTMLInputElement).value;
                const slug = name.toLowerCase().replace(/[^a-z0-9]+/g, '-');
                const province = (form.elements.namedItem('province') as HTMLInputElement).value;
                const corridor = (form.elements.namedItem('corridor') as HTMLInputElement).value;
                const description = (form.elements.namedItem('description') as HTMLTextAreaElement).value;
                const latitude = parseFloat((form.elements.namedItem('latitude') as HTMLInputElement).value);
                const longitude = parseFloat((form.elements.namedItem('longitude') as HTMLInputElement).value);

                const newDest: DestinationItem = {
                  id: `dest-${(destinations.length + 1).toString().padStart(3, '0')}`,
                  name,
                  slug,
                  province,
                  corridor,
                  description,
                  latitude,
                  longitude,
                  placesCount: 0,
                };

                setDestinations((prev) => [newDest, ...prev]);
                recordAudit('DESTINATION_CREATED', 'Destination', newDest.id, `Added destination ${name} in ${province}`);
                setShowAddDestModal(false);
              }}
              style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}
            >
              <div>
                <label style={labelStyle}>Destination Name</label>
                <input required name="name" placeholder="e.g. Ella Mountain Gap" style={inputStyle} />
              </div>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
                <div>
                  <label style={labelStyle}>Province</label>
                  <input required name="province" placeholder="Uva Province" style={inputStyle} />
                </div>
                <div>
                  <label style={labelStyle}>Corridor Name</label>
                  <input required name="corridor" placeholder="Hill Country Tea Route" style={inputStyle} />
                </div>
              </div>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
                <div>
                  <label style={labelStyle}>Latitude</label>
                  <input required type="number" step="any" name="latitude" placeholder="6.8667" style={inputStyle} />
                </div>
                <div>
                  <label style={labelStyle}>Longitude</label>
                  <input required type="number" step="any" name="longitude" placeholder="81.0466" style={inputStyle} />
                </div>
              </div>
              <div>
                <label style={labelStyle}>Description</label>
                <textarea required name="description" rows={3} placeholder="Scenic mountain gap known for Nine Arch Bridge..." style={inputStyle} />
              </div>
              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px', marginTop: '12px' }}>
                <button type="button" onClick={() => setShowAddDestModal(false)} className="btn btn-secondary">
                  Cancel
                </button>
                <button type="submit" className="btn btn-primary">
                  Save Destination
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* ============================================================== */}
      {/* MODAL 4B: EDIT DESTINATION */}
      {/* ============================================================== */}
      {showEditDestModal && (
        <div style={modalBackdropStyle}>
          <div className="glass-panel" style={modalContentStyle}>
            <h3 style={{ fontSize: '1.25rem', marginBottom: '16px' }}>Edit Destination Hub</h3>
            <form
              onSubmit={(e) => {
                e.preventDefault();
                const form = e.target as HTMLFormElement;
                const name = (form.elements.namedItem('name') as HTMLInputElement).value;
                const province = (form.elements.namedItem('province') as HTMLInputElement).value;
                const corridor = (form.elements.namedItem('corridor') as HTMLInputElement).value;
                const description = (form.elements.namedItem('description') as HTMLTextAreaElement).value;

                setDestinations((prev) =>
                  prev.map((d) =>
                    d.id === showEditDestModal.id ? { ...d, name, province, corridor, description } : d
                  )
                );
                recordAudit('DESTINATION_UPDATED', 'Destination', showEditDestModal.id, `Updated destination ${name}`);
                setShowEditDestModal(null);
              }}
              style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}
            >
              <div>
                <label style={labelStyle}>Destination Name</label>
                <input required name="name" defaultValue={showEditDestModal.name} style={inputStyle} />
              </div>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
                <div>
                  <label style={labelStyle}>Province</label>
                  <input required name="province" defaultValue={showEditDestModal.province} style={inputStyle} />
                </div>
                <div>
                  <label style={labelStyle}>Corridor Name</label>
                  <input required name="corridor" defaultValue={showEditDestModal.corridor} style={inputStyle} />
                </div>
              </div>
              <div>
                <label style={labelStyle}>Description</label>
                <textarea required name="description" rows={3} defaultValue={showEditDestModal.description} style={inputStyle} />
              </div>
              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px', marginTop: '12px' }}>
                <button type="button" onClick={() => setShowEditDestModal(null)} className="btn btn-secondary">
                  Cancel
                </button>
                <button type="submit" className="btn btn-primary">
                  Save Changes
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* ============================================================== */}
      {/* MODAL 5: ADD PLACE OF INTEREST */}
      {/* ============================================================== */}
      {showAddPlaceModal && (
        <div style={modalBackdropStyle}>
          <div className="glass-panel" style={modalContentStyle}>
            <h3 style={{ fontSize: '1.25rem', marginBottom: '16px' }}>Add Place of Interest (POI)</h3>
            <form
              onSubmit={(e) => {
                e.preventDefault();
                const form = e.target as HTMLFormElement;
                const destId = (form.elements.namedItem('destinationId') as HTMLSelectElement).value;
                const targetDest = destinations.find((d) => d.id === destId);
                const name = (form.elements.namedItem('name') as HTMLInputElement).value;
                const category = (form.elements.namedItem('category') as HTMLSelectElement).value as PlaceItem['category'];
                const openingHours = (form.elements.namedItem('openingHours') as HTMLInputElement).value;
                const recommendedDurationMinutes = parseInt((form.elements.namedItem('duration') as HTMLInputElement).value, 10);
                const ticketFeeLKR = parseInt((form.elements.namedItem('fee') as HTMLInputElement).value, 10);

                const newPlace: PlaceItem = {
                  id: `plc-${(places.length + 1).toString().padStart(3, '0')}`,
                  destinationId: destId,
                  destinationName: targetDest?.name || 'General',
                  name,
                  slug: name.toLowerCase().replace(/[^a-z0-9]+/g, '-'),
                  category,
                  description: `${name} located in ${targetDest?.name || 'Sri Lanka'}.`,
                  latitude: targetDest ? targetDest.latitude : 7.0,
                  longitude: targetDest ? targetDest.longitude : 80.0,
                  recommendedDurationMinutes,
                  openingHours,
                  ticketFeeLKR,
                };

                setPlaces((prev) => [newPlace, ...prev]);
                recordAudit('PLACE_CREATED', 'Place', newPlace.id, `Created POI ${name} under ${newPlace.destinationName}`);
                setShowAddPlaceModal(false);
              }}
              style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}
            >
              <div>
                <label style={labelStyle}>Target Destination Hub</label>
                <select name="destinationId" style={inputStyle}>
                  {destinations.map((d) => (
                    <option key={d.id} value={d.id}>{d.name} ({d.province})</option>
                  ))}
                </select>
              </div>
              <div>
                <label style={labelStyle}>Place Name</label>
                <input required name="name" placeholder="e.g. Nine Arch Bridge" style={inputStyle} />
              </div>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
                <div>
                  <label style={labelStyle}>Category</label>
                  <select name="category" style={inputStyle}>
                    <option value="CULTURAL">CULTURAL</option>
                    <option value="NATURE">NATURE</option>
                    <option value="BEACH">BEACH</option>
                    <option value="RELIGIOUS">RELIGIOUS</option>
                  </select>
                </div>
                <div>
                  <label style={labelStyle}>Opening Hours</label>
                  <input required name="openingHours" placeholder="06:00 - 18:00" style={inputStyle} />
                </div>
              </div>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
                <div>
                  <label style={labelStyle}>Dwell Time (Minutes)</label>
                  <input required type="number" name="duration" defaultValue={90} style={inputStyle} />
                </div>
                <div>
                  <label style={labelStyle}>Ticket Fee (LKR)</label>
                  <input required type="number" name="fee" defaultValue={0} style={inputStyle} />
                </div>
              </div>
              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px', marginTop: '12px' }}>
                <button type="button" onClick={() => setShowAddPlaceModal(false)} className="btn btn-secondary">
                  Cancel
                </button>
                <button type="submit" className="btn btn-primary">
                  Add Place
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* ============================================================== */}
      {/* MODAL 6: CREATE SERVICE LISTING */}
      {/* ============================================================== */}
      {showAddListingModal && (
        <div style={modalBackdropStyle}>
          <div className="glass-panel" style={modalContentStyle}>
            <h3 style={{ fontSize: '1.25rem', marginBottom: '16px' }}>Add Service Listing to Marketplace</h3>
            <form
              onSubmit={(e) => {
                e.preventDefault();
                const form = e.target as HTMLFormElement;
                const title = (form.elements.namedItem('title') as HTMLInputElement).value;
                const providerName = (form.elements.namedItem('providerName') as HTMLSelectElement).value;
                const category = (form.elements.namedItem('category') as HTMLSelectElement).value as ListingItem['category'];
                const destination = (form.elements.namedItem('destination') as HTMLInputElement).value;
                const basePriceLKR = parseInt((form.elements.namedItem('basePriceLKR') as HTMLInputElement).value, 10);
                const cancellationPolicy = (form.elements.namedItem('cancellationPolicy') as HTMLSelectElement).value as ListingItem['cancellationPolicy'];

                const newListing: ListingItem = {
                  id: `lst-${(listings.length + 1).toString().padStart(3, '0')}`,
                  title,
                  providerName,
                  category,
                  destination,
                  basePriceLKR,
                  cancellationPolicy,
                  isPublished: true,
                };

                setListings((prev) => [newListing, ...prev]);
                recordAudit('LISTING_CREATED', 'CatalogueListing', newListing.id, `Published listing ${title} (LKR ${basePriceLKR})`);
                setShowAddListingModal(false);
              }}
              style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}
            >
              <div>
                <label style={labelStyle}>Listing Title</label>
                <input required name="title" placeholder="e.g. Luxury Private Chauffeur SUV (Airport -> Sigiriya)" style={inputStyle} />
              </div>
              <div>
                <label style={labelStyle}>Offering Provider Organization</label>
                <select name="providerName" style={inputStyle}>
                  {providers.map((p) => (
                    <option key={p.id} value={p.name}>{p.name} ({p.sltdaLicense})</option>
                  ))}
                </select>
              </div>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
                <div>
                  <label style={labelStyle}>Category</label>
                  <select name="category" style={inputStyle}>
                    <option value="TRANSFER">TRANSFER</option>
                    <option value="STAY">STAY</option>
                    <option value="GUIDE">GUIDE</option>
                    <option value="ACTIVITY">ACTIVITY</option>
                  </select>
                </div>
                <div>
                  <label style={labelStyle}>Base Price (LKR)</label>
                  <input required type="number" name="basePriceLKR" placeholder="25000" style={inputStyle} />
                </div>
              </div>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
                <div>
                  <label style={labelStyle}>Corridor / Destination</label>
                  <input required name="destination" placeholder="Colombo - Sigiriya Corridor" style={inputStyle} />
                </div>
                <div>
                  <label style={labelStyle}>Cancellation Policy</label>
                  <select name="cancellationPolicy" style={inputStyle}>
                    <option value="STANDARD_48H">STANDARD_48H (Full refund 48h prior)</option>
                    <option value="STRICT_24H">STRICT_24H (Full refund 24h prior)</option>
                    <option value="FLEXIBLE">FLEXIBLE (Cancel anytime)</option>
                  </select>
                </div>
              </div>
              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px', marginTop: '12px' }}>
                <button type="button" onClick={() => setShowAddListingModal(false)} className="btn btn-secondary">
                  Cancel
                </button>
                <button type="submit" className="btn btn-primary">
                  Publish Listing
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* ============================================================== */}
      {/* MODAL 7: CREATE TOUR PACKAGE */}
      {/* ============================================================== */}
      {showAddPackageModal && (
        <div style={modalBackdropStyle}>
          <div className="glass-panel" style={modalContentStyle}>
            <h3 style={{ fontSize: '1.25rem', marginBottom: '16px' }}>Curate New Tour Package</h3>
            <form
              onSubmit={(e) => {
                e.preventDefault();
                const form = e.target as HTMLFormElement;
                const title = (form.elements.namedItem('title') as HTMLInputElement).value;
                const providerOrg = (form.elements.namedItem('providerOrg') as HTMLSelectElement).value;
                const priceLKR = parseInt((form.elements.namedItem('priceLKR') as HTMLInputElement).value, 10);
                const corridor = (form.elements.namedItem('corridor') as HTMLInputElement).value;
                const durationDays = parseInt((form.elements.namedItem('durationDays') as HTMLInputElement).value, 10);
                const inclusions = (form.elements.namedItem('inclusions') as HTMLInputElement).value;

                const newPkg: PackageItem = {
                  id: `pkg-${(packages.length + 1).toString().padStart(3, '0')}`,
                  title,
                  providerOrg,
                  type: 'OPERATOR_PACKAGE',
                  priceLKR,
                  corridor,
                  durationDays,
                  inclusions,
                  exclusions: 'Personal gratuities & discretionary fees',
                  sltdaLicense: 'SLTDA/SQA/2026/108',
                  status: 'APPROVED',
                };

                setPackages((prev) => [newPkg, ...prev]);
                recordAudit('PACKAGE_CREATED', 'TourPackage', newPkg.id, `Created & approved curated package: ${title}`);
                setShowAddPackageModal(false);
              }}
              style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}
            >
              <div>
                <label style={labelStyle}>Package Title</label>
                <input required name="title" placeholder="5-Day Cultural & Wildlife Grand Tour" style={inputStyle} />
              </div>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
                <div>
                  <label style={labelStyle}>Operator</label>
                  <select name="providerOrg" style={inputStyle}>
                    {providers.map((p) => (
                      <option key={p.id} value={p.name}>{p.name}</option>
                    ))}
                  </select>
                </div>
                <div>
                  <label style={labelStyle}>Price in LKR</label>
                  <input required type="number" name="priceLKR" placeholder="115000" style={inputStyle} />
                </div>
              </div>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
                <div>
                  <label style={labelStyle}>Corridor</label>
                  <input required name="corridor" placeholder="Colombo · Sigiriya · Kandy · Yala" style={inputStyle} />
                </div>
                <div>
                  <label style={labelStyle}>Duration (Days)</label>
                  <input required type="number" name="durationDays" defaultValue={5} style={inputStyle} />
                </div>
              </div>
              <div>
                <label style={labelStyle}>Included Services</label>
                <input required name="inclusions" placeholder="Private AC Van, 4-Star Stays, Safari Jeep & Driver Guide" style={inputStyle} />
              </div>
              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px', marginTop: '12px' }}>
                <button type="button" onClick={() => setShowAddPackageModal(false)} className="btn btn-secondary">
                  Cancel
                </button>
                <button type="submit" className="btn btn-primary">
                  Save & Publish
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* ============================================================== */}
      {/* MODAL 8: BOOKING STATE OVERRIDE */}
      {/* ============================================================== */}
      {showBookingOverrideModal && (
        <div style={modalBackdropStyle}>
          <div className="glass-panel" style={modalContentStyle}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
              <h3 style={{ fontSize: '1.25rem', margin: 0 }}>Enforce Administrative State Override</h3>
              <span className="badge badge-sapphire">{showBookingOverrideModal.id}</span>
            </div>

            <div style={{ background: '#f8fafc', padding: '14px', borderRadius: 'var(--radius-sm)', marginBottom: '16px', fontSize: '0.85rem' }}>
              <div>Trip Reference: <strong>{showBookingOverrideModal.tripRef}</strong></div>
              <div>Traveler: <strong>{showBookingOverrideModal.travelerName} ({showBookingOverrideModal.travelerEmail})</strong></div>
              <div>Current Status: <span className="badge badge-amber">{showBookingOverrideModal.status}</span></div>
            </div>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
              <div>
                <label style={labelStyle}>Target Booking Status</label>
                <select
                  value={overrideStatus}
                  onChange={(e) => setOverrideStatus(e.target.value as BookingItem['status'])}
                  style={inputStyle}
                >
                  <option value="CONFIRMED">CONFIRMED (Traveler paid & itinerary locked)</option>
                  <option value="PROVIDER_ACCEPTED">PROVIDER_ACCEPTED (Provider allocated resources)</option>
                  <option value="COMPLETED">COMPLETED (Trip safely executed)</option>
                  <option value="CANCELLED">CANCELLED (Trigger refund workflow)</option>
                  <option value="EXCEPTION">EXCEPTION (Escalate to Disruption Operations)</option>
                </select>
              </div>

              <div>
                <label style={labelStyle}>
                  Mandatory Operational Justification (Logged to Immutable Audit Trail)
                </label>
                <textarea
                  rows={3}
                  required
                  placeholder="e.g. SLTDA Grievance resolution #LK-892: Provider vehicle breakdown replacement confirmed via hotline."
                  value={overrideReason}
                  onChange={(e) => setOverrideReason(e.target.value)}
                  style={inputStyle}
                />
              </div>

              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px', marginTop: '12px' }}>
                <button
                  type="button"
                  onClick={() => setShowBookingOverrideModal(null)}
                  className="btn btn-secondary"
                >
                  Cancel
                </button>
                <button
                  type="button"
                  onClick={handleExecuteBookingOverride}
                  disabled={!overrideReason.trim()}
                  className="btn btn-primary"
                  style={{ background: 'var(--color-primary)' }}
                >
                  Commit State Override
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* ============================================================== */}
      {/* MODAL 9: BROADCAST DISPATCHER */}
      {/* ============================================================== */}
      {showBroadcastModal && (
        <div style={modalBackdropStyle}>
          <div className="glass-panel" style={modalContentStyle}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
              <h3 style={{ fontSize: '1.25rem', margin: 0 }}>📢 Dispatch System Broadcast Alert</h3>
              <span className="badge badge-ruby">{broadcastPriority} Priority</span>
            </div>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
              <div>
                <label style={labelStyle}>Alert Title</label>
                <input
                  required
                  placeholder="e.g. Flash Flood Advisory: Southern Expressway (Galle -> Matara)"
                  value={broadcastTitle}
                  onChange={(e) => setBroadcastTitle(e.target.value)}
                  style={inputStyle}
                />
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: '12px' }}>
                <div>
                  <label style={labelStyle}>Category</label>
                  <select
                    value={broadcastCategory}
                    onChange={(e) => setBroadcastCategory(e.target.value as typeof broadcastCategory)}
                    style={inputStyle}
                  >
                    <option value="SAFETY">SAFETY</option>
                    <option value="TRIP">TRIP</option>
                    <option value="BOOKING">BOOKING</option>
                    <option value="OFFERS">OFFERS</option>
                  </select>
                </div>
                <div>
                  <label style={labelStyle}>Priority</label>
                  <select
                    value={broadcastPriority}
                    onChange={(e) => setBroadcastPriority(e.target.value as 'HIGH' | 'MEDIUM' | 'LOW')}
                    style={inputStyle}
                  >
                    <option value="HIGH">HIGH</option>
                    <option value="MEDIUM">MEDIUM</option>
                    <option value="LOW">LOW</option>
                  </select>
                </div>
                <div>
                  <label style={labelStyle}>Corridor</label>
                  <select
                    value={broadcastCorridor}
                    onChange={(e) => setBroadcastCorridor(e.target.value)}
                    style={inputStyle}
                  >
                    <option value="Islandwide">Islandwide</option>
                    <option value="Colombo - Sigiriya - Kandy - Nuwara Eliya">Central Corridor</option>
                    <option value="Southern Coastal Corridor">Southern Coast</option>
                    <option value="Kandy - Nuwara Eliya Highlands">Highlands</option>
                  </select>
                </div>
              </div>

              <div>
                <label style={labelStyle}>Message Body</label>
                <textarea
                  rows={4}
                  required
                  placeholder="Enter concise, verified guidance for drivers and travelers currently in the corridor..."
                  value={broadcastBody}
                  onChange={(e) => setBroadcastBody(e.target.value)}
                  style={inputStyle}
                />
              </div>

              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px', marginTop: '12px' }}>
                <button
                  type="button"
                  onClick={() => setShowBroadcastModal(false)}
                  className="btn btn-secondary"
                >
                  Cancel
                </button>
                <button
                  type="button"
                  onClick={handleDispatchBroadcast}
                  disabled={!broadcastTitle.trim() || !broadcastBody.trim()}
                  className="btn btn-primary"
                  style={{ background: 'var(--accent-ruby)' }}
                >
                  Push Notification Alert
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

// ==========================================
// 4. SHARED STYLES FOR ENTERPRISE UI
// ==========================================

const modalBackdropStyle: React.CSSProperties = {
  position: 'fixed',
  top: 0,
  left: 0,
  right: 0,
  bottom: 0,
  background: 'rgba(7, 59, 92, 0.65)',
  backdropFilter: 'blur(8px)',
  display: 'flex',
  alignItems: 'center',
  justifyContent: 'center',
  zIndex: 1000,
  padding: '20px',
};

const modalContentStyle: React.CSSProperties = {
  width: '100%',
  maxWidth: '560px',
  background: '#ffffff',
  borderRadius: 'var(--radius-md)',
  padding: '28px',
  boxShadow: '0 20px 45px rgba(0, 0, 0, 0.2)',
  border: '1px solid var(--color-border)',
  maxHeight: '90vh',
  overflowY: 'auto',
};

const labelStyle: React.CSSProperties = {
  display: 'block',
  fontSize: '0.82rem',
  fontWeight: 600,
  color: 'var(--color-primary)',
  marginBottom: '6px',
};

const inputStyle: React.CSSProperties = {
  width: '100%',
  padding: '10px 14px',
  borderRadius: 'var(--radius-sm)',
  border: '1px solid var(--color-border)',
  fontSize: '0.88rem',
  background: '#ffffff',
  color: 'var(--color-text)',
  outline: 'none',
  boxSizing: 'border-box',
};
