import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'auth_sheet.dart';
import 'welcome_auth_screen.dart';

class AccountQuickSheet extends StatelessWidget {
  final VoidCallback? onNavigateToProfile;

  const AccountQuickSheet({
    super.key,
    this.onNavigateToProfile,
  });

  static Future<void> show(BuildContext context, {VoidCallback? onNavigateToProfile}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AccountQuickSheet(onNavigateToProfile: onNavigateToProfile),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TraverzaAuthService.instance,
      builder: (context, _) {
        final auth = TraverzaAuthService.instance;
        final profile = auth.currentProfile;
        final isAuth = auth.isAuthenticated;

        return Material(
          color: TraverzaColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
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

              // Header: User Card & Status
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: TraverzaColors.primary,
                    backgroundImage: (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty)
                        ? NetworkImage(profile.avatarUrl!)
                        : null,
                    child: (profile.avatarUrl == null || profile.avatarUrl!.isEmpty)
                        ? Text(
                            profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : 'T',
                            style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                profile.fullName,
                                style: const TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.bold,
                                  color: TraverzaColors.text,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (isAuth)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: TraverzaColors.secondary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: TraverzaColors.secondary.withValues(alpha: 0.3)),
                                ),
                                child: const Text(
                                  'ACTIVE',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: TraverzaColors.secondary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isAuth ? profile.email : 'Signed Out',
                          style: const TextStyle(fontSize: 12, color: TraverzaColors.textMuted),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.shield_outlined, size: 12, color: TraverzaColors.accent),
                            const SizedBox(width: 4),
                            Text(
                              profile.membershipTier,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: TraverzaColors.secondary),
                            ),
                          ],
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

              const SizedBox(height: 20),
              const Divider(height: 1),
              const SizedBox(height: 14),

              if (!isAuth) ...[
                // Guest Prompt
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        TraverzaColors.primary.withValues(alpha: 0.05),
                        TraverzaColors.secondary.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: TraverzaColors.secondary.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Unlock Your Full Sri Lanka Experience',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: TraverzaColors.primary),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Sign in to sync corridor itineraries, access your biometric digital passport, and receive live autopilot updates.',
                        style: TextStyle(fontSize: 11.5, color: TraverzaColors.textMuted, height: 1.4),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                AuthSheet.show(context, initialTabIndex: 0);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: TraverzaColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 11),
                              ),
                              child: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                AuthSheet.show(context, initialTabIndex: 1);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: TraverzaColors.primary,
                                side: const BorderSide(color: TraverzaColors.primary),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 11),
                              ),
                              child: const Text('Register', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ] else ...[
                // Authenticated Quick Actions
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: TraverzaColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.badge_outlined, color: TraverzaColors.primary, size: 20),
                  ),
                  title: const Text('Digital Passport & Credentials', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold)),
                  subtitle: Text('SLTDA Registration: ${profile.sltdaLicenseNo}', style: const TextStyle(fontSize: 11, color: TraverzaColors.textMuted)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: TraverzaColors.textMuted),
                  onTap: () {
                    Navigator.pop(context);
                    if (onNavigateToProfile != null) onNavigateToProfile!();
                  },
                ),
                const Divider(height: 16),
              ],

              // Onboarding Gateway Link
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: TraverzaColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.explore_outlined, color: TraverzaColors.secondary, size: 20),
                ),
                title: const Text('Welcome & Onboarding Portal', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold)),
                subtitle: const Text('Experience the cinematic travel onboarding', style: TextStyle(fontSize: 11, color: TraverzaColors.textMuted)),
                trailing: const Icon(Icons.chevron_right_rounded, color: TraverzaColors.textMuted),
                onTap: () {
                  Navigator.pop(context);
                  WelcomeAuthScreen.show(context);
                },
              ),

              const SizedBox(height: 10),

              if (isAuth)
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      auth.signOut();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Signed out successfully.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.logout_rounded, size: 16, color: TraverzaColors.roseEmergency),
                    label: const Text('Sign Out', style: TextStyle(color: TraverzaColors.roseEmergency, fontSize: 12.5, fontWeight: FontWeight.w600)),
                  ),
                ),
            ],
          ),
        ),
      );
    },
    );
  }
}
