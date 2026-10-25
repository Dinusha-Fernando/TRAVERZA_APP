import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../models/community_models.dart';
import '../../services/community_service.dart';
import '../post_detail_screen.dart';
import 'itinerary_feasibility_modal.dart';
import '../../../messenger/presentation/conversation_screen.dart';
import '../../../messenger/services/messenger_service.dart';
import '../../../auth/services/auth_service.dart';
import '../../../../widgets/creative_auth_gate_dialog.dart';

class CommunityPostCard extends StatelessWidget {
  final CommunityPostModel post;
  final VoidCallback? onDestinationTapped;

  const CommunityPostCard({
    super.key,
    required this.post,
    this.onDestinationTapped,
  });

  @override
  Widget build(BuildContext context) {
    final service = CommunityService.instance;
    final isSaved = service.isSaved(post.id);
    final isHelpful = service.isHelpful(post.id);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: TraverzaColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TraverzaColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Author & Provenance Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: TraverzaColors.primary,
                  backgroundImage: post.authorAvatarUrl != null ? NetworkImage(post.authorAvatarUrl!) : null,
                  onBackgroundImageError: post.authorAvatarUrl != null ? (exception, stackTrace) {} : null,
                  child: post.authorAvatarUrl == null
                      ? Text(
                          post.authorName.isNotEmpty ? post.authorName[0] : 'T',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              post.authorName,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: TraverzaColors.text,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          _buildBadgePill(post.authorBadge),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        post.trustLabel,
                        style: const TextStyle(fontSize: 10, color: TraverzaColors.secondary, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Freshness / Post Type Pill
                _buildFreshnessPill(post),
                const SizedBox(width: 4),

                // Direct Chat with Author Button
                IconButton(
                  tooltip: 'Chat with ${post.authorName}',
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: TraverzaColors.secondary),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  onPressed: () async {
                    if (!TraverzaAuthService.instance.isAccountComplete) {
                      final granted = await CreativeAuthGateSheet.show(
                        context,
                        featureTitle: 'Travel Messenger',
                        actionMessage: 'Direct Chat with ${post.authorName}',
                        clearanceReason:
                            'Direct communication with verified guides and travellers requires a registered SLTDA traveller profile.',
                        featureIcon: Icons.chat_bubble_outline_rounded,
                      );
                      if (!granted) return;
                    }

                    final convId = MessengerService.instance.startDirectChat(
                      userName: post.authorName,
                      userRole: post.trustLabel,
                      districtName: post.districtName,
                      initialMessage: 'Hi ${post.authorName}! Saw your moment regarding ${post.destinationName ?? post.districtName}.',
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ConversationScreen(conversationId: convId)),
                    );
                  },
                ),
              ],
            ),
          ),

          // 2. Media Image if available
          if (post.media.isNotEmpty)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PostDetailScreen(postId: post.id)),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 14),
                height: 210,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          post.media.first.mediaUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: TraverzaColors.surface,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  post.postType == PostType.fieldReport
                                      ? Icons.warning_amber_rounded
                                      : Icons.landscape_rounded,
                                  size: 38,
                                  color: TraverzaColors.accent.withValues(alpha: 0.7),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  post.destinationName ?? post.districtName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: TraverzaColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.black.withValues(alpha: 0.55), Colors.transparent],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                          padding: const EdgeInsets.all(12),
                          alignment: Alignment.bottomLeft,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (post.destinationName != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.65),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.place_rounded, size: 12, color: TraverzaColors.accent),
                                      const SizedBox(width: 4),
                                      Text(
                                        post.destinationName!,
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  post.districtName,
                                  style: const TextStyle(fontSize: 10, color: Colors.white70),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Video Play Emblem
                      if (post.postType == PostType.video || (post.media.isNotEmpty && post.media.first.mediaType == 'video')) ...[
                        Center(
                          child: Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: TraverzaColors.secondary.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: TraverzaColors.secondary.withValues(alpha: 0.45),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 30),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.videocam_rounded, color: TraverzaColors.secondary, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  '▶ 0:${post.media.first.durationSeconds ?? 18}s',
                                  style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

          // 3. Caption Body
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PostDetailScreen(postId: post.id)),
                );
              },
              child: Text(
                post.caption,
                style: const TextStyle(fontSize: 13, height: 1.45, color: TraverzaColors.text),
              ),
            ),
          ),

          // 4. District & Canonical Atlas Link Pill
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 6,
              children: [
                InkWell(
                  onTap: onDestinationTapped,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: TraverzaColors.secondary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: TraverzaColors.secondary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.explore_rounded, size: 11, color: TraverzaColors.secondary),
                        const SizedBox(width: 4),
                        Text(
                          'Atlas: ${post.districtName}',
                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: TraverzaColors.secondary),
                        ),
                      ],
                    ),
                  ),
                ),
                if (post.isQuestionResolved)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: TraverzaColors.emeraldSuccess.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.check_circle_rounded, size: 11, color: TraverzaColors.emeraldSuccess),
                        SizedBox(width: 4),
                        Text(
                          'Answer Accepted',
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: TraverzaColors.emeraldSuccess),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          const Divider(height: 1, color: TraverzaColors.border),

          // 5. Interaction Buttons Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Helpful Button
                TextButton.icon(
                  onPressed: () async {
                    if (!TraverzaAuthService.instance.isAccountComplete) {
                      final granted = await CreativeAuthGateSheet.show(
                        context,
                        featureTitle: 'Community Pulse',
                        actionMessage: 'Endorse Helpful Intelligence',
                        clearanceReason:
                            'To keep community voting credible and prevent bot manipulation, helpful votes require an active traveller account.',
                        featureIcon: Icons.thumb_up_alt_outlined,
                      );
                      if (!granted) return;
                    }
                    service.toggleHelpful(post.id);
                  },
                  icon: Icon(
                    isHelpful ? Icons.thumb_up_rounded : Icons.thumb_up_alt_outlined,
                    size: 15,
                    color: isHelpful ? TraverzaColors.emeraldSuccess : TraverzaColors.textMuted,
                  ),
                  label: Text(
                    'Helpful (${post.helpfulCount})',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isHelpful ? TraverzaColors.emeraldSuccess : TraverzaColors.textMuted,
                    ),
                  ),
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                ),

                // Q&A / Comments
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PostDetailScreen(postId: post.id)),
                    );
                  },
                  icon: const Icon(Icons.mode_comment_outlined, size: 15, color: TraverzaColors.textMuted),
                  label: Text(
                    post.postType == PostType.question
                        ? 'Answers (${post.commentCount})'
                        : 'Notes (${post.commentCount})',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: TraverzaColors.textMuted),
                  ),
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                ),

                // Add to Trip (TripGraph Feasibility)
                ElevatedButton.icon(
                  onPressed: () async {
                    if (!TraverzaAuthService.instance.isAccountComplete) {
                      final granted = await CreativeAuthGateSheet.show(
                        context,
                        featureTitle: 'Trip Planner Sync',
                        actionMessage: 'Add to Trip: ${post.destinationName ?? post.districtName}',
                        clearanceReason:
                            'Saving live community waypoints and corridor routing requires a verified TRAVERZA account.',
                        featureIcon: Icons.add_location_alt_rounded,
                      );
                      if (!granted) return;
                    }
                    ItineraryFeasibilityModal.show(context, post);
                  },
                  icon: const Icon(Icons.add_location_alt_rounded, size: 13, color: Colors.white),
                  label: const Text('Add to Trip', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TraverzaColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: const Size(80, 32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),

                // Save toggle
                IconButton(
                  tooltip: isSaved ? 'Saved in Wishlist' : 'Save to Wishlist',
                  onPressed: () async {
                    if (!TraverzaAuthService.instance.isAccountComplete) {
                      final granted = await CreativeAuthGateSheet.show(
                        context,
                        featureTitle: 'Wishlist & Vault',
                        actionMessage: 'Save to Wishlist: ${post.destinationName ?? post.districtName}',
                        clearanceReason:
                            'Syncing bookmarks across your devices and offline travel vault requires an authenticated account.',
                        featureIcon: Icons.bookmark_border_rounded,
                      );
                      if (!granted) return;
                    }
                    service.toggleSave(post.id);
                  },
                  icon: Icon(
                    isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    size: 19,
                    color: isSaved ? TraverzaColors.secondary : TraverzaColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgePill(AuthorBadge badge) {
    String label;
    Color color;

    switch (badge) {
      case AuthorBadge.licensedGuide:
        label = 'LICENSED GUIDE';
        color = TraverzaColors.oceanBlue;
        break;
      case AuthorBadge.verifiedVisitor:
        label = 'VERIFIED VISITOR';
        color = TraverzaColors.emeraldSuccess;
        break;
      case AuthorBadge.verifiedProvider:
        label = 'VERIFIED PROVIDER';
        color = const Color(0xFF6366F1);
        break;
      case AuthorBadge.communityExpert:
        label = 'LOCAL EXPERT';
        color = TraverzaColors.accent;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: color),
      ),
    );
  }

  Widget _buildFreshnessPill(CommunityPostModel p) {
    if (p.postType == PostType.fieldReport) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: p.isStale
              ? TraverzaColors.roseEmergency.withValues(alpha: 0.1)
              : TraverzaColors.emeraldSuccess.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: p.isStale ? TraverzaColors.roseEmergency : TraverzaColors.emeraldSuccess,
            width: 0.8,
          ),
        ),
        child: Text(
          p.freshnessLabel,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
            color: p.isStale ? TraverzaColors.roseEmergency : TraverzaColors.emeraldSuccess,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: TraverzaColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TraverzaColors.border),
      ),
      child: Text(
        p.postType == PostType.question ? '❓ Question' : '💡 Local Note',
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: TraverzaColors.textMuted),
      ),
    );
  }
}
