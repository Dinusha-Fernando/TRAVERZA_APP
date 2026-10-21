import 'package:flutter/material.dart';
import '../../profile/data/profile_models.dart';
import '../data/auth_models.dart';

/// Central Authentication & Session Management Service for TRAVERZA Sri Lanka
class TraverzaAuthService extends ChangeNotifier {
  TraverzaAuthService._internal() {
    _isAuthenticated = true;
    _currentProfile = TravellerProfile.defaultProfile;
    _authToken = 'jwt-mock-pilot-token-9041';
  }

  static final TraverzaAuthService instance = TraverzaAuthService._internal();

  late bool _isAuthenticated;
  late TravellerProfile _currentProfile;
  String? _authToken;

  bool get isAuthenticated => _isAuthenticated;
  TravellerProfile get currentProfile => _currentProfile;
  String? get authToken => _authToken;

  /// Sign In with credentials or match known demo accounts
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate async auth network latency

    final normalizedEmail = email.trim().toLowerCase();
    final demoMatch = DemoAccount.demoAccounts.firstWhere(
      (acc) => acc.email.toLowerCase() == normalizedEmail,
      orElse: () => DemoAccount(
        title: email.split('@').first,
        subtitle: 'Independent Traveller',
        email: email,
        password: password,
        profile: TravellerProfile(
          id: 'TRV-USER-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
          fullName: email.split('@').first,
          email: email,
          phone: '+94 77 000 0000',
          nationality: 'International Visitor',
          membershipTier: 'Standard Member',
          tierLevel: 1,
          sltdaLicenseNo: 'SLTDA/TOURIST/2026',
          isSltdaRegistered: true,
          isKycVerified: true,
          memberSince: 'October 2026',
          activeCorridor: 'Colombo → Cultural Triangle',
          tripsCompleted: 1,
          provincesVisited: 1,
          carbonOffsetKg: 5.0,
          safetyReadinessScore: 90,
          emergencyContact: const EmergencyContact(
            name: 'Primary Contact',
            relationship: 'Family',
            phone: '+94 77 987 6543',
            email: 'contact@traverza.lk',
            isPrimary: true,
          ),
          preferences: TravellerProfile.defaultProfile.preferences,
          documents: const [],
        ),
      ),
    );

    _isAuthenticated = true;
    _currentProfile = demoMatch.profile;
    _authToken = 'jwt-token-${DateTime.now().millisecondsSinceEpoch}';
    notifyListeners();
    return true;
  }

  /// Register new traveller account
  Future<bool> signUp({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String nationality,
    String? avatarUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final newProfile = TravellerProfile(
      id: 'TRV-LK-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      fullName: fullName.trim(),
      email: email.trim(),
      phone: phone.trim(),
      nationality: nationality.trim(),
      membershipTier: 'Pilot Member',
      tierLevel: 1,
      sltdaLicenseNo: 'SLTDA/REG/2026/${DateTime.now().millisecond}',
      isSltdaRegistered: true,
      isKycVerified: true,
      memberSince: 'October 2026',
      activeCorridor: 'Colombo (CMB) → Sigiriya → Kandy',
      tripsCompleted: 1,
      provincesVisited: 1,
      carbonOffsetKg: 8.0,
      safetyReadinessScore: 95,
      emergencyContact: const EmergencyContact(
        name: 'Family Emergency Desk',
        relationship: 'Next-of-Kin',
        phone: '+94 11 289 0123',
        email: 'emergency@traverza.lk',
        isPrimary: true,
      ),
      preferences: TravellerProfile.defaultProfile.preferences,
      documents: TravellerProfile.defaultProfile.documents,
      avatarUrl: avatarUrl,
    );

    _isAuthenticated = true;
    _currentProfile = newProfile;
    _authToken = 'jwt-token-new-${DateTime.now().millisecondsSinceEpoch}';
    notifyListeners();
    return true;
  }

  /// Sign out to guest mode
  void signOut() {
    _isAuthenticated = false;
    _currentProfile = TravellerProfile.guestProfile;
    _authToken = null;
    notifyListeners();
  }

  /// Update existing profile attributes
  void updateProfile(TravellerProfile updated) {
    _currentProfile = updated;
    notifyListeners();
  }

  /// Update traveller profile picture
  void updateAvatar(String? avatarUrl) {
    _currentProfile = _currentProfile.copyWith(
      avatarUrl: avatarUrl,
      clearAvatar: avatarUrl == null || avatarUrl.isEmpty,
    );
    notifyListeners();
  }

  /// Permanently delete profile and return to guest mode
  void deleteProfile() {
    _isAuthenticated = false;
    _currentProfile = TravellerProfile.guestProfile;
    _authToken = null;
    notifyListeners();
  }

  /// Switch directly between demo accounts
  void switchDemoAccount(int index) {
    if (index >= 0 && index < DemoAccount.demoAccounts.length) {
      final acc = DemoAccount.demoAccounts[index];
      _isAuthenticated = true;
      _currentProfile = acc.profile;
      _authToken = 'jwt-demo-token-$index';
      notifyListeners();
    }
  }

  /// Reset session to default pilot traveller (for test isolation)
  void resetToDefault() {
    _isAuthenticated = true;
    _currentProfile = TravellerProfile.defaultProfile;
    _authToken = 'jwt-mock-pilot-token-9041';
    notifyListeners();
  }
}
