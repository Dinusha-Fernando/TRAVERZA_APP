import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../data/auth_models.dart';
import '../services/auth_service.dart';

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
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _selectDemoAccount(DemoAccount demo) {
    setState(() {
      _signInEmailController.text = demo.email;
      _signInPasswordController.text = demo.password;
    });
    _handleSignIn();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
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

          // Brand Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [TraverzaColors.primary, TraverzaColors.secondary],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Text('T', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'TRAVERZA',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1.2, color: TraverzaColors.primary),
                        ),
                        Text(
                          'One island. One connected trip.',
                          style: TextStyle(fontSize: 10, color: TraverzaColors.textMuted, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: TraverzaColors.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Tab Bar: Sign In vs Register
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: TraverzaColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: TraverzaColors.border),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: TraverzaColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: TraverzaColors.textMuted,
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: 'Sign In'),
                  Tab(text: 'Register Account'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Demo Account Quick Selectors (Sign In Tab)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.flash_on_rounded, color: TraverzaColors.amberWarning, size: 14),
                const SizedBox(width: 4),
                const Text('Quick Pilot Login:', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: TraverzaColors.textMuted)),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: DemoAccount.demoAccounts.map((demo) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: InkWell(
                            onTap: () => _selectDemoAccount(demo),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: TraverzaColors.secondary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: TraverzaColors.secondary.withValues(alpha: 0.2)),
                              ),
                              child: Text(
                                demo.title.split(' ').first,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: TraverzaColors.secondary),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 18),

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
    );
  }

  Widget _buildSignInView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Form(
        key: _signInFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sign In to TRAVERZA',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TraverzaColors.text),
            ),
            const SizedBox(height: 4),
            const Text(
              'Access your live itinerary, biometric digital pass, and booking vouchers.',
              style: TextStyle(fontSize: 11.5, color: TraverzaColors.textMuted),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _signInEmailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(fontSize: 13.5, color: TraverzaColors.text),
              validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null,
              decoration: _inputDecoration('Email Address', Icons.email_outlined),
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _signInPasswordController,
              obscureText: _obscureSignInPassword,
              style: const TextStyle(fontSize: 13.5, color: TraverzaColors.text),
              validator: (v) => v == null || v.length < 6 ? 'Password must be at least 6 characters' : null,
              decoration: _inputDecoration(
                'Password',
                Icons.lock_outline_rounded,
                suffix: IconButton(
                  icon: Icon(
                    _obscureSignInPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 18,
                    color: TraverzaColors.textMuted,
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
                  backgroundColor: TraverzaColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Sign In to Account', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),

            Center(
              child: TextButton(
                onPressed: () {
                  TraverzaAuthService.instance.signOut();
                  Navigator.pop(context);
                },
                child: const Text('Continue as Guest Traveller', style: TextStyle(fontSize: 12, color: TraverzaColors.textMuted)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Form(
        key: _signUpFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Register Traveller Account',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TraverzaColors.text),
            ),
            const SizedBox(height: 4),
            const Text(
              'Get SLTDA accredited digital passport and access instant corridor booking.',
              style: TextStyle(fontSize: 11.5, color: TraverzaColors.textMuted),
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _signUpNameController,
              style: const TextStyle(fontSize: 13.5, color: TraverzaColors.text),
              validator: (v) => v == null || v.trim().isEmpty ? 'Enter full legal name' : null,
              decoration: _inputDecoration('Full Legal Name', Icons.person_outline_rounded),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _signUpEmailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(fontSize: 13.5, color: TraverzaColors.text),
              validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null,
              decoration: _inputDecoration('Email Address', Icons.email_outlined),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _signUpPhoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontSize: 13.5, color: TraverzaColors.text),
              validator: (v) => v == null || v.trim().isEmpty ? 'Phone number required' : null,
              decoration: _inputDecoration('Phone / WhatsApp', Icons.phone_outlined),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _signUpNationalityController,
              style: const TextStyle(fontSize: 13.5, color: TraverzaColors.text),
              validator: (v) => v == null || v.trim().isEmpty ? 'Nationality required' : null,
              decoration: _inputDecoration('Nationality / Passport Country', Icons.flag_outlined),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _signUpPasswordController,
              obscureText: _obscureSignUpPassword,
              style: const TextStyle(fontSize: 13.5, color: TraverzaColors.text),
              validator: (v) => v == null || v.length < 6 ? 'Password must be at least 6 characters' : null,
              decoration: _inputDecoration(
                'Password',
                Icons.lock_outline_rounded,
                suffix: IconButton(
                  icon: Icon(
                    _obscureSignUpPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 18,
                    color: TraverzaColors.textMuted,
                  ),
                  onPressed: () => setState(() => _obscureSignUpPassword = !_obscureSignUpPassword),
                ),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSignUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TraverzaColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Register & Create Digital Passport', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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
      labelStyle: const TextStyle(fontSize: 12, color: TraverzaColors.textMuted),
      prefixIcon: Icon(icon, size: 20, color: TraverzaColors.textMuted),
      suffixIcon: suffix,
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
    );
  }
}
