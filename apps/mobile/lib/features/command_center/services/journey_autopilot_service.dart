import 'package:flutter/material.dart';
import '../models/journey_command_center_model.dart';
import '../../notifications/services/notification_service.dart';
import '../../notifications/data/notification_model.dart';

class JourneyAutopilotService extends ChangeNotifier {
  static final JourneyAutopilotService instance = JourneyAutopilotService._internal();

  JourneyAutopilotService._internal() {
    _initDefaults();
  }

  bool _isHotelConfirmed = false;
  bool get isHotelConfirmed => _isHotelConfirmed;

  void setHotelConfirmed(bool confirmed) {
    _isHotelConfirmed = confirmed;
    notifyListeners();
  }

  // Active Incidents in Autopilot loop
  final List<AutopilotIncidentData> _incidents = [];
  List<AutopilotIncidentData> get incidents => List.unmodifiable(_incidents);

  // Active Disruption Count
  int get pendingAuthorizationCount =>
      _incidents.where((i) => i.status == AutopilotStatus.pendingAuthorization).length;

  // Active Autopilot Loop Step (0: Idle/Observe, 1: Observe, 2: Assess, 3: Propose, 4: Authorize, 5: Execute, 6: Verify)
  int _currentLoopStep = 0;
  int get currentLoopStep => _currentLoopStep;

  String _lastLoopMessage = 'Autopilot Loop: Monitoring flight, weather & provider telemetry';
  String get lastLoopMessage => _lastLoopMessage;

  void _initDefaults() {
    // Seed 1 active disruption for Day 1
    _incidents.add(
      AutopilotIncidentData(
        id: 'AP-INC-8902',
        tripId: 'TRIP-LK-2026-9041',
        eventType: 'FLIGHT_DELAY',
        sourceFeed: 'AviationStack Live Radar (Flight UL-504)',
        observedAt: '4m ago',
        severity: AutopilotSeverity.high,
        impactAnalysis:
            'Flight UL-504 delayed by +90m. Original landing 14:30 shifted to 16:00 at CMB Airport. Scheduled Sigiriya sunset hike (cutoff 17:30) is at risk.',
        proposedResolution:
            'Adjust CMB transfer pickup to 16:30. Reschedule Sigiriya Rock ascent to Day 2 sunrise (06:30) and swap Day 1 evening with Minneriya sunset drive.',
        costDeltaLKR: 0,
        timingDeltaMinutes: 90,
        backupProvider: 'Cultural Heritage Guide Guild (SLTDA/GD/2026/044)',
        status: AutopilotStatus.pendingAuthorization,
        tripGraphFeasibility: 'FEASIBLE (Deterministic re-check passed)',
        timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
      ),
    );
    _currentLoopStep = 4; // At Authorization step
    _lastLoopMessage = 'Step 4: Traveller Authorization required for flight delay reschedule';
  }

  // Journey Status
  JourneyStatusData get status => JourneyStatusData(
        tripId: 'TRIP-LK-2026-9041',
        title: 'Cultural Triangle & Highland Heritage',
        currentDay: 1,
        totalDays: 3,
        corridor: 'Colombo → Sigiriya → Kandy → Nuwara Eliya',
        derivedStatus: _isHotelConfirmed ? 'Fully Confirmed (3/3)' : 'Partially Confirmed (2/3)',
        isHotelConfirmed: _isHotelConfirmed,
        lastUpdated: DateTime.now(),
      );

  // Next Action
  NextActionData get nextAction {
    if (_incidents.any((i) => i.status == AutopilotStatus.pendingAuthorization)) {
      final inc = _incidents.firstWhere((i) => i.status == AutopilotStatus.pendingAuthorization);
      return NextActionData(
        title: 'Autopilot Decision Required: ${inc.eventType.replaceAll('_', ' ')}',
        description: inc.proposedResolution,
        deadlineText: 'Review before driver dispatch (25m remaining)',
        remainingMinutes: 25,
        urgency: NextActionUrgency.high,
        actionLabel: 'Review & Authorize',
      );
    }

    if (!_isHotelConfirmed) {
      return const NextActionData(
        title: 'Sigiriya Water Garden: Awaiting Provider Response',
        description: 'Boutique Heritage Stays (Pvt) Ltd has 11h 14m remaining on 12h SLA quote.',
        deadlineText: '11h 14m remaining on quote snapshot',
        remainingMinutes: 674,
        urgency: NextActionUrgency.medium,
        actionLabel: 'View Quote Details',
      );
    }

    return const NextActionData(
      title: 'Airport Transfer: Pickup at CMB Terminal',
      description: 'Chauffeur Guide (Fleet #LK-402) on standby at Arrival Hall Gate 4.',
      deadlineText: 'Pickup scheduled at 16:30',
      remainingMinutes: 45,
      urgency: NextActionUrgency.info,
      actionLabel: 'Contact Chauffeur',
    );
  }

