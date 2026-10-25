import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/creative_experience_tab_switcher.dart';

class SelectedMediaItem {
  final String mediaUrl;
  final String mediaType; // 'image' or 'video'
  final String fileName;
  final String fileSize;
  final int? durationSeconds;
  final String? thumbnailUrl;
  final String? resolution;
  final String? locationTag;

  const SelectedMediaItem({
    required this.mediaUrl,
    required this.mediaType,
    required this.fileName,
    required this.fileSize,
    this.durationSeconds,
    this.thumbnailUrl,
    this.resolution,
    this.locationTag,
  });
}

class MediaGalleryPickerModal extends StatefulWidget {
  final int initialTabIndex;

  const MediaGalleryPickerModal({
    super.key,
    this.initialTabIndex = 0,
  });

  static Future<SelectedMediaItem?> show(
    BuildContext context, {
    int initialTabIndex = 0,
  }) {
    return showModalBottomSheet<SelectedMediaItem?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MediaGalleryPickerModal(initialTabIndex: initialTabIndex),
    );
  }

  @override
  State<MediaGalleryPickerModal> createState() => _MediaGalleryPickerModalState();
}

class _MediaGalleryPickerModalState extends State<MediaGalleryPickerModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _customPathController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  SelectedMediaItem? _selectedItem;

  final List<SelectedMediaItem> _galleryPhotos = const [
    SelectedMediaItem(
      mediaUrl: 'https://images.unsplash.com/photo-1589308078059-be1415eab4c3?auto=format&fit=crop&w=800&q=80',
      mediaType: 'image',
      fileName: 'IMG_20261023_NineArch_Dawn.jpg',
      fileSize: '4.2 MB',
      resolution: '4K HDR',
      locationTag: 'Ella · Badulla',
    ),
    SelectedMediaItem(
      mediaUrl: 'https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?auto=format&fit=crop&w=800&q=80',
      mediaType: 'image',
      fileName: 'IMG_20261023_Pidurangala_Sunrise.jpg',
      fileSize: '3.8 MB',
      resolution: 'RAW · 48MP',
      locationTag: 'Sigiriya · Matale',
    ),
    SelectedMediaItem(
      mediaUrl: 'https://images.unsplash.com/photo-1552465011-b4e21bf6e79a?auto=format&fit=crop&w=800&q=80',
      mediaType: 'image',
      fileName: 'IMG_20261022_Mirissa_PalmHill.jpg',
      fileSize: '2.9 MB',
      resolution: '1080p',
      locationTag: 'Mirissa · Matara',
    ),
    SelectedMediaItem(
      mediaUrl: 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?auto=format&fit=crop&w=800&q=80',
      mediaType: 'image',
      fileName: 'IMG_20261021_Yala_Leopard_Rock.jpg',
      fileSize: '5.1 MB',
      resolution: '4K Telephoto',
      locationTag: 'Yala Block 1',
    ),
    SelectedMediaItem(
      mediaUrl: 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?auto=format&fit=crop&w=800&q=80',
      mediaType: 'image',
      fileName: 'IMG_20261020_Kandy_TempleTooth.jpg',
      fileSize: '3.4 MB',
      resolution: 'HDR',
      locationTag: 'Kandy Sacred City',
    ),
    SelectedMediaItem(
      mediaUrl: 'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?auto=format&fit=crop&w=800&q=80',
      mediaType: 'image',
      fileName: 'IMG_20261019_Galle_Fort_Lighthouse.jpg',
      fileSize: '4.0 MB',
      resolution: '4K Ultra',
      locationTag: 'Galle Dutch Fort',
    ),
  ];

  final List<SelectedMediaItem> _galleryVideos = const [
    SelectedMediaItem(
      mediaUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      thumbnailUrl: 'https://images.unsplash.com/photo-1589308078059-be1415eab4c3?auto=format&fit=crop&w=800&q=80',
      mediaType: 'video',
      fileName: 'VID_20261023_BlueTrain_Viaduct.mp4',
      fileSize: '24.2 MB',
      durationSeconds: 18,
      resolution: '1080p 60fps',
      locationTag: 'Ella Valley',
    ),
    SelectedMediaItem(
      mediaUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      thumbnailUrl: 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?auto=format&fit=crop&w=800&q=80',
      mediaType: 'video',
      fileName: 'VID_20261022_Minneriya_ElephantHerd.mp4',
      fileSize: '42.8 MB',
      durationSeconds: 24,
      resolution: '4K 30fps',
      locationTag: 'Minneriya NP',
    ),
    SelectedMediaItem(
      mediaUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
      thumbnailUrl: 'https://images.unsplash.com/photo-1552465011-b4e21bf6e79a?auto=format&fit=crop&w=800&q=80',
      mediaType: 'video',
      fileName: 'VID_20261021_Mirissa_WhaleSurfacing.mp4',
      fileSize: '19.4 MB',
      durationSeconds: 15,
      resolution: '1080p HDR',
      locationTag: 'Mirissa Coast',
    ),
    SelectedMediaItem(
      mediaUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
      thumbnailUrl: 'https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?auto=format&fit=crop&w=800&q=80',
      mediaType: 'video',
      fileName: 'VID_20261020_Sigiriya_MistDrone.mp4',
      fileSize: '31.6 MB',
      durationSeconds: 20,
      resolution: '4K Cine',
      locationTag: 'Sigiriya Rock',
    ),
  ];

  final List<Map<String, String>> _storageFiles = const [
    {
      'path': '/storage/emulated/0/DCIM/Camera/IMG_20261023_091522.jpg',
      'name': 'IMG_20261023_091522.jpg',
      'size': '4.2 MB · JPEG',
      'url': 'https://images.unsplash.com/photo-1589308078059-be1415eab4c3?auto=format&fit=crop&w=800&q=80',
      'type': 'image',
    },
    {
      'path': '/storage/emulated/0/DCIM/Camera/VID_20261023_114015.mp4',
      'name': 'VID_20261023_114015.mp4',
      'size': '24.2 MB · MP4 (0:18)',
      'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      'type': 'video',
    },
    {
      'path': '/storage/emulated/0/Download/Ella_NineArch_Highlands.jpg',
      'name': 'Ella_NineArch_Highlands.jpg',
      'size': '3.8 MB · JPEG',
      'url': 'https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?auto=format&fit=crop&w=800&q=80',
      'type': 'image',
    },
    {
      'path': '/storage/emulated/0/Movies/Minneriya_ElephantGathering.mp4',
      'name': 'Minneriya_ElephantGathering.mp4',
      'size': '42.8 MB · MP4 (0:24)',
      'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      'type': 'video',
    },
    {
      'path': '/storage/emulated/0/Pictures/GalleFort_SunsetRamparts.jpg',
      'name': 'GalleFort_SunsetRamparts.jpg',
      'size': '4.0 MB · JPEG',
      'url': 'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?auto=format&fit=crop&w=800&q=80',
      'type': 'image',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTabIndex);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    if (_galleryPhotos.isNotEmpty) {
      _selectedItem = _galleryPhotos.first;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _customPathController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _confirmSelection() {
    if (_selectedItem != null) {
      Navigator.pop(context, _selectedItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: TraverzaColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(color: TraverzaColors.border, borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Select Travel Media',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: TraverzaColors.primary),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Choose photos or video clips from Gallery or Open Files',
                        style: TextStyle(fontSize: 11, color: TraverzaColors.textMuted),
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
          ),
          const SizedBox(height: 8),

          // Creative Segmented Tab Switcher: Gallery Photos, Video Clips, File Storage
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: CreativeExperienceTabSwitcher(
              selectedIndex: _tabController.index,
              onTabChanged: (index) {
                _tabController.animateTo(index);
                setState(() {});
              },
              isDarkTheme: false,
              height: 48,
              items: const [
                CreativeExperienceTabItem(
                  label: 'Gallery',
                  icon: Icons.photo_library_rounded,
                  badge: 'HDR',
                  gradientColors: [Color(0xFF0284C7), Color(0xFF0369A1), Color(0xFF075985)],
                ),
                CreativeExperienceTabItem(
                  label: 'Videos',
                  icon: Icons.videocam_rounded,
                  badge: '4K',
                  gradientColors: [Color(0xFFD97706), Color(0xFFB45309), Color(0xFF92400E)],
                ),
                CreativeExperienceTabItem(
                  label: 'Open Files',
                  icon: Icons.folder_open_rounded,
                  badge: 'STORAGE',
                  gradientColors: [Color(0xFF059669), Color(0xFF047857), Color(0xFF065F46)],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGalleryPhotosTab(),
                _buildGalleryVideosTab(),
                _buildOpenFilesTab(),
              ],
            ),
          ),

          // Bottom Selection Bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: TraverzaColors.surface,
              border: const Border(top: BorderSide(color: TraverzaColors.border)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -3)),
              ],
            ),
            child: Row(
              children: [
                if (_selectedItem != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _selectedItem!.thumbnailUrl ?? _selectedItem!.mediaUrl,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(width: 44, height: 44, color: Colors.black12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedItem!.fileName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: TraverzaColors.text),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${_selectedItem!.mediaType == 'video' ? '🎥 Video (0:${_selectedItem!.durationSeconds}s)' : '📷 Photo'} · ${_selectedItem!.fileSize}',
                          style: const TextStyle(fontSize: 10.5, color: TraverzaColors.secondary, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  const Expanded(
                    child: Text('No media selected', style: TextStyle(color: TraverzaColors.textMuted, fontSize: 12)),
                  ),
                ],
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TraverzaColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.check_circle_rounded, size: 16, color: Colors.white),
                  label: const Text('Attach Media', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5)),
                  onPressed: _selectedItem != null ? _confirmSelection : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryPhotosTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _galleryPhotos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.92,
      ),
      itemBuilder: (context, index) {
        final item = _galleryPhotos[index];
        final isSelected = _selectedItem?.mediaUrl == item.mediaUrl;

        return InkWell(
          onTap: () => setState(() => _selectedItem = item),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? TraverzaColors.secondary : TraverzaColors.border,
                width: isSelected ? 2.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: TraverzaColors.secondary.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    item.mediaUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(color: Colors.black12),
                  ),
                  // Dark gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Resolution pill
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.resolution ?? 'HD',
                        style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  // Selected checkmark
                  if (isSelected)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: TraverzaColors.secondary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                      ),
                    ),
                  // Bottom caption
                  Positioned(
                    left: 8,
                    right: 8,
                    bottom: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.locationTag ?? 'Sri Lanka',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          item.fileSize,
                          style: const TextStyle(color: Colors.white70, fontSize: 9.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGalleryVideosTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _galleryVideos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.92,
      ),
      itemBuilder: (context, index) {
        final item = _galleryVideos[index];
        final isSelected = _selectedItem?.mediaUrl == item.mediaUrl;

        return InkWell(
          onTap: () => setState(() => _selectedItem = item),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? TraverzaColors.secondary : TraverzaColors.border,
                width: isSelected ? 2.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: TraverzaColors.secondary.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  Image.network(
                    item.thumbnailUrl ?? item.mediaUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(color: const Color(0xFF1E293B)),
                  ),
                  Container(
                    color: Colors.black.withValues(alpha: 0.35),
                  ),
                  // Center Play Icon
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: TraverzaColors.secondary.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                  ),
                  // Duration pill
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '▶ 0:${item.durationSeconds}s',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  // Selected checkmark
                  if (isSelected)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: TraverzaColors.secondary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                      ),
                    ),
                  // Bottom detail
                  Positioned(
                    left: 8,
                    right: 8,
                    bottom: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.locationTag ?? 'Travel Clip',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${item.resolution} · ${item.fileSize}',
                          style: const TextStyle(color: Colors.white70, fontSize: 9.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOpenFilesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Real Device Storage Browse Button
        InkWell(
          onTap: () async {
            try {
              final files = await FilePicker.pickFiles();
              if (files.isNotEmpty) {
                final f = files.first;
                final path = f.path ?? f.uri.toString();
                final len = f.lengthSync();
                final isVid = ['mp4', 'mov', 'avi', 'mkv'].contains(f.extension?.toLowerCase());
                final item = SelectedMediaItem(
                  mediaUrl: path,
                  mediaType: isVid ? 'video' : 'image',
                  fileName: f.name,
                  fileSize: len != null && len > 0 ? '${(len / 1024).toStringAsFixed(1)} KB' : 'File',
                  locationTag: 'Device Storage',
                );
                setState(() {
                  _selectedItem = item;
                });
              }
            } catch (_) {}
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [TraverzaColors.secondary, Color(0xFF0E7490)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: TraverzaColors.secondary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.folder_open_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Browse Device Storage / Files',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ),
        ),

        // Custom File Path or URL Input
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: TraverzaColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: TraverzaColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Open File from Local Storage or URL', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: TraverzaColors.primary)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _customPathController,
                      decoration: InputDecoration(
                        hintText: '/storage/emulated/0/... or https://...',
                        hintStyle: const TextStyle(fontSize: 12, color: TraverzaColors.textMuted),
                        filled: true,
                        fillColor: TraverzaColors.surface,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: TraverzaColors.border)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: TraverzaColors.border)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TraverzaColors.secondary,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      final p = _customPathController.text.trim();
                      if (p.isEmpty) return;
                      final isVid = p.toLowerCase().endsWith('.mp4') || p.toLowerCase().endsWith('.mov');
                      final item = SelectedMediaItem(
                        mediaUrl: p.startsWith('http') ? p : 'https://images.unsplash.com/photo-1589308078059-be1415eab4c3?auto=format&fit=crop&w=800&q=80',
                        mediaType: isVid ? 'video' : 'image',
                        fileName: p.split('/').last,
                        fileSize: '3.5 MB',
                        durationSeconds: isVid ? 15 : null,
                      );
                      setState(() => _selectedItem = item);
                    },
                    child: const Text('Add', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        const Text('RECENT DEVICE MEDIA FILES', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: TraverzaColors.textMuted, letterSpacing: 0.6)),
        const SizedBox(height: 8),

        ..._storageFiles.map((f) {
          final isVid = f['type'] == 'video';
          final isSelected = _selectedItem?.fileName == f['name'];

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: TraverzaColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? TraverzaColors.secondary : TraverzaColors.border,
                width: isSelected ? 1.8 : 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isVid ? TraverzaColors.secondary.withValues(alpha: 0.15) : TraverzaColors.oceanBlue.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isVid ? Icons.videocam_rounded : Icons.image_rounded,
                    color: isVid ? TraverzaColors.secondary : TraverzaColors.oceanBlue,
                    size: 20,
                  ),
                ),
                title: Text(
                  f['name']!,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${f['path']} · ${f['size']}',
                  style: const TextStyle(fontSize: 10, color: TraverzaColors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle_rounded, color: TraverzaColors.secondary, size: 20)
                    : const Icon(Icons.radio_button_unchecked_rounded, color: TraverzaColors.textMuted, size: 20),
                onTap: () {
                  setState(() {
                    _selectedItem = SelectedMediaItem(
                      mediaUrl: f['url']!,
                      thumbnailUrl: f['url']!,
                      mediaType: f['type']!,
                      fileName: f['name']!,
                      fileSize: f['size']!,
                      durationSeconds: isVid ? 18 : null,
                    );
                  });
                },
              ),
            ),
          );
        }),
      ],
    );
  }
}
