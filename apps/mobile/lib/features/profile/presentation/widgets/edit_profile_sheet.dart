import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../auth/services/auth_service.dart';
import '../../data/profile_models.dart';
import 'avatar_picker_sheet.dart';

class EditProfileSheet extends StatefulWidget {
  final TravellerProfile profile;

  const EditProfileSheet({
    super.key,
    required this.profile,
  });

  static Future<void> show(BuildContext context, TravellerProfile profile) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditProfileSheet(profile: profile),
    );
  }

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _nationalityController;
  late TextEditingController _emergencyNameController;
  late TextEditingController _emergencyRelationController;
  late TextEditingController _emergencyPhoneController;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _avatarUrl = p.avatarUrl;
    _nameController = TextEditingController(text: p.fullName);
    _emailController = TextEditingController(text: p.email);
    _phoneController = TextEditingController(text: p.phone);
    _nationalityController = TextEditingController(text: p.nationality);
    _emergencyNameController = TextEditingController(text: p.emergencyContact.name);
    _emergencyRelationController = TextEditingController(text: p.emergencyContact.relationship);
    _emergencyPhoneController = TextEditingController(text: p.emergencyContact.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nationalityController.dispose();
    _emergencyNameController.dispose();
    _emergencyRelationController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  Future<void> _changeAvatar() async {
    final result = await AvatarPickerSheet.show(
      context,
      currentAvatarUrl: _avatarUrl,
      fallbackInitial: _nameController.text.trim().isNotEmpty ? _nameController.text.trim()[0].toUpperCase() : 'T',
    );
    if (result != null) {
      setState(() {
        _avatarUrl = result.isEmpty ? null : result;
      });
    }
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;

    final updated = widget.profile.copyWith(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      nationality: _nationalityController.text.trim(),
      avatarUrl: _avatarUrl,
      clearAvatar: _avatarUrl == null || _avatarUrl!.isEmpty,
      emergencyContact: widget.profile.emergencyContact.copyWith(
        name: _emergencyNameController.text.trim(),
        relationship: _emergencyRelationController.text.trim(),
        phone: _emergencyPhoneController.text.trim(),
      ),
    );

    TraverzaAuthService.instance.updateProfile(updated);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully'),
        backgroundColor: TraverzaColors.secondary,
        duration: Duration(seconds: 2),
      ),
    );
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
          const SizedBox(height: 16),

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
                        'Edit Traveller Profile',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: TraverzaColors.text,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Update personal details and emergency contact',
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
          const Divider(height: 20),

          // Form Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Photo Avatar Section
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              GestureDetector(
                                onTap: _changeAvatar,
                                child: Container(
                                  width: 82,
                                  height: 82,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: TraverzaColors.secondary, width: 2.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: TraverzaColors.primary.withValues(alpha: 0.15),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 39,
                                    backgroundColor: TraverzaColors.primary,
                                    backgroundImage: (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                                        ? NetworkImage(_avatarUrl!)
                                        : null,
                                    onBackgroundImageError: (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                                        ? (e, s) {}
                                        : null,
                                    child: (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                                        ? null
                                        : Text(
                                            _nameController.text.trim().isNotEmpty
                                                ? _nameController.text.trim()[0].toUpperCase()
                                                : 'T',
                                            style: const TextStyle(
                                              fontSize: 30,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: GestureDetector(
                                  onTap: _changeAvatar,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: TraverzaColors.secondary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.camera_alt_rounded, size: 15, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          TextButton.icon(
                            onPressed: _changeAvatar,
                            icon: const Icon(Icons.photo_library_outlined, size: 14),
                            label: const Text('Change Profile Picture', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            style: TextButton.styleFrom(
                              foregroundColor: TraverzaColors.secondary,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              minimumSize: Size.zero,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    const Text(
                      'PERSONAL IDENTITY',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: TraverzaColors.secondary),
                    ),
                    const SizedBox(height: 10),

                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Legal Name',
                      icon: Icons.person_outline_rounded,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v == null || !v.contains('@') ? 'Valid email required' : null,
                    ),
                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone / WhatsApp',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Phone required' : null,
                    ),
                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: _nationalityController,
                      label: 'Nationality / Passport Country',
                      icon: Icons.flag_outlined,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Nationality required' : null,
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'NEXT-OF-KIN EMERGENCY CONTACT',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: TraverzaColors.roseEmergency),
                    ),
                    const SizedBox(height: 10),

                    _buildTextField(
                      controller: _emergencyNameController,
                      label: 'Contact Name',
                      icon: Icons.contact_emergency_outlined,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Emergency contact name required' : null,
                    ),
                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: _emergencyRelationController,
                      label: 'Relationship (e.g. Spouse, Sister, Father)',
                      icon: Icons.family_restroom_outlined,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Relationship required' : null,
                    ),
                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: _emergencyPhoneController,
                      label: 'Emergency Phone Number',
                      icon: Icons.phone_in_talk_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Emergency phone required' : null,
                    ),
                    const SizedBox(height: 24),

                    // Save CTA
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TraverzaColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text(
                          'Save Profile Changes',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 13.5, color: TraverzaColors.text),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, color: TraverzaColors.textMuted),
        prefixIcon: Icon(icon, size: 20, color: TraverzaColors.textMuted),
        filled: true,
        fillColor: TraverzaColors.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TraverzaColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TraverzaColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TraverzaColors.secondary, width: 1.5),
        ),
      ),
    );
  }
}
