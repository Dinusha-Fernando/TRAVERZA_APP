import '../data/../services/../../profile/data/profile_models.dart';

class AuthUser {
  final String id;
  final String email;
  final String fullName;
  final String phone;
  final String nationality;
  final String role;
  final String token;

  const AuthUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.nationality,
    this.role = 'TRAVELER',
    required this.token,
  });
}

class DemoAccount {
  final String title;
  final String subtitle;
  final String email;
  final String password;
  final TravellerProfile profile;

  const DemoAccount({
    required this.title,
    required this.subtitle,
    required this.email,
    required this.password,
    required this.profile,
  });

  static List<DemoAccount> get demoAccounts => [
        DemoAccount(
          title: 'Dinusha Wijesinghe',
          subtitle: 'Pilot Elite Member • Level 3',
          email: 'dinusha.w@traverza.lk',
          password: 'password123',
          profile: TravellerProfile.defaultProfile,
        ),
        DemoAccount(
          title: 'Sarah Jenkins',
          subtitle: 'Independent Backpacker • Level 1',
          email: 'sarah.j@travel.com',
          password: 'password123',
          profile: TravellerProfile(
            id: 'TRV-UK-7102',
            fullName: 'Sarah Jenkins',
            email: 'sarah.j@travel.com',
            phone: '+44 7911 123456',
            nationality: 'United Kingdom',
            membershipTier: 'Backpacker Explorer',
            tierLevel: 1,
            sltdaLicenseNo: 'SLTDA/TOURIST/2026/1102',
            isSltdaRegistered: true,
            isKycVerified: true,
            memberSince: 'March 2026',
            activeCorridor: 'Colombo → Kandy → Ella',
            tripsCompleted: 3,
            provincesVisited: 2,
            carbonOffsetKg: 12.0,
            safetyReadinessScore: 88,
            emergencyContact: const EmergencyContact(
              name: 'Oliver Jenkins',
              relationship: 'Father',
              phone: '+44 7911 654321',
              email: 'oliver.j@travel.com',
              isPrimary: true,
            ),
            preferences: const TravelPreferences(
              hillPacing: 'Standard (+20m)',
              preferredVehicle: 'Comfort Sedan',
              dietary: 'Vegetarian / Vegan',
              spiceTolerance: 'Mild (Foreign Palate)',
              guideLanguage: 'English (Fluent)',
              settlementCurrency: 'GBP (£)',
              offlineMapCaching: true,
              biometricLock: false,
              motionSicknessKit: true,
            ),
            documents: const [],
            avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
          ),
        ),
        DemoAccount(
          title: 'Alexander Wright',
          subtitle: 'Luxury Pilot Traveller • Level 3',
          email: 'alex.wright@luxurytravel.com',
          password: 'password123',
          profile: TravellerProfile(
            id: 'TRV-US-8901',
            fullName: 'Alexander Wright',
            email: 'alex.wright@luxurytravel.com',
            phone: '+1 415 555 2671',
            nationality: 'United States',
            membershipTier: 'Luxury Pilot Tier',
            tierLevel: 3,
            sltdaLicenseNo: 'SLTDA/LUX/2026/8901',
            isSltdaRegistered: true,
            isKycVerified: true,
            memberSince: 'February 2026',
            activeCorridor: 'Colombo (CMB) → Cultural Triangle → Hill Country',
            tripsCompleted: 8,
            provincesVisited: 5,
            carbonOffsetKg: 64.0,
            safetyReadinessScore: 99,
            emergencyContact: const EmergencyContact(
              name: 'Victoria Wright',
              relationship: 'Spouse',
              phone: '+1 415 555 9811',
              email: 'victoria.w@luxurytravel.com',
              isPrimary: true,
            ),
            preferences: const TravelPreferences(
              hillPacing: 'Scenic Buffers (+45m)',
              preferredVehicle: 'Hybrid SUV / Prado 4x4',
              dietary: 'Halal & Ceylon Seafood',
              spiceTolerance: 'Medium Authentic',
              guideLanguage: 'English (Fluent)',
              settlementCurrency: 'USD (\$)',
              offlineMapCaching: true,
              biometricLock: true,
              motionSicknessKit: true,
            ),
            documents: const [],
            avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=300&q=80',
          ),
        ),
      ];
}
