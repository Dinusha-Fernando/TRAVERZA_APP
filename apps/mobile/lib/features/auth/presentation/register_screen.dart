import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/animated_traverza_logo.dart';
import '../../../../widgets/creative_google_button.dart';
import '../services/auth_service.dart';
import 'sign_in_screen.dart';

/// Full-screen Creative Register Account Page for TRAVERZA Sri Lanka
/// Features Live Dynamic Passport Preview Card and Interactive Corridor Selection
class RegisterScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const RegisterScreen({
    super.key,
    this.onComplete,
  });

  static Future<void> show(BuildContext context, {VoidCallback? onComplete}) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) =>
            RegisterScreen(onComplete: onComplete),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
      ),
    );
  }

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nationalityController = TextEditingController(text: 'International Visitor');
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _acceptTerms = true;
  String _selectedCorridor = 'Colombo → Sigiriya → Kandy';

  final List<String> _corridors = const [
    'Colombo → Sigiriya → Kandy',
    'Kandy → Nuwara Eliya → Ella',
    'Galle → Mirissa → Yala',
    'Jaffna → Trincomalee',
  ];

  final List<Map<String, String>> _popularCountries = const [
    {'flag': '🇱🇰', 'name': 'Sri Lanka'},
    {'flag': '🇬🇧', 'name': 'United Kingdom'},
    {'flag': '🇺🇸', 'name': 'United States'},
    {'flag': '🇩🇪', 'name': 'Germany'},
    {'flag': '🇦🇺', 'name': 'Australia'},
    {'flag': '🇫🇷', 'name': 'France'},
    {'flag': '🇮🇳', 'name': 'India'},
  ];

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();

    // Listen to text updates to re-render the live digital passport preview
    _nameController.addListener(() => setState(() {}));
    _nationalityController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nationalityController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  int get _passwordStrength {
    final pwd = _passwordController.text;
    if (pwd.isEmpty) return 0;
    int strength = 0;
    if (pwd.length >= 8) strength++;
    if (RegExp(r'[0-9]').hasMatch(pwd)) strength++;
    if (RegExp(r'[A-Z]').hasMatch(pwd)) strength++;
    if (RegExp(r'[!@#\$&*~]').hasMatch(pwd) || pwd.length >= 12) strength++;
    return strength;
  }

  Color get _strengthColor {
    switch (_passwordStrength) {
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

  String get _strengthLabel {
    switch (_passwordStrength) {
      case 1:
        return 'Basic (needs length)';
      case 2:
        return 'Fair (add numbers/caps)';
      case 3:
        return 'Strong';
      case 4:
        return 'SLTDA Encrypted (Elite)';
      default:
        return 'Enter at least 8 characters';
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the SLTDA Safe Corridor guidelines to proceed.'),
          backgroundColor: TraverzaColors.amberWarning,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await TraverzaAuthService.instance.signUp(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      nationality: _nationalityController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      final profile = TraverzaAuthService.instance.currentProfile;
      _finishAuth(profile.fullName);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    await TraverzaAuthService.instance.signInWithGoogle();
    if (!mounted) return;
    setState(() => _isLoading = false);
    final profile = TraverzaAuthService.instance.currentProfile;
    _finishAuth(profile.fullName);
  }

  void _finishAuth([String? welcomeName]) {
    if (widget.onComplete != null) {
      widget.onComplete!();
    } else {
      Navigator.of(context).pop();
    }

    if (welcomeName != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Digital Passport Issued! Welcome to TRAVERZA, $welcomeName.'),
          backgroundColor: TraverzaColors.secondary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF041826),
      body: Stack(
        children: [
          // 1. Ambient Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(0xFF03141F),
                    Color(0xFF07293D),
                    Color(0xFF0A3C59),
                    Color(0xFF062334),
                  ],
                  stops: [0.0, 0.4, 0.8, 1.0],
                ),
              ),
            ),
          ),

          // 2. Ambient Island Orbs
          Positioned(
            top: -60,
            left: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    TraverzaColors.secondary.withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.2,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    TraverzaColors.sand.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 3. Foreground Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top App Bar
                    Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                          tooltip: 'Back',
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.shield_outlined, size: 13, color: TraverzaColors.accent),
                                  SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      'INSTANT PASSPORT ISSUANCE',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.6,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Creative Header with Animated Brand Logo
                    Row(
                      children: [
                        const AnimatedTraverzaLogo(
                          size: 48,
                          borderRadius: 14,
                          showHalo: true,
                          showCompassRing: true,
                          showFloatingEffect: true,
                          heroTag: 'register_traverza_logo',
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'TRAVERZA PASSPORT',
                                style: TextStyle(
                                  color: TraverzaColors.sand,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Register Traveller Account',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Receive an SLTDA-accredited digital travel passport with off-grid GPS coordinates and biometric check-ins.',
                      style: TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.4),
                    ),

                    const SizedBox(height: 18),

                    // Creative Live Interactive Digital Passport Preview Card
                    _buildLivePassportCardPreview(),

                    const SizedBox(height: 22),

                    // Form Glass Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Full Legal Name
                            _buildFieldLabel('FULL LEGAL NAME'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _nameController,
                              textCapitalization: TextCapitalization.words,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Enter full legal name' : null,
                              decoration: _buildInputDecoration(
                                hint: 'e.g. Dinusha Wijesinghe',
                                icon: Icons.person_outline_rounded,
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Email Address
                            _buildFieldLabel('EMAIL ADDRESS'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null,
                              decoration: _buildInputDecoration(
                                hint: 'traveller@domain.com',
                                icon: Icons.alternate_email_rounded,
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Phone Number / WhatsApp
                            _buildFieldLabel('PHONE / WHATSAPP NUMBER'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Phone number required' : null,
                              decoration: _buildInputDecoration(
                                hint: '+94 77 123 4567 or intl code',
                                icon: Icons.phone_outlined,
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Nationality
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(child: _buildFieldLabel('NATIONALITY / PASSPORT COUNTRY')),
                                const SizedBox(width: 8),
                                const Text(
                                  'Tap quick flag below',
                                  style: TextStyle(color: TraverzaColors.sand, fontSize: 10.5),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _nationalityController,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Nationality required' : null,
                              decoration: _buildInputDecoration(
                                hint: 'e.g. United Kingdom',
                                icon: Icons.public_rounded,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Quick Country Chips
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                children: _popularCountries.map((c) {
                                  final isSelected = _nationalityController.text.contains(c['name']!);
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: InkWell(
                                      onTap: () => setState(() => _nationalityController.text = c['name']!),
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? TraverzaColors.secondary.withValues(alpha: 0.35)
                                              : Colors.white.withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: isSelected ? TraverzaColors.accent : Colors.white.withValues(alpha: 0.15),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(c['flag']!, style: const TextStyle(fontSize: 12)),
                                            const SizedBox(width: 4),
                                            Text(
                                              c['name']!,
                                              style: TextStyle(
                                                color: isSelected ? Colors.white : Colors.white70,
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),

                            const SizedBox(height: 18),

                            // Primary Travel Corridor
                            _buildFieldLabel('PREFERRED SRI LANKA CORRIDOR'),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _corridors.map((c) {
                                final isSelected = _selectedCorridor == c;
                                return InkWell(
                                  onTap: () => setState(() => _selectedCorridor = c),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? TraverzaColors.secondary.withValues(alpha: 0.3)
                                          : Colors.white.withValues(alpha: 0.06),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected ? TraverzaColors.accent : Colors.white.withValues(alpha: 0.14),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isSelected ? Icons.check_circle_rounded : Icons.route_rounded,
                                          size: 13,
                                          color: isSelected ? TraverzaColors.accent : Colors.white54,
                                        ),
                                        const SizedBox(width: 5),
                                        Flexible(
                                          child: Text(
                                            c,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                              color: isSelected ? Colors.white : Colors.white70,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 18),

                            // Password Field with Dynamic Strength Meter
                            _buildFieldLabel('CREATE PASSWORD (MIN 8 CHARS)'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              validator: (v) => v == null || v.length < 8 ? 'Password must be at least 8 characters' : null,
                              decoration: _buildInputDecoration(
                                hint: '••••••••',
                                icon: Icons.lock_outline_rounded,
                                suffix: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: Colors.white70,
                                    size: 19,
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Interactive Strength Indicator Bar
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: _passwordStrength / 4.0,
                                      backgroundColor: Colors.white12,
                                      valueColor: AlwaysStoppedAnimation<Color>(_strengthColor),
                                      minHeight: 5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  flex: 4,
                                  child: Text(
                                    _strengthLabel,
                                    style: TextStyle(
                                      color: _strengthColor,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Safe Corridor Checkbox
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    value: _acceptTerms,
                                    activeColor: TraverzaColors.secondary,
                                    side: const BorderSide(color: Colors.white38),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                    onChanged: (val) => setState(() => _acceptTerms = val ?? true),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'I agree to SLTDA Safe Corridor Guidelines and instant digital passport verification.',
                                    style: TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.3),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 22),

                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleRegister,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                                  backgroundColor: TraverzaColors.sand,
                                  foregroundColor: TraverzaColors.primary,
                                  elevation: 6,
                                  shadowColor: TraverzaColors.sand.withValues(alpha: 0.4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: TraverzaColors.primary),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(Icons.badge_rounded, size: 18),
                                          SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              'Register & Create Digital Passport',
                                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.3),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Social Authentications Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.2))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'or register with',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.2))),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Creative 1-Tap Google Registration with 4-Color Logo
                    CreativeGoogleButton(
                      onPressed: _isLoading ? null : _handleGoogleSignIn,
                      isLoading: _isLoading,
                      text: 'Register with Google',
                      subtitle: 'Auto-Generate SLTDA Digital Passport',
                      variant: CreativeGoogleVariant.pearl,
                      badgeText: 'INSTANT',
                    ),

                    const SizedBox(height: 24),

                    // Switch to Sign In Button
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            'Already registered with TRAVERZA? ',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              SignInScreen.show(context, onComplete: widget.onComplete);
                            },
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                color: TraverzaColors.sand,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.75),
        fontSize: 10.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.0,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 13.5),
      prefixIcon: Icon(icon, color: TraverzaColors.accent, size: 19),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.black.withValues(alpha: 0.25),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: TraverzaColors.accent, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: TraverzaColors.roseEmergency, width: 1.5),
      ),
    );
  }

  Widget _buildLivePassportCardPreview() {
    final displayName = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : 'YOUR NAME HERE';
    final displayNat = _nationalityController.text.trim().isNotEmpty
        ? _nationalityController.text.trim()
        : 'International Visitor';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F3E5D),
            Color(0xFF09293F),
            Color(0xFF134E5E),
          ],
        ),
        border: Border.all(color: TraverzaColors.sand.withValues(alpha: 0.45), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Passport Top Tag Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.flight_takeoff_rounded, color: TraverzaColors.sand, size: 14),
                    SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        'DIGITAL PASSPORT PREVIEW',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: TraverzaColors.emeraldSuccess.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: TraverzaColors.emeraldSuccess.withValues(alpha: 0.4)),
                ),
                child: const Text(
                  'SLTDA READY',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // User Info
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: TraverzaColors.sand,
                child: Text(
                  displayName[0].toUpperCase(),
                  style: const TextStyle(
                    color: TraverzaColors.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$displayNat · Pilot Explorer',
                      style: const TextStyle(color: Color(0xFFD9E5EC), fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Corridor Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.route_rounded, size: 13, color: TraverzaColors.sand),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _selectedCorridor,
                    style: const TextStyle(fontSize: 10.5, color: Colors.white70),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Text(
                  'Auto-Synced',
                  style: TextStyle(fontSize: 9.5, color: TraverzaColors.sand, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
