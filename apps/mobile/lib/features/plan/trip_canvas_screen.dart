import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/sri_lanka_map_canvas.dart';
import 'widgets/active_trip_summary_card.dart';
import 'widgets/add_to_trip_sheet.dart';
import 'widgets/transit_buffer_connector.dart';
import 'widgets/trip_stop_card.dart';

class TripCanvasScreen extends StatefulWidget {
  final bool isHotelConfirmed;
  final VoidCallback onToggleSimulation;
  final VoidCallback onBackToHub;
  final VoidCallback? onNavigateToPackages;
  final VoidCallback? onNavigateToCustomBuilder;

  const TripCanvasScreen({
    super.key,
    required this.isHotelConfirmed,
    required this.onToggleSimulation,
    required this.onBackToHub,
    this.onNavigateToPackages,
    this.onNavigateToCustomBuilder,
  });

  @override
  State<TripCanvasScreen> createState() => _TripCanvasScreenState();
}

class _TripCanvasScreenState extends State<TripCanvasScreen> {
  int _selectedDay = 1;

  void _showReadinessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.health_and_safety_outlined, color: TraverzaColors.secondary),
            SizedBox(width: 8),
            Text('Trip Readiness Audit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReadinessItem(
              'Bandaranaike Intl Airport Reception',
              'Arrival scheduled & customs buffer verified',
              true,
            ),
            const SizedBox(height: 10),
            _buildReadinessItem(
              'Chauffeur Transfer (Prado LK-402)',
              'Driver assigned · Ceylon Chauffeurs Guild',
              true,
            ),
            const SizedBox(height: 10),
            _buildReadinessItem(
              'Sigiriya Water Garden Eco Villa',
              widget.isHotelConfirmed
                  ? 'Confirmed by property · Voucher issued'
                  : 'Awaiting provider acceptance response',
              widget.isHotelConfirmed,
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: widget.isHotelConfirmed
                    ? TraverzaColors.emeraldSuccess.withValues(alpha: 0.1)
                    : TraverzaColors.amberWarning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.isHotelConfirmed
                    ? 'All 3 required bookings confirmed. Trip is 100% travel ready.'
                    : '2 of 3 service bookings confirmed. Eco villa response pending.',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: widget.isHotelConfirmed
                      ? TraverzaColors.emeraldSuccess
                      : TraverzaColors.amberWarning,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: TraverzaColors.secondary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildReadinessItem(String title, String subtitle, bool isConfirmed) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          isConfirmed ? Icons.check_circle : Icons.hourglass_top_rounded,
          color: isConfirmed ? TraverzaColors.emeraldSuccess : TraverzaColors.amberWarning,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: TraverzaColors.textMuted)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Navigation Header with Back Button
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: TraverzaColors.text),
                  tooltip: 'Back to Plan Hub',
                  onPressed: widget.onBackToHub,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Trip Canvas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: TraverzaColors.text,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: TraverzaColors.secondary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Active Workspace',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: TraverzaColors.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Connected corridor: Colombo (CMB) → Sigiriya → Kandy',
                        style: TextStyle(fontSize: 11, color: TraverzaColors.textMuted),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: widget.onBackToHub,
                  icon: const Icon(Icons.hub_outlined, size: 14, color: TraverzaColors.secondary),
                  label: const Text(
                    'Plan Hub',
                    style: TextStyle(
                      color: TraverzaColors.secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Sub-navigation mode bar (Switch between Plan Hub, Trip Canvas, Packages, Custom Builder)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 2, 16, 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: TraverzaColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: TraverzaColors.border),
            ),
            child: Row(
              children: [
                _buildModeTab('Plan Hub', false, Icons.hub_outlined, widget.onBackToHub),
                _buildModeTab('Trip Canvas', true, Icons.alt_route, () {}),
                _buildModeTab('Packages', false, Icons.card_travel_outlined, widget.onNavigateToPackages),
                _buildModeTab('Custom Builder', false, Icons.edit_note_outlined, widget.onNavigateToCustomBuilder),
              ],
            ),
          ),

          // Active Trip Summary Card with Back to Plan Hub button
          ActiveTripSummaryCard(
            isHotelConfirmed: widget.isHotelConfirmed,
            onToggleSimulation: widget.onToggleSimulation,
            isCanvasView: true,
            onBackToHub: widget.onBackToHub,
            onOpenReadiness: _showReadinessDialog,
          ),

          // Google Maps Real Route Canvas
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SriLankaMapCanvas(),
          ),
          const SizedBox(height: 12),

          // Planning Toolbar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      side: const BorderSide(color: TraverzaColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => AddToTripSheet.show(context),
                    icon: const Icon(Icons.add, size: 16, color: TraverzaColors.secondary),
                    label: const Text('Add to Trip', style: TextStyle(fontSize: 12, color: TraverzaColors.secondary, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      side: const BorderSide(color: TraverzaColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _showReadinessDialog,
                    icon: const Icon(Icons.verified_outlined, size: 16, color: TraverzaColors.secondary),
                    label: const Text('Trip Readiness', style: TextStyle(fontSize: 12, color: TraverzaColors.secondary, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Day Selector Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: TraverzaColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: TraverzaColors.border),
            ),
            child: Row(
              children: [
                _buildDayTab(1, 'Day 1: Cultural Gateway'),
                _buildDayTab(2, 'Day 2: Kandy City'),
                _buildDayTab(3, 'Day 3: Highlands'),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Day 1 Timeline Content
          if (_selectedDay == 1) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Day 1: Cultural Gateway',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: TraverzaColors.text,
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onToggleSimulation,
                    child: Text(
                      widget.isHotelConfirmed ? 'Simulate Unconfirmed' : 'Simulate Provider Accept',
                      style: const TextStyle(color: TraverzaColors.secondary, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // Stop 1: Flight Arrival
            const TripStopCard(
              time: '09:00 - 10:00',
              title: 'Bandaranaike Intl Airport (CMB) Arrival',
              subtitle: 'Flight UL-504 • Customs & Immigration',
              category: 'FLIGHT',
              status: 'NONE',
              icon: Icons.flight_land,
              iconColor: Colors.blueAccent,
              price: null,
              latitude: 7.1808,
              longitude: 79.8841,
            ),

            // Transit buffer connector
            const TransitBufferConnector(
              duration: '30m customs buffer',
              note: 'Highland transit calculator verified',
            ),

            // Stop 2: Chauffeur Transfer
            const TripStopCard(
              time: '10:30 - 14:00',
              title: 'Chauffeur Transfer to Sigiriya Cultural Triangle',
              subtitle: 'Ceylon Chauffeurs Guild • Fleet #LK-402 (Toyota Prado)',
              category: 'TRANSFER',
              status: 'CONFIRMED',
              icon: Icons.directions_car,
              iconColor: TraverzaColors.emeraldSuccess,
              price: 'LKR 18,500',
              latitude: 7.4863,
              longitude: 80.3623,
            ),

            // Transit buffer connector
            const TransitBufferConnector(
              duration: '45m check-in buffer',
              note: 'Rest period before ascent',
            ),

            // Stop 3: Sigiriya Rock Fortress Guided Ascent
            const TripStopCard(
              time: '15:00 - 17:30',
              title: 'Sigiriya Rock Fortress Guided Ascent',
              subtitle: 'Cultural Heritage Guide Guild • SLTDA Lic #044',
              category: 'ACTIVITY',
              status: 'CONFIRMED',
              icon: Icons.landscape,
              iconColor: Colors.amberAccent,
              price: 'LKR 12,000',
              latitude: 7.9570,
              longitude: 80.7603,
            ),

            // Stop 4: Eco Villa
            TripStopCard(
              time: '18:30 Check-in',
              title: 'Sigiriya Water Garden Eco Villa',
              subtitle: 'Deluxe Chalet with Private Plunge Pool',
              category: 'STAY',
              status: widget.isHotelConfirmed ? 'CONFIRMED' : 'REQUEST_SUBMITTED',
              icon: Icons.hotel,
              iconColor: widget.isHotelConfirmed ? TraverzaColors.emeraldSuccess : Colors.orangeAccent,
              price: 'LKR 38,000',
              latitude: 7.9525,
              longitude: 80.7480,
            ),
          ] else if (_selectedDay == 2) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: const Text(
                'Day 2: Sacred Hill Capital',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: TraverzaColors.text),
              ),
            ),
            const TripStopCard(
              time: '08:30 - 10:00',
              title: 'Dambulla Golden Cave Temple Excursion',
              subtitle: 'Ancient Buddhist Cave Monastery',
              category: 'ACTIVITY',
              status: 'CONFIRMED',
              icon: Icons.landscape,
              iconColor: Colors.amberAccent,
              price: 'LKR 3,500',
              latitude: 7.8566,
              longitude: 80.6492,
            ),
            const TransitBufferConnector(
              duration: '2h scenic hill drive',
              note: 'Matale pass road geometry',
            ),
            const TripStopCard(
              time: '14:30 - 16:30',
              title: 'Temple of the Sacred Tooth Relic',
              subtitle: 'UNESCO World Heritage royal temple complex',
              category: 'ACTIVITY',
              status: 'CONFIRMED',
              icon: Icons.account_balance,
              iconColor: TraverzaColors.emeraldSuccess,
              price: 'LKR 4,000',
              latitude: 7.2936,
              longitude: 80.6413,
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: const Text(
                'Day 3: Highlands & Tea Country',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: TraverzaColors.text),
              ),
            ),
            const TripStopCard(
              time: '09:00 - 13:00',
              title: 'Ramboda Falls & Highland Tea Estate Tour',
              subtitle: 'High-altitude Ceylon tea tasting & scenic waterfall',
              category: 'ACTIVITY',
              status: 'CONFIRMED',
              icon: Icons.local_florist,
              iconColor: TraverzaColors.emeraldSuccess,
              price: 'LKR 4,500',
              latitude: 7.0515,
              longitude: 80.6974,
            ),
          ],

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildModeTab(String title, bool isSelected, IconData icon, VoidCallback? onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? TraverzaColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : TraverzaColors.textMuted,
              ),
              const SizedBox(height: 3),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : TraverzaColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayTab(int dayNumber, String title) {
    final isSelected = _selectedDay == dayNumber;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedDay = dayNumber),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? TraverzaColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              'Day $dayNumber',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : TraverzaColors.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
