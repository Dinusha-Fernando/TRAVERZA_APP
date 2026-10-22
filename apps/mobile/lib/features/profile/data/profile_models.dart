import 'package:flutter/material.dart';

/// Models for TRAVERZA Traveller Profile & Emergency Hub
class EmergencyContact {
  final String name;
  final String relationship;
  final String phone;
  final String email;
  final bool isPrimary;

  const EmergencyContact({
    required this.name,
    required this.relationship,
    required this.phone,
    required this.email,
    this.isPrimary = true,
  });

  EmergencyContact copyWith({
    String? name,
    String? relationship,
    String? phone,
    String? email,
    bool? isPrimary,
  }) {
    return EmergencyContact(
      name: name ?? this.name,
      relationship: relationship ?? this.relationship,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }
}

class TravelPreferences {
  final String hillPacing; // 'Scenic Buffers (+45m)', 'Standard (+20m)', 'Direct Express'
  final String preferredVehicle; // 'Hybrid SUV / Prado 4x4', 'Premium AC Van (KDH)', 'Comfort Sedan'
  final String dietary; // 'Halal & Ceylon Seafood', 'Vegetarian / Vegan', 'No Restrictions'
  final String spiceTolerance; // 'Mild (Foreign Palate)', 'Medium Authentic', 'Fiery Sri Lankan'
  final String guideLanguage; // 'English (Fluent)', 'German', 'French', 'Sinhala / Tamil'
  final String settlementCurrency; // 'USD ($)', 'LKR (Rs)', 'EUR (€)', 'GBP (£)'
  final bool offlineMapCaching;
  final bool biometricLock;
  final bool motionSicknessKit;

  const TravelPreferences({
    required this.hillPacing,
    required this.preferredVehicle,
    required this.dietary,
    required this.spiceTolerance,
    required this.guideLanguage,
    required this.settlementCurrency,
    this.offlineMapCaching = true,
    this.biometricLock = true,
    this.motionSicknessKit = true,
  });

  TravelPreferences copyWith({
    String? hillPacing,
    String? preferredVehicle,
    String? dietary,
    String? spiceTolerance,
    String? guideLanguage,
    String? settlementCurrency,
    bool? offlineMapCaching,
    bool? biometricLock,
    bool? motionSicknessKit,
  }) {
    return TravelPreferences(
      hillPacing: hillPacing ?? this.hillPacing,
      preferredVehicle: preferredVehicle ?? this.preferredVehicle,
      dietary: dietary ?? this.dietary,
      spiceTolerance: spiceTolerance ?? this.spiceTolerance,
      guideLanguage: guideLanguage ?? this.guideLanguage,
      settlementCurrency: settlementCurrency ?? this.settlementCurrency,
      offlineMapCaching: offlineMapCaching ?? this.offlineMapCaching,
      biometricLock: biometricLock ?? this.biometricLock,
      motionSicknessKit: motionSicknessKit ?? this.motionSicknessKit,
    );
  }
}

enum DocumentType {
  etaVisa,
  insurance,
  passport,
  drivingPermit,
  hotelVoucher,
}

class TravelDocument {
  final String id;
  final String title;
  final DocumentType type;
  final String documentNumber;
  final String issuer;
  final String expiryDate;
  final String statusLabel;
  final bool isValid;
  final String notes;
  final IconData icon;

  const TravelDocument({
    required this.id,
    required this.title,
    required this.type,
    required this.documentNumber,
    required this.issuer,
    required this.expiryDate,
    required this.statusLabel,
    this.isValid = true,
    required this.notes,
    required this.icon,
  });
}

class TravellerProfile {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String nationality;
  final String membershipTier;
  final int tierLevel;
  final String sltdaLicenseNo;
  final bool isSltdaRegistered;
  final bool isKycVerified;
  final String memberSince;
  final String activeCorridor;
  final int tripsCompleted;
  final int provincesVisited;
  final double carbonOffsetKg;
  final int safetyReadinessScore;
  final EmergencyContact emergencyContact;
  final TravelPreferences preferences;
  final List<TravelDocument> documents;
  final String? avatarUrl;

