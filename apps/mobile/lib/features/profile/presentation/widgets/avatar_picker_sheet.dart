import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../data/avatar_presets.dart';

class AvatarPickerSheet extends StatefulWidget {
  final String? initialAvatarUrl;
  final String fallbackInitial;

  const AvatarPickerSheet({
    super.key,
    this.initialAvatarUrl,
    this.fallbackInitial = 'T',
  });

  static Future<String?> show(
    BuildContext context, {
    String? currentAvatarUrl,
    String fallbackInitial = 'T',
  }) {
    return showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AvatarPickerSheet(
        initialAvatarUrl: currentAvatarUrl,
        fallbackInitial: fallbackInitial,
      ),
    );
  }

  @override
  State<AvatarPickerSheet> createState() => _AvatarPickerSheetState();
}

class _AvatarPickerSheetState extends State<AvatarPickerSheet> {
  late String? _selectedUrl;
  final TextEditingController _customUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedUrl = widget.initialAvatarUrl;
    if (_selectedUrl != null && !AvatarPreset.presets.any((p) => p.url == _selectedUrl)) {
      _customUrlController.text = _selectedUrl!;
    }
  }

  @override
  void dispose() {
    _customUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color: TraverzaColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: TraverzaColors.border,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 14),

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
                        'Update Profile Picture',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: TraverzaColors.text,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Choose a curated explorer style or enter custom photo URL',
                        style: TextStyle(fontSize: 11.5, color: TraverzaColors.textMuted),
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
          const Divider(height: 18),

          // Live Preview Area
          Center(
            child: Column(
              children: [
                Container(
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: TraverzaColors.secondary, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: TraverzaColors.primary.withValues(alpha: 0.18),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: TraverzaColors.primary,
                    backgroundImage: (_selectedUrl != null && _selectedUrl!.isNotEmpty)
                        ? NetworkImage(_selectedUrl!)
                        : null,
                    onBackgroundImageError: (_selectedUrl != null && _selectedUrl!.isNotEmpty)
                        ? (e, s) {}
                        : null,
                    child: (_selectedUrl != null && _selectedUrl!.isNotEmpty)
                        ? null
                        : Text(
                            widget.fallbackInitial,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedUrl == null || _selectedUrl!.isEmpty
                      ? 'Monogram Initial (Default)'
                      : 'Active Selection',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: TraverzaColors.secondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Scrollable Selection Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CURATED SRI LANKA EXPLORER STYLES',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: TraverzaColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Presets Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: AvatarPreset.presets.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.82,
                    ),
                    itemBuilder: (context, index) {
                      final preset = AvatarPreset.presets[index];
                      final isSelected = _selectedUrl == preset.url;

                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedUrl = preset.url;
                          });
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? TraverzaColors.secondary.withValues(alpha: 0.08)
                                : TraverzaColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? TraverzaColors.secondary : TraverzaColors.border,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor: TraverzaColors.background,
                                    backgroundImage: NetworkImage(preset.url),
                                    onBackgroundImageError: (e, s) {},
                                  ),
                                  if (isSelected)
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: TraverzaColors.emeraldSuccess,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.check, size: 12, color: Colors.white),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${preset.emoji} ${preset.title}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? TraverzaColors.secondary : TraverzaColors.text,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 1),
                              Text(
                                preset.subtitle,
                                style: const TextStyle(fontSize: 8.5, color: TraverzaColors.textMuted),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Custom URL Section
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Custom Photo URL',
                                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  // Simulated camera snapshot option
                                  const cameraMock = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80';
                                  setState(() {
                                    _selectedUrl = cameraMock;
                                    _customUrlController.text = cameraMock;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Camera snapshot captured!'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.camera_alt_outlined, size: 14),
                                label: const Text('Take Photo', style: TextStyle(fontSize: 11)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _customUrlController,
                            style: const TextStyle(fontSize: 12),
                            decoration: InputDecoration(
                              hintText: 'https://example.com/my-photo.jpg',
                              hintStyle: const TextStyle(fontSize: 11, color: TraverzaColors.textMuted),
                              prefixIcon: const Icon(Icons.link_rounded, size: 16),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.check_circle_outline, size: 18),
                                onPressed: () {
                                  if (_customUrlController.text.trim().isNotEmpty) {
                                    setState(() {
                                      _selectedUrl = _customUrlController.text.trim();
                                    });
                                  }
                                },
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onChanged: (val) {
                              if (val.trim().isNotEmpty) {
                                setState(() {
                                  _selectedUrl = val.trim();
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Clear / Reset to Initial Button
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedUrl = ''; // Clear photo
                          _customUrlController.clear();
                        });
                      },
                      icon: const Icon(Icons.delete_outline, size: 14, color: TraverzaColors.roseEmergency),
                      label: const Text(
                        'Remove Photo & Use Monogram Initial',
                        style: TextStyle(fontSize: 11.5, color: TraverzaColors.roseEmergency, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // Bottom Confirmation Action Bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            decoration: BoxDecoration(
              color: TraverzaColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, _selectedUrl);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: TraverzaColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  'Apply Profile Picture',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
