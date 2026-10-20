import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

enum BookingStatus {
  requestSubmitted,
  providerAccepted,
  confirmed,
  inProgress,
  completed,
  cancelled,
  exception,
}

extension BookingStatusExtension on BookingStatus {
  String get label {
    switch (this) {
      case BookingStatus.requestSubmitted:
        return 'REQUEST SUBMITTED';
      case BookingStatus.providerAccepted:
        return 'PROVIDER ACCEPTED';
      case BookingStatus.confirmed:
        return 'CONFIRMED';
      case BookingStatus.inProgress:
        return 'IN PROGRESS';
      case BookingStatus.completed:
        return 'COMPLETED';
      case BookingStatus.cancelled:
        return 'CANCELLED';
      case BookingStatus.exception:
        return 'DISRUPTED / SOS';
    }
  }

  Color get color {
    switch (this) {
      case BookingStatus.requestSubmitted:
        return TraverzaColors.amberWarning;
      case BookingStatus.providerAccepted:
        return TraverzaColors.secondary;
      case BookingStatus.confirmed:
      case BookingStatus.completed:
        return TraverzaColors.emeraldSuccess;
      case BookingStatus.inProgress:
        return TraverzaColors.primary;
      case BookingStatus.cancelled:
        return Colors.redAccent;
      case BookingStatus.exception:
        return Colors.deepOrangeAccent;
    }
  }
}

class TraverzaBookingEvent {
  final String title;
  final String description;
  final String timestamp;
  final String actorRole;
  final bool isCompleted;

  const TraverzaBookingEvent({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.actorRole,
    this.isCompleted = true,
  });
}

class TraverzaBooking {
  final String id;
  final String tripId;
  final String serviceTitle;
  final String category;
  final String providerName;
  final String sltdaLicenseNo;
  final String dateDescription;
  final String timeWindow;
  final String locationDetails;
  final String priceFormatted;
  final String priceBasis;
  BookingStatus status;
  final String cancellationTerms;
  final DateTime? responseDeadline;
  final String qrToken;
  final List<TraverzaBookingEvent> timeline;

  TraverzaBooking({
    required this.id,
    required this.tripId,
    required this.serviceTitle,
    required this.category,
    required this.providerName,
    required this.sltdaLicenseNo,
    required this.dateDescription,
    required this.timeWindow,
    required this.locationDetails,
    required this.priceFormatted,
    required this.priceBasis,
    required this.status,
    required this.cancellationTerms,
    this.responseDeadline,
    required this.qrToken,
    required this.timeline,
  });

