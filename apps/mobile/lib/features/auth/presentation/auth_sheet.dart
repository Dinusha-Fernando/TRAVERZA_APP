import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/animated_traverza_logo.dart';
import '../../../../widgets/creative_google_button.dart';
import '../../../../widgets/creative_auth_tab_switcher.dart';
import '../services/auth_service.dart';
import 'sign_in_screen.dart';
import 'register_screen.dart';

/// Creative Modal Authentication Sheet for TRAVERZA Sri Lanka
class AuthSheet extends StatefulWidget {
  final int initialTabIndex; // 0 for Sign In, 1 for Register

  const AuthSheet({
    super.key,
    this.initialTabIndex = 0,
  });

  static Future<void> show(BuildContext context, {int initialTabIndex = 0}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AuthSheet(initialTabIndex: initialTabIndex),
    );
  }

  @override
  State<AuthSheet> createState() => _AuthSheetState();
}

class _AuthSheetState extends State<AuthSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _signInFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();

  final _signInEmailController = TextEditingController(text: 'dinusha.w@traverza.lk');
  final _signInPasswordController = TextEditingController(text: 'password123');

  final _signUpNameController = TextEditingController();
  final _signUpEmailController = TextEditingController();
  final _signUpPhoneController = TextEditingController();
  final _signUpNationalityController = TextEditingController(text: 'International Visitor');
  final _signUpPasswordController = TextEditingController();

  bool _obscureSignInPassword = true;
  bool _obscureSignUpPassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTabIndex);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _signUpPasswordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _signInEmailController.dispose();
    _signInPasswordController.dispose();
    _signUpNameController.dispose();
    _signUpEmailController.dispose();
    _signUpPhoneController.dispose();
    _signUpNationalityController.dispose();
    _signUpPasswordController.dispose();
    super.dispose();
  }

  int get _signUpPasswordStrength {
    final pwd = _signUpPasswordController.text;
    if (pwd.isEmpty) return 0;
    int strength = 0;
    if (pwd.length >= 8) strength++;
    if (RegExp(r'[0-9]').hasMatch(pwd)) strength++;
    if (RegExp(r'[A-Z]').hasMatch(pwd)) strength++;
    if (RegExp(r'[!@#\$&*~]').hasMatch(pwd) || pwd.length >= 12) strength++;
    return strength;
  }

  Color get _strengthColor {
    switch (_signUpPasswordStrength) {
      case 1:
        return TraverzaColors.roseEmergency;
      case 2:
        return TraverzaColors.amberWarning;
      case 3:
        return const Color(0xFFFBBF24);
      case 4:
        return TraverzaColors.emeraldSuccess;
      default:
        return Colors.white24;
    }
  }

  Future<void> _handleSignIn() async {
    if (!_signInFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final email = _signInEmailController.text.trim();
    final password = _signInPasswordController.text;

    await TraverzaAuthService.instance.signIn(email: email, password: password);
    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.pop(context);
    final profile = TraverzaAuthService.instance.currentProfile;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Welcome back, ${profile.fullName}!'),
        backgroundColor: TraverzaColors.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleSignUp() async {
    if (!_signUpFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await TraverzaAuthService.instance.signUp(
      fullName: _signUpNameController.text.trim(),
      email: _signUpEmailController.text.trim(),
      phone: _signUpPhoneController.text.trim(),
      nationality: _signUpNationalityController.text.trim(),
      password: _signUpPasswordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.pop(context);
    final profile = TraverzaAuthService.instance.currentProfile;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Account registered! Welcome to TRAVERZA, ${profile.fullName}.'),
        backgroundColor: TraverzaColors.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    await TraverzaAuthService.instance.signInWithGoogle();
    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.pop(context);
    final profile = TraverzaAuthService.instance.currentProfile;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Signed in as ${profile.fullName}!'),
        backgroundColor: TraverzaColors.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }


  void _openFullScreenAuth() {
    Navigator.pop(context);
    if (_tabController.index == 0) {
      SignInScreen.show(context);
    } else {
      RegisterScreen.show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Color(0xFF041826),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Stack(
        children: [
          // Ambient Glow
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    TraverzaColors.accent.withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main Column
          Column(
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Brand Banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const AnimatedTraverzaLogo(
                          size: 38,
                          borderRadius: 12,
                          showHalo: true,
                          showCompassRing: false,
                          showFloatingEffect: true,
                          heroTag: 'auth_sheet_traverza_logo',
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'TRAVERZA',
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.2, color: Colors.white),
                            ),
                            Text(
                              'One island. One connected trip.',
                              style: TextStyle(fontSize: 10.5, color: TraverzaColors.sand, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.open_in_full_rounded, color: Colors.white70, size: 18),
                          tooltip: 'Expand Fullscreen',
                          onPressed: _openFullScreenAuth,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Creative Tab Switcher: Sign In vs Register
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CreativeAuthTabSwitcher(
                  selectedIndex: _tabController.index,
                  onTabChanged: (index) {
                    _tabController.animateTo(index);
                    setState(() {});
                  },
                  leftLabel: 'Sign In',
                  rightLabel: 'Register Account',
                  leftBadge: 'VAULT',
                  rightBadge: 'FREE',
                  height: 46.0,
                ),
              ),
              const SizedBox(height: 6),
              Divider(height: 14, color: Colors.white.withValues(alpha: 0.1)),

              // Form Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSignInView(),
                    _buildSignUpView(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignInView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Form(
        key: _signInFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sign In to TRAVERZA',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            const Text(
              'Access your live itinerary, biometric digital pass, and booking vouchers.',
              style: TextStyle(fontSize: 11.5, color: Colors.white70),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _signInEmailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(fontSize: 13.5, color: Colors.white),
              validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null,
              decoration: _inputDecoration('Email Address', Icons.email_outlined),
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _signInPasswordController,
              obscureText: _obscureSignInPassword,
              style: const TextStyle(fontSize: 13.5, color: Colors.white),
              validator: (v) => v == null || v.length < 6 ? 'Password must be at least 6 characters' : null,
              decoration: _inputDecoration(
                'Password',
                Icons.lock_outline_rounded,
                suffix: IconButton(
                  icon: Icon(
                    _obscureSignInPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 18,
                    color: Colors.white60,
                  ),
                  onPressed: () => setState(() => _obscureSignInPassword = !_obscureSignInPassword),
                ),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSignIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TraverzaColors.sand,
                  foregroundColor: TraverzaColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: TraverzaColors.primary, strokeWidth: 2))
                    : const Text('Sign In to Account', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),

            // Social Logins Divider
            Row(
              children: [
                Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.15))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('or continue with', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.6))),
                ),
                Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.15))),
              ],
            ),
            const SizedBox(height: 12),

            CreativeGoogleButton(
              onPressed: _isLoading ? null : _handleGoogleSignIn,
              isLoading: _isLoading,
              text: 'Continue with Google',
              height: 50,
              variant: CreativeGoogleVariant.pearl,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Form(
        key: _signUpFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Register Traveller Account',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            const Text(
              'Get SLTDA accredited digital passport and access instant corridor booking.',
              style: TextStyle(fontSize: 11.5, color: Colors.white70),
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _signUpNameController,
              style: const TextStyle(fontSize: 13.5, color: Colors.white),
              validator: (v) => v == null || v.trim().isEmpty ? 'Enter full legal name' : null,
              decoration: _inputDecoration('Full Legal Name', Icons.person_outline_rounded),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _signUpEmailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(fontSize: 13.5, color: Colors.white),
              validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null,
              decoration: _inputDecoration('Email Address', Icons.email_outlined),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _signUpPhoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontSize: 13.5, color: Colors.white),
              validator: (v) => v == null || v.trim().isEmpty ? 'Phone number required' : null,
              decoration: _inputDecoration('Phone / WhatsApp (+94 or Intl)', Icons.phone_outlined),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _signUpNationalityController,
              style: const TextStyle(fontSize: 13.5, color: Colors.white),
              validator: (v) => v == null || v.trim().isEmpty ? 'Nationality required' : null,
              decoration: _inputDecoration('Nationality / Passport Country', Icons.flag_outlined),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _signUpPasswordController,
              obscureText: _obscureSignUpPassword,
              style: const TextStyle(fontSize: 13.5, color: Colors.white),
              validator: (v) => v == null || v.length < 8 ? 'Password must be at least 8 characters' : null,
              decoration: _inputDecoration(
                'Password',
                Icons.lock_outline_rounded,
                suffix: IconButton(
                  icon: Icon(
                    _obscureSignUpPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 18,
                    color: Colors.white60,
                  ),
                  onPressed: () => setState(() => _obscureSignUpPassword = !_obscureSignUpPassword),
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Live strength bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _signUpPasswordStrength / 4.0,
                backgroundColor: Colors.white10,
                valueColor: AlwaysStoppedAnimation<Color>(_strengthColor),
                minHeight: 4,
              ),
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSignUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TraverzaColors.sand,
                  foregroundColor: TraverzaColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: TraverzaColors.primary, strokeWidth: 2))
                    : const Text('Register & Create Digital Passport', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),

            Center(
              child: Text(
                'Protected by Sri Lanka PDPA (2027) & SLTDA Traveler Safety Standards',
                style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.5)),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
      prefixIcon: Icon(icon, size: 19, color: TraverzaColors.accent),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.black.withValues(alpha: 0.25),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: TraverzaColors.accent, width: 1.5),
      ),
    );
  }
}
