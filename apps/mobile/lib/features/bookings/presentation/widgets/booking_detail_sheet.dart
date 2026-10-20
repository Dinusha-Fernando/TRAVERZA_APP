import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../data/booking_models.dart';
import 'booking_voucher_sheet.dart';

class BookingDetailSheet extends StatefulWidget {
  final TraverzaBooking booking;
  final VoidCallback onBookingUpdated;

  const BookingDetailSheet({
    super.key,
    required this.booking,
    required this.onBookingUpdated,
  });

  static void show(
    BuildContext context, {
    required TraverzaBooking booking,
    required VoidCallback onBookingUpdated,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BookingDetailSheet(
        booking: booking,
        onBookingUpdated: onBookingUpdated,
      ),
    );
  }

  @override
  State<BookingDetailSheet> createState() => _BookingDetailSheetState();
}

class _BookingDetailSheetState extends State<BookingDetailSheet> {
  void _simulateAcceptance() {
    setState(() {
      widget.booking.status = BookingStatus.confirmed;
    });
    widget.onBookingUpdated();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Simulated provider acceptance: ${widget.booking.serviceTitle} confirmed!'),
        backgroundColor: TraverzaColors.emeraldSuccess,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _requestCancellation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Reservation?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Under the ${widget.booking.cancellationTerms}, you are eligible for 100% refund of ${widget.booking.priceFormatted}.',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: TraverzaColors.emeraldSuccess.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Zero platform cancellation penalty. Escrow refund will be remitted to original payment card within 2-4 business days.',
                style: TextStyle(fontSize: 11, color: TraverzaColors.emeraldSuccess, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Booking', style: TextStyle(color: TraverzaColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              setState(() {
                widget.booking.status = BookingStatus.cancelled;
              });
              widget.onBookingUpdated();
              Navigator.pop(ctx);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Booking cancelled. Full refund initiated via payment gateway.'),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Confirm Cancellation', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.id,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: TraverzaColors.secondary,
                      ),
                    ),
                    const Text(
                      'Reservation Control Centre',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TraverzaColors.text),
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

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Overview Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: TraverzaColors.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: TraverzaColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: TraverzaColors.secondary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                booking.category,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: TraverzaColors.secondary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: booking.status.color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: booking.status.color),
                              ),
                              child: Text(
                                booking.status.label,
                                style: TextStyle(
                                  color: booking.status.color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          booking.serviceTitle,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: TraverzaColors.text),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${booking.providerName} • ${booking.sltdaLicenseNo}',
                          style: const TextStyle(fontSize: 12, color: TraverzaColors.textMuted),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Date & Timing', style: TextStyle(fontSize: 11, color: TraverzaColors.textMuted)),
                                  Text(booking.dateDescription, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Total Quoted Rate', style: TextStyle(fontSize: 11, color: TraverzaColors.textMuted)),
                                Text(
                                  booking.priceFormatted,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: TraverzaColors.primary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // If pending, show SLA countdown
                  if (booking.status == BookingStatus.requestSubmitted && booking.responseDeadline != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: TraverzaColors.amberWarning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: TraverzaColors.amberWarning.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.hourglass_top_outlined, color: TraverzaColors.amberWarning, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Provider Response Window (12h SLA)',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: TraverzaColors.amberWarning),
                                ),
                                Text(
                                  'Reservation desk must accept or decline before 18:00 UTC. If unanswered, escrow authorization will release automatically.',
                                  style: TextStyle(fontSize: 11, color: TraverzaColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Authoritative Event Timeline
                  const Text(
                    'Authoritative Event Timeline',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: TraverzaColors.text),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Immutable audit log stored in PostgreSQL for SLTDA compliance.',
                    style: TextStyle(fontSize: 11.5, color: TraverzaColors.textMuted),
                  ),
                  const SizedBox(height: 14),

                  ...booking.timeline.asMap().entries.map((entry) {
                    final index = entry.key;
                    final ev = entry.value;
                    final isLast = index == booking.timeline.length - 1;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: TraverzaColors.secondary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.check, size: 10, color: Colors.white),
                            ),
                            if (!isLast)
                              Container(
                                width: 2,
                                height: 42,
                                color: TraverzaColors.border,
                              ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(ev.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    Text(
                                      ev.actorRole,
                                      style: const TextStyle(fontSize: 9.5, color: TraverzaColors.secondary, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(ev.description, style: const TextStyle(fontSize: 11.5, color: TraverzaColors.textMuted)),
                                const SizedBox(height: 2),
                                Text(ev.timestamp, style: const TextStyle(fontSize: 10, color: TraverzaColors.textMuted)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 16),

                  // Cancellation terms preview
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: TraverzaColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: TraverzaColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Cancellation & Refund Policy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(booking.cancellationTerms, style: const TextStyle(fontSize: 12, color: TraverzaColors.textMuted)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Simulation action (only for testing/demo)
                  if (booking.status == BookingStatus.requestSubmitted) ...[
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: TraverzaColors.secondary,
                        side: const BorderSide(color: TraverzaColors.secondary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        minimumSize: const Size(double.infinity, 44),
                      ),
                      onPressed: _simulateAcceptance,
                      icon: const Icon(Icons.bolt, size: 16),
                      label: const Text('Simulate Provider Accept (Demo Mode)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Bottom Action Buttons
                  Row(
                    children: [
                      if (booking.status == BookingStatus.confirmed) ...[
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TraverzaColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              BookingVoucherSheet.show(context, booking: booking);
                            },
                            icon: const Icon(Icons.qr_code, color: Colors.white, size: 16),
                            label: const Text('View Digital Voucher', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      if (booking.status != BookingStatus.cancelled && booking.status != BookingStatus.completed)
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              side: const BorderSide(color: Colors.redAccent),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: _requestCancellation,
                            child: const Text('Cancel Booking', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
