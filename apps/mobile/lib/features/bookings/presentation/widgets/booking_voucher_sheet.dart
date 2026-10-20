import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../data/booking_models.dart';

class BookingVoucherSheet extends StatelessWidget {
  final TraverzaBooking booking;

  const BookingVoucherSheet({
    super.key,
    required this.booking,
  });

  static void show(BuildContext context, {required TraverzaBooking booking}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BookingVoucherSheet(booking: booking),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: TraverzaColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: TraverzaColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: TraverzaColors.secondary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.qr_code_2, color: TraverzaColors.secondary, size: 20),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Digital Travel Voucher',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: TraverzaColors.text,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: TraverzaColors.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: TraverzaColors.border),

          // Voucher Card Content (Scrollable)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Boarding Pass Style Card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: TraverzaColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: TraverzaColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: TraverzaColors.primary.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Top Header
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: TraverzaColors.primary,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(19)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'TRAVERZA BOARDING PASS',
                                    style: TextStyle(
                                      color: TraverzaColors.accent,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    booking.id,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'monospace',
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: booking.status.color.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: booking.status.color),
                                ),
                                child: Text(
                                  booking.status.label,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // QR Code Section
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Column(
                              children: [
                                Container(
                                  width: 170,
                                  height: 170,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: TraverzaColors.border, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.04),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      _buildSimulatedQrGrid(),
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: TraverzaColors.primary,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Icon(Icons.verified, color: Colors.white, size: 22),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Scan for Instant On-Site Verification',
                                  style: TextStyle(fontSize: 11, color: TraverzaColors.textMuted, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: TraverzaColors.background,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: TraverzaColors.border),
                                  ),
                                  child: Text(
                                    'CRYPTOGRAPHIC TOKEN (SHA-256): ${booking.qrToken.substring(0, 14)}...',
                                    style: const TextStyle(fontSize: 9.5, fontFamily: 'monospace', color: TraverzaColors.textMuted, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Dashed Separator
                        _buildDashedSeparator(),

                        // Booking Specification Details
                        Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.serviceTitle,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TraverzaColors.text),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.business_outlined, size: 14, color: TraverzaColors.secondary),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '${booking.providerName} • ${booking.sltdaLicenseNo}',
                                      style: const TextStyle(fontSize: 12, color: TraverzaColors.textMuted),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              _buildDetailRow(
                                'Scheduled Date',
                                booking.dateDescription,
                                'Time Window',
                                booking.timeWindow,
                              ),
                              const SizedBox(height: 12),
                              _buildDetailRow(
                                'Service Location',
                                booking.locationDetails,
                                'Basis / Specs',
                                booking.priceBasis,
                              ),
                              const SizedBox(height: 12),
                              _buildDetailRow(
                                'Total Amount',
                                booking.priceFormatted,
                                'Payment Status',
                                booking.status == BookingStatus.confirmed
                                    ? 'Escrow Captured'
                                    : 'Awaiting Settlement',
                              ),
                            ],
                          ),
                        ),

                        // Footer Guarantee
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: TraverzaColors.secondary.withValues(alpha: 0.08),
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(19)),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.shield_outlined, size: 16, color: TraverzaColors.secondary),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Protected under SLTDA marketplace safety and dispute rules.',
                                  style: TextStyle(fontSize: 11, color: TraverzaColors.secondary, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Offline notice card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: TraverzaColors.warmSand.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: TraverzaColors.border),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.wifi_off_outlined, color: TraverzaColors.text, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cached for Offline Travel',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                              ),
                              Text(
                                'This cryptographic pass can be scanned by chauffeurs and front desks even without internet access.',
                                style: TextStyle(fontSize: 11, color: TraverzaColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Voucher PDF downloaded to device downloads.'),
                                backgroundColor: TraverzaColors.secondary,
                              ),
                            );
                          },
                          icon: const Icon(Icons.download_outlined, size: 16),
                          label: const Text('Download PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: TraverzaColors.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Connected to ${booking.providerName} concierge channel.'),
                                backgroundColor: TraverzaColors.primary,
                              ),
                            );
                          },
                          icon: const Icon(Icons.chat_outlined, size: 16, color: Colors.white),
                          label: const Text('Contact Provider', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TraverzaColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Added to Apple / Google Wallet pass storage.'),
                            backgroundColor: TraverzaColors.secondary,
                          ),
                        );
                      },
                      icon: const Icon(Icons.account_balance_wallet_outlined, size: 16, color: TraverzaColors.secondary),
                      label: const Text(
                        'Apple / Google Wallet',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: TraverzaColors.secondary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label1, String value1, String label2, String value2) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label1, style: const TextStyle(fontSize: 10.5, color: TraverzaColors.textMuted)),
              const SizedBox(height: 2),
              Text(value1, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: TraverzaColors.text)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label2, style: const TextStyle(fontSize: 10.5, color: TraverzaColors.textMuted)),
              const SizedBox(height: 2),
              Text(value2, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: TraverzaColors.text)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDashedSeparator() {
    return Row(
      children: List.generate(
        32,
        (index) => Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: 1.5,
            color: index % 2 == 0 ? TraverzaColors.border : Colors.transparent,
          ),
        ),
      ),
    );
  }

  Widget _buildSimulatedQrGrid() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(9, (r) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(9, (c) {
            final isCorner = (r < 3 && c < 3) || (r < 3 && c > 5) || (r > 5 && c < 3);
            final isDark = isCorner || ((r * c + r + c) % 3 == 0);
            return Container(
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF102A43) : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      }),
    );
  }
}
