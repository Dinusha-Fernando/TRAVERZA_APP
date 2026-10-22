import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../models/community_models.dart';
import '../services/community_service.dart';
import 'widgets/itinerary_feasibility_modal.dart';
import 'widgets/place_signal_card.dart';
import '../../messenger/presentation/conversation_screen.dart';
import '../../messenger/services/messenger_service.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({
    super.key,
    required this.postId,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    CommunityService.instance.addComment(widget.postId, text);
    _commentController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CommunityService.instance,
      builder: (context, _) {
        final post = CommunityService.instance.allPosts.firstWhere(
          (p) => p.id == widget.postId,
          orElse: () => CommunityService.instance.allPosts.first,
        );

        final placeSignal = post.destinationName != null
            ? CommunityService.instance.getPlaceSignal(post.destinationName!)
            : null;

        return Scaffold(
          backgroundColor: TraverzaColors.background,
          appBar: AppBar(
            backgroundColor: TraverzaColors.surface,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: TraverzaColors.primary),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              post.postType == PostType.question ? 'Community Q&A' : 'Travel Moment',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: TraverzaColors.primary),
            ),
            actions: [
              IconButton(
                tooltip: 'Report Content',
                icon: const Icon(Icons.flag_outlined, size: 20, color: TraverzaColors.textMuted),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Content report submitted to TRAVERZA Moderation Desk.'),
                      backgroundColor: TraverzaColors.primary,
                    ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    // Author & Trust Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: TraverzaColors.surface,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: TraverzaColors.primary,
                                child: Text(
                                  post.authorName[0],
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      post.authorName,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: TraverzaColors.text),
                                    ),
                                    Text(
                                      post.trustLabel,
                                      style: const TextStyle(fontSize: 11, color: TraverzaColors.secondary, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                              // Chat with Author Button
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: TraverzaColors.secondary,
                                  side: const BorderSide(color: TraverzaColors.secondary),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  minimumSize: const Size(60, 30),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 12),
                                label: const Text('Chat', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                onPressed: () {
                                  final convId = MessengerService.instance.startDirectChat(
                                    userName: post.authorName,
                                    userRole: post.trustLabel,
                                    districtName: post.districtName,
                                    initialMessage: 'Hi ${post.authorName}! I am viewing your moment: "${post.caption}"',
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => ConversationScreen(conversationId: convId)),
                                  );
                                },
                              ),
                              const SizedBox(width: 6),
                              if (post.destinationName != null)
                                ElevatedButton.icon(
                                  onPressed: () => ItineraryFeasibilityModal.show(context, post),
                                  icon: const Icon(Icons.alt_route, size: 14, color: Colors.white),
                                  label: const Text('Add to Trip', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: TraverzaColors.primary,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    minimumSize: const Size(60, 30),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Caption / Question
                          Text(
                            post.caption,
                            style: const TextStyle(fontSize: 14.5, height: 1.5, color: TraverzaColors.text),
                          ),
                        ],
                      ),
                    ),

                    // Media Image / Video Clip if available
                    if (post.media.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          if (post.postType == PostType.video || post.media.first.mediaType == 'video') {
                            _showVideoPlayer(context, post.media.first);
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.network(
                                  post.media.first.thumbnailUrl ?? post.media.first.mediaUrl,
                                  height: 230,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) => Container(
                                    height: 230,
                                    color: TraverzaColors.surface,
                                    alignment: Alignment.center,
                                    child: Icon(
                                      post.postType == PostType.video ? Icons.videocam_rounded : Icons.image_rounded,
                                      size: 48,
                                      color: TraverzaColors.textMuted,
                                    ),
                                  ),
                                ),
                                if (post.postType == PostType.video || post.media.first.mediaType == 'video') ...[
                                  Container(
                                    height: 230,
                                    color: Colors.black.withValues(alpha: 0.35),
                                  ),
                                  Container(
                                    width: 54,
                                    height: 54,
                                    decoration: BoxDecoration(
                                      color: TraverzaColors.secondary.withValues(alpha: 0.9),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: TraverzaColors.secondary.withValues(alpha: 0.45),
                                          blurRadius: 14,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
                                  ),
                                  Positioned(
                                    top: 12,
                                    left: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.75),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.videocam_rounded, color: TraverzaColors.secondary, size: 14),
                                          const SizedBox(width: 4),
                                          Text(
                                            '▶ 0:${post.media.first.durationSeconds ?? 18}s · HIGH-DEF CLIP',
                                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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

                    // Place Signal Card
                    if (placeSignal != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: PlaceSignalCard(signal: placeSignal),
                      ),

                    const SizedBox(height: 12),

                    // Comments / Answers Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            post.postType == PostType.question
                                ? 'Answers & Verified Advice (${post.comments.length})'
                                : 'Local Discussion (${post.comments.length})',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: TraverzaColors.primary),
                          ),
                          if (post.isQuestionResolved)
                            const Text(
                              '✓ Question Resolved',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: TraverzaColors.emeraldSuccess),
                            ),
                        ],
                      ),
                    ),

                    // Comments List
                    if (post.comments.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            'No answers yet. Share local knowledge or helpful advice!',
                            style: TextStyle(color: TraverzaColors.textMuted, fontSize: 13),
                          ),
                        ),
                      )
                    else
                      ...post.comments.map((comment) => _buildCommentItem(post, comment)),
                  ],
                ),
              ),

              // Comment Composer Bar
              Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                decoration: BoxDecoration(
                  color: TraverzaColors.surface,
                  border: const Border(top: BorderSide(color: TraverzaColors.border)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2)),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: post.postType == PostType.question
                              ? 'Write a helpful answer...'
                              : 'Add local tip or observation...',
                          hintStyle: const TextStyle(fontSize: 13, color: TraverzaColors.textMuted),
                          filled: true,
                          fillColor: TraverzaColors.background,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(color: TraverzaColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(color: TraverzaColors.border),
                          ),
                        ),
                        onSubmitted: (_) => _submitComment(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send_rounded, color: TraverzaColors.secondary),
                      onPressed: _submitComment,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentItem(CommunityPostModel post, PostCommentModel comment) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: comment.isAcceptedAnswer
            ? TraverzaColors.emeraldSuccess.withValues(alpha: 0.06)
            : TraverzaColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: comment.isAcceptedAnswer
              ? TraverzaColors.emeraldSuccess.withValues(alpha: 0.4)
              : TraverzaColors.border,
          width: comment.isAcceptedAnswer ? 1.5 : 1.0,
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
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: TraverzaColors.secondary,
                    child: Text(
                      comment.authorName[0],
                      style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    comment.authorName,
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: TraverzaColors.text),
                  ),
                  if (comment.authorBadge == AuthorBadge.licensedGuide) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: TraverzaColors.oceanBlue.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'GUIDE',
                        style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: TraverzaColors.oceanBlue),
                      ),
                    ),
                  ],
                ],
              ),
              if (comment.isAcceptedAnswer)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: TraverzaColors.emeraldSuccess,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '✓ Accepted Answer',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment.commentText,
            style: const TextStyle(fontSize: 12.5, height: 1.4, color: TraverzaColors.text),
          ),
          const SizedBox(height: 10),

          // Actions on comment
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Helpful votes: ${comment.helpfulVotes}',
                style: const TextStyle(fontSize: 10.5, color: TraverzaColors.textMuted),
              ),
              if (!comment.isAcceptedAnswer && post.postType == PostType.question)
                InkWell(
                  onTap: () {
                    CommunityService.instance.markAcceptedAnswer(post.id, comment.id);
                  },
                  child: const Text(
                    'Mark as Accepted Answer',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: TraverzaColors.secondary),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showVideoPlayer(BuildContext context, PostMediaModel media) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF0F172A),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    media.thumbnailUrl ?? media.mediaUrl,
                    height: 240,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(
                      height: 240,
                      color: Colors.black,
                      alignment: Alignment.center,
                      child: const Icon(Icons.videocam_rounded, color: Colors.white, size: 50),
                    ),
                  ),
                ),
                Container(
                  height: 240,
                  color: Colors.black.withValues(alpha: 0.35),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: TraverzaColors.secondary.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
                ),
                Positioned(
                  bottom: 12,
                  left: 16,
                  right: 16,
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: 0.55,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(TraverzaColors.secondary),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('0:10', style: TextStyle(color: Colors.white70, fontSize: 10)),
                          Text('0:${(media.durationSeconds ?? 18).toString().padLeft(2, '0')}', style: const TextStyle(color: Colors.white70, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.hd_rounded, color: TraverzaColors.secondary, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        media.fileName ?? 'Travel Video Clip',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  if (media.altText != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      media.altText!,
                      style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TraverzaColors.secondary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close Player', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