  // Trip Health
  TripHealthData get health {
    final hasDisruption = _incidents.any((i) => i.status == AutopilotStatus.pendingAuthorization);
    return TripHealthData(
      scorePercentage: hasDisruption ? 82 : (_isHotelConfirmed ? 98 : 92),
      summary: hasDisruption
          ? 'Attention Required: Active disruption under Autopilot assessment'
          : (_isHotelConfirmed
              ? 'Excellent: All 3 components confirmed with calibrated buffers'
              : 'Good: Transfer & Excursion confirmed, Hotel pending SLA'),
      indicators: [
        'TripGraph 2.0: Deterministic validation verified',
        'Buffer calibration: +30m mountain terrain allowance active',
        'SLTDA Verified: All assigned operators licensed & accredited',
        'Double-entry escrow protection: Payment captured in suspense',
      ],
      hasActiveDisruptions: hasDisruption,
    );
  }

  // Timeline
  List<TimelineSegmentData> get timeline => [
        const TimelineSegmentData(
          timeRange: '14:30 – 16:30',
          title: 'Airport to Sigiriya Private Transfer',
          location: 'Bandaranaike Int Airport (CMB) → Sigiriya',
          category: StopCategory.transfer,
          provider: 'Ceylon Chauffeurs Guild (Fleet #LK-402)',
          status: 'CONFIRMED',
          bufferMinutes: 30,
          latitude: 7.1808,
          longitude: 79.8841,
          notes: 'Highway route A1/A6. Chauffeur tracks live radar feed.',
        ),
        TimelineSegmentData(
          timeRange: '18:30 Check-in',
          title: 'Sigiriya Water Garden Eco Villa',
          location: 'Sigiriya Ancient Citadel Precinct',
          category: StopCategory.stay,
          provider: 'Boutique Heritage Stays (Pvt) Ltd',
          status: _isHotelConfirmed ? 'CONFIRMED' : 'REQUESTED',
          bufferMinutes: 0,
          latitude: 7.9541,
          longitude: 80.7547,
          notes: _isHotelConfirmed
              ? 'Voucher #VOUCH-LK-9041 active. Welcome King Coconut confirmed.'
              : 'Pending provider confirmation. 12h SLA active.',
        ),
        const TimelineSegmentData(
          timeRange: 'Day 2 · 06:30 – 09:30',
          title: 'Sigiriya Rock Fortress Guided Archaeological Ascent',
          location: 'Sigiriya UNESCO World Heritage Site',
          category: StopCategory.guide,
          provider: 'Cultural Heritage Guide Guild',
          status: 'CONFIRMED',
          bufferMinutes: 45,
          latitude: 7.9570,
          longitude: 80.7603,
          notes: 'Sunrise slot reserved. Includes Lion Rock summit pass.',
        ),
      ];

  // Budget
  BudgetBreakdownData get budget => BudgetBreakdownData(
        committedLKR: _isHotelConfirmed ? 68500 : 30500,
        paidLKR: 30500,
        pendingLKR: _isHotelConfirmed ? 0 : 38000,
        estimatedOnSiteLKR: 14000,
        currency: 'LKR',
        exchangeRateTimestamp: 'Verified 22 Oct 2026 02:30 UTC',
      );