  static List<TraverzaBooking> getSampleBookings() {
    return [
      TraverzaBooking(
        id: 'TRIP-LK-2026-9041-B01',
        tripId: 'TRIP-LK-2026-9041',
        serviceTitle: 'Airport to Sigiriya Luxury Transfer',
        category: 'TRANSFER',
        providerName: 'Ceylon Chauffeurs Guild (Pvt) Ltd',
        sltdaLicenseNo: 'SLTDA/CG/2026/102',
        dateDescription: '24 Oct 2026',
        timeWindow: '10:30 Departure (Flight UL-504 CMB Arrival)',
        locationDetails: 'Bandaranaike Intl Airport (CMB) → Sigiriya',
        priceFormatted: 'LKR 18,500',
        priceBasis: 'Per Vehicle (Toyota Prado LK-402)',
        status: BookingStatus.confirmed,
        cancellationTerms: 'Free cancellation up to 24h before pickup',
        qrToken: 'TRV-VOUCHER-LK402-9041-CONFIRMED-CMB-SIG',
        timeline: const [
          TraverzaBookingEvent(
            title: 'Quote Snapshot Generated',
            description: 'Guaranteed rate LKR 18,500 locked for 24 hours.',
            timestamp: '20 Oct 2026, 09:15 UTC',
            actorRole: 'SYSTEM',
          ),
          TraverzaBookingEvent(
            title: 'Booking Request Submitted',
            description: 'Requested chauffeur dispatch for arrival flight UL-504.',
            timestamp: '20 Oct 2026, 09:20 UTC',
            actorRole: 'TRAVELLER',
          ),
          TraverzaBookingEvent(
            title: 'Provider Accepted Request',
            description: 'Vehicle Prado #LK-402 and accredited chauffeur assigned.',
            timestamp: '20 Oct 2026, 11:45 UTC',
            actorRole: 'PROVIDER',
          ),
          TraverzaBookingEvent(
            title: 'Escrow Payment Confirmed',
            description: 'Payment captured securely. Protected under SLTDA traveler guarantee.',
            timestamp: '20 Oct 2026, 12:00 UTC',
            actorRole: 'PAYMENT_GATEWAY',
          ),
        ],
      ),
      TraverzaBooking(
        id: 'TRIP-LK-2026-9041-B02',
        tripId: 'TRIP-LK-2026-9041',
        serviceTitle: 'Sigiriya Water Garden Eco Villa',
        category: 'STAY',
        providerName: 'Boutique Heritage Stays (Pvt) Ltd',
        sltdaLicenseNo: 'SLTDA/SQ/2026/089',
        dateDescription: '24 Oct - 25 Oct 2026 (1 Night)',
        timeWindow: '14:00 Check-in • 11:00 Check-out',
        locationDetails: 'Sigiriya Ancient Moat Precinct, Central Province',
        priceFormatted: 'LKR 38,000',
        priceBasis: 'Per Villa / Night (Deluxe Plunge Pool Chalet)',
        status: BookingStatus.requestSubmitted,
        responseDeadline: DateTime.now().add(const Duration(hours: 8, minutes: 42)),
        cancellationTerms: 'Standard 48h cancellation policy',
        qrToken: 'TRV-VOUCHER-ECOVILLA-9041-PENDING-SIG',
        timeline: const [
          TraverzaBookingEvent(
            title: 'Quote Snapshot Generated',
            description: 'Deluxe Chalet quote LKR 38,000 locked with breakfast inclusion.',
            timestamp: '20 Oct 2026, 10:00 UTC',
            actorRole: 'SYSTEM',
          ),
          TraverzaBookingEvent(
            title: 'Booking Request Submitted',
            description: 'Submitted to property reservation desk. Awaiting 12-hour SLA response.',
            timestamp: '20 Oct 2026, 10:18 UTC',
            actorRole: 'TRAVELLER',
          ),
        ],
      ),
      TraverzaBooking(
        id: 'TRIP-LK-2026-9041-B03',
        tripId: 'TRIP-LK-2026-9041',
        serviceTitle: 'Sigiriya Rock Fortress Guided Archaeological Ascent',
        category: 'ACTIVITY',
        providerName: 'Cultural Heritage Guide Guild',
        sltdaLicenseNo: 'SLTDA/GD/2026/044',
        dateDescription: '24 Oct 2026',
        timeWindow: '15:00 - 17:30 (Sunset Ascent)',
        locationDetails: 'Sigiriya Citadel Lion Rock Base Entrance',
        priceFormatted: 'LKR 12,000',
        priceBasis: 'Per Group (Up to 4 Persons)',
        status: BookingStatus.confirmed,
        cancellationTerms: 'Free cancellation up to 24h before ascent',
        qrToken: 'TRV-VOUCHER-SIGASCENT-9041-CONFIRMED',
        timeline: const [
          TraverzaBookingEvent(
            title: 'Booking Request Submitted',
            description: 'Requested afternoon archaeological guide ascent.',
            timestamp: '19 Oct 2026, 14:00 UTC',
            actorRole: 'TRAVELLER',
          ),
          TraverzaBookingEvent(
            title: 'Provider Accepted Request',
            description: 'Licensed archaeological guide assigned (SLTDA Lic #044).',
            timestamp: '19 Oct 2026, 15:30 UTC',
            actorRole: 'PROVIDER',
          ),
          TraverzaBookingEvent(
            title: 'Escrow Payment Confirmed',
            description: 'Digital voucher issued. SLTDA standard rate guaranteed.',
            timestamp: '19 Oct 2026, 16:00 UTC',
            actorRole: 'PAYMENT_GATEWAY',
          ),
        ],
      ),
      TraverzaBooking(
        id: 'TRIP-LK-2026-8812-B01',
        tripId: 'TRIP-LK-2026-8812',
        serviceTitle: 'Sacred City of Kandy Walking Tour',
        category: 'GUIDE',
        providerName: 'Kandyan Heritage Guild',
        sltdaLicenseNo: 'SLTDA/GD/2026/031',
        dateDescription: '15 Sep 2026',
        timeWindow: '09:00 - 12:00 Completed',
        locationDetails: 'Kandy Lake Round & Tooth Relic Precinct',
        priceFormatted: 'LKR 9,500',
        priceBasis: 'Per Session (2 Travellers)',
        status: BookingStatus.completed,
        cancellationTerms: 'Non-refundable (Service completed)',
        qrToken: 'TRV-VOUCHER-KANDYWALK-COMPLETED-PAST',
        timeline: const [
          TraverzaBookingEvent(
            title: 'Tour Commenced',
            description: 'Guide validated QR check-in at Queen\'s Hotel meeting point.',
            timestamp: '15 Sep 2026, 09:05 Local',
            actorRole: 'PROVIDER',
          ),
          TraverzaBookingEvent(
            title: 'Service Completed',
            description: 'Excursion successfully concluded. Escrow payout released to provider.',
            timestamp: '15 Sep 2026, 12:15 Local',
            actorRole: 'SYSTEM',
          ),
        ],
      ),
      TraverzaBooking(
        id: 'TRIP-LK-2026-8700-B04',
        tripId: 'TRIP-LK-2026-8700',
        serviceTitle: 'Yala National Park Leopard Dawn Safari',
        category: 'ACTIVITY',
        providerName: 'Yala Wild Trackers (Pvt) Ltd',
        sltdaLicenseNo: 'SLTDA/WT/2026/007',
        dateDescription: '02 Aug 2026',
        timeWindow: '05:30 - 10:00 (Palatupana Gate)',
        locationDetails: 'Yala National Park Block 1',
        priceFormatted: 'LKR 24,000',
        priceBasis: 'Per Jeep (Full Safari Rig)',
        status: BookingStatus.cancelled,
        cancellationTerms: 'Refund of LKR 24,000 completed to original payment method',
        qrToken: 'TRV-VOUCHER-YALASAFARI-CANCELLED-REFUNDED',
        timeline: const [
          TraverzaBookingEvent(
            title: 'Cancellation Requested',
            description: 'Traveller rescheduled due to severe monsoon rain alert.',
            timestamp: '01 Aug 2026, 10:00 Local',
            actorRole: 'TRAVELLER',
          ),
          TraverzaBookingEvent(
            title: 'Refund Approved & Processed',
            description: 'Full refund LKR 24,000 returned to card. Zero platform cancellation fees.',
            timestamp: '01 Aug 2026, 11:30 Local',
            actorRole: 'RESCUE_DESK',
          ),
        ],
      ),
    ];
  }
}

