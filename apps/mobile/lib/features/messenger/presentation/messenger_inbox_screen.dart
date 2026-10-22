import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../models/messenger_models.dart';
import '../services/messenger_service.dart';
import 'conversation_screen.dart';

class MessengerInboxScreen extends StatefulWidget {
  const MessengerInboxScreen({super.key});

  @override
  State<MessengerInboxScreen> createState() => _MessengerInboxScreenState();
}

class _MessengerInboxScreenState extends State<MessengerInboxScreen> {
  final TextEditingController _searchController = TextEditingController();
  ConversationTypeEnum? _typeFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TraverzaColors.background,
      appBar: AppBar(
        backgroundColor: TraverzaColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: TraverzaColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Travel Messenger',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: TraverzaColors.primary),
            ),
            Text(
              'District Lounges · Travellers · Guides · Providers',
              style: TextStyle(fontSize: 10, color: TraverzaColors.secondary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Discover Lounges & Travellers',
            icon: const Icon(Icons.group_add_outlined, color: TraverzaColors.secondary),
            onPressed: () => _showDiscoverLoungesAndTravellersSheet(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: TraverzaColors.primary,
        icon: const Icon(Icons.explore_rounded, color: Colors.white, size: 20),
        label: const Text(
          'Join Lounge / Chat',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
        ),
        onPressed: () => _showDiscoverLoungesAndTravellersSheet(context),
      ),
      body: ListenableBuilder(
        listenable: MessengerService.instance,
        builder: (context, _) {
          final query = _searchController.text.trim().toLowerCase();
          final convs = MessengerService.instance.conversations.where((c) {
            if (_typeFilter != null && c.conversationType != _typeFilter) return false;
            if (query.isNotEmpty) {
              final matchTitle = c.title.toLowerCase().contains(query);
              final matchLast = c.lastMessageText.toLowerCase().contains(query);
              final matchDistrict = (c.districtName ?? '').toLowerCase().contains(query);
              if (!matchTitle && !matchLast && !matchDistrict) return false;
            }
            return true;
          }).toList();

          return Column(
            children: [
              // Search & Filter header
              Container(
                color: TraverzaColors.surface,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search lounges, places, travellers, guides...',
                        hintStyle: const TextStyle(fontSize: 12.5, color: TraverzaColors.textMuted),
                        prefixIcon: const Icon(Icons.search_rounded, size: 20, color: TraverzaColors.textMuted),
                        filled: true,
                        fillColor: TraverzaColors.background,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: TraverzaColors.border)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: TraverzaColors.border)),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 10),

                    // Filter chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(null, 'All Inboxes'),
                          _buildFilterChip(ConversationTypeEnum.districtLounge, '🌍 District Lounges'),
                          _buildFilterChip(ConversationTypeEnum.direct, '💬 Travellers & Guides'),
                          _buildFilterChip(ConversationTypeEnum.providerInquiry, '🏨 Provider Inquiries'),
                          _buildFilterChip(ConversationTypeEnum.tripGroup, '👥 Trip Groups'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Conversations list
              Expanded(
                child: convs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.chat_bubble_outline_rounded, size: 48, color: TraverzaColors.textMuted),
                            const SizedBox(height: 12),
                            const Text('No conversations match your filter.', style: TextStyle(color: TraverzaColors.textMuted, fontSize: 13)),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: TraverzaColors.secondary),
                              icon: const Icon(Icons.explore_rounded, size: 16, color: Colors.white),
                              label: const Text('Explore Lounges', style: TextStyle(color: Colors.white, fontSize: 12)),
                              onPressed: () => _showDiscoverLoungesAndTravellersSheet(context),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: convs.length,
                        separatorBuilder: (context, index) => const Divider(height: 1, indent: 72, color: TraverzaColors.border),
                        itemBuilder: (context, index) {
                          final c = convs[index];
                          return _buildConversationTile(c);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildConversationTile(ChatConversationModel c) {
    IconData icon;
    Color iconColor;

    switch (c.conversationType) {
      case ConversationTypeEnum.districtLounge:
        icon = Icons.forum_rounded;
        iconColor = TraverzaColors.secondary;
        break;
      case ConversationTypeEnum.providerInquiry:
        icon = Icons.storefront_rounded;
        iconColor = TraverzaColors.emeraldSuccess;
        break;
      case ConversationTypeEnum.tripGroup:
        icon = Icons.groups_rounded;
        iconColor = const Color(0xFF6366F1);
        break;
      default:
        icon = Icons.person_rounded;
        iconColor = TraverzaColors.oceanBlue;
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  iconColor.withValues(alpha: 0.20),
                  iconColor.withValues(alpha: 0.06),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: iconColor.withValues(alpha: 0.35),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withValues(alpha: 0.12),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 23),
          ),
          if (c.unreadCount > 0)
            Positioned(
              right: -3,
              top: -3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: TraverzaColors.roseEmergency,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: TraverzaColors.roseEmergency.withValues(alpha: 0.4),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  '${c.unreadCount}',
                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              c.title,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: c.unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
                color: TraverzaColors.text,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${c.lastMessageAt.hour.toString().padLeft(2, '0')}:${c.lastMessageAt.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 10.5, color: TraverzaColors.textMuted),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 3),
          Text(
            c.lastMessageText,
            style: TextStyle(
              fontSize: 12,
              color: c.unreadCount > 0 ? TraverzaColors.primary : TraverzaColors.textMuted,
              fontWeight: c.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              if (c.conversationType == ConversationTypeEnum.districtLounge) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: TraverzaColors.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${c.memberCount} in lounge',
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: TraverzaColors.secondary),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  c.participantSubtitle,
                  style: const TextStyle(fontSize: 10, color: TraverzaColors.textMuted, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ConversationScreen(conversationId: c.id),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(ConversationTypeEnum? type, String label) {
    final isSelected = _typeFilter == type;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
        selected: isSelected,
        selectedColor: TraverzaColors.secondary.withValues(alpha: 0.15),
        backgroundColor: TraverzaColors.background,
        onSelected: (val) {
          setState(() {
            _typeFilter = val ? type : null;
          });
        },
      ),
    );
  }

  void _showDiscoverLoungesAndTravellersSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.92,
        minChildSize: 0.5,
        builder: (ctx, scrollController) => Container(
          decoration: const BoxDecoration(
            color: TraverzaColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: TraverzaColors.border, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Explore District Lounges & Travellers',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TraverzaColors.primary),
              ),
              const Text(
                'Connect with travellers in any region of Sri Lanka or message creators & licensed guides directly.',
                style: TextStyle(fontSize: 11.5, color: TraverzaColors.textMuted),
              ),
              const SizedBox(height: 20),

              // Section 1: District Lounges
              Row(
                children: const [
                  Icon(Icons.public_rounded, size: 16, color: TraverzaColors.secondary),
                  SizedBox(width: 6),
                  Text('REGIONAL DISTRICT LOUNGES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: TraverzaColors.secondary, letterSpacing: 0.6)),
                ],
              ),
              const SizedBox(height: 10),

              _buildLoungeOptionCard(
                title: 'Ella & Uva Travellers Lounge',
                district: 'Badulla / Ella',
                members: 342,
                recentTopic: 'Nine Arch viaduct photo spots, Ella Rock dawn trek, Ravana Falls pool conditions',
                onJoin: () {
                  final convId = MessengerService.instance.joinDistrictLounge(
                    districtId: 'badulla',
                    loungeTitle: 'Ella & Uva Travellers Lounge',
                    subtitle: 'Public District Lounge · 342 Travellers',
                    districtName: 'Badulla / Ella',
                  );
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ConversationScreen(conversationId: convId)));
                },
              ),
              const SizedBox(height: 8),

              _buildLoungeOptionCard(
                title: 'Sigiriya & Cultural Triangle Hub',
                district: 'Matale / Sigiriya',
                members: 516,
                recentTopic: 'Pidurangala sunrise climb times, Dambulla cave temples dress code, elephant corridor alerts',
                onJoin: () {
                  final convId = MessengerService.instance.joinDistrictLounge(
                    districtId: 'matale',
                    loungeTitle: 'Sigiriya & Cultural Triangle Hub',
                    subtitle: 'Public District Lounge · 516 Travellers',
                    districtName: 'Matale / Sigiriya',
                  );
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ConversationScreen(conversationId: convId)));
                },
              ),
              const SizedBox(height: 8),

              _buildLoungeOptionCard(
                title: 'Mirissa & Southern Coast Waves',
                district: 'Matara / Mirissa',
                members: 280,
                recentTopic: 'Whale watching catamaran departures, surf break swell reports, coconut tree hill sunsets',
                onJoin: () {
                  final convId = MessengerService.instance.joinDistrictLounge(
                    districtId: 'matara',
                    loungeTitle: 'Mirissa & Southern Coast Waves',
                    subtitle: 'Public District Lounge · 280 Travellers',
                    districtName: 'Matara / Mirissa',
                  );
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ConversationScreen(conversationId: convId)));
                },
              ),
              const SizedBox(height: 8),

