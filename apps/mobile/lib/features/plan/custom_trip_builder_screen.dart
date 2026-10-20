import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'widgets/add_to_trip_sheet.dart';

class CustomTripBuilderScreen extends StatefulWidget {
  final VoidCallback onBackToHub;
  final VoidCallback onTripSaved;

  const CustomTripBuilderScreen({
    super.key,
    required this.onBackToHub,
    required this.onTripSaved,
  });

  @override
  State<CustomTripBuilderScreen> createState() => _CustomTripBuilderScreenState();
}

class _CustomTripBuilderScreenState extends State<CustomTripBuilderScreen> {
  int _currentStage = 0; // 0: Basics, 1: Destinations, 2: Services, 3: TripGraph Feasibility, 4: Review & Save

  // Stage A: Basics
  String _tripTitle = 'My Cultural & Highland Journey';
  int _durationDays = 3;
  int _travellers = 2;
  double _budgetLkr = 75000;
  bool _datesFlexible = true;

  // Stage B: Destinations with priority
  final List<Map<String, dynamic>> _destinations = [
    {'name': 'Colombo (CMB)', 'priority': 'Must-see', 'stay': false},
    {'name': 'Sigiriya & Dambulla', 'priority': 'Must-see', 'stay': true},
    {'name': 'Kandy Sacred City', 'priority': 'Must-see', 'stay': true},
    {'name': 'Nuwara Eliya Tea Country', 'priority': 'Would-like', 'stay': false},
  ];

  // Stage C: Custom Services
  final List<Map<String, String>> _selectedServices = [
    {'title': 'Toyota Prado Chauffeur Transfer', 'cat': 'TRANSFER', 'price': 'LKR 18,500'},
    {'title': 'Sigiriya Water Garden Eco Villa (1 Night)', 'cat': 'STAY', 'price': 'LKR 38,000'},
    {'title': 'Sigiriya Rock Fortress Guided Ascent', 'cat': 'ACTIVITY', 'price': 'LKR 12,000'},
  ];

  // Stage D: TripGraph issues & repairs
  bool _bufferIssueResolved = false;

  void _nextStage() {
    if (_currentStage < 4) {
      setState(() => _currentStage++);
    }
  }

