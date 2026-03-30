import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/auth_service.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _rememberDevice = true;
  bool _showPassword = false;
  final _formKey = GlobalKey<FormState>();

  // Design tokens
  static const Color primary = Color(0xFF005e53);
  static const Color primaryContainer = Color(0xFF00796b);
  static const Color primaryFixed = Color(0xFF97f3e2);
  static const Color surface = Color(0xFFF8FAFB);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F4F5);
  static const Color onSurface = Color(0xFF191c1d);
  static const Color secondary = Color(0xFF4c616c);

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration(String label, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: secondary,
        letterSpacing: 0.8,
      ),
      filled: true,
      fillColor: surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryFixed, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      suffixIcon: suffixIcon,
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final auth = context.read<AdminAuthService>();
    final ok = await auth.signIn(
      _email.text.trim(),
      _password.text,
      rememberDevice: _rememberDevice,
    );
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Login failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AdminAuthService>();
    
    return Scaffold(
      backgroundColor: surface,
      body: Stack(
        children: [
          // Atmospheric background
          Positioned.fill(
            child: Stack(
              children: [
                Positioned(
                  top: -100,
                  left: -100,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryFixed.withAlpha((0.15 * 255).toInt()),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -150,
                  right: -100,
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFCFE6F2).withAlpha((0.2 * 255).toInt()),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Main content
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Container(
                    decoration: BoxDecoration(
                      color: surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: onSurface.withAlpha((0.04 * 255).toInt()),
                          blurRadius: 48,
                          spreadRadius: -4,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Brand header
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: primaryContainer,
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: const Icon(Icons.admin_panel_settings, size: 32, color: Colors.white),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'WellQueue Admin',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Clinic Administration Portal',
                          style: TextStyle(
                            fontSize: 16,
                            color: secondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Email field
                        TextFormField(
                          controller: _email,
                          decoration: _buildInputDecoration('Email Address'),
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 20),
                        // Password field
                        TextFormField(
                          controller: _password,
                          decoration: _buildInputDecoration(
                            'Password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showPassword ? Icons.visibility : Icons.visibility_off,
                                color: secondary,
                              ),
                              onPressed: () => setState(() => _showPassword = !_showPassword),
                            ),
                          ),
                          obscureText: !_showPassword,
                          validator: _validatePassword,
                        ),
                        const SizedBox(height: 16),
                        // Remember device checkbox
                        SizedBox(
                          height: 36,
                          child: CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            value: _rememberDevice,
                            onChanged: (v) => setState(() => _rememberDevice = v ?? true),
                            title: const Text(
                              'Remember this device for 30 days',
                              style: TextStyle(
                                fontSize: 14,
                                color: onSurface,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Primary button
                        SizedBox(
                          height: 56,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment(0, -1),
                                end: Alignment(1, 1),
                                colors: [primary, primaryContainer],
                              ),
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: primary.withAlpha((0.3 * 255).toInt()),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: auth.loading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              child: auth.loading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Footer message
                        Center(
                          child: Column(
                            children: [
                              const Text(
                                'New to WellQueue Administration?',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: secondary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const _InlineAdminSignupScreen()),
                                ),
                                child: const Text(
                                  'Create Admin Profile',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineAdminSignupScreen extends StatefulWidget {
  const _InlineAdminSignupScreen();

  @override
  State<_InlineAdminSignupScreen> createState() => _InlineAdminSignupScreenState();
}

class _InlineAdminSignupScreenState extends State<_InlineAdminSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _clinicName = TextEditingController();
  final _clinicAddress = TextEditingController();
  final _clinicEmail = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _clinicName.dispose();
    _clinicAddress.dispose();
    _clinicEmail.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AdminAuthService>();
    final ok = await auth.createAdminProfile(
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      clinicName: _clinicName.text.trim(),
      clinicAddress: _clinicAddress.text.trim(),
      latitude: 0,
      longitude: 0,
      clinicEmail: _clinicEmail.text.trim(),
      password: _password.text,
    );

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin profile created. Please sign in.')),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Failed to create admin profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AdminAuthService>();
    return Scaffold(
      appBar: AppBar(title: const Text('Create Admin Profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(controller: _firstName, decoration: const InputDecoration(labelText: 'First Name'), validator: (v) => (v == null || v.trim().isEmpty) ? 'First name is required' : null),
            const SizedBox(height: 12),
            TextFormField(controller: _lastName, decoration: const InputDecoration(labelText: 'Last Name'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Last name is required' : null),
            const SizedBox(height: 12),
            TextFormField(controller: _clinicName, decoration: const InputDecoration(labelText: 'Clinic Name'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Clinic name is required' : null),
            const SizedBox(height: 12),
            TextFormField(controller: _clinicAddress, decoration: const InputDecoration(labelText: 'Clinic Address'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Clinic address is required' : null),
            const SizedBox(height: 12),
            TextFormField(controller: _clinicEmail, decoration: const InputDecoration(labelText: 'Clinic Email'), validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              final okEmail = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim());
              return okEmail ? null : 'Please enter a valid email';
            }),
            const SizedBox(height: 12),
            TextFormField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Password'), validator: (v) => (v == null || v.length < 6) ? 'Password must be at least 6 characters' : null),
            const SizedBox(height: 12),
            TextFormField(controller: _confirmPassword, obscureText: true, decoration: const InputDecoration(labelText: 'Confirm Password'), validator: (v) => v != _password.text ? 'Passwords do not match' : null),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: auth.loading ? null : _submit,
              child: Text(auth.loading ? 'Creating...' : 'Create Admin Account'),
            ),
          ],
        ),
      ),
    );
  }
}
