import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../models/community_models.dart';
import '../services/community_service.dart';
import 'widgets/media_gallery_picker_modal.dart';
import '../../auth/services/auth_service.dart';
import '../../../widgets/creative_auth_gate_dialog.dart';

class CreatePostSheet extends StatefulWidget {
  final PostType? initialPostType;
  final int? initialMediaTab;

  const CreatePostSheet({
    super.key,
    this.initialPostType,
    this.initialMediaTab,
  });

  static Future<void> show(
    BuildContext context, {
    PostType? initialPostType,
    int? initialMediaTab,
  }) async {
    if (!TraverzaAuthService.instance.isAccountComplete) {
      final granted = await CreativeAuthGateSheet.show(
        context,
        featureTitle: 'Community Pulse',
        actionMessage: 'Publish Live Moment & Field Reports',
        clearanceReason:
            'Sri Lanka Tourism (SLTDA) verified credentials required to publish live trail dispatches, road alerts, and local guides.',
        featureIcon: Icons.podcasts_rounded,
      );
      if (!granted) return;
    }

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreatePostSheet(
        initialPostType: initialPostType,
        initialMediaTab: initialMediaTab,
      ),
    );
  }

  @override
  State<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<CreatePostSheet> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();

  PostType _selectedType = PostType.photo;
  String _selectedDistrict = 'matale';
  int _expiryHours = 4;
  SelectedMediaItem? _selectedMedia;

  @override
  void initState() {
    super.initState();
    if (widget.initialPostType != null) {
      _selectedType = widget.initialPostType!;
    }
    if (widget.initialMediaTab != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _openMediaPicker(widget.initialMediaTab!);
        }
      });
    }
  }

  final List<Map<String, String>> _districts = const [
    {'id': 'matale', 'name': 'Matale (Sigiriya / Dambulla)'},
    {'id': 'kandy', 'name': 'Kandy (Temple of Tooth / Hunnasgiriya)'},
    {'id': 'badulla', 'name': 'Badulla (Ella / Nine Arch / Dunhinda)'},
    {'id': 'nuwara-eliya', 'name': 'Nuwara Eliya (Tea Hills / Horton Plains)'},
    {'id': 'galle', 'name': 'Galle (Dutch Fort / Unawatuna)'},
    {'id': 'jaffna', 'name': 'Jaffna (Nallur / Fort / Delft)'},
    {'id': 'trincomalee', 'name': 'Trincomalee (Nilaveli / Koneswaram)'},
    {'id': 'colombo', 'name': 'Colombo (Galle Face / Pettah)'},
    {'id': 'anuradhapura', 'name': 'Anuradhapura (Sacred City / Mihintale)'},
  ];

  @override
  void dispose() {
    _captionController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  Future<void> _openMediaPicker(int tabIndex) async {
    final result = await MediaGalleryPickerModal.show(context, initialTabIndex: tabIndex);
    if (result != null) {
      setState(() {
        _selectedMedia = result;
        if (result.mediaType == 'video') {
          _selectedType = PostType.video;
        } else if (_selectedType == PostType.video) {
          _selectedType = PostType.photo;
        }
      });
    }
  }

  void _submit() {
    final text = _captionController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a caption or observation.')),
      );
      return;
    }

    final mediaUrls = <String>[];
    String mediaType = 'image';
    int? durationSeconds;
    String? thumbnailUrl;
    String? fileName;
    String? fileSize;

    if (_selectedMedia != null) {
      mediaUrls.add(_selectedMedia!.mediaUrl);
      mediaType = _selectedMedia!.mediaType;
      durationSeconds = _selectedMedia!.durationSeconds;
      thumbnailUrl = _selectedMedia!.thumbnailUrl;
      fileName = _selectedMedia!.fileName;
      fileSize = _selectedMedia!.fileSize;
    } else if (_selectedType == PostType.photo) {
      mediaUrls.add('https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?auto=format&fit=crop&w=800&q=80');
      fileName = 'Default_Scenic.jpg';
      fileSize = '3.2 MB';
    } else if (_selectedType == PostType.video) {
      mediaUrls.add('https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4');
      mediaType = 'video';
      durationSeconds = 18;
      thumbnailUrl = 'https://images.unsplash.com/photo-1589308078059-be1415eab4c3?auto=format&fit=crop&w=800&q=80';
      fileName = 'Highland_Train_Clip.mp4';
      fileSize = '24.2 MB';
    }

    CommunityService.instance.createPost(
      postType: _selectedType,
      caption: text,
      districtId: _selectedDistrict,
      destinationName: _landmarkController.text.trim().isNotEmpty ? _landmarkController.text.trim() : null,
      mediaUrls: mediaUrls,
      mediaType: mediaType,
      durationSeconds: durationSeconds,
      thumbnailUrl: thumbnailUrl,
      fileName: fileName,
      fileSize: fileSize,
      expiryHours: _selectedType == PostType.fieldReport ? _expiryHours : null,
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Moment shared and published to Community Pulse!'),
        backgroundColor: TraverzaColors.emeraldSuccess,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(
        color: TraverzaColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(color: TraverzaColors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),

            // Sheet Title
            const Text(
              'Share a Travel Moment or Field Report',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TraverzaColors.primary),
            ),
            const SizedBox(height: 14),

            // Post Type Toggle
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTypeChip(PostType.photo, '📸 Photo Moment'),
                  _buildTypeChip(PostType.video, '🎥 Travel Video'),
                  _buildTypeChip(PostType.localNote, '💡 Local Note'),
                  _buildTypeChip(PostType.fieldReport, '⏱️ Field Report'),
                  _buildTypeChip(PostType.question, '❓ Ask Community'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Media Selector / Live Preview Area
            _buildMediaAttachmentArea(),
            const SizedBox(height: 16),

            // District Picker
            const Text('District & Geographic Hub', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: TraverzaColors.textMuted)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: TraverzaColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: TraverzaColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedDistrict,
                  isExpanded: true,
                  items: _districts.map((d) {
                    return DropdownMenuItem<String>(
                      value: d['id'],
                      child: Text(d['name']!, style: const TextStyle(fontSize: 13, color: TraverzaColors.text)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedDistrict = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Landmark name
            const Text('Specific Place or Trail (Optional)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: TraverzaColors.textMuted)),
            const SizedBox(height: 6),
            TextField(
              controller: _landmarkController,
              decoration: InputDecoration(
                hintText: 'e.g., Sigiriya Lion Rock, Nine Arch Bridge',
                hintStyle: const TextStyle(fontSize: 13, color: TraverzaColors.textMuted),
                filled: true,
                fillColor: TraverzaColors.background,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: TraverzaColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: TraverzaColors.border)),
              ),
            ),
            const SizedBox(height: 14),

            // Caption Field
            Text(
              _selectedType == PostType.question ? 'What would you like to ask?' : 'Story / Practical Observation',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: TraverzaColors.textMuted),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _captionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: _selectedType == PostType.question
                    ? 'e.g., Is Pidurangala climb suitable for children?'
                    : 'Share authentic timing tips, road/trail conditions, or cultural insights...',
                hintStyle: const TextStyle(fontSize: 13, color: TraverzaColors.textMuted),
                filled: true,
                fillColor: TraverzaColors.background,
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: TraverzaColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: TraverzaColors.border)),
              ),
            ),
            const SizedBox(height: 14),

            // Field Report Expiry policy if field report
            if (_selectedType == PostType.fieldReport) ...[
              const Text('Field Report Freshness Expiry', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: TraverzaColors.textMuted)),
              const SizedBox(height: 6),
              Row(
                children: [2, 4, 8, 24].map((h) {
                  final isSel = _expiryHours == h;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => setState(() => _expiryHours = h),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSel ? TraverzaColors.secondary : TraverzaColors.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isSel ? TraverzaColors.secondary : TraverzaColors.border),
                        ),
                        child: Text(
                          'Valid ${h}h',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSel ? Colors.white : TraverzaColors.text,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
            ],

            // Privacy & EXIF banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TraverzaColors.oceanBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: TraverzaColors.oceanBlue.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.shield_rounded, size: 16, color: TraverzaColors.oceanBlue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'TRAVERZA Privacy Guard: Hidden EXIF coordinates are automatically stripped from uploaded images to protect your privacy.',
                      style: TextStyle(fontSize: 10.5, color: TraverzaColors.primary, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TraverzaColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  'Publish Moment to Pulse',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaAttachmentArea() {
    if (_selectedMedia == null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: TraverzaColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: TraverzaColors.border, style: BorderStyle.solid),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.add_photo_alternate_rounded, size: 18, color: TraverzaColors.secondary),
                SizedBox(width: 8),
                Text(
                  'Attach Photos, Videos or Device Files',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: TraverzaColors.text),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Select captured moments from your phone gallery or open media files directly.',
              style: TextStyle(fontSize: 11, color: TraverzaColors.textMuted),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: TraverzaColors.secondary,
                      side: const BorderSide(color: TraverzaColors.secondary),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.photo_library_rounded, size: 16),
                    label: const Text('Open Gallery', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    onPressed: () => _openMediaPicker(0),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: TraverzaColors.oceanBlue,
                      side: const BorderSide(color: TraverzaColors.oceanBlue),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.videocam_rounded, size: 16),
                    label: const Text('Select Video', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    onPressed: () => _openMediaPicker(1),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: TraverzaColors.primary,
                      side: const BorderSide(color: TraverzaColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.folder_open_rounded, size: 16),
                    label: const Text('Browse Files', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    onPressed: () => _openMediaPicker(2),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final isVid = _selectedMedia!.mediaType == 'video';

    return Container(
      decoration: BoxDecoration(
        color: TraverzaColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TraverzaColors.secondary.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.network(
                  _selectedMedia!.thumbnailUrl ?? _selectedMedia!.mediaUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    height: 140,
                    color: Colors.black12,
                    alignment: Alignment.center,
                    child: Icon(isVid ? Icons.videocam_rounded : Icons.image_rounded, size: 40, color: TraverzaColors.textMuted),
                  ),
                ),
                if (isVid) ...[
                  Container(
                    height: 160,
                    color: Colors.black.withValues(alpha: 0.35),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: TraverzaColors.secondary.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '▶ 0:${_selectedMedia!.durationSeconds ?? 15}s · VIDEO',
                        style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: TraverzaColors.emeraldSuccess,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.check_circle_rounded, color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Text('ATTACHED', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedMedia!.fileName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: TraverzaColors.text),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${isVid ? 'High-Def Video' : 'Photo'} · ${_selectedMedia!.fileSize}',
                        style: const TextStyle(fontSize: 10.5, color: TraverzaColors.textMuted),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => _openMediaPicker(isVid ? 1 : 0),
                  child: const Text('Change', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: TraverzaColors.secondary)),
                ),
                IconButton(
                  tooltip: 'Remove',
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: TraverzaColors.roseEmergency),
                  onPressed: () => setState(() => _selectedMedia = null),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(PostType type, String label) {
    final isSelected = _selectedType == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedType = type);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7.5),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [TraverzaColors.secondary, Color(0xFF0E7490)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : TraverzaColors.background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? TraverzaColors.secondary
                  : TraverzaColors.border,
              width: isSelected ? 1.4 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: TraverzaColors.secondary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? Colors.white : TraverzaColors.text,
            ),
          ),
        ),
      ),
    );
  }
}
