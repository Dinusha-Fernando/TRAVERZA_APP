import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class SavedCollection {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  int itemCount;
  final bool isDefault;

  SavedCollection({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.itemCount,
    this.isDefault = false,
  });
}

class SavedItem {
  final String id;
  final String serviceId;
  final String title;
  final String category; // STAY, TRANSFER, GUIDE, ACTIVITY, DINING
  final String provider;
  final String sltdaLicense;
  final String price;
  final String priceBasis;
  final String rating;
  final String location;
  final String imageUrl;
  String collectionId;
  final String corridorDay; // e.g. Day 1 - Arrival, Day 2 - Sigiriya, Day 3 - Kandy, Day 4 - Nuwara Eliya
  String? personalNotes;
  final bool isFitToTrip;
  final String fitToTripReason;
  final String cancellationTerms;
  final String inclusions;
  final DateTime dateSaved;

  SavedItem({
    required this.id,
    required this.serviceId,
    required this.title,
    required this.category,
    required this.provider,
    required this.sltdaLicense,
    required this.price,
    required this.priceBasis,
    required this.rating,
    required this.location,
    required this.imageUrl,
    required this.collectionId,
    required this.corridorDay,
    this.personalNotes,
    this.isFitToTrip = true,
    required this.fitToTripReason,
    required this.cancellationTerms,
    required this.inclusions,
    required this.dateSaved,
  });

  SavedItem copyWith({
    String? collectionId,
    String? personalNotes,
  }) {
    return SavedItem(
      id: id,
      serviceId: serviceId,
      title: title,
      category: category,
      provider: provider,
      sltdaLicense: sltdaLicense,
      price: price,
      priceBasis: priceBasis,
      rating: rating,
      location: location,
      imageUrl: imageUrl,
      collectionId: collectionId ?? this.collectionId,
      corridorDay: corridorDay,
      personalNotes: personalNotes ?? this.personalNotes,
      isFitToTrip: isFitToTrip,
      fitToTripReason: fitToTripReason,
      cancellationTerms: cancellationTerms,
      inclusions: inclusions,
      dateSaved: dateSaved,
    );
  }
}

class SavedRepository {
  static List<SavedCollection> getInitialCollections() {
    return [
      SavedCollection(
        id: 'col_all',
        name: 'All Saved',
        description: 'Complete shortlist of saved services across Sri Lanka',
        icon: Icons.bookmarks_outlined,
        color: TraverzaColors.primary,
        itemCount: 5,
        isDefault: true,
      ),
      SavedCollection(
        id: 'col_stays',
        name: 'Cultural Triangle Stays',
        description: 'Eco villas, heritage resorts and luxury chalets in Sigiriya & Dambulla',
        icon: Icons.hotel_outlined,
        color: TraverzaColors.secondary,
        itemCount: 2,
      ),
      SavedCollection(
        id: 'col_trans',
        name: 'Highland Chauffeurs',
        description: 'Air-conditioned Toyota Prado transfers with certified tourist drivers',
        icon: Icons.directions_car_outlined,
        color: TraverzaColors.primary,
        itemCount: 1,
      ),
      SavedCollection(
        id: 'col_guides',
        name: 'UNESCO Heritage & Walks',
        description: 'Archaeological lectures, fortress ascents and botanical tours',
        icon: Icons.tour_outlined,
        color: TraverzaColors.accent,
        itemCount: 2,
      ),
    ];
  }