              _buildLoungeOptionCard(
                title: 'Kandy Sacred Hill Country',
                district: 'Kandy',
                members: 410,
                recentTopic: 'Temple of the Tooth Relic evening ceremonies, Hanthana ridge hikes, Peradeniya gardens',
                onJoin: () {
                  final convId = MessengerService.instance.joinDistrictLounge(
                    districtId: 'kandy',
                    loungeTitle: 'Kandy Sacred Hill Country',
                    subtitle: 'Public District Lounge · 410 Travellers',
                    districtName: 'Kandy',
                  );
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ConversationScreen(conversationId: convId)));
                },
              ),
              const SizedBox(height: 8),

              _buildLoungeOptionCard(
                title: 'Jaffna & Northern Heritage Hub',
                district: 'Jaffna Peninsula',
                members: 195,
                recentTopic: 'Nallur Kandaswamy Kovil darshan, Delft Island wild pony trails, Rio ice cream',
                onJoin: () {
                  final convId = MessengerService.instance.joinDistrictLounge(
                    districtId: 'jaffna',
                    loungeTitle: 'Jaffna & Northern Heritage Hub',
                    subtitle: 'Public District Lounge · 195 Travellers',
                    districtName: 'Jaffna Peninsula',
                  );
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ConversationScreen(conversationId: convId)));
                },
              ),
              const SizedBox(height: 24),

              // Section 2: Travellers & Creators
              Row(
                children: const [
                  Icon(Icons.person_pin_rounded, size: 16, color: TraverzaColors.primary),
                  SizedBox(width: 6),
                  Text('COMMUNITY CREATORS & VERIFIED GUIDES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: TraverzaColors.primary, letterSpacing: 0.6)),
                ],
              ),
              const SizedBox(height: 10),

              _buildCreatorTile(
                name: 'Elena Rostova',
                role: 'Highland Trekker & Photographer',
                district: 'Central Province / Ella',
                avatarInitial: 'E',
                onChat: () {
                  final convId = MessengerService.instance.startDirectChat(
                    userName: 'Elena Rostova',
                    userRole: 'Highland Trekker',
                    districtName: 'Ella / Badulla',
                    initialMessage: 'Hi Elena! Loved your photos of the Nine Arch Bridge.',
                  );
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ConversationScreen(conversationId: convId)));
                },
              ),
              const SizedBox(height: 8),

              _buildCreatorTile(
                name: 'Markus Weber',
                role: 'Cultural Triangle Explorer',
                district: 'Matale / Sigiriya',
                avatarInitial: 'M',
                onChat: () {
                  final convId = MessengerService.instance.startDirectChat(
                    userName: 'Markus Weber',
                    userRole: 'Cultural Explorer',
                    districtName: 'Matale / Sigiriya',
                    initialMessage: 'Hi Markus! Have a question about the Pidurangala climb.',
                  );
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ConversationScreen(conversationId: convId)));
                },
              ),
              const SizedBox(height: 8),

              _buildCreatorTile(
                name: 'Ayesha De Silva',
                role: 'Southern Coast Creator',
                district: 'Galle / Matara',
                avatarInitial: 'A',
                onChat: () {
                  final convId = MessengerService.instance.startDirectChat(
                    userName: 'Ayesha De Silva',
                    userRole: 'Southern Coast Creator',
                    districtName: 'Galle / Coast',
                    initialMessage: 'Ayubowan Ayesha! How are the sunset conditions at Galle Fort?',
                  );
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ConversationScreen(conversationId: convId)));
                },
              ),
              const SizedBox(height: 8),

              _buildCreatorTile(
                name: 'Duminda Bandara',
                role: 'SLTDA Licensed Cultural Guide',
                district: 'Matale / Sigiriya',
                avatarInitial: 'D',
                onChat: () {
                  final convId = MessengerService.instance.startDirectChat(
                    userName: 'Duminda Bandara',
                    userRole: 'Licensed Guide',
                    districtName: 'Matale / Sigiriya',
                    initialMessage: 'Ayubowan Duminda! Looking to book a guided archaeological tour.',
                  );
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ConversationScreen(conversationId: convId)));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoungeOptionCard({
    required String title,
    required String district,
    required int members,
    required String recentTopic,
    required VoidCallback onJoin,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TraverzaColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TraverzaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: TraverzaColors.text)),
                    Text(district, style: const TextStyle(fontSize: 10.5, color: TraverzaColors.secondary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: TraverzaColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: const Size(60, 30),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: onJoin,
                child: const Text('Join Lounge', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: TraverzaColors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('$members Travellers', style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: TraverzaColors.secondary)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  recentTopic,
                  style: const TextStyle(fontSize: 10.5, color: TraverzaColors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCreatorTile({
    required String name,
    required String role,
    required String district,
    required String avatarInitial,
    required VoidCallback onChat,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: TraverzaColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TraverzaColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: TraverzaColors.primary,
            child: Text(avatarInitial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: TraverzaColors.text)),
                Text('$role · $district', style: const TextStyle(fontSize: 10.5, color: TraverzaColors.textMuted)),
              ],
            ),
          ),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: TraverzaColors.secondary,
              side: const BorderSide(color: TraverzaColors.secondary),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: const Size(64, 28),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 12),
            label: const Text('Chat', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            onPressed: onChat,
          ),
        ],
      ),
    );
  }
}
