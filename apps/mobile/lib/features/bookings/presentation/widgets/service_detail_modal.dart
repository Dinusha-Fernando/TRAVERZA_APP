import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../data/booking_models.dart';

class ServiceDetailModal extends StatelessWidget {
  final TraverzaServiceItem service;
  final VoidCallback onAddToTrip;
  final VoidCallback onRequestBooking;

  const ServiceDetailModal({
    super.key,
    required this.service,
    required this.onAddToTrip,
    required this.onRequestBooking,
  });

  static void show(
    BuildContext context, {
    required TraverzaServiceItem service,
    required VoidCallback onAddToTrip,
    required VoidCallback onRequestBooking,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ServiceDetailModal(
        service: service,
        onAddToTrip: onAddToTrip,
        onRequestBooking: onRequestBooking,
      ),
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

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo with Category Overlay
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        Image.network(
                          service.imageUrl,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 180,
                            color: TraverzaColors.primary.withValues(alpha: 0.1),
                            alignment: Alignment.center,
                            child: const Icon(Icons.image_not_supported_outlined, size: 40, color: TraverzaColors.textMuted),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: TraverzaColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              service.category,
                              style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star, color: TraverzaColors.rating, size: 13),
                                const SizedBox(width: 3),
                                Text(
                                  service.rating,
                                  style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title & Location
                  Text(
                    service.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TraverzaColors.text),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: TraverzaColors.secondary),
                      const SizedBox(width: 4),
                      Text(service.location, style: const TextStyle(fontSize: 12, color: TraverzaColors.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Provider Identity & SLTDA Verification Chip
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: TraverzaColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: TraverzaColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: TraverzaColors.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.verified_outlined, color: TraverzaColors.secondary, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(service.provider, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(height: 2),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Audited SLTDA: ${service.license}',
                                      style: const TextStyle(fontSize: 11, color: TraverzaColors.secondary, fontWeight: FontWeight.w600),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('What is verified?'),
                                          content: Text('TRAVERZA validates that ${service.provider} holds active SLTDA registration (${service.license}) and verified commercial vehicle/guide permits for the Colombo-Sigiriya-Kandy corridor.'),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Understood')),
                                          ],
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'What is verified?',
                                      style: TextStyle(fontSize: 10.5, color: TraverzaColors.secondary, decoration: TextDecoration.underline),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Fit to Trip Reason
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: TraverzaColors.emeraldSuccess.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: TraverzaColors.emeraldSuccess.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.alt_route, color: TraverzaColors.emeraldSuccess, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            service.fitToTripReason,
                            style: const TextStyle(fontSize: 11.5, color: TraverzaColors.emeraldSuccess, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Inclusions & Highlights
                  const Text('Inclusions & Highlights', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 6),
                  Text(service.inclusions, style: const TextStyle(fontSize: 12.5, color: TraverzaColors.text, height: 1.4)),
                  const SizedBox(height: 14),

                  // Cancellation & Change Terms
                  const Text('Cancellation & Change Terms', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 6),
                  Text(service.policy, style: const TextStyle(fontSize: 12.5, color: TraverzaColors.textMuted)),
                  const SizedBox(height: 20),

                  // Pricing Breakdown (Quote Snapshot)
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
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pricing Breakdown (Quote Snapshot)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: TraverzaColors.text),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Base Rate', style: TextStyle(fontSize: 12, color: TraverzaColors.textMuted)),
                            Text(service.price, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('Taxes & Buffer Included', style: TextStyle(fontSize: 12, color: TraverzaColors.textMuted)),
                            Text('LKR 0', style: TextStyle(fontSize: 12, color: TraverzaColors.emeraldSuccess, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Divider(height: 16, color: TraverzaColors.border),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Total Estimated Quote', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: TraverzaColors.text)),
                                  Text(service.priceBasis, style: const TextStyle(fontSize: 10.5, color: TraverzaColors.textMuted)),
                                ],
                              ),
                            ),
                            Text(
                              service.price,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TraverzaColors.primary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TraverzaColors.surface,
              border: Border(top: BorderSide(color: TraverzaColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: TraverzaColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      onAddToTrip();
                    },
                    icon: const Icon(Icons.add, size: 16, color: TraverzaColors.secondary),
                    label: const Text('Add to Trip', style: TextStyle(color: TraverzaColors.secondary, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TraverzaColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      onRequestBooking();
                    },
                    icon: const Icon(Icons.check_circle_outline, size: 16, color: Colors.white),
                    label: const Text('Request Booking', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
