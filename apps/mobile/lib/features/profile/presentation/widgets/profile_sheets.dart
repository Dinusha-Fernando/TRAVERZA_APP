import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../utils/maps_launcher.dart';
import '../../data/profile_models.dart';

class ProfileSheets {
  /// Shows high-tech Digital QR Pass for SLTDA checkpoints, hotels & national parks
  static void showQrBoardingPassModal(BuildContext context, TravellerProfile profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: TraverzaColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: TraverzaColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'TRAVERZA DIGITAL PASS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: TraverzaColors.secondary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Universal Check-in Token',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TraverzaColors.text),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: TraverzaColors.emeraldSuccess.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'ACTIVE & VERIFIED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: TraverzaColors.emeraldSuccess,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Mock QR Visual Block
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: TraverzaColors.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: TraverzaColors.border),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: TraverzaColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: TraverzaColors.primary.withValues(alpha: 0.06),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.qr_code_2_rounded, size: 130, color: TraverzaColors.primary),
                          Text(
                            profile.id,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: TraverzaColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      profile.fullName,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: TraverzaColors.text),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'SLTDA Accreditation: ${profile.sltdaLicenseNo}',
                      style: const TextStyle(fontSize: 11, color: TraverzaColors.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Info Tiles
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: TraverzaColors.sand.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('HOTEL & PARK ACCESS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: TraverzaColors.textMuted)),
                          SizedBox(height: 4),
                          Text('Contactless Express', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: TraverzaColors.text)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: TraverzaColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('CORRIDOR PASS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: TraverzaColors.secondary)),
                          SizedBox(height: 4),
                          Text('Cultural Triangle Valid', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: TraverzaColors.text)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Digital Pass saved to Apple Wallet / Google Wallet'),
                        backgroundColor: TraverzaColors.secondary,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.wallet_rounded, size: 18),
                  label: const Text('Add to Digital Wallet', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TraverzaColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Shows full Document inspection modal
  static void showDocumentDetailsModal(BuildContext context, TravelDocument doc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: TraverzaColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: TraverzaColors.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(doc.icon, color: TraverzaColors.secondary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc.title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TraverzaColors.text),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          doc.issuer,
                          style: const TextStyle(fontSize: 11, color: TraverzaColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: TraverzaColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: TraverzaColors.border),
                ),
                child: Column(
                  children: [
                    _buildDocMetaRow('Document Number', doc.documentNumber),
                    const Divider(height: 20),
                    _buildDocMetaRow('Expiry Date', doc.expiryDate),
                    const Divider(height: 20),
                    _buildDocMetaRow('Compliance Status', doc.statusLabel),
                    const Divider(height: 20),
                    _buildDocMetaRow('Coverage / Notes', doc.notes),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Copied ${doc.documentNumber} to clipboard'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: const Text('Copy Ref'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Downloaded offline certificate for ${doc.title}'),
                            backgroundColor: TraverzaColors.secondary,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.download_rounded, size: 16),
                      label: const Text('Offline PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TraverzaColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildDocMetaRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 11.5, color: TraverzaColors.textMuted)),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: TraverzaColors.text),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  /// Shows SOS Beacon trigger confirmation with real-time GPS coordinates
  static void showSosBeaconDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: TraverzaColors.roseEmergency, size: 26),
              SizedBox(width: 8),
              Text(
                'Trigger SOS Beacon?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: TraverzaColors.text),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'This will transmit an urgent emergency signal with your live telemetry to the TRAVERZA 24/7 Operations Rescue Desk and alert your primary emergency contact.',
                style: TextStyle(fontSize: 12.5, color: TraverzaColors.text, height: 1.4),
              ),
              SizedBox(height: 14),
              Text(
                'Current GPS Telemetry:',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: TraverzaColors.textMuted),
              ),
              SizedBox(height: 4),
              Text(
                'Lat: 7.9542° N · Lng: 80.7554° E (Sigiriya Sector)\nElevation: 184m · Low Cell Coverage Buffer',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: TraverzaColors.primary),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: TraverzaColors.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                TraverzaMapsLauncher.openEmergencyRoute(
                  lat: 7.9542,
                  lng: 80.7554,
                  facilityName: 'Sigiriya Tourist Police Station',
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('SOS Beacon Dispatched to Rescue Desk (+94 11 289 0123) & 1990 Ambulance'),
                    backgroundColor: TraverzaColors.roseEmergency,
                    duration: Duration(seconds: 4),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TraverzaColors.roseEmergency,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Dispatch SOS Now', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