  void _prevStage() {
    if (_currentStage > 0) {
      setState(() => _currentStage--);
    } else {
      widget.onBackToHub();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TraverzaColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: TraverzaColors.text),
          onPressed: _prevStage,
        ),
        title: Text(
          'Stage ${_currentStage + 1} of 5: ${_stageTitles[_currentStage]}',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: TraverzaColors.text),
        ),
        actions: [
          TextButton(
            onPressed: widget.onBackToHub,
            child: const Text('Exit Draft', style: TextStyle(color: TraverzaColors.secondary, fontSize: 12)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Step progress indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: TraverzaColors.surface,
            child: Row(
              children: List.generate(5, (index) {
                final isDone = index < _currentStage;
                final isCurrent = index == _currentStage;
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDone
                          ? TraverzaColors.emeraldSuccess
                          : isCurrent
                              ? TraverzaColors.secondary
                              : TraverzaColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          const Divider(height: 1, color: TraverzaColors.border),

          // Main stage content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildStageContent(),
            ),
          ),

          // Bottom Stage Navigation Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TraverzaColors.surface,
              boxShadow: [
                BoxShadow(
                  color: TraverzaColors.primary.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  if (_currentStage > 0)
                    OutlinedButton(
                      onPressed: _prevStage,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        side: const BorderSide(color: TraverzaColors.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Back', style: TextStyle(color: TraverzaColors.text)),
                    ),
                  if (_currentStage > 0) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _currentStage == 4 ? widget.onTripSaved : _nextStage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TraverzaColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        _currentStage == 4 ? 'Save Draft & Open Canvas' : 'Continue to ${_stageTitles[_currentStage + 1]}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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

  static const List<String> _stageTitles = [
    'Trip Basics',
    'Destinations',
    'Add Services',
    'TripGraph Feasibility',
    'Review & Save',
  ];

  Widget _buildStageContent() {
    switch (_currentStage) {
      case 0:
        return _buildStageABasics();
      case 1:
        return _buildStageBDestinations();
      case 2:
        return _buildStageCServices();
      case 3:
        return _buildStageDTripGraph();
      case 4:
        return _buildStageEReview();
      default:
        return const SizedBox();
    }
  }

  // --- STAGE A: Basics ---
  Widget _buildStageABasics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Stage A: Define Your Trip Foundation',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TraverzaColors.text),
        ),
        const SizedBox(height: 6),
        const Text(
          'Set duration, group size and budget. You can refine dates and details at any time.',
          style: TextStyle(fontSize: 12.5, color: TraverzaColors.textMuted),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: TextEditingController(text: _tripTitle),
          onChanged: (val) => _tripTitle = val,
          decoration: InputDecoration(
            labelText: 'Trip Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                decoration: BoxDecoration(
                  color: TraverzaColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: TraverzaColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Duration', style: TextStyle(fontSize: 11, color: TraverzaColors.textMuted)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$_durationDays Days',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: IconButton(
                            icon: const Icon(Icons.remove, size: 14),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: _durationDays > 1 ? () => setState(() => _durationDays--) : null,
                          ),
                        ),
                        const SizedBox(width: 4),
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: IconButton(
                            icon: const Icon(Icons.add, size: 14),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => setState(() => _durationDays++),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                decoration: BoxDecoration(
                  color: TraverzaColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: TraverzaColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Travellers', style: TextStyle(fontSize: 11, color: TraverzaColors.textMuted)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$_travellers People',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: IconButton(
                            icon: const Icon(Icons.remove, size: 14),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: _travellers > 1 ? () => setState(() => _travellers--) : null,
                          ),
                        ),
                        const SizedBox(width: 4),
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: IconButton(
                            icon: const Icon(Icons.add, size: 14),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => setState(() => _travellers++),
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
        const SizedBox(height: 16),
        SwitchListTile(
          value: _datesFlexible,
          onChanged: (val) => setState(() => _datesFlexible = val),
          title: const Text('My dates are flexible', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold)),
          subtitle: const Text('Gives you maximum availability for boutique stays and safari permits', style: TextStyle(fontSize: 11.5)),
          activeColor: TraverzaColors.secondary,
          tileColor: TraverzaColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: TraverzaColors.border),
          ),
        ),
        const SizedBox(height: 16),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Target Budget', style: TextStyle(fontSize: 12, color: TraverzaColors.textMuted)),
                  Text('LKR ${_budgetLkr.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: TraverzaColors.primary)),
                ],
              ),
              Slider(
                value: _budgetLkr,
                min: 30000,
                max: 200000,
                divisions: 17,
                activeColor: TraverzaColors.secondary,
                onChanged: (val) => setState(() => _budgetLkr = val),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- STAGE B: Destinations ---
  Widget _buildStageBDestinations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Stage B: Choose Destinations & Overnight Areas',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TraverzaColors.text),
        ),
        const SizedBox(height: 6),
        const Text(
          'Organize your sequence along the Cultural Triangle & Highland corridor. Reorder stops or tag overnight stays.',
          style: TextStyle(fontSize: 12.5, color: TraverzaColors.textMuted),
        ),
        const SizedBox(height: 16),
        ..._destinations.asMap().entries.map((entry) {
          final index = entry.key;
          final dest = entry.value;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: TraverzaColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: TraverzaColors.border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: TraverzaColors.primary,
                  child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dest['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: TraverzaColors.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              dest['priority'] as String,
                              style: const TextStyle(fontSize: 10, color: TraverzaColors.secondary, fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (dest['stay'] == true) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.hotel, size: 12, color: TraverzaColors.emeraldSuccess),
                            const Text(' Overnight Stay', style: TextStyle(fontSize: 10.5, color: TraverzaColors.emeraldSuccess, fontWeight: FontWeight.bold)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.swap_vert, color: TraverzaColors.textMuted),
                  onPressed: () {
                    // Reorder item downwards if possible
                    if (index < _destinations.length - 1) {
                      setState(() {
                        final item = _destinations.removeAt(index);
                        _destinations.insert(index + 1, item);
                      });
                    }
                  },
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // --- STAGE C: Services ---
  Widget _buildStageCServices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Stage C: Add Stays, Drivers & Guides',
                style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold, color: TraverzaColors.text),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                AddToTripSheet.show(
                  context,
                  onItemAdded: (title, cat, subtitle, price) {
                    setState(() {
                      _selectedServices.add({'title': title, 'cat': cat, 'price': price});
                    });
                  },
                );
              },
              icon: const Icon(Icons.add, size: 16, color: TraverzaColors.secondary),
              label: const Text('Add Service', style: TextStyle(color: TraverzaColors.secondary, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Each service retains its own quote and booking contract. Add stays, transfers, guides or rest buffers.',
          style: TextStyle(fontSize: 12.5, color: TraverzaColors.textMuted),
        ),
        const SizedBox(height: 16),
        ..._selectedServices.map((svc) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: TraverzaColors.surface,
              borderRadius: BorderRadius.circular(14),
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
                  child: const Icon(Icons.check_circle_outline, color: TraverzaColors.secondary, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(svc['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                      const SizedBox(height: 2),
                      Text(svc['cat']!, style: const TextStyle(fontSize: 10.5, color: TraverzaColors.textMuted, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Text(svc['price']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: TraverzaColors.primary)),
              ],
            ),
          );
        }),
      ],
    );
  }

  // --- STAGE D: TripGraph Feasibility Engine ---
  Widget _buildStageDTripGraph() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: TraverzaColors.secondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.analytics_outlined, color: TraverzaColors.secondary, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'TripGraph Schedule Audit',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TraverzaColors.text),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Deterministic feasibility engine assessing highway road geometry, check-in windows, and immigration buffers.',
          style: TextStyle(fontSize: 12.5, color: TraverzaColors.textMuted),
        ),
        const SizedBox(height: 16),

        // Issue 1: Buffer Issue
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _bufferIssueResolved
                ? TraverzaColors.emeraldSuccess.withValues(alpha: 0.08)
                : TraverzaColors.amberWarning.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _bufferIssueResolved
                  ? TraverzaColors.emeraldSuccess.withValues(alpha: 0.3)
                  : TraverzaColors.amberWarning.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _bufferIssueResolved ? Icons.check_circle : Icons.warning_amber_rounded,
                    color: _bufferIssueResolved ? TraverzaColors.emeraldSuccess : TraverzaColors.amberWarning,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _bufferIssueResolved ? 'Buffer Resolved: 30m Customs Buffer Added' : 'Warning: Tight Airport Transfer Window',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                        color: _bufferIssueResolved ? TraverzaColors.emeraldSuccess : TraverzaColors.amberWarning,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _bufferIssueResolved
                    ? 'Arrival at CMB now includes 30m customs and baggage clearance prior to 10:30 Kurunegala highway departure.'
                    : 'CMB arrival at 09:00 with transfer at 09:30 allows only 30m for customs and baggage claim. Recommended buffer is 45-60m.',
                style: const TextStyle(fontSize: 12, color: TraverzaColors.textMuted),
              ),
              if (!_bufferIssueResolved) ...[
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TraverzaColors.secondary,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => setState(() => _bufferIssueResolved = true),
                  icon: const Icon(Icons.auto_fix_high, size: 14, color: Colors.white),
                  label: const Text('Apply 30m Buffer Repair', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Issue 2: Daylight check
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TraverzaColors.emeraldSuccess.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TraverzaColors.emeraldSuccess.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: const [
              Icon(Icons.check_circle, color: TraverzaColors.emeraldSuccess, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Sigiriya ascent (15:00 - 17:30) completes comfortably before 18:15 sunset.',
                  style: TextStyle(fontSize: 12, color: TraverzaColors.text, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- STAGE E: Review & Save ---
  Widget _buildStageEReview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Stage E: Review Your Custom Draft',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TraverzaColors.text),
        ),
        const SizedBox(height: 6),
        const Text(
          'Saved as an independent draft. No payments or supplier obligations are created until you explicitly submit booking requests.',
          style: TextStyle(fontSize: 12.5, color: TraverzaColors.textMuted),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TraverzaColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TraverzaColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_tripTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TraverzaColors.text)),
              const SizedBox(height: 4),
              const Text('Corridor: Colombo · Sigiriya · Kandy · Nuwara Eliya', style: TextStyle(fontSize: 12, color: TraverzaColors.secondary, fontWeight: FontWeight.w600)),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Estimated Draft Total:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const Text('LKR 68,500', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TraverzaColors.primary)),
                ],
              ),
              const SizedBox(height: 4),
              const Text('Committed spend: LKR 0 (Draft state)', style: TextStyle(fontSize: 11, color: TraverzaColors.textMuted)),
              const SizedBox(height: 12),
              Row(
                children: const [
                  Icon(Icons.check_circle, size: 14, color: TraverzaColors.emeraldSuccess),
                  SizedBox(width: 6),
                  Text('TripGraph Feasibility Passed', style: TextStyle(fontSize: 11.5, color: TraverzaColors.emeraldSuccess, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
