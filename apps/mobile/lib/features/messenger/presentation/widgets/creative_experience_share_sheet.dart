import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/creative_experience_tab_switcher.dart';
import '../../models/messenger_models.dart';
import '../../services/messenger_service.dart';

/// Ultra-Modern Creative Travel Experience Sharing Hub
/// Empowers travellers to share real user gallery photos/videos, device travel files
/// (e-Visas, train tickets, hotel vouchers, GPX tracks), and live composed experience notes.
class CreativeExperienceShareSheet extends StatefulWidget {
  final String conversationId;
  final VoidCallback onMessageSent;

  const CreativeExperienceShareSheet({
    super.key,
    required this.conversationId,
    required this.onMessageSent,
  });

  static Future<void> show(
    BuildContext context, {
    required String conversationId,
    required VoidCallback onMessageSent,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreativeExperienceShareSheet(
        conversationId: conversationId,
        onMessageSent: onMessageSent,
      ),
    );
  }

  @override
  State<CreativeExperienceShareSheet> createState() => _CreativeExperienceShareSheetState();
}

class _CreativeExperienceShareSheetState extends State<CreativeExperienceShareSheet> {
  int _selectedTabIndex = 0;
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _composerController = TextEditingController();
  final TextEditingController _customFilePathController = TextEditingController();

  final TextEditingController _customPhotoPathController = TextEditingController();
  final TextEditingController _customVideoPathController = TextEditingController();

  String _selectedCategory = 'Trail Condition';
  String _selectedDistrict = 'Ella · Badulla';

  final List<CreativeExperienceTabItem> _tabs = const [
    CreativeExperienceTabItem(
      label: 'Gallery',
      icon: Icons.photo_library_rounded,
      badge: 'PHOTOS',
      gradientColors: [Color(0xFF0284C7), Color(0xFF0369A1), Color(0xFF075985)],
    ),
    CreativeExperienceTabItem(
      label: 'Videos',
      icon: Icons.videocam_rounded,
      badge: 'CLIPS',
      gradientColors: [Color(0xFFD97706), Color(0xFFB45309), Color(0xFF92400E)],
    ),
    CreativeExperienceTabItem(
      label: 'Files',
      icon: Icons.folder_shared_rounded,
      badge: 'DOCS',
      gradientColors: [Color(0xFF059669), Color(0xFF047857), Color(0xFF065F46)],
    ),
    CreativeExperienceTabItem(
      label: 'Notes',
      icon: Icons.rate_review_rounded,
      badge: 'COMPOSE',
      gradientColors: [Color(0xFF8B5CF6), Color(0xFF7C3AED), Color(0xFF6D28D9)],
    ),
  ];

  final List<String> _categories = const [
    'Trail Condition',
    'Transport Tip',
    'Food & Dining',
    'Hidden Gem',
    'Safety Advisory',
  ];

  final List<String> _districts = const [
    'Ella · Badulla',
    'Sigiriya · Matale',
    'Mirissa · Matara',
    'Kandy · Central',
    'Nuwara Eliya',
    'Galle · Coast',
    'Yala · Hambantota',
    'Colombo · Metro',
  ];

  @override
  void dispose() {
    _captionController.dispose();
    _composerController.dispose();
    _customFilePathController.dispose();
    _customPhotoPathController.dispose();
    _customVideoPathController.dispose();
    super.dispose();
  }

