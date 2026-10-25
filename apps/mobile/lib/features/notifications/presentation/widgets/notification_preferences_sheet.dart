import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../data/notification_model.dart';
import '../../services/notification_service.dart';

/// Interactive Notification Preferences & Channel Settings Sheet
class NotificationPreferencesSheet extends StatefulWidget {
  const NotificationPreferencesSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NotificationPreferencesSheet(),
    );
  }

  @override
  State<NotificationPreferencesSheet> createState() => _NotificationPreferencesSheetState();
}

class _NotificationPreferencesSheetState extends State<NotificationPreferencesSheet> {
  late NotificationPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _prefs = TraverzaNotificationService.instance.preferences.copyWith();
  }

  void _update() {
    TraverzaNotificationService.instance.updatePreferences(_prefs);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: TraverzaColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: TraverzaColors.border,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TraverzaColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.tune_rounded, color: TraverzaColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Notification Preferences',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: TraverzaColors.text,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Control alert channels, corridor advisories, and quiet hours',
                      style: TextStyle(fontSize: 11, color: TraverzaColors.textMuted),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: TraverzaColors.textMuted),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),

          // Settings List
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 14),
                  _buildSectionHeader('DELIVERY CHANNELS'),
                  _buildSwitchTile(
                    title: 'Push Notifications',
                    subtitle: 'Receive instant alerts when the app is in the background',
                    icon: Icons.notifications_active_rounded,
                    value: _prefs.pushEnabled,
                    onChanged: (val) {
                      _prefs.pushEnabled = val;
                      _update();
                    },
                  ),
                  _buildSwitchTile(
                    title: 'In-App Heads-Up Banners',
                    subtitle: 'Show floating alerts at the top while exploring the app',
                    icon: Icons.layers_rounded,
                    value: _prefs.inAppBannersEnabled,
                    onChanged: (val) {
                      _prefs.inAppBannersEnabled = val;
                      _update();
                    },
                  ),

                  const SizedBox(height: 16),
                  _buildSectionHeader('CORRIDOR & TRIP ALERT CATEGORIES'),
                  _buildSwitchTile(
                    title: 'Safety & Emergency Advisories',
                    subtitle: 'Hill country landslides, monsoon rain buffers, road closures (Critical)',
                    icon: Icons.shield_rounded,
                    value: _prefs.safetyEnabled,
                    isProtected: true,
                    onChanged: (val) {
                      _prefs.safetyEnabled = val;
                      _update();
                    },
                  ),
                  _buildSwitchTile(
                    title: 'Journey Autopilot & Disruption Recovery',
                    subtitle: 'CMB flight delays, standby chauffeur dispatch authorizations',
                    icon: Icons.bolt_rounded,
                    value: _prefs.autopilotEnabled,
                    onChanged: (val) {
                      _prefs.autopilotEnabled = val;
                      _update();
                    },
                  ),
                  _buildSwitchTile(
                    title: 'Bookings & SLA Time Tracking',
                    subtitle: '12h confirmation deadlines, chauffeur arrival, check-in vouchers',
                    icon: Icons.confirmation_number_rounded,
                    value: _prefs.bookingEnabled,
                    onChanged: (val) {
                      _prefs.bookingEnabled = val;
                      _update();
                    },
                  ),
                  _buildSwitchTile(
                    title: 'Messages & Community Pulse',
                    subtitle: 'District lounge replies, host check-ins, local hiker tips',
                    icon: Icons.forum_rounded,
                    value: _prefs.messengerEnabled,
                    onChanged: (val) {
                      _prefs.messengerEnabled = val;
                      _update();
                    },
                  ),
                  _buildSwitchTile(
                    title: 'Perks, Passes & Exclusive Privileges',
                    subtitle: 'Early rock climb passes, high-altitude Ceylon tea tastings',
                    icon: Icons.local_offer_rounded,
                    value: _prefs.offersEnabled,
                    onChanged: (val) {
                      _prefs.offersEnabled = val;
                      _update();
                    },
                  ),

                  const SizedBox(height: 16),
                  _buildSectionHeader('DO NOT DISTURB'),
                  _buildSwitchTile(
                    title: 'Quiet Hours',
                    subtitle: 'Mute non-safety alerts from 10:00 PM to 06:00 AM',
                    icon: Icons.bedtime_rounded,
                    value: _prefs.quietHoursEnabled,
                    onChanged: (val) {
                      _prefs.quietHoursEnabled = val;
                      _update();
                    },
                  ),

                  const SizedBox(height: 20),
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _prefs = NotificationPreferences();
                        _update();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Preferences reset to recommended defaults'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.restore_rounded, size: 16),
                      label: const Text('Reset to Recommended Defaults'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: TraverzaColors.textMuted,
                        side: const BorderSide(color: TraverzaColors.border),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: TraverzaColors.secondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isProtected = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: TraverzaColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TraverzaColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: TraverzaColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: TraverzaColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: TraverzaColors.text),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isProtected) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: TraverzaColors.roseEmergency.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'ALWAYS ON',
                          style: TextStyle(
                            fontSize: 7.5,
                            fontWeight: FontWeight.w900,
                            color: TraverzaColors.roseEmergency,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 10.5, color: TraverzaColors.textMuted, height: 1.3),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: TraverzaColors.primary,
            onChanged: isProtected ? null : onChanged,
          ),
        ],
      ),
    );
  }
}