class TraverzaServiceItem {
  final String id;
  final String title;
  final String category;
  final String provider;
  final String license;
  final String price;
  final String priceBasis;
  final String policy;
  final String rating;
  final String location;
  final String imageUrl;
  final String fitToTripReason;
  final String inclusions;

  const TraverzaServiceItem({
    required this.id,
    required this.title,
    required this.category,
    required this.provider,
    required this.license,
    required this.price,
    required this.priceBasis,
    required this.policy,
    required this.rating,
    required this.location,
    required this.imageUrl,
    required this.fitToTripReason,
    required this.inclusions,
  });

  static List<TraverzaServiceItem> getCuratedInventory() {
    return const [
      TraverzaServiceItem(
        id: 'SVC-LK-001',
        category: 'TRANSFER',
        title: 'Airport to Sigiriya Luxury Transfer',
        provider: 'Ceylon Chauffeurs Guild (Pvt) Ltd',
        license: 'SLTDA/CG/2026/102',
        price: 'LKR 18,500',
        priceBasis: 'per vehicle · up to 4 passengers',
        policy: 'Free cancellation up to 24h before pickup',
        rating: '4.98 (124 reviews)',
        location: 'Katunayake (CMB) → Sigiriya',
        imageUrl: 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?auto=format&fit=crop&w=800&q=80',
        fitToTripReason: 'Matches Day 1 arrival corridor · Verified highway transit buffer',
        inclusions: 'Air-conditioned Toyota Prado, expressway tolls, bottled Ceylon water, English-speaking tourist chauffeur.',
      ),
      TraverzaServiceItem(
        id: 'SVC-LK-002',
        category: 'STAY',
        title: 'Sigiriya Water Garden Eco Villa',
        provider: 'Boutique Heritage Stays (Pvt) Ltd',
        license: 'SLTDA/SQ/2026/089',
        price: 'LKR 38,000',
        priceBasis: 'per villa / night · breakfast included',
        policy: 'Standard 48h cancellation policy',
        rating: '4.95 (88 reviews)',
        location: 'Sigiriya Ancient Citadel Precinct',
        imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=800&q=80',
        fitToTripReason: 'Located 4.5km from Lion Rock · Guaranteed check-in rest period',
        inclusions: 'Deluxe Chalet, private plunge pool, welcome king coconut drink, daily traditional breakfast.',
      ),
      TraverzaServiceItem(
        id: 'SVC-LK-003',
        category: 'GUIDE',
        title: 'Sacred City of Kandy Walking Tour',
        provider: 'Cultural Heritage Guide Guild',
        license: 'SLTDA/GD/2026/044',
        price: 'LKR 9,500',
        priceBasis: 'per session · 2 travellers',
        policy: 'Free cancellation up to 24h',
        rating: '4.92 (54 reviews)',
        location: 'Kandy Sacred City & Temple of the Tooth',
        imageUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?auto=format&fit=crop&w=800&q=80',
        fitToTripReason: 'Fits Day 2 morning itinerary · Certified archaeological lecturer',
        inclusions: 'Licensed National Tour Guide Lecturer, entrance logistics guidance, UNESCO architectural commentary.',
      ),
      TraverzaServiceItem(
        id: 'SVC-LK-004',
        category: 'ACTIVITY',
        title: 'Pedro Tea Estate Heritage Factory Walk',
        provider: 'Highland Tea Excursions (Pvt) Ltd',
        license: 'SLTDA/AC/2026/015',
        price: 'LKR 8,000',
        priceBasis: 'per adult · guided tasting included',
        policy: 'Standard 24h policy',
        rating: '4.89 (42 reviews)',
        location: 'Nuwara Eliya Highlands',
        imageUrl: 'https://images.unsplash.com/photo-1588598198321-9735fd52455b?auto=format&fit=crop&w=800&q=80',
        fitToTripReason: 'Fits Day 3 Highland corridor · High-altitude artisanal tea processing',
        inclusions: 'Tea field plucking walk, working factory tour, guided tea master tasting of 5 single-estate black teas.',
      ),
      TraverzaServiceItem(
        id: 'SVC-LK-005',
        category: 'ACTIVITY',
        title: 'Sigiriya Rock Fortress Guided Archaeological Ascent',
        provider: 'Cultural Heritage Guide Guild',
        license: 'SLTDA/GD/2026/044',
        price: 'LKR 12,000',
        priceBasis: 'per group · up to 4 persons',
        policy: 'Free cancellation up to 24h',
        rating: '4.96 (142 reviews)',
        location: 'Sigiriya Ancient Citadel',
        imageUrl: 'https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?auto=format&fit=crop&w=800&q=80',
        fitToTripReason: 'Scheduled 15:00-17:30 · Concludes safely before 18:15 sunset',
        inclusions: 'Certified archaeological guide, water garden commentary, mirror wall fresco history, summit assistance.',
      ),
      TraverzaServiceItem(
        id: 'SVC-LK-006',
        category: 'GUIDE',
        title: 'Galle Dutch Fort Heritage & Ramparts Sunset Walk',
        provider: 'Southern Coast Heritage Guild',
        license: 'SLTDA/GD/2026/058',
        price: 'LKR 8,500',
        priceBasis: 'per couple · 2 hours',
        policy: 'Free cancellation up to 24h',
        rating: '4.94 (67 reviews)',
        location: 'Galle Maritime District',
        imageUrl: 'https://images.unsplash.com/photo-1552465011-b4e21bf6e79a?auto=format&fit=crop&w=800&q=80',
        fitToTripReason: 'Southern coastal extension · Bastion & lighthouse maritime history',
        inclusions: '17th-century fortification commentary, Dutch Reformed Church visit, sunset rampart viewing.',
      ),
    ];
  }
}