  Future<void> _takeCameraPhoto() async {
    try {
      final picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 92,
      );
      if (photo != null) {
        if (!mounted) return;
        Navigator.pop(context);
        final userNote = _captionController.text.trim();
        final caption = userNote.isNotEmpty ? userNote : 'Live Camera Shot · ${photo.name}';

        MessengerService.instance.sendPhotoMessage(
          conversationId: widget.conversationId,
          photoUrl: photo.path,
          caption: caption,
        );
        widget.onMessageSent();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera unavailable or permission denied')),
        );
      }
    }
  }

  Future<void> _pickRealPhotoFromGallery() async {
    try {
      final picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 92,
      );
      if (photo != null) {
        if (!mounted) return;
        Navigator.pop(context);
        final userNote = _captionController.text.trim();
        final caption = userNote.isNotEmpty ? userNote : photo.name;

        MessengerService.instance.sendPhotoMessage(
          conversationId: widget.conversationId,
          photoUrl: photo.path,
          caption: caption,
        );
        widget.onMessageSent();
      }
    } catch (_) {}
  }

  Future<void> _recordVideoClip() async {
    try {
      final picker = ImagePicker();
      final XFile? video = await picker.pickVideo(source: ImageSource.camera);
      if (video != null) {
        if (!mounted) return;
        Navigator.pop(context);
        final userNote = _captionController.text.trim();
        final caption = userNote.isNotEmpty ? userNote : 'Recorded Video Clip · ${video.name}';

        MessengerService.instance.sendVideoMessage(
          conversationId: widget.conversationId,
          videoUrl: video.path,
          caption: caption,
          durationSeconds: 15,
          thumbnailUrl: null,
        );
        widget.onMessageSent();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video recording unavailable or permission denied')),
        );
      }
    }
  }

  Future<void> _pickRealVideoFromGallery() async {
    try {
      final picker = ImagePicker();
      final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        if (!mounted) return;
        Navigator.pop(context);
        final userNote = _captionController.text.trim();
        final caption = userNote.isNotEmpty ? userNote : video.name;

        MessengerService.instance.sendVideoMessage(
          conversationId: widget.conversationId,
          videoUrl: video.path,
          caption: caption,
          durationSeconds: 15,
          thumbnailUrl: null,
        );
        widget.onMessageSent();
      }
    } catch (_) {}
  }

  Future<void> _pickRealFileFromStorage() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'gpx', 'kml', 'doc', 'docx', 'jpg', 'jpeg', 'png', 'txt'],
      );
      if (files.isNotEmpty) {
        final file = files.first;
        if (!mounted) return;
        Navigator.pop(context);

        final fileName = file.name;
        final filePath = file.path ?? file.uri.toString();
        final len = file.lengthSync();
        final fileSize = len != null && len > 0
            ? '${(len / 1024).toStringAsFixed(1)} KB'
            : 'Document';
        final ext = (file.extension ?? (fileName.contains('.') ? fileName.split('.').last : 'DOC')).toUpperCase();
        final userNote = _captionController.text.trim();
        final caption = userNote.isNotEmpty ? userNote : 'Shared file: $fileName';

        MessengerService.instance.sendFileMessage(
          conversationId: widget.conversationId,
          fileUrl: filePath,
          fileName: fileName,
          fileSize: fileSize,
          fileExtension: ext,
          caption: caption,
        );
        widget.onMessageSent();
        return;
      }
    } catch (_) {}
  }

  void _sendCustomPhotoPath() {
    final customPath = _customPhotoPathController.text.trim();
    if (customPath.isEmpty) return;

    Navigator.pop(context);
    final fileName = customPath.split('/').last.split('\\').last;
    final userNote = _captionController.text.trim();
    final caption = userNote.isNotEmpty ? userNote : (fileName.isNotEmpty ? fileName : 'Photo Attachment');

    MessengerService.instance.sendPhotoMessage(
      conversationId: widget.conversationId,
      photoUrl: customPath,
      caption: caption,
    );
    widget.onMessageSent();
  }

  void _sendCustomVideoPath() {
    final customPath = _customVideoPathController.text.trim();
    if (customPath.isEmpty) return;

    Navigator.pop(context);
    final fileName = customPath.split('/').last.split('\\').last;
    final userNote = _captionController.text.trim();
    final caption = userNote.isNotEmpty ? userNote : (fileName.isNotEmpty ? fileName : 'Video Attachment');

    MessengerService.instance.sendVideoMessage(
      conversationId: widget.conversationId,
      videoUrl: customPath,
      caption: caption,
      durationSeconds: 15,
      thumbnailUrl: null,
    );
    widget.onMessageSent();
  }

  void _sendCustomFilePath() {
    final customPath = _customFilePathController.text.trim();
    if (customPath.isEmpty) return;

    Navigator.pop(context);
    final fileName = customPath.split('/').last.split('\\').last;
    final ext = fileName.contains('.') ? fileName.split('.').last.toUpperCase() : 'DOC';

    MessengerService.instance.sendFileMessage(
      conversationId: widget.conversationId,
      fileUrl: customPath,
      fileName: fileName.isNotEmpty ? fileName : 'User_Travel_File.$ext',
      fileSize: 'Local File · Storage',
      fileExtension: ext,
      caption: _captionController.text.trim().isNotEmpty ? _captionController.text.trim() : 'Custom File Attachment',
    );
    widget.onMessageSent();
  }

  void _dispatchCustomExperienceNote() {
    final noteContent = _composerController.text.trim();
    final content = noteContent.isNotEmpty
        ? noteContent
        : 'Checked in at $_selectedDistrict · All trail and transit routes are open.';

    Navigator.pop(context);
    final dispatchText = '[$_selectedCategory] $content ($_selectedDistrict)';

    MessengerService.instance.sendMessage(
      conversationId: widget.conversationId,
      textContent: dispatchText,
      messageType: MessageTypeEnum.text,
    );
    widget.onMessageSent();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: EdgeInsets.fromLTRB(18, 14, 18, bottomInset + 18),
      decoration: BoxDecoration(
        color: const Color(0xFF071E2D),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Drag Handle
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 2. Creative Title Bar
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [TraverzaColors.secondary, Color(0xFF0E7490)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: TraverzaColors.secondary.withValues(alpha: 0.35),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(Icons.share_location_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Share Travel Experience',
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: TraverzaColors.secondary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: TraverzaColors.secondary.withValues(alpha: 0.4),
                              width: 0.8,
                            ),
                          ),
                          child: const Text(
                            'USER VAULT',
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              color: TraverzaColors.secondary,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Share photos & clips from your gallery, travel files, or compose live notes',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.65),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 3. Creative Animated Segmented Tab Switcher
          CreativeExperienceTabSwitcher(
            selectedIndex: _selectedTabIndex,
            onTabChanged: (index) {
              setState(() {
                _selectedTabIndex = index;
              });
            },
            items: _tabs,
            height: 48,
          ),
          const SizedBox(height: 14),

          // 4. Tab Content Area
          Flexible(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: _buildActiveTabContent(),
            ),
          ),

          // 5. Bottom Caption Row (Only for Media & File attachment tabs: 0, 1, 2)
          if (_selectedTabIndex != 3) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit_note_rounded, size: 18, color: Colors.white60),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _captionController,
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Add an optional note / caption to attachment...',
                        hintStyle: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4)),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      ),
                    ),
                  ),
                  if (_captionController.text.isNotEmpty)
                    InkWell(
                      onTap: () {
                        setState(() {
                          _captionController.clear();
                        });
                      },
                      child: const Icon(Icons.clear_rounded, size: 16, color: Colors.white54),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActiveTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildUserGalleryDeck();
      case 1:
        return _buildUserVideosDeck();
      case 2:
        return _buildUserFilesDeck();
      case 3:
      default:
        return _buildExperienceComposerDeck();
    }
  }

  Widget _buildActionHeroCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPathInputBar({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onAttach,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: accentColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(fontSize: 11, color: Colors.white),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(fontSize: 10.5, color: Colors.white54),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 6),
              ),
            ),
          ),
          InkWell(
            onTap: onAttach,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Attach',
                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStatusCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: iconColor.withValues(alpha: 0.25), width: 1.5),
            ),
            child: Icon(icon, size: 28, color: iconColor),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.5,
              color: Colors.white.withValues(alpha: 0.65),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 0: User Gallery Photos Deck ---
  Widget _buildUserGalleryDeck() {
    return SingleChildScrollView(
      key: const ValueKey('gallery_deck'),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Two primary Hero Action Cards (Open Gallery & Capture)
          Row(
            children: [
              Expanded(
                child: _buildActionHeroCard(
                  icon: Icons.photo_library_rounded,
                  title: 'Open Gallery',
                  subtitle: 'Choose from photos',
                  gradientColors: const [Color(0xFF0284C7), Color(0xFF0369A1)],
                  onTap: _pickRealPhotoFromGallery,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildActionHeroCard(
                  icon: Icons.camera_alt_rounded,
                  title: 'Capture',
                  subtitle: 'Take live photo',
                  gradientColors: const [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                  onTap: _takeCameraPhoto,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 2. Direct Photo Path / URL Bar
          _buildPathInputBar(
            controller: _customPhotoPathController,
            hint: 'Enter photo path or URL (/storage/... or https://...)',
            icon: Icons.link_rounded,
            accentColor: const Color(0xFF38BDF8),
            onAttach: _sendCustomPhotoPath,
          ),
          const SizedBox(height: 12),

          // 3. Status Info Card
          _buildEmptyStatusCard(
            icon: Icons.add_photo_alternate_rounded,
            iconColor: const Color(0xFF38BDF8),
            title: 'No photos selected yet',
            subtitle: 'Select any photo from your gallery or capture live moments to share with your fellow travellers.',
          ),
        ],
      ),
    );
  }

  // --- TAB 1: User Videos Deck ---
  Widget _buildUserVideosDeck() {
    return SingleChildScrollView(
      key: const ValueKey('videos_deck'),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Two primary Hero Action Cards (Open Videos & Record)
          Row(
            children: [
              Expanded(
                child: _buildActionHeroCard(
                  icon: Icons.video_collection_rounded,
                  title: 'Open Videos',
                  subtitle: 'Choose from clips',
                  gradientColors: const [Color(0xFFD97706), Color(0xFFB45309)],
                  onTap: _pickRealVideoFromGallery,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildActionHeroCard(
                  icon: Icons.fiber_manual_record_rounded,
                  title: 'Record',
                  subtitle: 'Shoot live video',
                  gradientColors: const [Color(0xFFF59E0B), Color(0xFFD97706)],
                  onTap: _recordVideoClip,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 2. Direct Video Path / URL Bar
          _buildPathInputBar(
            controller: _customVideoPathController,
            hint: 'Enter video path or URL (/storage/... or https://...)',
            icon: Icons.link_rounded,
            accentColor: const Color(0xFFFBBF24),
            onAttach: _sendCustomVideoPath,
          ),
          const SizedBox(height: 12),

          // 3. Status Info Card
          _buildEmptyStatusCard(
            icon: Icons.movie_filter_rounded,
            iconColor: const Color(0xFFFBBF24),
            title: 'No video clips selected yet',
            subtitle: 'Choose a video from your device or record a live clip to share your travel experience.',
          ),
        ],
      ),
    );
  }

  // --- TAB 2: User Travel Files & Documents Deck ---
  Widget _buildUserFilesDeck() {
    return SingleChildScrollView(
      key: const ValueKey('files_deck'),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Primary Device File Browser Hero Card
          InkWell(
            onTap: _pickRealFileFromStorage,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF059669), Color(0xFF047857)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF059669).withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.folder_open_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Flexible(
                    child: Text(
                      'Browse Device Files (PDF, GPX, Tickets)',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 2. Direct File Path Bar
          _buildPathInputBar(
            controller: _customFilePathController,
            hint: 'Enter device path or URL (/storage/.../file.pdf)',
            icon: Icons.file_upload_rounded,
            accentColor: const Color(0xFF34D399),
            onAttach: _sendCustomFilePath,
          ),
          const SizedBox(height: 12),

          // 3. Status Info Card
          _buildEmptyStatusCard(
            icon: Icons.folder_shared_rounded,
            iconColor: const Color(0xFF34D399),
            title: 'No files attached yet',
            subtitle: 'Browse your device storage to attach e-Visas, train tickets, hotel vouchers, or GPX trail maps.',
          ),
        ],
      ),
    );
  }

  // --- TAB 3: Custom Experience Composer Deck ---
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Trail Condition':
        return Icons.terrain_rounded;
      case 'Transport Tip':
        return Icons.directions_bus_rounded;
      case 'Food & Dining':
        return Icons.restaurant_rounded;
      case 'Hidden Gem':
        return Icons.diamond_rounded;
      case 'Safety Advisory':
        return Icons.health_and_safety_rounded;
      default:
        return Icons.local_offer_rounded;
    }
  }

  Widget _buildTopicChip(String category) {
    final isSelected = _selectedCategory == category;
    final icon = _getCategoryIcon(category);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedCategory = category;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFA78BFA)
                  : Colors.white.withValues(alpha: 0.12),
              width: isSelected ? 1.4 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.45),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : const Color(0xFFA78BFA),
              ),
              const SizedBox(width: 6),
              Text(
                category,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.8),
                  letterSpacing: 0.2,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 5),
                const Icon(
                  Icons.check_circle_rounded,
                  size: 13,
                  color: Colors.white,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDistrictChip(String district) {
    final isSelected = _selectedDistrict == district;

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: () => setState(() => _selectedDistrict = district),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF7C3AED).withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                ? const Color(0xFFA78BFA)
                : Colors.white.withValues(alpha: 0.1),
              width: isSelected ? 1.2 : 0.8,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 11,
                color: isSelected ? const Color(0xFFA78BFA) : Colors.white54,
              ),
              const SizedBox(width: 4),
              Text(
                district,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExperienceComposerDeck() {
    return SingleChildScrollView(
      key: const ValueKey('notes_composer_deck'),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Topic Category Chips with visible glowing background color change
          const Text(
            'EXPERIENCE TOPIC',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Color(0xFFA78BFA),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _categories.map((cat) => _buildTopicChip(cat)).toList(),
            ),
          ),
          const SizedBox(height: 14),

          // 2. District Tag Chips
          const Text(
            'DESTINATION / DISTRICT',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Color(0xFFA78BFA),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _districts.map((dst) => _buildDistrictChip(dst)).toList(),
            ),
          ),
          const SizedBox(height: 14),

          // 3. User's Real Note Editor
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.edit_note_rounded, color: Color(0xFFA78BFA), size: 18),
                    const SizedBox(width: 6),
                    const Text(
                      'Your Authentic Travel Observation',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'LIVE DISPATCH',
                        style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFFA78BFA)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _composerController,
                  maxLines: 4,
                  style: const TextStyle(fontSize: 12, color: Colors.white, height: 1.35),
                  decoration: InputDecoration(
                    hintText: 'Describe trail terrain, secret spots, wave conditions, crowd size, local tips...',
                    hintStyle: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.35)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4. Prominent Dispatch Button
          InkWell(
            onTap: _dispatchCustomExperienceNote,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.send_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Dispatch Experience Note',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.3,
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
}