  static List<SavedItem> getInitialSavedItems() {
    return [
      SavedItem(
        id: 'save_001',
        serviceId: 'SVC-LK-001',
        title: 'Airport to Sigiriya Luxury Transfer',
        category: 'TRANSFER',
        provider: 'Ceylon Chauffeurs Guild (Pvt) Ltd',
        sltdaLicense: 'SLTDA/CG/2026/102',
        price: 'LKR 18,500',
        priceBasis: 'per vehicle · up to 4 passengers',
        rating: '4.98 (124 reviews)',
        location: 'Katunayake (CMB) → Sigiriya',
        imageUrl: 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?auto=format&fit=crop&w=800&q=80',
        collectionId: 'col_trans',
        corridorDay: 'Day 1 · CMB Arrival',
        personalNotes: 'Requested Prado with booster seat for arrival flight UL-504.',
        isFitToTrip: true,
        fitToTripReason: 'Matches Day 1 arrival corridor · Expressway toll included',
        cancellationTerms: 'Free cancellation up to 24h before pickup',
        inclusions: 'Toyota Prado LK-402, highway tolls, cold Ceylon king coconut, tourist chauffeur.',
        dateSaved: DateTime(2026, 10, 19, 14, 30),
      ),
      SavedItem(
        id: 'save_002',
        serviceId: 'SVC-LK-002',
        title: 'Sigiriya Water Garden Eco Villa',
        category: 'STAY',
        provider: 'Boutique Heritage Stays (Pvt) Ltd',
        sltdaLicense: 'SLTDA/SQ/2026/089',
        price: 'LKR 38,000',
        priceBasis: 'per villa / night · breakfast included',
        rating: '4.95 (88 reviews)',
        location: 'Sigiriya Ancient Citadel Precinct',
        imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=800&q=80',
        collectionId: 'col_stays',
        corridorDay: 'Day 2 · Sigiriya Overnight',
        personalNotes: 'Private plunge pool with direct view towards Lion Rock fortress.',
        isFitToTrip: true,
        fitToTripReason: 'Located 4.5km from Lion Rock · Guaranteed 14:00 check-in rest period',
        cancellationTerms: 'Standard 48h cancellation policy · 100% refund',
        inclusions: 'Deluxe Chalet, private plunge pool, daily organic breakfast, lotus tea welcome.',
        dateSaved: DateTime(2026, 10, 19, 16, 45),
      ),
      SavedItem(
        id: 'save_003',
        serviceId: 'SVC-LK-005',
        title: 'Sigiriya Rock Fortress Guided Archaeological Ascent',
        category: 'ACTIVITY',
        provider: 'Cultural Heritage Guide Guild',
        sltdaLicense: 'SLTDA/GD/2026/044',
        price: 'LKR 12,000',
        priceBasis: 'per group · up to 4 persons',
        rating: '4.96 (142 reviews)',
        location: 'Sigiriya Ancient Citadel',
        imageUrl: 'https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?auto=format&fit=crop&w=800&q=80',
        collectionId: 'col_guides',
        corridorDay: 'Day 2 · Afternoon Ascent',
        personalNotes: 'Scheduled for 15:30 to beat mid-day heat and catch golden hour on summit.',
        isFitToTrip: true,
        fitToTripReason: 'Scheduled 15:00-17:30 · Concludes safely before 18:15 sunset',
        cancellationTerms: 'Free cancellation up to 24h before ascent',
        inclusions: 'Certified archaeological guide, water garden commentary, fresco history, summit logistics.',
        dateSaved: DateTime(2026, 10, 20, 09, 15),
      ),
      SavedItem(
        id: 'save_004',
        serviceId: 'SVC-LK-003',
        title: 'Sacred City of Kandy Walking Tour',
        category: 'GUIDE',
        provider: 'Cultural Heritage Guide Guild',
        sltdaLicense: 'SLTDA/GD/2026/031',
        price: 'LKR 9,500',
        priceBasis: 'per session · 2 travellers',
        rating: '4.92 (54 reviews)',
        location: 'Kandy Sacred City & Temple of the Tooth',
        imageUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?auto=format&fit=crop&w=800&q=80',
        collectionId: 'col_guides',
        corridorDay: 'Day 3 · Kandy Morning',
        personalNotes: null,
        isFitToTrip: true,
        fitToTripReason: 'Fits Day 3 morning itinerary · Certified archaeological lecturer',
        cancellationTerms: 'Free cancellation up to 24h before session',
        inclusions: 'National Tour Guide Lecturer, entrance logistics, UNESCO royal court commentary.',
        dateSaved: DateTime(2026, 10, 20, 11, 20),
      ),
      SavedItem(
        id: 'save_005',
        serviceId: 'SVC-LK-007',
        title: 'Heritance Kandalama Forest Suite',
        category: 'STAY',
        provider: 'Aitken Spence Hotel Managements (Pvt) Ltd',
        sltdaLicense: 'SLTDA/HT/2026/012',
        price: 'LKR 46,000',
        priceBasis: 'per suite / night · half-board',
        rating: '4.96 (210 reviews)',
        location: 'Dambulla Kandalama Lake',
        imageUrl: 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=800&q=80',
        collectionId: 'col_stays',
        corridorDay: 'Day 2 · Alternative Stay',
        personalNotes: 'Geoffrey Bawa architectural landmark. Shortlisted to compare against Sigiriya Eco Villa.',
        isFitToTrip: true,
        fitToTripReason: '12km from Sigiriya · Buffer transit 25 mins through scenic reserve',
        cancellationTerms: 'Free cancellation up to 7 days before check-in',
        inclusions: 'Luxury Lake View Suite, breakfast & dinner, resident naturalist guided bird walk.',
        dateSaved: DateTime(2026, 10, 20, 13, 00),
      ),
    ];
  }
}
