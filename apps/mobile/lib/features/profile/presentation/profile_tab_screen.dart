import 'package:flutter/material.dart';
import '../../../../models/route_waypoint.dart';
import '../../../../theme/app_theme.dart';
import '../../../../utils/maps_launcher.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/presentation/auth_sheet.dart';
import '../data/profile_models.dart';
import 'widgets/digital_passport_card.dart';
import 'widgets/profile_sheets.dart';
import 'widgets/edit_profile_sheet.dart';
import 'widgets/delete_profile_dialog.dart';

class ProfileTabScreen extends StatefulWidget {
  final int initialSegment;

  const ProfileTabScreen({
    super.key,
    this.initialSegment = 0,
  });

  @override
  State<ProfileTabScreen> createState() => _ProfileTabScreenState();
}

class _ProfileTabScreenState extends State<ProfileTabScreen> {
  late int _selectedSegment;
  late TravellerProfile _profile;
  final TraverzaAuthService _authService = TraverzaAuthService.instance;

  @override
  void initState() {
    super.initState();
    _selectedSegment = widget.initialSegment;
    _profile = _authService.currentProfile;
    _authService.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    _authService.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) {
      setState(() {
        _profile = _authService.currentProfile;
      });
    }
  }

  void _showFeedback(String message, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? TraverzaColors.secondary : TraverzaColors.roseEmergency,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        // Guest mode banner if not signed in
        if (!_authService.isAuthenticated) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: TraverzaColors.sand.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: TraverzaColors.amberWarning.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: TraverzaColors.primary, size: 18),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Guest Explorer Mode · Sign in to save digital passport and sync bookings.',
                    style: TextStyle(fontSize: 11.5, color: TraverzaColors.text, fontWeight: FontWeight.w500),
                  ),
                ),
                TextButton(
                  onPressed: () => AuthSheet.show(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                  ),
                  child: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: TraverzaColors.primary)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // 1. Digital Passport & Status Card
        DigitalPassportCard(
          profile: _profile,
          onShowQrPass: () => ProfileSheets.showQrBoardingPassModal(context, _profile),
          onEditProfile: () => setState(() => _selectedSegment = 1),
          onEditDetails: () => EditProfileSheet.show(context, _profile),
          onSignIn: () => AuthSheet.show(context),
        ),
        const SizedBox(height: 16),

        // 2. Bento Milestone Metrics Grid
        _buildMilestoneMetrics(),
        const SizedBox(height: 16),

        // 3. Segmented Navigation Bar
        _buildSegmentedNavBar(),
        const SizedBox(height: 16),

        // 4. Dynamic Segment Content
        _buildActiveSegmentView(),
      ],
    );
  }

  /// 4 Milestone Statistics
  Widget _buildMilestoneMetrics() {
    return Row(
      children: [
        _buildMetricPill(
          icon: Icons.flight_takeoff_rounded,
          value: '${_profile.tripsCompleted}',
          label: 'Trips',
          color: TraverzaColors.primary,
        ),
        const SizedBox(width: 8),
        _buildMetricPill(
          icon: Icons.map_rounded,
          value: '${_profile.provincesVisited}/9',
          label: 'Provinces',
          color: TraverzaColors.secondary,
        ),
        const SizedBox(width: 8),
        _buildMetricPill(
          icon: Icons.shield_rounded,
          value: '${_profile.safetyReadinessScore}%',
          label: 'Safety Score',
          color: TraverzaColors.emeraldSuccess,
        ),
        const SizedBox(width: 8),
        _buildMetricPill(
          icon: Icons.eco_rounded,
          value: '${_profile.carbonOffsetKg}kg',
          label: 'CO₂ Offset',
          color: const Color(0xFF0D9488),
        ),
      ],
    );
  }

  Widget _buildMetricPill({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: TraverzaColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: TraverzaColors.border),
          boxShadow: [
            BoxShadow(
              color: TraverzaColors.primary.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: TraverzaColors.text,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w500,
                color: TraverzaColors.textMuted,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Segmented Switcher for 4 Modes
  Widget _buildSegmentedNavBar() {
    final segments = [
      {'title': 'Safety & SOS', 'icon': Icons.shield_rounded},
      {'title': 'Preferences', 'icon': Icons.tune_rounded},
      {'title': 'Vault', 'icon': Icons.folder_shared_rounded},
      {'title': 'Settings', 'icon': Icons.settings_rounded},
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: TraverzaColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TraverzaColors.border),
      ),
      child: Row(
        children: List.generate(segments.length, (index) {
          final isSelected = _selectedSegment == index;
          final item = segments[index];

          return Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedSegment = index),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? TraverzaColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: TraverzaColors.primary.withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      size: 16,
                      color: isSelected ? Colors.white : TraverzaColors.textMuted,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item['title'] as String,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : TraverzaColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActiveSegmentView() {
    switch (_selectedSegment) {
      case 0:
        return _buildSafetyAndSosVaultView();
      case 1:
        return _buildCorridorPreferencesView();
      case 2:
        return _buildDocumentsVaultView();
      case 3:
      default:
        return _buildAccountSettingsView();
    }
  }

  // ===========================================================================
  // SEGMENT 0: Offline SOS & Emergency Vault (Fully backward compatible with tests)
  // ===========================================================================
  Widget _buildSafetyAndSosVaultView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Exact header required for test compatibility
        const Text(
          'Offline SOS & Emergency Vault',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TraverzaColors.text),
        ),
        const SizedBox(height: 6),
        const Text(
          'Available 100% offline during low-connectivity travel across mountain tea routes.',
          style: TextStyle(fontSize: 12, color: TraverzaColors.textMuted),
        ),
        const SizedBox(height: 14),

        // Live Emergency SOS Beacon Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF1F2), Color(0xFFFFE4E6)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TraverzaColors.roseEmergency.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: TraverzaColors.roseEmergency,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: TraverzaColors.roseEmergency.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.sos_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Emergency GPS Beacon',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: TraverzaColors.roseEmergency),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Broadcast live telemetry & coordinates to SLTDA and rescue services.',
                      style: TextStyle(fontSize: 11, color: TraverzaColors.text),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => ProfileSheets.showSosBeaconDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TraverzaColors.roseEmergency,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Text('SOS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Nearest Emergency Facilities Card (Required for test compatibility)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TraverzaColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TraverzaColors.border),
            boxShadow: [
              BoxShadow(
                color: TraverzaColors.primary.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.near_me_rounded, color: TraverzaColors.roseEmergency, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Nearest Emergency Facilities',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: TraverzaColors.text,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: TraverzaColors.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Sigiriya Sector',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: TraverzaColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Instant Google Maps routing with pre-calculated off-grid coordinates.',
                style: TextStyle(fontSize: 11, color: TraverzaColors.textMuted),
              ),
              const SizedBox(height: 14),

              ...TraverzaWaypoints.emergencyFacilities.map((facility) {
                final isPolice = facility['type'] == 'POLICE';
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: TraverzaColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: TraverzaColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isPolice
                              ? Colors.blue.withValues(alpha: 0.12)
                              : TraverzaColors.roseEmergency.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isPolice ? Icons.local_police_rounded : Icons.local_hospital_rounded,
                          color: isPolice ? Colors.blue : TraverzaColors.roseEmergency,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              facility['title'] as String,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: TraverzaColors.text,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              facility['distance'] as String,
                              style: const TextStyle(
                                fontSize: 11,
                                color: TraverzaColors.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          TraverzaMapsLauncher.openEmergencyRoute(
                            lat: facility['lat'] as double,
                            lng: facility['lng'] as double,
                            facilityName: facility['title'] as String,
                          );
                        },
                        icon: const Icon(Icons.directions_rounded, size: 13),
                        label: const Text('Map', style: TextStyle(fontSize: 11)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TraverzaColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          minimumSize: const Size(64, 30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Emergency Helplines & Desks
        const Text(
          'Emergency Helplines & Desks',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: TraverzaColors.text),
        ),
        const SizedBox(height: 8),

        _buildEmergencyContactCard(
          title: 'Sri Lanka Tourist Police Hotline',
          number: '1912',
          description: 'Official SLTDA emergency tourist assistance desk',
          icon: Icons.local_police_outlined,
          latitude: 7.9542,
          longitude: 80.7554,
        ),
        _buildEmergencyContactCard(
          title: 'Suwa Seriya Emergency Ambulance',
          number: '1990',
          description: 'Free nationwide medical paramedic dispatch',
          icon: Icons.medical_services_outlined,
          latitude: 7.9210,
          longitude: 80.6840,
        ),
        _buildEmergencyContactCard(
          title: 'TRAVERZA 24/7 Operations Rescue Desk',
          number: '+94 11 289 0123',
          description: 'Emergency vehicle dispatch and supplier re-routing',
          icon: Icons.headset_mic_outlined,
        ),
        _buildEmergencyContactCard(
          title: 'Assigned Chauffeur (Lalith J.)',
          number: '+94 71 234 8899',
          description: 'Fleet #LK-402 • Direct vehicle mobile',
          icon: Icons.phone_android_outlined,
        ),

        const SizedBox(height: 14),

        // Primary Next-of-Kin Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: TraverzaColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: TraverzaColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: TraverzaColors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.family_restroom_rounded, color: TraverzaColors.secondary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _profile.emergencyContact.name,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: TraverzaColors.text),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: TraverzaColors.secondary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _profile.emergencyContact.relationship,
                            style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: TraverzaColors.secondary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Next-of-Kin • ${_profile.emergencyContact.phone}',
                      style: const TextStyle(fontSize: 11, color: TraverzaColors.textMuted),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.call_outlined, color: TraverzaColors.primary, size: 20),
                onPressed: () => _showFeedback('Calling Next-of-Kin ${_profile.emergencyContact.name}...'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyContactCard({
    required String title,
    required String number,
    required String description,
    required IconData icon,
    double? latitude,
    double? longitude,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: TraverzaColors.roseEmergency.withValues(alpha: 0.15),
          child: Icon(icon, color: TraverzaColors.roseEmergency),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: TraverzaColors.text),
        ),
        subtitle: Text(
          description,
          style: const TextStyle(fontSize: 11, color: TraverzaColors.textMuted),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (latitude != null && longitude != null) ...[
              IconButton(
                icon: const Icon(Icons.directions_outlined, color: TraverzaColors.secondary, size: 20),
                tooltip: 'Open in Google Maps',
                onPressed: () {
                  TraverzaMapsLauncher.openEmergencyRoute(
                    lat: latitude,
                    lng: longitude,
                    facilityName: title,
                  );
                },
              ),
              const SizedBox(width: 4),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: TraverzaColors.roseEmergency.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                number,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: TraverzaColors.roseEmergency,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // SEGMENT 1: Corridor Travel Preferences
  // ===========================================================================
  Widget _buildCorridorPreferencesView() {
    final prefs = _profile.preferences;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Corridor Travel Preferences',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TraverzaColors.text),
                ),
                SizedBox(height: 2),
                Text(
                  'Customises route buffering, vehicles, dining and language.',
                  style: TextStyle(fontSize: 11.5, color: TraverzaColors.textMuted),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.restore_rounded, color: TraverzaColors.secondary),
              tooltip: 'Reset to Defaults',
              onPressed: () {
                setState(() {
                  _profile = _profile.copyWith(preferences: TravellerProfile.defaultProfile.preferences);
                });
                _showFeedback('Reset preferences to recommended corridor defaults');
              },
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Hill Country Road Pacing
        _buildPreferenceSection(
          title: 'Hill Country Route Pacing',
          subtitle: 'Buffers added to mountain hairpin routes (e.g. Kandy to Nuwara Eliya)',
          icon: Icons.timer_outlined,
          child: Column(
            children: [
              _buildChoiceChipGroup(
                options: ['Scenic Buffers (+45m)', 'Standard (+20m)', 'Direct Express'],
                selected: prefs.hillPacing,
                onSelected: (val) {
                  setState(() {
                    _profile = _profile.copyWith(preferences: prefs.copyWith(hillPacing: val));
                  });
                  _showFeedback('Updated Route Pacing to $val');
                },
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: TraverzaColors.sand.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline_rounded, size: 14, color: TraverzaColors.textMuted),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Scenic Buffers allow unscheduled tea plantation stops, photography pauses, and waterfall overlooks.',
                        style: TextStyle(fontSize: 10.5, color: TraverzaColors.text, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Preferred Vehicle Tier
        _buildPreferenceSection(
          title: 'Preferred Vehicle Class',
          subtitle: 'Matches your fleet tier across private transfers and airport pickups',
          icon: Icons.directions_car_filled_outlined,
          child: _buildChoiceChipGroup(
            options: ['Hybrid SUV / Prado 4x4', 'Premium AC Van (KDH)', 'Comfort Sedan'],
            selected: prefs.preferredVehicle,
            onSelected: (val) {
              setState(() {
                _profile = _profile.copyWith(preferences: prefs.copyWith(preferredVehicle: val));
              });
              _showFeedback('Vehicle tier set to $val');
            },
          ),
        ),
        const SizedBox(height: 16),

        // Dietary & Ceylon Spice Tolerance
        _buildPreferenceSection(
          title: 'Dietary & Spice Tolerance',
          subtitle: 'Passed automatically to partner boutique stays and cooking classes',
          icon: Icons.restaurant_menu_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Dietary Restrictions', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: TraverzaColors.textMuted)),
              const SizedBox(height: 6),
              _buildChoiceChipGroup(
                options: ['Halal & Ceylon Seafood', 'Vegetarian / Vegan', 'No Restrictions'],
                selected: prefs.dietary,
                onSelected: (val) {
                  setState(() {
                    _profile = _profile.copyWith(preferences: prefs.copyWith(dietary: val));
                  });
                },
              ),
              const SizedBox(height: 12),
              const Text('Ceylon Curry Spice Sensitivity', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: TraverzaColors.textMuted)),
              const SizedBox(height: 6),
              _buildChoiceChipGroup(
                options: ['Mild (Foreign Palate)', 'Medium Authentic', 'Fiery Sri Lankan'],
                selected: prefs.spiceTolerance,
                onSelected: (val) {
                  setState(() {
                    _profile = _profile.copyWith(preferences: prefs.copyWith(spiceTolerance: val));
                  });
                  _showFeedback('Spice tolerance set to $val');
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Settlement Currency & Language
        _buildPreferenceSection(
          title: 'Settlement Currency & Guide Language',
          subtitle: 'Primary payment denomination and guide language filter',
          icon: Icons.language_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Settlement Currency', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: TraverzaColors.textMuted)),
              const SizedBox(height: 6),
              _buildChoiceChipGroup(
                options: ['USD (\$)', 'LKR (Rs)', 'EUR (€)', 'GBP (£)'],
                selected: prefs.settlementCurrency,
                onSelected: (val) {
                  setState(() {
                    _profile = _profile.copyWith(preferences: prefs.copyWith(settlementCurrency: val));
                  });
                  _showFeedback('Default billing currency switched to $val');
                },
              ),
              const SizedBox(height: 12),
              const Text('Guide Primary Language', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: TraverzaColors.textMuted)),
              const SizedBox(height: 6),
              _buildChoiceChipGroup(
                options: ['English (Fluent)', 'German', 'French', 'Sinhala / Tamil'],
                selected: prefs.guideLanguage,
                onSelected: (val) {
                  setState(() {
                    _profile = _profile.copyWith(preferences: prefs.copyWith(guideLanguage: val));
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreferenceSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TraverzaColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TraverzaColors.border),
        boxShadow: [
          BoxShadow(
            color: TraverzaColors.primary.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: TraverzaColors.secondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: TraverzaColors.text),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: TraverzaColors.textMuted)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildChoiceChipGroup({
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelected,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isChosen = opt == selected;
        return ChoiceChip(
          label: Text(
            opt,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: isChosen ? FontWeight.bold : FontWeight.w500,
              color: isChosen ? Colors.white : TraverzaColors.text,
            ),
          ),
          selected: isChosen,
          selectedColor: TraverzaColors.primary,
          backgroundColor: TraverzaColors.background,
          side: BorderSide(
            color: isChosen ? TraverzaColors.primary : TraverzaColors.border,
          ),
          onSelected: (active) {
            if (active) onSelected(opt);
          },
        );
      }).toList(),
    );
  }

  // ===========================================================================
  // SEGMENT 2: Digital Documents & Vault
  // ===========================================================================
  Widget _buildDocumentsVaultView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Digital Documents Vault',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TraverzaColors.text),
                ),
                SizedBox(height: 2),
                Text(
                  'Encrypted offline travel credentials & SLTDA verifications.',
                  style: TextStyle(fontSize: 11.5, color: TraverzaColors.textMuted),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () {
                _showFeedback('Opening Camera / Document Scanner...');
              },
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Add', style: TextStyle(fontSize: 11.5)),
              style: ElevatedButton.styleFrom(
                backgroundColor: TraverzaColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: const Size(64, 30),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Offline storage badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: TraverzaColors.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: TraverzaColors.secondary.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: const [
              Icon(Icons.lock_clock_rounded, size: 16, color: TraverzaColors.secondary),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'All documents are cryptographically signed & available offline without cellular service.',
                  style: TextStyle(fontSize: 11, color: TraverzaColors.text, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Document Cards
        ..._profile.documents.map((doc) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: TraverzaColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: TraverzaColors.border),
              boxShadow: [
                BoxShadow(
                  color: TraverzaColors.primary.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: TraverzaColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(doc.icon, color: TraverzaColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              doc.title,
                              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: TraverzaColors.text),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: TraverzaColors.emeraldSuccess.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              doc.statusLabel,
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: TraverzaColors.emeraldSuccess),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ref: ${doc.documentNumber} · Expires: ${doc.expiryDate}',
                        style: const TextStyle(fontSize: 11, color: TraverzaColors.textMuted),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        doc.notes,
                        style: const TextStyle(fontSize: 11, color: TraverzaColors.text),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          InkWell(
                            onTap: () => ProfileSheets.showDocumentDetailsModal(context, doc),
                            child: Row(
                              children: const [
                                Icon(Icons.remove_red_eye_rounded, size: 14, color: TraverzaColors.secondary),
                                SizedBox(width: 4),
                                Text(
                                  'View Details',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: TraverzaColors.secondary),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          InkWell(
                            onTap: () => _showFeedback('Certificate for ${doc.title} is verified by SLTDA'),
                            child: Row(
                              children: const [
                                Icon(Icons.verified_outlined, size: 14, color: TraverzaColors.emeraldSuccess),
                                SizedBox(width: 4),
                                Text(
                                  'Verified',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: TraverzaColors.emeraldSuccess),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ===========================================================================
  // SEGMENT 3: Account & Security Settings
  // ===========================================================================
  Widget _buildAccountSettingsView() {
    final prefs = _profile.preferences;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Account & Device Security',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TraverzaColors.text),
        ),
        const SizedBox(height: 4),
        const Text(
          'Manage offline map caching, biometric authentication and payments.',
          style: TextStyle(fontSize: 11.5, color: TraverzaColors.textMuted),
        ),
        const SizedBox(height: 14),

        // Account & Profile Management Card
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Account & Profile',
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: TraverzaColors.text),
                    ),
                    if (_authService.isAuthenticated)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: TraverzaColors.emeraldSuccess.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Signed In',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: TraverzaColors.emeraldSuccess),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: TraverzaColors.amberWarning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Guest Mode',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: TraverzaColors.primary),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: TraverzaColors.surfaceWarm,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: TraverzaColors.border),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: TraverzaColors.primary,
                        backgroundImage: (_authService.isAuthenticated && _profile.avatarUrl != null && _profile.avatarUrl!.isNotEmpty)
                            ? NetworkImage(_profile.avatarUrl!)
                            : null,
                        onBackgroundImageError: (_authService.isAuthenticated && _profile.avatarUrl != null && _profile.avatarUrl!.isNotEmpty)
                            ? (e, s) {}
                            : null,
                        child: (_authService.isAuthenticated && _profile.avatarUrl != null && _profile.avatarUrl!.isNotEmpty)
                            ? null
                            : Text(
                                _authService.isAuthenticated && _profile.fullName.isNotEmpty
                                    ? _profile.fullName.substring(0, 1).toUpperCase()
                                    : 'G',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _authService.isAuthenticated ? _profile.fullName : 'Guest Explorer',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: TraverzaColors.text),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _authService.isAuthenticated ? _profile.email : 'Explore as guest or sign in to sync',
                              style: const TextStyle(fontSize: 11, color: TraverzaColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      if (_authService.isAuthenticated)
                        IconButton(
                          tooltip: 'Edit Profile Details',
                          icon: const Icon(Icons.edit_note_rounded, color: TraverzaColors.primary, size: 22),
                          onPressed: () => EditProfileSheet.show(context, _profile),
                        )
                      else
                        TextButton(
                          onPressed: () => AuthSheet.show(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            minimumSize: Size.zero,
                          ),
                          child: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.edit_outlined, color: TraverzaColors.primary, size: 20),
                  title: const Text('Edit Personal Profile', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Full name, phone, nationality & emergency contact', style: TextStyle(fontSize: 10.5, color: TraverzaColors.textMuted)),
                  trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: TraverzaColors.textMuted),
                  onTap: () => EditProfileSheet.show(context, _profile),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.switch_account_outlined, color: TraverzaColors.secondary, size: 20),
                  title: Text(
                    _authService.isAuthenticated ? 'Switch Account / Login' : 'Sign In / Register',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('1-tap demo logins or email authentication', style: TextStyle(fontSize: 10.5, color: TraverzaColors.textMuted)),
                  trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: TraverzaColors.textMuted),
                  onTap: () => AuthSheet.show(context),
                ),
                if (_authService.isAuthenticated) ...[
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.logout_rounded, color: TraverzaColors.amberWarning, size: 20),
                    title: const Text('Sign Out to Guest Mode', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: TraverzaColors.amberWarning)),
                    subtitle: const Text('Return to guest state while preserving emergency features', style: TextStyle(fontSize: 10.5, color: TraverzaColors.textMuted)),
                    trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: TraverzaColors.textMuted),
                    onTap: () {
                      _authService.signOut();
                      _showFeedback('Signed out to Guest Mode');
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.delete_forever_rounded, color: TraverzaColors.roseEmergency, size: 20),
                    title: const Text('Delete Profile & Account', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: TraverzaColors.roseEmergency)),
                    subtitle: const Text('Permanently wipe traveller profile and reset session', style: TextStyle(fontSize: 10.5, color: TraverzaColors.textMuted)),
                    trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: TraverzaColors.textMuted),
                    onTap: () => DeleteProfileDialog.show(context),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Device Security Settings Group
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Biometric App Lock', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: TraverzaColors.text)),
                  subtitle: const Text('Requires FaceID / Fingerprint to view documents and book', style: TextStyle(fontSize: 11, color: TraverzaColors.textMuted)),
                  value: prefs.biometricLock,
                  activeColor: TraverzaColors.secondary,
                  onChanged: (val) {
                    setState(() {
                      _profile = _profile.copyWith(preferences: prefs.copyWith(biometricLock: val));
                    });
                    _showFeedback(val ? 'Biometric Lock enabled' : 'Biometric Lock disabled');
                  },
                ),
                const Divider(height: 14),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Offline Route & Map Caching', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: TraverzaColors.text)),
                  subtitle: const Text('Pre-downloads 142 MB of terrain & emergency data', style: TextStyle(fontSize: 11, color: TraverzaColors.textMuted)),
                  value: prefs.offlineMapCaching,
                  activeColor: TraverzaColors.secondary,
                  onChanged: (val) {
                    setState(() {
                      _profile = _profile.copyWith(preferences: prefs.copyWith(offlineMapCaching: val));
                    });
                    _showFeedback(val ? 'Offline Map Caching active' : 'Offline Cache disabled');
                  },
                ),
                const Divider(height: 14),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Motion Sickness Assistance Kit', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: TraverzaColors.text)),
                  subtitle: const Text('Alerts chauffeur to provide ginger candies and smooth braking', style: TextStyle(fontSize: 11, color: TraverzaColors.textMuted)),
                  value: prefs.motionSicknessKit,
                  activeColor: TraverzaColors.secondary,
                  onChanged: (val) {
                    setState(() {
                      _profile = _profile.copyWith(preferences: prefs.copyWith(motionSicknessKit: val));
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Payment Methods Card
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Payment Gateways', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: TraverzaColors.text)),
                    TextButton.icon(
                      onPressed: () => _showFeedback('Add Card modal opened'),
                      icon: const Icon(Icons.add, size: 14),
                      label: const Text('Add Card', style: TextStyle(fontSize: 11.5)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: TraverzaColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.credit_card_rounded, color: TraverzaColors.primary, size: 20),
                  ),
                  title: const Text('PayHere Visa •••• 4022', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Default settlement card · Expires 09/28', style: TextStyle(fontSize: 11, color: TraverzaColors.textMuted)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: TraverzaColors.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Default', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: TraverzaColors.secondary)),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Cache Management Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showFeedback('Local cache cleared (142 MB freed)'),
            icon: const Icon(Icons.cleaning_services_rounded, size: 16),
            label: const Text('Clear Offline Corridor Cache (142 MB)', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: TraverzaColors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // App Version and SLTDA info
        Center(
          child: Column(
            children: const [
              Text(
                'TRAVERZA Sri Lanka Operating Platform v2.0-PROD',
                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: TraverzaColors.textMuted),
              ),
              SizedBox(height: 2),
              Text(
                'SLTDA Digital Tourism Certification #SLTDA-APP-2026-9041',
                style: TextStyle(fontSize: 9.5, color: TraverzaColors.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
