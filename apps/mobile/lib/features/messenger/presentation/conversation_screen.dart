import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../theme/app_theme.dart';
import '../models/messenger_models.dart';
import '../services/messenger_service.dart';
import 'widgets/creative_experience_share_sheet.dart';

class ConversationScreen extends StatefulWidget {
  final String conversationId;

  const ConversationScreen({
    super.key,
    required this.conversationId,
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        MessengerService.instance.markAsRead(widget.conversationId);
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    MessengerService.instance.sendMessage(
      conversationId: widget.conversationId,
      textContent: text,
      messageType: MessageTypeEnum.text,
    );

    _textController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
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
    return ListenableBuilder(
      listenable: MessengerService.instance,
      builder: (context, _) {
        final conv = MessengerService.instance.conversations.firstWhere(
          (c) => c.id == widget.conversationId,
          orElse: () => MessengerService.instance.conversations.first,
        );
        final messages = MessengerService.instance.getMessages(widget.conversationId);
        final isLounge = conv.conversationType == ConversationTypeEnum.districtLounge;

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
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        conv.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: TraverzaColors.primary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isLounge) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: TraverzaColors.secondary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${conv.memberCount} online',
                          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: TraverzaColors.secondary),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  conv.participantSubtitle,
                  style: const TextStyle(fontSize: 10.5, color: TraverzaColors.secondary, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Share Experiences & Media',
                icon: const Icon(Icons.add_photo_alternate_outlined, size: 22, color: TraverzaColors.secondary),
                onPressed: () => _showMediaAttachmentSheet(context),
              ),
              IconButton(
                tooltip: 'Conversation Info & Safety',
                icon: const Icon(Icons.info_outline_rounded, size: 20, color: TraverzaColors.textMuted),
                onPressed: () {
                  _showConversationSafetyDialog(context, conv);
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Lounge Banner if District Lounge
              if (isLounge)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: TraverzaColors.secondary.withValues(alpha: 0.08),
                    border: const Border(bottom: BorderSide(color: TraverzaColors.border)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.public_rounded, size: 16, color: TraverzaColors.secondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Public regional hub: Share photos, videos, and live trail updates with travellers in ${conv.districtName ?? 'Sri Lanka'}.',
                          style: const TextStyle(fontSize: 11, color: TraverzaColors.text, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),

              // Chat Messages Stream
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == 'u-traveller';
                    return _buildMessageBubble(msg, isMe);
                  },
                ),
              ),

              // Composer Bar
              Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 16, 18),
                decoration: BoxDecoration(
                  color: TraverzaColors.surface,
                  border: const Border(top: BorderSide(color: TraverzaColors.border)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, -2)),
                  ],
                ),
                child: Row(
                  children: [
                    // Creative Media & Story Attachment Button
                    IconButton(
                      tooltip: 'Attach Photos, Videos & Places',
                      icon: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: TraverzaColors.secondary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                          border: Border.all(color: TraverzaColors.secondary.withValues(alpha: 0.25)),
                        ),
                        child: const Icon(Icons.add_rounded, color: TraverzaColors.secondary, size: 20),
                      ),
                      onPressed: () => _showMediaAttachmentSheet(context),
                    ),
                    const SizedBox(width: 4),

                    // Input Field
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          hintText: isLounge
                              ? 'Discuss places, conditions, tips...'
                              : 'Type a message to ${conv.title.split('·')[0]}...',
                          hintStyle: const TextStyle(fontSize: 13, color: TraverzaColors.textMuted),
                          filled: true,
                          fillColor: TraverzaColors.background,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: TraverzaColors.border)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: TraverzaColors.border)),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Send Button
                    InkWell(
                      onTap: _sendMessage,
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [TraverzaColors.primary, TraverzaColors.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: TraverzaColors.secondary.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Transform.rotate(
                          angle: -0.38,
                          child: const Icon(Icons.near_me_rounded, color: Colors.white, size: 20),
                        ),
                      ),
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

  Widget _buildMessageBubble(ChatMessageModel msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? TraverzaColors.primary : TraverzaColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          border: Border.all(color: isMe ? TraverzaColors.primary : TraverzaColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  msg.senderName,
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: TraverzaColors.secondary),
                ),
              ),

            // 1. Rich Card: Photo Experience
            if (msg.messageType == MessageTypeEnum.photo && msg.mediaAttachment != null)
              GestureDetector(
                onTap: () => _showPhotoViewer(context, msg.mediaAttachment!),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isMe ? Colors.white24 : TraverzaColors.border),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        Image.network(
                          msg.mediaAttachment!.mediaUrl,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => Container(
                            height: 140,
                            color: Colors.black12,
                            alignment: Alignment.center,
                            child: const Icon(Icons.image_rounded, size: 40, color: TraverzaColors.textMuted),
                          ),
                        ),
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.fullscreen_rounded, color: Colors.white, size: 14),
                                SizedBox(width: 4),
                                Text('View Photo', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // 2. Rich Card: Video Experience Clip
            if (msg.messageType == MessageTypeEnum.video && msg.mediaAttachment != null)
              GestureDetector(
                onTap: () => _showVideoPlayer(context, msg.mediaAttachment!),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isMe ? Colors.white24 : TraverzaColors.border),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.network(
                          msg.mediaAttachment!.thumbnailUrl ?? msg.mediaAttachment!.mediaUrl,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => Container(
                            height: 140,
                            color: const Color(0xFF1E293B),
                            alignment: Alignment.center,
                            child: const Icon(Icons.videocam_rounded, size: 40, color: TraverzaColors.textMuted),
                          ),
                        ),
                        // Dark gradient overlay
                        Container(
                          height: 180,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.black.withValues(alpha: 0.3), Colors.black.withValues(alpha: 0.6)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        // Pulsing Play Button
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: TraverzaColors.secondary.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: TraverzaColors.secondary.withValues(alpha: 0.5),
                                blurRadius: 16,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
                        ),
                        // Top Video badge
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.videocam_rounded, color: TraverzaColors.accent, size: 12),
                                SizedBox(width: 4),
                                Text('VIDEO CLIP', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                              ],
                            ),
                          ),
                        ),
                        // Duration Pill
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '▶ 0:${(msg.mediaAttachment!.durationSeconds ?? 15).toString().padLeft(2, '0')}',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // 3. Rich Card: Place Snippet
            if (msg.messageType == MessageTypeEnum.placeSnippet && msg.placeSnippet != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isMe ? Colors.white.withValues(alpha: 0.12) : TraverzaColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isMe ? Colors.white24 : TraverzaColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (msg.placeSnippet!.photoUrl != null)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(
                          msg.placeSnippet!.photoUrl!,
                          height: 110,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => Container(
                            height: 80,
                            color: Colors.black12,
                            alignment: Alignment.center,
                            child: const Icon(Icons.landscape_rounded, color: TraverzaColors.textMuted),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.place_rounded, size: 13, color: TraverzaColors.accent),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  msg.placeSnippet!.destinationName,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: isMe ? Colors.white : TraverzaColors.text,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            msg.placeSnippet!.districtName,
                            style: TextStyle(fontSize: 10.5, color: isMe ? Colors.white70 : TraverzaColors.textMuted),
                          ),
                          if (msg.placeSnippet!.summary != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              msg.placeSnippet!.summary!,
                              style: TextStyle(fontSize: 11, color: isMe ? Colors.white : TraverzaColors.text, height: 1.3),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // 4. Rich Card: Provider Quote Request
            if (msg.messageType == MessageTypeEnum.providerQuoteRequest && msg.quoteRequest != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: TraverzaColors.secondary.withValues(alpha: isMe ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: TraverzaColors.secondary.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'CONTEXTUAL INQUIRY',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: TraverzaColors.secondary, letterSpacing: 0.6),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: TraverzaColors.emeraldSuccess,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            msg.quoteRequest!.bookingStatus,
                            style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      msg.quoteRequest!.serviceName,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isMe ? Colors.white : TraverzaColors.text),
                    ),
                    Text(
                      'Dates: ${msg.quoteRequest!.proposedDate} · ${msg.quoteRequest!.guestsCount} Guests',
                      style: TextStyle(fontSize: 10.5, color: isMe ? Colors.white70 : TraverzaColors.textMuted),
                    ),
                    if (msg.quoteRequest!.estimatedLKR != null)
                      Text(
                        'Estimated: LKR ${msg.quoteRequest!.estimatedLKR!.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: TraverzaColors.emeraldSuccess),
                      ),
                  ],
                ),
              ),

            // 5. Rich Card: Document / File Attachment
            if ((msg.messageType == MessageTypeEnum.file || msg.mediaAttachment?.mediaType == 'file') && msg.mediaAttachment != null)
              _buildFileAttachmentCard(msg, isMe),

            // Message text
            Text(
              msg.textContent,
              style: TextStyle(
                fontSize: 13,
                color: isMe ? Colors.white : TraverzaColors.text,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 4),

            // Timestamp
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                '${msg.createdAt.hour.toString().padLeft(2, '0')}:${msg.createdAt.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 9.5,
                  color: isMe ? Colors.white70 : TraverzaColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileAttachmentCard(ChatMessageModel msg, bool isMe) {
    final attachment = msg.mediaAttachment!;
    final fileName = attachment.fileName ?? 'Travel_Document.pdf';
    final ext = (attachment.fileExtension ?? (fileName.contains('.') ? fileName.split('.').last : 'DOC')).toUpperCase();
    final fileSize = attachment.fileSize ?? '1.2 MB';

    IconData fileIcon;
    Color iconColor;
    Color iconBg;

    if (ext == 'PDF') {
      fileIcon = Icons.picture_as_pdf_rounded;
      iconColor = const Color(0xFFEF4444);
      iconBg = const Color(0xFFEF4444).withValues(alpha: 0.15);
    } else if (ext == 'GPX' || ext == 'KML') {
      fileIcon = Icons.route_rounded;
      iconColor = const Color(0xFF10B981);
      iconBg = const Color(0xFF10B981).withValues(alpha: 0.15);
    } else if (ext == 'DOC' || ext == 'DOCX') {
      fileIcon = Icons.description_rounded;
      iconColor = const Color(0xFF3B82F6);
      iconBg = const Color(0xFF3B82F6).withValues(alpha: 0.15);
    } else {
      fileIcon = Icons.insert_drive_file_rounded;
      iconColor = const Color(0xFFF59E0B);
      iconBg = const Color(0xFFF59E0B).withValues(alpha: 0.15);
    }

    return InkWell(
      onTap: () => _openRealFile(attachment.mediaUrl, fileName),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isMe ? Colors.white.withValues(alpha: 0.12) : TraverzaColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isMe ? Colors.white24 : TraverzaColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(fileIcon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isMe ? Colors.white : TraverzaColors.text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          ext,
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                            color: iconColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        fileSize,
                        style: TextStyle(
                          fontSize: 10,
                          color: isMe ? Colors.white70 : TraverzaColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isMe ? Colors.white24 : TraverzaColors.secondary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.open_in_new_rounded,
                size: 16,
                color: isMe ? Colors.white : TraverzaColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openRealFile(String fileUrl, String fileName) async {
    _showFileDetailDialog(fileName, fileUrl);
  }

  void _showFileDetailDialog(String fileName, String fileUrl) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.folder_shared_rounded, color: TraverzaColors.secondary, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    fileName,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('FILE STORAGE PATH', style: TextStyle(fontSize: 9.5, color: Colors.white54, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(fileUrl, style: const TextStyle(fontSize: 11.5, color: TraverzaColors.secondary, fontFamily: 'monospace')),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: const Text('Copy Path'),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: fileUrl));
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Path copied to clipboard')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TraverzaColors.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.open_in_new_rounded, size: 16),
                    label: const Text('Open System App'),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      try {
                        final uri = fileUrl.startsWith('http') ? Uri.parse(fileUrl) : Uri.file(fileUrl);
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Could not open file: $e')),
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showMediaAttachmentSheet(BuildContext context) {
    CreativeExperienceShareSheet.show(
      context,
      conversationId: widget.conversationId,
      onMessageSent: _scrollToBottom,
    );
  }







  void _showPhotoViewer(BuildContext context, MediaAttachmentModel media) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black.withValues(alpha: 0.9),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                media.mediaUrl,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(
                  height: 200,
                  color: Colors.black26,
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_rounded, color: Colors.white, size: 50),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (media.caption != null)
                    Text(
                      media.caption!,
                      style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close', style: TextStyle(color: Colors.white70)),
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

  void _showVideoPlayer(BuildContext context, MediaAttachmentModel media) {
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
            // Video Frame Simulation
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
                        value: 0.45,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(TraverzaColors.secondary),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('0:08', style: TextStyle(color: Colors.white70, fontSize: 10)),
                          Text('0:${(media.durationSeconds ?? 15).toString().padLeft(2, '0')}', style: const TextStyle(color: Colors.white70, fontSize: 10)),
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
                    children: const [
                      Icon(Icons.hd_rounded, color: TraverzaColors.secondary, size: 18),
                      SizedBox(width: 6),
                      Text('High Definition Travel Clip', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  if (media.caption != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      media.caption!,
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

  void _showConversationSafetyDialog(BuildContext context, ChatConversationModel conv) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(conv.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('• Regional Lounges and direct chats let verified travellers exchange on-the-ground experiences.', style: TextStyle(fontSize: 12, height: 1.4)),
            SizedBox(height: 6),
            Text('• Media items (photos and videos) are scanned for community safety and content authenticity.', style: TextStyle(fontSize: 12, height: 1.4)),
            SizedBox(height: 6),
            Text('• Quotes and bookings are finalized through the authoritative TRAVERZA booking state machine.', style: TextStyle(fontSize: 12, height: 1.4)),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Report / Block User', style: TextStyle(color: TraverzaColors.roseEmergency, fontSize: 12)),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Safety report filed with TRAVERZA Operations Desk.')),
              );
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: TraverzaColors.primary),
            child: const Text('Close', style: TextStyle(color: Colors.white, fontSize: 12)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
