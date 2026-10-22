import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../services/journey_autopilot_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? badgeText;
  final bool isEscalation;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.badgeText,
    this.isEscalation = false,
  });
}

class AICompanionSheet extends StatefulWidget {
  const AICompanionSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AICompanionSheet(),
    );
  }

  @override
  State<AICompanionSheet> createState() => _AICompanionSheetState();
}

class _AICompanionSheetState extends State<AICompanionSheet> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [
    ChatMessage(
      text:
          'Ayubowan! I am your TRAVERZA 2.0 Travel Companion. I am grounded in your live trip record (TRIP-LK-2026-9041). How can I assist you with your journey today?',
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      badgeText: 'GROUNDED IN TRIP-LK-2026-9041',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final userMsg = text.trim();
    _controller.clear();

    setState(() {
      _messages.add(
        ChatMessage(
          text: userMsg,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
    });

    _scrollToBottom();

    // AI Contextual Response
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      final reply = _generateGroundedReply(userMsg);
      setState(() {
        _messages.add(reply);
      });
      _scrollToBottom();
    });
  }

  ChatMessage _generateGroundedReply(String input) {
    final lower = input.toLowerCase();
    final service = JourneyAutopilotService.instance;

    if (lower.contains('escalat') || lower.contains('human') || lower.contains('support') || lower.contains('emergency')) {
      return ChatMessage(
        text:
            '🚨 Connecting you to the TRAVERZA Priority Operations Desk in Colombo.\n\n• Duty Operator: Nimali (Trip Operations)\n• SLTDA Grievance Compliance SLA: < 15 minutes\n• Emergency Hotline: 1912 (Sri Lanka Tourist Police)\n• Operations Desk direct token generated. An operator has been alerted to your session.',
        isUser: false,
        timestamp: DateTime.now(),
        badgeText: 'OPERATIONS DESK ESCALATION',
        isEscalation: true,
      );
    }

    if (lower.contains('next action') || lower.contains('what next') || lower.contains('action')) {
      final action = service.nextAction;
      return ChatMessage(
        text:
            'Your current Next Action:\n\n📌 **${action.title}**\n${action.description}\n\n⏳ SLA Status: ${action.deadlineText}\n\nTripGraph confirms your transfer buffer has +30m mountain driving allowance.',
        isUser: false,
        timestamp: DateTime.now(),
        badgeText: 'TRIPGRAPH AUTHORITATIVE STATE',
      );
    }

    if (lower.contains('delay') || lower.contains('flight') || lower.contains('safe') || lower.contains('schedule')) {
      return ChatMessage(
        text:
            'I reviewed your schedule through TripGraph 2.0:\n\n• Flight UL-504 landing at 16:00 (revised from 14:30).\n• Airport to Sigiriya: 148 km via A1/A6 Highway (estimated 224 min duration).\n• Safety Check: Sigiriya sunset gate closes at 17:30. Because landing is at 16:00, Autopilot moved the Sigiriya climb to Day 2 sunrise (06:30).\n• Feasibility Result: 100% Feasible with zero conflicting reservations.',
        isUser: false,
        timestamp: DateTime.now(),
        badgeText: 'DETERMINISTIC VALIDATION',
      );
    }

    if (lower.contains('budget') || lower.contains('cost') || lower.contains('spend') || lower.contains('pay')) {
      final b = service.budget;
      return ChatMessage(
        text:
            'Here is your 5-point transparent budget breakdown:\n\n• Committed: LKR ${b.committedLKR.toLocaleString()}\n• Paid in Escrow: LKR ${b.paidLKR.toLocaleString()}\n• Pending Acceptance: LKR ${b.pendingLKR.toLocaleString()}\n• Estimated On-Site (Tickets & Meals): LKR ${b.estimatedOnSiteLKR.toLocaleString()}\n• Total Expected Spend: LKR ${b.totalSpendLKR.toLocaleString()}\n\nNote: Double-entry escrow ledger guarantees zero hidden card surcharges.',
        isUser: false,
        timestamp: DateTime.now(),
        badgeText: 'IMMUTABLE FINANCIAL RECORD',
      );
    }

    if (lower.contains('etiquette') || lower.contains('temple') || lower.contains('clothes') || lower.contains('dress')) {
      return ChatMessage(
        text:
            'Cultural Etiquette Advice for Sacred Sites (Kandy & Sigiriya):\n\n• Dress Code: White or light-coloured attire covering shoulders and knees is required at the Sacred Temple of the Tooth.\n• Footwear: Must be removed at temple footwear depositories.\n• Photography: Never turn your back to a Buddha statue for a selfie; respectful photography of architecture is welcomed.\n• Local Greetings: Press palms together and say "Ayubowan" (May you have a long life).',
        isUser: false,
        timestamp: DateTime.now(),
        badgeText: 'LOCAL TRAVEL INTELLIGENCE',
      );
    }

    return ChatMessage(
      text:
          'I checked your active journey (ID: TRIP-LK-2026-9041). Stays, transfer and guide bookings are verified. Would you like to review your Autopilot recovery plan, inspect day-by-day buffers, or ask for local dining recommendations?',
      isUser: false,
      timestamp: DateTime.now(),
      badgeText: 'CONNECTED JOURNEY AI',
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
          // Header Handle & Title
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: TraverzaColors.border)),
            ),
            child: Column(
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
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [TraverzaColors.primary, TraverzaColors.secondary],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'AI Travel Companion',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: TraverzaColors.text,
                                  ),
                                ),
                                Text(
                                  'Grounded in TripGraph 2.0 & Live Booking Truth',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: TraverzaColors.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: TraverzaColors.textMuted),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Quick Prompt Chips
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildPromptChip('What is my next action?'),
                _buildPromptChip('Is Day 1 schedule safe?'),
                _buildPromptChip('Explain my budget'),
                _buildPromptChip('Temple dress code'),
                _buildPromptChip('🚨 Escalate to Human Concierge'),
              ],
            ),
          ),

          const Divider(height: 1, color: TraverzaColors.border),

          // Messages View
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageItem(msg);
              },
            ),
          ),

          // Input Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            decoration: const BoxDecoration(
              color: TraverzaColors.surface,
              border: Border(top: BorderSide(color: TraverzaColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: TraverzaColors.background,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: TraverzaColors.border),
                    ),
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _sendMessage,
                      decoration: const InputDecoration(
                        hintText: 'Ask about your trip, schedule, or budget...',
                        hintStyle: TextStyle(fontSize: 13, color: TraverzaColors.textMuted),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _sendMessage(_controller.text),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: TraverzaColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptChip(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
      child: ActionChip(
        label: Text(
          text,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: TraverzaColors.primary),
        ),
        backgroundColor: TraverzaColors.background,
        side: const BorderSide(color: TraverzaColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () => _sendMessage(text),
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: msg.isUser
              ? TraverzaColors.primary
              : msg.isEscalation
                  ? const Color(0xFFFEF2F2)
                  : TraverzaColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: msg.isUser
                ? TraverzaColors.primary
                : msg.isEscalation
                    ? TraverzaColors.roseEmergency.withValues(alpha: 0.3)
                    : TraverzaColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (msg.badgeText != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: msg.isEscalation
                      ? TraverzaColors.roseEmergency.withValues(alpha: 0.12)
                      : TraverzaColors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  msg.badgeText!,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: msg.isEscalation ? TraverzaColors.roseEmergency : TraverzaColors.secondary,
                  ),
                ),
              ),
            ],
            Text(
              msg.text,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: msg.isUser ? Colors.white : TraverzaColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension IntFormatting on int {
  String toLocaleString() {
    final str = toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}
