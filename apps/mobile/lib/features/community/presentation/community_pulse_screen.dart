import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../models/community_models.dart';
import '../services/community_service.dart';
import 'widgets/community_post_card.dart';
import 'create_post_sheet.dart';
import '../../messenger/presentation/widgets/creative_messenger_button.dart';

class CommunityPulseScreen extends StatefulWidget {
  final String? initialDistrictId;

  const CommunityPulseScreen({
    super.key,
    this.initialDistrictId,
  });

  @override
  State<CommunityPulseScreen> createState() => _CommunityPulseScreenState();
}

class _CommunityPulseScreenState extends State<CommunityPulseScreen> {
  final TextEditingController _searchController = TextEditingController();
  PostType? _selectedPostType;
  String? _selectedDistrictId;

  final List<Map<String, String>> _districtShortcuts = const [
    {'id': '', 'name': 'All Districts'},
    {'id': 'matale', 'name': 'Sigiriya / Matale'},
    {'id': 'badulla', 'name': 'Ella / Badulla'},
    {'id': 'kandy', 'name': 'Kandy'},
    {'id': 'jaffna', 'name': 'Jaffna'},
    {'id': 'nuwara-eliya', 'name': 'Nuwara Eliya'},
    {'id': 'galle', 'name': 'Galle'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedDistrictId = widget.initialDistrictId;
  }

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
              'Community Pulse',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: TraverzaColors.primary,
              ),
            ),
            Text(
              'A living island, told by people who know it',
              style: TextStyle(fontSize: 10, color: TraverzaColors.secondary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          const CreativeMessengerButton(compact: true),
          IconButton(
            tooltip: 'Share Moment',
            icon: const Icon(Icons.add_photo_alternate_rounded, color: TraverzaColors.secondary),
            onPressed: () => CreatePostSheet.show(context),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: CommunityService.instance,
        builder: (context, _) {
          final posts = CommunityService.instance.filterPosts(
            postType: _selectedPostType,
            districtId: _selectedDistrictId,
            searchQuery: _searchController.text.trim(),
          );

          return Column(
            children: [
              // Search & Filters Header
              Container(
                color: TraverzaColors.surface,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  children: [
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search places, questions, field reports...',
                        hintStyle: const TextStyle(fontSize: 12.5, color: TraverzaColors.textMuted),
                        prefixIcon: const Icon(Icons.search_rounded, size: 20, color: TraverzaColors.textMuted),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 16),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: TraverzaColors.background,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: TraverzaColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: TraverzaColors.border),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 10),

                    // Post Type Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(null, 'All Moments (${CommunityService.instance.allPosts.length})'),
                          _buildFilterChip(PostType.fieldReport, '⏱️ Field Reports'),
                          _buildFilterChip(PostType.question, '❓ Questions & Q&A'),
                          _buildFilterChip(PostType.video, '🎥 Videos'),
                          _buildFilterChip(PostType.photo, '📸 Photos'),
                          _buildFilterChip(PostType.localNote, '💡 Local Notes'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // District Shortcuts Carousel
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _districtShortcuts.map((dist) {
                          final isSel = (_selectedDistrictId ?? '') == dist['id'];
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedDistrictId = dist['id']!.isEmpty ? null : dist['id'];
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isSel ? TraverzaColors.secondary : TraverzaColors.background,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSel ? TraverzaColors.secondary : TraverzaColors.border,
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  dist['name']!,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                                    color: isSel ? Colors.white : TraverzaColors.textMuted,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // Post Feed Stream
              Expanded(
                child: posts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.explore_off_rounded, size: 48, color: TraverzaColors.textMuted),
                            const SizedBox(height: 12),
                            const Text(
                              'No moments match this filter',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: TraverzaColors.text),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Be the first to share a local note or ask a question!',
                              style: TextStyle(fontSize: 12, color: TraverzaColors.textMuted),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedPostType = null;
                                  _selectedDistrictId = null;
                                  _searchController.clear();
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: TraverzaColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Reset Filters', style: TextStyle(color: Colors.white, fontSize: 12)),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          await Future.delayed(const Duration(milliseconds: 400));
                          setState(() {});
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            final post = posts[index];
                            return CommunityPostCard(
                              post: post,
                              onDestinationTapped: () {
                                setState(() {
                                  _selectedDistrictId = post.districtId;
                                });
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: TraverzaColors.secondary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Share Moment', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        onPressed: () => CreatePostSheet.show(context),
      ),
    );
  }

  Widget _buildFilterChip(PostType? type, String label) {
    final isSelected = _selectedPostType == type;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? TraverzaColors.secondary : TraverzaColors.text,
          ),
        ),
        selected: isSelected,
        selectedColor: TraverzaColors.secondary.withValues(alpha: 0.15),
        backgroundColor: TraverzaColors.background,
        checkmarkColor: TraverzaColors.secondary,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        onSelected: (val) {
          setState(() {
            _selectedPostType = val ? type : null;
          });
        },
      ),
    );
  }
}
