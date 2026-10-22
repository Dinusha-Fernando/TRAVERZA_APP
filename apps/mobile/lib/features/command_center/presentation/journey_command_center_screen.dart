import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/maps_launcher.dart';
import '../models/journey_command_center_model.dart';
import '../services/journey_autopilot_service.dart';
import 'widgets/ai_companion_sheet.dart';

enum CommandCenterTab {
  missionControl,
  autopilot,
  travelWallet,
}

class JourneyCommandCenterScreen extends StatefulWidget {
  final CommandCenterTab initialTab;

  const JourneyCommandCenterScreen({
    super.key,
    this.initialTab = CommandCenterTab.missionControl,
  });

  @override
  State<JourneyCommandCenterScreen> createState() => _JourneyCommandCenterScreenState();
}

class _JourneyCommandCenterScreenState extends State<JourneyCommandCenterScreen> {
  late CommandCenterTab _currentTab;
  final JourneyAutopilotService _service = JourneyAutopilotService.instance;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _service,
      builder: (context, _) {
        final status = _service.status;
        final nextAction = _service.nextAction;
        final health = _service.health;
        final timeline = _service.timeline;
        final budget = _service.budget;
        final incidents = _service.incidents;
        final vouchers = _service.vouchers;

        return Scaffold(
          backgroundColor: TraverzaColors.background,
          appBar: _buildAppBar(status),
          body: Column(
            children: [
              // Navigation Tab Segment
              _buildSegmentedTab(),

              // Active Tab Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: _buildTabBody(
                    status: status,
                    nextAction: nextAction,
                    health: health,
                    timeline: timeline,
                    budget: budget,
                    incidents: incidents,
                    vouchers: vouchers,
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => AICompanionSheet.show(context),
            backgroundColor: TraverzaColors.primary,
            icon: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
            label: const Text(
              'AI Companion',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(JourneyStatusData status) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'JOURNEY COMMAND CENTER',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                  color: TraverzaColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: TraverzaColors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'TRAVERZA 2.0',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: TraverzaColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          Text(
            '${status.tripId} · ${status.corridor}',
            style: const TextStyle(
              fontSize: 10,
              color: TraverzaColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'SLTDA Protected',
          icon: const Icon(Icons.verified_user_rounded, color: TraverzaColors.emeraldSuccess),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('SLTDA Compliance: Verified merchants & ISO 27001 data protection active.'),
                backgroundColor: TraverzaColors.emeraldSuccess,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSegmentedTab() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: TraverzaColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TraverzaColors.border),
      ),
      child: Row(
        children: [
          _buildTabButton('Mission Control', CommandCenterTab.missionControl, Icons.dashboard_outlined),
          _buildTabButton(
            'Autopilot (${_service.pendingAuthorizationCount})',
            CommandCenterTab.autopilot,
            Icons.bolt_rounded,
            highlight: _service.pendingAuthorizationCount > 0,
          ),
          _buildTabButton('Travel Wallet', CommandCenterTab.travelWallet, Icons.wallet_outlined),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, CommandCenterTab tab, IconData icon, {bool highlight = false}) {
    final isSelected = _currentTab == tab;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentTab = tab),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? TraverzaColors.primary
                : (highlight ? TraverzaColors.roseEmergency.withValues(alpha: 0.08) : Colors.transparent),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected
                    ? Colors.white
                    : (highlight ? TraverzaColors.roseEmergency : TraverzaColors.textMuted),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : (highlight ? TraverzaColors.roseEmergency : TraverzaColors.textMuted),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBody({
    required JourneyStatusData status,
    required NextActionData nextAction,
    required TripHealthData health,
    required List<TimelineSegmentData> timeline,
    required BudgetBreakdownData budget,
    required List<AutopilotIncidentData> incidents,
    required List<DigitalVoucherData> vouchers,
  }) {
    switch (_currentTab) {
      case CommandCenterTab.missionControl:
        return _buildMissionControlTab(
          status: status,
          nextAction: nextAction,
          health: health,
          timeline: timeline,
          budget: budget,
        );
      case CommandCenterTab.autopilot:
        return _buildAutopilotTab(incidents: incidents);
      case CommandCenterTab.travelWallet:
        return _buildTravelWalletTab(vouchers: vouchers, budget: budget);
    }
  }

  // 1. Mission Control Tab View
  Widget _buildMissionControlTab({
    required JourneyStatusData status,
    required NextActionData nextAction,
    required TripHealthData health,
    required List<TimelineSegmentData> timeline,
    required BudgetBreakdownData budget,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Module 1: Journey Status Hero
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [TraverzaColors.primary, TraverzaColors.primaryHover],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: TraverzaColors.primary.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 6),
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
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'DAY ${status.currentDay} OF ${status.totalDays}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: status.isHotelConfirmed
                          ? TraverzaColors.emeraldSuccess.withValues(alpha: 0.25)
                          : TraverzaColors.amberWarning.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: status.isHotelConfirmed
                            ? TraverzaColors.emeraldSuccess
                            : TraverzaColors.amberWarning,
                      ),
                    ),
                    child: Text(
                      status.derivedStatus,
                      style: TextStyle(
                        color: status.isHotelConfirmed ? const Color(0xFF6EE7B7) : const Color(0xFFFDE68A),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                status.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.route_outlined, size: 14, color: TraverzaColors.accent),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      status.corridor,
                      style: const TextStyle(fontSize: 12, color: Colors.white70),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Trip ID: ${status.tripId}',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: Colors.white54,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _service.setHotelConfirmed(!status.isHotelConfirmed);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            !status.isHotelConfirmed
                                ? 'Simulated Provider Accept: Hotel reservation fully confirmed!'
                                : 'Simulated Hotel reset to pending confirmation.',
                          ),
                          backgroundColor: TraverzaColors.secondary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status.isHotelConfirmed ? 'Revert to Partial' : 'Simulate Provider Accept',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Module 2: Next Action Alert
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: nextAction.urgency == NextActionUrgency.high
                ? const Color(0xFFFEF2F2)
                : (nextAction.urgency == NextActionUrgency.medium ? const Color(0xFFFFFBEB) : TraverzaColors.surface),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: nextAction.urgency == NextActionUrgency.high
                  ? TraverzaColors.roseEmergency.withValues(alpha: 0.4)
                  : (nextAction.urgency == NextActionUrgency.medium
                      ? TraverzaColors.amberWarning.withValues(alpha: 0.4)
                      : TraverzaColors.border),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    nextAction.urgency == NextActionUrgency.high
                        ? Icons.error_outline_rounded
                        : (nextAction.urgency == NextActionUrgency.medium
                            ? Icons.hourglass_top_rounded
                            : Icons.check_circle_outline_rounded),
                    size: 18,
                    color: nextAction.urgency == NextActionUrgency.high
                        ? TraverzaColors.roseEmergency
                        : (nextAction.urgency == NextActionUrgency.medium
                            ? TraverzaColors.amberWarning
                            : TraverzaColors.emeraldSuccess),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'NEXT ACTION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: TraverzaColors.primary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: TraverzaColors.border),
                    ),
                    child: Text(
                      nextAction.deadlineText,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: TraverzaColors.textMuted),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                nextAction.title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: TraverzaColors.text),
              ),
              const SizedBox(height: 4),
              Text(
                nextAction.description,
                style: const TextStyle(fontSize: 12, color: TraverzaColors.textMuted, height: 1.3),
              ),
              if (nextAction.urgency == NextActionUrgency.high) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => setState(() => _currentTab = CommandCenterTab.autopilot),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TraverzaColors.roseEmergency,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'Review Autopilot Recovery Options',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Module 3: Trip Health Radar
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TraverzaColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TraverzaColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.health_and_safety_outlined, size: 18, color: TraverzaColors.secondary),
                      const SizedBox(width: 8),
                      const Text(
                        'TRIP HEALTH & FEASIBILITY',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: TraverzaColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: health.scorePercentage > 90
                          ? const Color(0x2610B981)
                          : const Color(0x26F59E0B),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${health.scorePercentage}% Feasible',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: health.scorePercentage > 90 ? TraverzaColors.emeraldSuccess : TraverzaColors.amberWarning,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                health.summary,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: TraverzaColors.text),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: health.indicators.map((ind) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: TraverzaColors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: TraverzaColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_rounded, size: 12, color: TraverzaColors.emeraldSuccess),
                        const SizedBox(width: 4),
                        Text(
                          ind,
                          style: const TextStyle(fontSize: 10, color: TraverzaColors.textMuted, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Module 4: Connected Timeline with Google Maps deep link
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Connected Timeline',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TraverzaColors.text),
            ),
            Text(
              '${timeline.length} Stops Scheduled',
              style: const TextStyle(fontSize: 12, color: TraverzaColors.secondary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...timeline.map((seg) => _buildTimelineCard(seg)),

        const SizedBox(height: 16),

        // Module 5: 5-Tier Budget Breakdown
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: TraverzaColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TraverzaColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.account_balance_wallet_outlined, size: 18, color: TraverzaColors.secondary),
                      SizedBox(width: 8),
                      Text(
                        'BUDGET BREAKDOWN',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: TraverzaColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'LKR ${budget.totalSpendLKR.toLocaleString()}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: TraverzaColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildBudgetRow('Committed Spend (Services)', 'LKR ${budget.committedLKR.toLocaleString()}', TraverzaColors.primary),
              _buildBudgetRow('Paid in Escrow Ledger', 'LKR ${budget.paidLKR.toLocaleString()}', TraverzaColors.emeraldSuccess),
              _buildBudgetRow('Pending Provider Acceptance', 'LKR ${budget.pendingLKR.toLocaleString()}', TraverzaColors.amberWarning),
              _buildBudgetRow('Estimated On-Site (Meals/Passes)', 'LKR ${budget.estimatedOnSiteLKR.toLocaleString()}', TraverzaColors.textMuted),
              const Divider(height: 20, color: TraverzaColors.border),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Auditable Ledger Status', style: TextStyle(fontSize: 11, color: TraverzaColors.textMuted)),
                  Text(budget.exchangeRateTimestamp, style: const TextStyle(fontSize: 10, color: TraverzaColors.secondary, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildTimelineCard(TimelineSegmentData seg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TraverzaColors.surface,
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
                  color: TraverzaColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  seg.timeRange,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: TraverzaColors.secondary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: seg.status == 'CONFIRMED'
                      ? const Color(0x2610B981)
                      : const Color(0x26F59E0B),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  seg.status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: seg.status == 'CONFIRMED' ? TraverzaColors.emeraldSuccess : TraverzaColors.amberWarning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            seg.title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: TraverzaColors.text),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 12, color: TraverzaColors.secondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  seg.location,
                  style: const TextStyle(fontSize: 12, color: TraverzaColors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Provider: ${seg.provider}',
            style: const TextStyle(fontSize: 11, color: TraverzaColors.primary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (seg.bufferMinutes > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0x1A0284C7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '+${seg.bufferMinutes}m Calibrated Buffer',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
                  ),
                )
              else
                const SizedBox(),
              InkWell(
                onTap: () {
                  TraverzaMapsLauncher.openLocation(
                    latitude: seg.latitude,
                    longitude: seg.longitude,
                    label: seg.title,
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: TraverzaColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: TraverzaColors.border),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.directions_outlined, size: 12, color: TraverzaColors.secondary),
                      SizedBox(width: 4),
                      Text(
                        'Google Maps',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: TraverzaColors.secondary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetRow(String label, String amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: TraverzaColors.textMuted)),
          Text(amount, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  // 2. Autopilot Tab View (Flagship Innovation)
  Widget _buildAutopilotTab({required List<AutopilotIncidentData> incidents}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 6-Step Loop Visualizer
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: TraverzaColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TraverzaColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.sync_rounded, size: 18, color: TraverzaColors.secondary),
                      SizedBox(width: 8),
                      Text(
                        'AUTOPILOT 6-STEP LOOP',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: TraverzaColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: TraverzaColors.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'TripGraph 2.0 Governed',
                      style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: TraverzaColors.secondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Step Indicators
              Row(
                children: [
                  _buildLoopStepIndicator('1. Observe', 1, _service.currentLoopStep),
                  _buildLoopStepIndicator('2. Assess', 2, _service.currentLoopStep),
                  _buildLoopStepIndicator('3. Propose', 3, _service.currentLoopStep),
                  _buildLoopStepIndicator('4. Authorize', 4, _service.currentLoopStep),
                  _buildLoopStepIndicator('5. Execute', 5, _service.currentLoopStep),
                  _buildLoopStepIndicator('6. Verify', 6, _service.currentLoopStep),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: TraverzaColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: TraverzaColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 14, color: TraverzaColors.secondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _service.lastLoopMessage,
                        style: const TextStyle(fontSize: 11, color: TraverzaColors.text, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Live Disruption Incidents
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Active Disruption Events',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TraverzaColors.text),
            ),
            Text(
              '${incidents.length} Monitored',
              style: const TextStyle(fontSize: 12, color: TraverzaColors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...incidents.map((inc) => _buildIncidentCard(inc)),

        const SizedBox(height: 16),

        // Interactive Sandbox Controls (To test live disruptions)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: TraverzaColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TraverzaColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.science_outlined, size: 18, color: TraverzaColors.primary),
                  SizedBox(width: 8),
                  Text(
                    'DISRUPTION SIMULATION SANDBOX',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: TraverzaColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Test how Autopilot protects your journey against real-world incidents:',
                style: TextStyle(fontSize: 12, color: TraverzaColors.textMuted),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _service.simulateFlightDelay(90),
                    icon: const Icon(Icons.flight_land, size: 14, color: TraverzaColors.secondary),
                    label: const Text('Simulate +90m Flight Delay (UL-504)', style: TextStyle(fontSize: 11)),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _service.simulateDriverBreakdown(),
                    icon: const Icon(Icons.car_crash_outlined, size: 14, color: TraverzaColors.roseEmergency),
                    label: const Text('Simulate Chauffeur Breakdown', style: TextStyle(fontSize: 11, color: TraverzaColors.roseEmergency)),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _service.simulateWeatherDisruption(),
                    icon: const Icon(Icons.thunderstorm_outlined, size: 14, color: TraverzaColors.amberWarning),
                    label: const Text('Simulate Ramboda Pass Mudslide', style: TextStyle(fontSize: 11, color: TraverzaColors.amberWarning)),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _service.resetToBaseline(),
                    icon: const Icon(Icons.refresh_rounded, size: 14, color: TraverzaColors.textMuted),
                    label: const Text('Reset All to Baseline', style: TextStyle(fontSize: 11, color: TraverzaColors.textMuted)),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildLoopStepIndicator(String label, int stepIndex, int currentStep) {
    final isDone = currentStep >= stepIndex;
    final isCurrent = currentStep == stepIndex;
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: isCurrent
                  ? TraverzaColors.secondary
                  : (isDone ? TraverzaColors.emeraldSuccess : TraverzaColors.border),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isCurrent
                  ? TraverzaColors.secondary
                  : (isDone ? TraverzaColors.emeraldSuccess : TraverzaColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncidentCard(AutopilotIncidentData inc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TraverzaColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: inc.status == AutopilotStatus.pendingAuthorization
              ? TraverzaColors.roseEmergency.withValues(alpha: 0.4)
              : TraverzaColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: inc.severity == AutopilotSeverity.critical
                          ? const Color(0x26E11D48)
                          : const Color(0x26F59E0B),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${inc.severity.name.toUpperCase()} · ${inc.eventType.replaceAll('_', ' ')}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: inc.severity == AutopilotSeverity.critical
                            ? TraverzaColors.roseEmergency
                            : TraverzaColors.amberWarning,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('#${inc.id}', style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: TraverzaColors.textMuted)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: inc.status == AutopilotStatus.approved
                      ? const Color(0x2610B981)
                      : (inc.status == AutopilotStatus.declined ? const Color(0x26E11D48) : const Color(0x26F59E0B)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  inc.status == AutopilotStatus.approved
                      ? 'APPROVED'
                      : (inc.status == AutopilotStatus.declined ? 'DECLINED' : 'PENDING APPROVAL'),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: inc.status == AutopilotStatus.approved
                        ? TraverzaColors.emeraldSuccess
                        : (inc.status == AutopilotStatus.declined ? TraverzaColors.roseEmergency : TraverzaColors.amberWarning),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '📡 Provenance: ${inc.sourceFeed} (${inc.observedAt})',
            style: const TextStyle(fontSize: 11, color: TraverzaColors.textMuted),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: TraverzaColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              inc.impactAnalysis,
              style: const TextStyle(fontSize: 12, color: TraverzaColors.text, height: 1.3),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: TraverzaColors.secondary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: TraverzaColors.secondary.withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '⚡ Autopilot Proposed Plan',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: TraverzaColors.secondary),
                    ),
                    Text(
                      inc.costDeltaLKR == 0 ? 'Cost Delta: LKR 0' : '+LKR ${inc.costDeltaLKR.toLocaleString()}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: TraverzaColors.emeraldSuccess),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  inc.proposedResolution,
                  style: const TextStyle(fontSize: 12, color: TraverzaColors.text, height: 1.3),
                ),
                if (inc.backupProvider != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Matched Provider: ${inc.backupProvider}',
                    style: const TextStyle(fontSize: 11, color: TraverzaColors.primary, fontWeight: FontWeight.w600),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  inc.tripGraphFeasibility,
                  style: const TextStyle(fontSize: 10, color: TraverzaColors.emeraldSuccess, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          if (inc.status == AutopilotStatus.pendingAuthorization) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _service.declineProposal(inc.id),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: TraverzaColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Decline Plan', style: TextStyle(fontSize: 12, color: TraverzaColors.textMuted)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => _service.approveProposal(inc.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TraverzaColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      '✓ Authorize & Update Itinerary',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // 3. Travel Wallet Tab View (Section 4.3 Offline-First)
  Widget _buildTravelWalletTab({
    required List<DigitalVoucherData> vouchers,
    required BudgetBreakdownData budget,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Offline Sync Status Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: TraverzaColors.emeraldSuccess.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: const [
              Icon(Icons.offline_pin_rounded, color: TraverzaColors.emeraldSuccess, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  '100% Offline Ready · Trip pack, encrypted vouchers and emergency contacts are cached locally.',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF065F46)),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Digital Travel Vouchers',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TraverzaColors.text),
            ),
            Text(
              '${vouchers.length} Active',
              style: const TextStyle(fontSize: 12, color: TraverzaColors.secondary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...vouchers.map((vouch) => _buildVoucherCard(vouch)),

        const SizedBox(height: 16),

        // Emergency Assistance Vault
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: TraverzaColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TraverzaColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.shield_outlined, size: 18, color: TraverzaColors.roseEmergency),
                  SizedBox(width: 8),
                  Text(
                    'OFFLINE EMERGENCY CONTACTS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: TraverzaColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildEmergencyRow('Sri Lanka Tourism Hotline (SLTDA)', '1912 (24/7 Toll-Free)'),
              _buildEmergencyRow('Tourist Police Division Direct', '+94 11 242 1052 / 119 Emergency'),
              _buildEmergencyRow('Suwa Seriya Ambulance', '1990 (National Rapid Response)'),
              _buildEmergencyRow('Traverza Colombo Operations Desk', '+94 11 234 5678 (Priority Concierge)'),
            ],
          ),
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildVoucherCard(DigitalVoucherData vouch) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TraverzaColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TraverzaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                vouch.voucherCode,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12, fontWeight: FontWeight.bold, color: TraverzaColors.secondary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: TraverzaColors.emeraldSuccess.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'SLTDA Verified',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: TraverzaColors.emeraldSuccess),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            vouch.serviceTitle,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: TraverzaColors.text),
          ),
          const SizedBox(height: 4),
          Text(
            'Provider: ${vouch.providerName} • License: ${vouch.sltdaLicense}',
            style: const TextStyle(fontSize: 11, color: TraverzaColors.textMuted),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Check-in / Meeting', style: TextStyle(fontSize: 10, color: TraverzaColors.textMuted)),
                  Text(vouch.checkInTime, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: TraverzaColors.primary)),
                ],
              ),
              const Icon(Icons.qr_code_2_rounded, size: 36, color: TraverzaColors.primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyRow(String label, String number) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: TraverzaColors.textMuted)),
          Text(number, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: TraverzaColors.primary)),
        ],
      ),
    );
  }
}