  const TravellerProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.nationality,
    required this.membershipTier,
    required this.tierLevel,
    required this.sltdaLicenseNo,
    required this.isSltdaRegistered,
    required this.isKycVerified,
    required this.memberSince,
    required this.activeCorridor,
    required this.tripsCompleted,
    required this.provincesVisited,
    required this.carbonOffsetKg,
    required this.safetyReadinessScore,
    required this.emergencyContact,
    required this.preferences,
    required this.documents,
    this.avatarUrl,
  });

  TravellerProfile copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? nationality,
    String? membershipTier,
    int? tierLevel,
    String? sltdaLicenseNo,
    bool? isSltdaRegistered,
    bool? isKycVerified,
    String? memberSince,
    String? activeCorridor,
    int? tripsCompleted,
    int? provincesVisited,
    double? carbonOffsetKg,
    int? safetyReadinessScore,
    EmergencyContact? emergencyContact,
    TravelPreferences? preferences,
    List<TravelDocument>? documents,
    String? avatarUrl,
    bool clearAvatar = false,
  }) {
    return TravellerProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      nationality: nationality ?? this.nationality,
      membershipTier: membershipTier ?? this.membershipTier,
      tierLevel: tierLevel ?? this.tierLevel,
      sltdaLicenseNo: sltdaLicenseNo ?? this.sltdaLicenseNo,
      isSltdaRegistered: isSltdaRegistered ?? this.isSltdaRegistered,
      isKycVerified: isKycVerified ?? this.isKycVerified,
      memberSince: memberSince ?? this.memberSince,
      activeCorridor: activeCorridor ?? this.activeCorridor,
      tripsCompleted: tripsCompleted ?? this.tripsCompleted,
      provincesVisited: provincesVisited ?? this.provincesVisited,
      carbonOffsetKg: carbonOffsetKg ?? this.carbonOffsetKg,
      safetyReadinessScore: safetyReadinessScore ?? this.safetyReadinessScore,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      preferences: preferences ?? this.preferences,
      documents: documents ?? this.documents,
      avatarUrl: clearAvatar ? null : (avatarUrl ?? this.avatarUrl),
    );
  }

  /// Default baseline profile for TRAVERZA Pilot Traveller
  static TravellerProfile get defaultProfile => const TravellerProfile(
        id: 'TRV-LK-9041-INTL',
        fullName: 'Dinusha Wijesinghe',
        email: 'dinusha.w@traverza.lk',
        phone: '+94 77 123 4567',
        nationality: 'Sri Lanka / International Pilot',
        membershipTier: 'Pilot Elite Member',
        tierLevel: 3,
        sltdaLicenseNo: 'SLTDA/IND/2026/0921',
        isSltdaRegistered: true,
        isKycVerified: true,
        memberSince: 'January 2026',
        activeCorridor: 'Colombo (CMB) → Sigiriya → Kandy → Nuwara Eliya',
        tripsCompleted: 12,
        provincesVisited: 4,
        carbonOffsetKg: 48.5,
        safetyReadinessScore: 98,
        emergencyContact: EmergencyContact(
          name: 'Dilani Wijesinghe',
          relationship: 'Sister',
          phone: '+94 77 987 6543',
          email: 'dilani.w@outlook.com',
          isPrimary: true,
        ),
        preferences: TravelPreferences(
          hillPacing: 'Scenic Buffers (+45m)',
          preferredVehicle: 'Hybrid SUV / Prado 4x4',
          dietary: 'Halal & Ceylon Seafood',
          spiceTolerance: 'Mild (Foreign Palate)',
          guideLanguage: 'English (Fluent)',
          settlementCurrency: 'USD (\$)',
          offlineMapCaching: true,
          biometricLock: true,
          motionSicknessKit: true,
        ),
        documents: [
          TravelDocument(
            id: 'DOC-ETA-01',
            title: 'Sri Lanka Electronic Travel Authorization (ETA)',
            type: DocumentType.etaVisa,
            documentNumber: 'ETA-2026-LK-88319',
            issuer: 'Dept. of Immigration & Emigration Sri Lanka',
            expiryDate: '30 Nov 2026',
            statusLabel: 'Active · Approved',
            isValid: true,
            notes: 'Double entry tourist visa valid for 30 days',
            icon: Icons.airplanemode_active_rounded,
          ),
          TravelDocument(
            id: 'DOC-INS-02',
            title: 'Allianz Global Travel Insurance Policy',
            type: DocumentType.insurance,
            documentNumber: 'POL-AZ-772910',
            issuer: 'Allianz Global Care / Sri Lanka Insurance',
            expiryDate: '15 Dec 2026',
            statusLabel: 'Verified · \$150K Med Evac',
            isValid: true,
            notes: 'Includes 24/7 mountain air rescue, hospitalisation & luggage',
            icon: Icons.health_and_safety_rounded,
          ),
          TravelDocument(
            id: 'DOC-PASS-03',
            title: 'International Passport',
            type: DocumentType.passport,
            documentNumber: 'N••••••42',
            issuer: 'Department of Immigration & Emigration',
            expiryDate: '14 Oct 2031',
            statusLabel: 'Valid (> 5 Years)',
            isValid: true,
            notes: 'Exceeds Sri Lanka 6-month validity threshold',
            icon: Icons.badge_rounded,
          ),
          TravelDocument(
            id: 'DOC-IDP-04',
            title: 'Automobile Association Ceylon (AAC) Permit',
            type: DocumentType.drivingPermit,
            documentNumber: 'AAC-PERMIT-2026-44',
            issuer: 'Automobile Association of Ceylon',
            expiryDate: '01 May 2027',
            statusLabel: 'Endorsed for Local Driving',
            isValid: true,
            notes: 'Approved for driving 4x4 SUV and light passenger vehicles',
            icon: Icons.directions_car_rounded,
          ),
        ],
      );

  /// Guest profile when signed out
  static TravellerProfile get guestProfile => const TravellerProfile(
        id: 'TRV-GUEST-001',
        fullName: 'Guest Traveller',
        email: 'guest@traverza.lk',
        phone: '+94 00 000 0000',
        nationality: 'International Visitor',
        membershipTier: 'Guest Explorer',
        tierLevel: 1,
        sltdaLicenseNo: 'GUEST_UNREGISTERED',
        isSltdaRegistered: false,
        isKycVerified: false,
        memberSince: 'October 2026',
        activeCorridor: 'Colombo (CMB) → Cultural Triangle',
        tripsCompleted: 0,
        provincesVisited: 1,
        carbonOffsetKg: 0.0,
        safetyReadinessScore: 60,
        emergencyContact: EmergencyContact(
          name: 'SLTDA Tourism Assistance Desk',
          relationship: 'Emergency Authority',
          phone: '1912',
          email: 'safety@sltda.gov.lk',
          isPrimary: true,
        ),
        preferences: TravelPreferences(
          hillPacing: 'Standard (+20m)',
          preferredVehicle: 'Comfort Sedan',
          dietary: 'No Restrictions',
          spiceTolerance: 'Mild (Foreign Palate)',
          guideLanguage: 'English (Fluent)',
          settlementCurrency: 'USD (\$)',
          offlineMapCaching: true,
          biometricLock: false,
          motionSicknessKit: true,
        ),
        documents: [],
      );
}