  // Digital Vouchers
  List<DigitalVoucherData> get vouchers => [
        const DigitalVoucherData(
          voucherCode: 'VOUCH-LK-TRANSFER-402',
          bookingRef: 'BK-LK-4402',
          serviceTitle: 'CMB Airport to Sigiriya Luxury Transfer',
          providerName: 'Ceylon Chauffeurs Guild (Fleet #LK-402)',
          sltdaLicense: 'SLTDA/CG/2026/102',
          checkInTime: '16:30 CMB Arrival Gate 4',
          securityHash: 'SHA256:8f92a10b...3d99',
        ),
        if (_isHotelConfirmed)
          const DigitalVoucherData(
            voucherCode: 'VOUCH-LK-STAY-9041',
            bookingRef: 'BK-LK-9041',
            serviceTitle: 'Sigiriya Water Garden Eco Villa (Deluxe Chalet)',
            providerName: 'Boutique Heritage Stays (Pvt) Ltd',
            sltdaLicense: 'SLTDA/HTL/2026/088',
            checkInTime: '18:30 Check-in (Reception Desk)',
            securityHash: 'SHA256:7c43d81e...91fa',
          ),
        const DigitalVoucherData(
          voucherCode: 'VOUCH-LK-EXCURSION-802',
          bookingRef: 'BK-LK-8802',
          serviceTitle: 'Sigiriya Rock Fortress Archaeological Guided Ascent',
          providerName: 'Cultural Heritage Guide Guild',
          sltdaLicense: 'SLTDA/GD/2026/044',
          checkInTime: 'Day 2 · 06:30 Main Ticket Gate',
          securityHash: 'SHA256:1a82f099...6e42',
        ),
      ];

  // Simulations
  void simulateFlightDelay(int delayMinutes) {
    final newId = 'AP-INC-${DateTime.now().millisecondsSinceEpoch % 10000}';
    _incidents.insert(
      0,
      AutopilotIncidentData(
        id: newId,
        tripId: 'TRIP-LK-2026-9041',
        eventType: 'FLIGHT_DELAY',
        sourceFeed: 'AviationStack Live Radar (Flight UL-504)',
        observedAt: 'Just now',
        severity: AutopilotSeverity.high,
        impactAnalysis:
            'Flight UL-504 delayed by +${delayMinutes}m. Landing revised from 14:30 to 16:00. CMB Airport pickup buffer adjusted.',
        proposedResolution:
            'Shift airport chauffeur pickup by +${delayMinutes}m. Reschedule Sigiriya climb to Day 2 sunrise and swap evening with Minneriya drive.',
        costDeltaLKR: 0,
        timingDeltaMinutes: delayMinutes,
        backupProvider: 'Cultural Heritage Guide Guild (SLTDA/GD/2026/044)',
        status: AutopilotStatus.pendingAuthorization,
        tripGraphFeasibility: 'FEASIBLE (Deterministic re-check passed)',
        timestamp: DateTime.now(),
      ),
    );

    _currentLoopStep = 4;
    _lastLoopMessage = 'Step 4: Traveller Authorization required for +${delayMinutes}m flight delay';

    TraverzaNotificationService.instance.addNotification(
      TraverzaNotification(
        id: 'NOTIF-AUTOPILOT-$newId',
        title: '⚡ Autopilot Alert: Flight UL-504 Delayed',
        body: 'Landing delayed by +${delayMinutes}m. Feasible recovery plan ready for your approval.',
        category: NotificationCategory.autopilot,
        timestamp: DateTime.now(),
        isRead: false,
        actionRoute: 'command_center',
        actionLabel: 'Review Recovery Plan',
        priority: 'high',
      ),
    );

    notifyListeners();
  }

  void simulateDriverBreakdown() {
    final newId = 'AP-INC-${DateTime.now().millisecondsSinceEpoch % 10000}';
    _incidents.insert(
      0,
      AutopilotIncidentData(
        id: newId,
        tripId: 'TRIP-LK-2026-9041',
        eventType: 'DRIVER_CANCEL',
        sourceFeed: 'IoT Chauffeur Vehicle Telemetry & SOS Call',
        observedAt: 'Just now',
        severity: AutopilotSeverity.critical,
        impactAnalysis:
            'Chauffeur Van (Fleet #LK-402) transmission breakdown on A1 Highway near Warakapola. 3h 15m until CMB flight landing.',
        proposedResolution:
            'Auto-dispatch verified standby chauffeur from Negombo Fleet Depot. Recalculate CMB pickup with +15m buffer.',
        costDeltaLKR: 0,
        timingDeltaMinutes: 15,
        backupProvider: 'Ceylon Chauffeurs Guild (Fleet #LK-214 · SLTDA/CG/2026/102)',
        status: AutopilotStatus.pendingAuthorization,
        tripGraphFeasibility: 'FEASIBLE (Deterministic re-check passed)',
        timestamp: DateTime.now(),
      ),
    );

    _currentLoopStep = 4;
    _lastLoopMessage = 'Step 4: Standby Chauffeur match found. Authorization required to dispatch.';

    TraverzaNotificationService.instance.addNotification(
      TraverzaNotification(
        id: 'NOTIF-AUTOPILOT-$newId',
        title: '🚨 Autopilot Alert: Driver Breakdown',
        body: 'Standby chauffeur identified in Negombo. Tap to authorize dispatch with no extra charge.',
        category: NotificationCategory.autopilot,
        timestamp: DateTime.now(),
        isRead: false,
        actionRoute: 'command_center',
        actionLabel: 'Authorize Fleet Dispatch',
        priority: 'emergency',
      ),
    );

    notifyListeners();
  }

