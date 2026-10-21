import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../auth/services/auth_service.dart';

class DeleteProfileDialog {
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.warning_rounded, color: TraverzaColors.roseEmergency, size: 26),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Delete Traveller Profile?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: TraverzaColors.text),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'This will permanently remove your local traveller profile, SLTDA KYC verification tokens, and cached offline passes.',
                style: TextStyle(fontSize: 12.5, color: TraverzaColors.text, height: 1.4),
              ),
              SizedBox(height: 12),
              Text(
                'You will be returned to guest mode. Emergency SOS and offline hospital routes will remain accessible.',
                style: TextStyle(fontSize: 11.5, color: TraverzaColors.textMuted),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel', style: TextStyle(color: TraverzaColors.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                TraverzaAuthService.instance.deleteProfile();
                Navigator.pop(ctx, true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile and local credentials deleted. Switched to guest mode.'),
                    backgroundColor: TraverzaColors.roseEmergency,
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TraverzaColors.roseEmergency,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Delete Profile', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
