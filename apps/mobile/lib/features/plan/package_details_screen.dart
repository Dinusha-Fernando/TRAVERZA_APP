import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'data/package_model.dart';

class PackageDetailsScreen extends StatelessWidget {
  final TraverzaPackage package;
  final VoidCallback onCustomize;
  final VoidCallback? onBook;

  const PackageDetailsScreen({
    super.key,
    required this.package,
    required this.onCustomize,
    this.onBook,
  });

  static void show(
    BuildContext context, {
    required TraverzaPackage package,
    required VoidCallback onCustomize,
    VoidCallback? onBook,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => PackageDetailsScreen(
          package: package,
          onCustomize: onCustomize,
          onBook: onBook,
        ),
      ),
    );
  }

  void _showBookingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final phoneCtrl = TextEditingController(text: '+94 77 123 4567');
        int partySize = 2;
        DateTime selectedDate = DateTime(2026, 10, 24);

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 16,
              ),
              decoration: const BoxDecoration(
                color: TraverzaColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: TraverzaColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Request Booking: ${package.title}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: TraverzaColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Fulfilled by ${package.providerName} • ${package.sltdaLicenseNo}',
                    style: const TextStyle(fontSize: 11.5, color: TraverzaColors.secondary),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Preferred Arrival Date:', style: TextStyle(fontSize: 13, color: TraverzaColors.text)),
                      Text(
                        '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: TraverzaColors.secondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Travellers:', style: TextStyle(fontSize: 13, color: TraverzaColors.text)),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: TraverzaColors.secondary),
                            onPressed: partySize > 1 ? () => setModalState(() => partySize--) : null,
                          ),
                          Text('$partySize', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: TraverzaColors.secondary),
                            onPressed: () => setModalState(() => partySize++),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: phoneCtrl,
                    decoration: InputDecoration(
                      labelText: 'Contact Phone / WhatsApp',
                      prefixIcon: const Icon(Icons.phone, color: TraverzaColors.secondary, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: TraverzaColors.sand.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Estimated Booking:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        Text(
                          'LKR ${(package.basePriceLkr * partySize).toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: TraverzaColors.primary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TraverzaColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Booking Request sent to ${package.providerName}! Ref: REQ-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'),
                            backgroundColor: TraverzaColors.emeraldSuccess,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Text('Submit Booking Request', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOperator = package.isOperatorPackage;

    return Scaffold(
      backgroundColor: TraverzaColors.background,
      appBar: AppBar(
        title: Text(
          isOperator ? 'Operator Package Details' : 'Itinerary Route Template',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TraverzaColors.text),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline, color: TraverzaColors.primary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Package saved to your Saved list'),
                  backgroundColor: TraverzaColors.secondary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: TraverzaColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Banner Card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: TraverzaColors.surface,
                borderRadius: BorderRadius.circular(20),
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isOperator
                              ? TraverzaColors.primary.withValues(alpha: 0.1)
                              : TraverzaColors.sand.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isOperator ? 'OPERATOR BUNDLED PACKAGE' : 'ITINERARY ROUTE INSPIRATION',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: isOperator ? TraverzaColors.primary : TraverzaColors.text,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 16, color: TraverzaColors.rating),
                          const SizedBox(width: 3),
                          Text(
                            '${package.rating} (${package.reviewCount} reviews)',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    package.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: TraverzaColors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 15, color: TraverzaColors.secondary),
                      const SizedBox(width: 5),
                      Text(
                        '${package.durationDays} Days / ${package.durationNights} Nights',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: TraverzaColors.secondary),
                      ),
                      const SizedBox(width: 14),
                      const Icon(Icons.map_outlined, size: 15, color: TraverzaColors.secondary),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          package.corridorName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: TraverzaColors.textMuted, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Provider badge
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: TraverzaColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 18,
                          backgroundColor: TraverzaColors.primary,
                          child: Icon(Icons.business, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                package.providerName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: TraverzaColors.text),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.verified, size: 12, color: TraverzaColors.emeraldSuccess),
                                  const SizedBox(width: 4),
                                  Text(
                                    package.sltdaLicenseNo,
                                    style: const TextStyle(fontSize: 11, color: TraverzaColors.emeraldSuccess, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    package.description,
                    style: const TextStyle(fontSize: 13, color: TraverzaColors.textMuted, height: 1.4),
                  ),
                ],
              ),
            ),

            // Day-by-Day Itinerary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                'Day-by-Day Journey Itinerary',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TraverzaColors.text),
              ),
            ),
            const SizedBox(height: 8),
            ...package.itinerary.map((day) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: TraverzaColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: TraverzaColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: TraverzaColors.secondary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Day ${day.dayNumber}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: TraverzaColors.secondary),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            day.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: TraverzaColors.text),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...day.stops.map((stop) => Padding(
                          padding: const EdgeInsets.only(left: 8, top: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_outline, size: 13, color: TraverzaColors.secondary),
                              const SizedBox(width: 6),
                              Text(stop, style: const TextStyle(fontSize: 12, color: TraverzaColors.textMuted)),
                            ],
                          ),
                        )),
                  ],
                ),
              );
            }),

            const SizedBox(height: 16),
            // Inclusions and Exclusions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                'Inclusions & Terms',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TraverzaColors.text),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TraverzaColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: TraverzaColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('What is Included:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: TraverzaColors.emeraldSuccess)),
                  const SizedBox(height: 6),
                  ...package.inclusions.map((inc) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check, size: 14, color: TraverzaColors.emeraldSuccess),
                            const SizedBox(width: 6),
                            Expanded(child: Text(inc, style: const TextStyle(fontSize: 12, color: TraverzaColors.textMuted))),
                          ],
                        ),
                      )),
                  const SizedBox(height: 12),
                  const Text('Exclusions:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: TraverzaColors.roseEmergency)),
                  const SizedBox(height: 6),
                  ...package.exclusions.map((exc) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.close, size: 14, color: TraverzaColors.roseEmergency),
                            const SizedBox(width: 6),
                            Expanded(child: Text(exc, style: const TextStyle(fontSize: 12, color: TraverzaColors.textMuted))),
                          ],
                        ),
                      )),
                  const SizedBox(height: 12),
                  const Divider(color: TraverzaColors.border),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.policy_outlined, size: 16, color: TraverzaColors.secondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Cancellation Policy: ${package.cancellationPolicy}',
                          style: const TextStyle(fontSize: 11.5, color: TraverzaColors.textMuted),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TraverzaColors.surface,
          boxShadow: [
            BoxShadow(
              color: TraverzaColors.primary.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOperator ? 'LKR ${package.basePriceLkr.toStringAsFixed(0)}' : 'Est. LKR ${package.basePriceLkr.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TraverzaColors.primary),
                  ),
                  Text(
                    isOperator ? 'per person · all taxes incl.' : 'independent bookings',
                    style: const TextStyle(fontSize: 10.5, color: TraverzaColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onCustomize();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: TraverzaColors.secondary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    isOperator ? 'Customize Trip' : 'Build Route',
                    style: const TextStyle(color: TraverzaColors.secondary, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              if (isOperator) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showBookingSheet(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TraverzaColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Book Package', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