  void simulateWeatherDisruption() {
    final newId = 'AP-INC-${DateTime.now().millisecondsSinceEpoch % 10000}';
    _incidents.insert(
      0,
      AutopilotIncidentData(
        id: newId,
        tripId: 'TRIP-LK-2026-9041',
        eventType: 'WEATHER_DISRUPTION',
        sourceFeed: 'Sri Lanka Disaster Management Centre (SL-DMCC)',
        observedAt: 'Just now',
        severity: AutopilotSeverity.medium,
        impactAnalysis:
            'Heavy monsoon rainfall advisory on A5 Highway (Ramboda Pass). Mountain vehicle speed restricted to 25 km/h.',
        proposedResolution:
            'Re-route via Hatton/Gampola corridor (+22 km, +35m duration) avoiding active mudslide advisory zone.',
        costDeltaLKR: 3500,
        timingDeltaMinutes: 35,
        backupProvider: null,
        status: AutopilotStatus.pendingAuthorization,
        tripGraphFeasibility: 'FEASIBLE (Deterministic re-check passed)',
        timestamp: DateTime.now(),
      ),
    );

    _currentLoopStep = 4;
    _lastLoopMessage = 'Step 4: Weather detour proposed. Traveller approval required.';

    TraverzaNotificationService.instance.addNotification(
      TraverzaNotification(
        id: 'NOTIF-AUTOPILOT-$newId',
        title: '🌧️ Autopilot Weather Advisory: Ramboda Pass',
        body: 'Safe mountain detour via Hatton suggested (+35m). Tap to inspect re-route.',
        category: NotificationCategory.safety,
        timestamp: DateTime.now(),
        isRead: false,
        actionRoute: 'command_center',
        actionLabel: 'Review Re-route',
        priority: 'high',
      ),
    );

    notifyListeners();
  }

  // Authorization Decision Actions
  void approveProposal(String incidentId) {
    final idx = _incidents.indexWhere((i) => i.id == incidentId);
    if (idx != -1) {
      _incidents[idx] = _incidents[idx].copyWith(status: AutopilotStatus.approved);
      _currentLoopStep = 6; // Verified!
      _lastLoopMessage = 'Step 6: Executed & Verified via TripGraph. Provider notified via WhatsApp/SMS.';

      TraverzaNotificationService.instance.addNotification(
        TraverzaNotification(
          id: 'NOTIF-APPROVED-$incidentId',
          title: '✓ Autopilot Recovery Approved & Verified',
          body: 'Itinerary safely updated. Chauffeur and guide dispatched with revised schedule.',
          category: NotificationCategory.autopilot,
          timestamp: DateTime.now(),
          isRead: false,
          actionRoute: 'command_center',
          actionLabel: 'View Updated Itinerary',
          priority: 'high',
        ),
      );

      notifyListeners();
    }
  }

  void declineProposal(String incidentId) {
    final idx = _incidents.indexWhere((i) => i.id == incidentId);
    if (idx != -1) {
      _incidents[idx] = _incidents[idx].copyWith(status: AutopilotStatus.declined);
      _currentLoopStep = 0;
      _lastLoopMessage = 'Proposal declined. Original itinerary preserved; manual concierge assigned.';

      TraverzaNotificationService.instance.addNotification(
        TraverzaNotification(
          id: 'NOTIF-DECLINED-$incidentId',
          title: 'Proposal Declined',
          body: 'Original booking intact. Operations desk notified for manual assistance.',
          category: NotificationCategory.trip,
          timestamp: DateTime.now(),
          isRead: false,
          actionRoute: 'command_center',
          actionLabel: 'View Trip Status',
          priority: 'normal',
        ),
      );

      notifyListeners();
    }
  }

  void resetToBaseline() {
    _incidents.clear();
    _initDefaults();
    notifyListeners();
  }
}
