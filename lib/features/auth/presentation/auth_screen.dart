import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/auth_service.dart';
import '../../location_access/presentation/location_access_screen.dart';

enum AuthState { initial, signup, login }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AuthState _authState = AuthState.initial;
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _showPassword = false;

  bool get _isCompact => MediaQuery.sizeOf(context).width < 390;
  double get _outerPadding => _isCompact ? 16 : 24;
  double get _cardRadius => _isCompact ? 24 : 32;
  double get _buttonHeight => _isCompact ? 52 : 56;

  void _setAuthState(AuthState next) {
    if (_authState == next) return;
    _formKey.currentState?.reset();
    _emailController.clear();
    _passwordController.clear();
    if (next != AuthState.signup) {
      _firstNameController.clear();
      _lastNameController.clear();
    }
    setState(() {
      _authState = next;
      _showPassword = false;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  // Design tokens from Calm Clinical Premium
  static const Color primary = Color(0xFF005e53);
  static const Color primaryContainer = Color(0xFF00796b);
  static const Color primaryFixed = Color(0xFF97f3e2);
  static const Color surface = Color(0xFFF8FAFB);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F4F5);
  static const Color onSurface = Color(0xFF191c1d);
  static const Color secondary = Color(0xFF4c616c);
  Widget _buildAuthHeader(String title, String subtitle) {
    return Column(
      children: [
        Container(
          width: _isCompact ? 56 : 64,
          height: _isCompact ? 56 : 64,
          decoration: BoxDecoration(
            color: primaryContainer,
            borderRadius: BorderRadius.circular(_isCompact ? 28 : 32),
          ),
          child: Icon(Icons.local_hospital, size: _isCompact ? 28 : 32, color: Colors.white),
        ),
        SizedBox(height: _isCompact ? 18 : 24),
        Text(
          title,
          style: TextStyle(
            fontSize: _isCompact ? 24 : 28,
            fontWeight: FontWeight.w800,
            height: 1.05,
            color: onSurface,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: _isCompact ? 14 : 16,
            color: secondary,
            height: 1.35,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: _isCompact ? 24 : 32),
      ],
    );
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
        borderRadius: BorderRadius.circular(_isCompact ? 14 : 16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_isCompact ? 14 : 16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_isCompact ? 14 : 16),
        borderSide: const BorderSide(color: primaryFixed, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: _isCompact ? 14 : 16),
      suffixIcon: suffixIcon,
    );
  }

  Future<void> _submitLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final authService = context.read<AuthService>();
    final success = await authService.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    setState(() => _isLoading = false);

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LocationAccessScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authService.error ?? 'Login failed')),
      );
    }
  }

  Future<void> _submitSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final authService = context.read<AuthService>();
    final success = await authService.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
    );
    setState(() => _isLoading = false);

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LocationAccessScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authService.error ?? 'Signup failed')),
      );
    }
  }

  String? _validateName(String? value, String field) {
    if (value == null || value.trim().isEmpty) return 'Please enter your $field';
    if (value.trim().length < 2) return '$field must be at least 2 characters';
    return null;
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

  Widget _buildInitialView() {
    return Stack(
      children: [
        // Atmospheric background
        Positioned.fill(
          child: Container(
            color: surface,
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
                      color: primaryFixed.withValues(alpha: 0.15),
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
                      color: const Color(0xFFCFE6F2).withValues(alpha: 0.2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Main content
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(_outerPadding),
              child: Container(
                decoration: BoxDecoration(
                  color: surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(_cardRadius),
                  boxShadow: [
                    BoxShadow(
                      color: onSurface.withAlpha((0.04 * 255).toInt()),
                      blurRadius: 48,
                      spreadRadius: -4,
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: _isCompact ? 20 : 32, vertical: _isCompact ? 28 : 48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildAuthHeader('WellQueue', 'Your restorative care journey begins here.'),
                    SizedBox(height: _isCompact ? 26 : 40),
                    // Feature preview card
                    Container(
                      padding: EdgeInsets.all(_isCompact ? 18 : 24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment(0, -1),
                          end: Alignment(1, 1),
                          colors: [primary, primaryContainer],
                        ),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Real-time wait times',
                            style: TextStyle(
                              fontSize: _isCompact ? 13 : 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.hourglass_bottom, color: primary, size: 28),
                                const SizedBox(width: 12),
                                Text(
                                  'Approx. 4 mins',
                                  style: TextStyle(
                                    fontSize: _isCompact ? 19 : 22,
                                    fontWeight: FontWeight.w700,
                                    color: onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: _isCompact ? 26 : 40),
                    // Primary button with gradient
                    SizedBox(
                      height: _buttonHeight,
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
                                color: primary.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => _setAuthState(AuthState.signup),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: const Text(
                            'Get Started',
                              style: TextStyle(
                                fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Secondary button
                    TextButton(
                      onPressed: () => _setAuthState(AuthState.login),
                      child: const Text(
                        'Log In',
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
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignupView() {
    return Stack(
      children: [
        // Atmospheric background
        Positioned.fill(
          child: Container(
            color: surface,
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
                      color: primaryFixed.withValues(alpha: 0.15),
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
                      color: const Color(0xFFCFE6F2).withValues(alpha: 0.2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Main content
        Form(
          key: _formKey,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(_outerPadding),
                child: Container(
                  decoration: BoxDecoration(
                    color: surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(_cardRadius),
                    boxShadow: [
                      BoxShadow(
                        color: onSurface.withValues(alpha: 0.04),
                        blurRadius: 48,
                        spreadRadius: -4,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: _isCompact ? 20 : 32, vertical: _isCompact ? 28 : 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildAuthHeader('Create Account', 'Get started with just a few details.'),
                      TextFormField(
                        controller: _firstNameController,
                        decoration: _buildInputDecoration('First Name'),
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.givenName],
                        validator: (v) => _validateName(v, 'first name'),
                      ),
                      SizedBox(height: _isCompact ? 16 : 20),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: _buildInputDecoration('Last Name'),
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.familyName],
                        validator: (v) => _validateName(v, 'last name'),
                      ),
                      SizedBox(height: _isCompact ? 16 : 20),
                      TextFormField(
                        controller: _emailController,
                        decoration: _buildInputDecoration('Email Address'),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        validator: _validateEmail,
                      ),
                      SizedBox(height: _isCompact ? 16 : 20),
                      TextFormField(
                        controller: _passwordController,
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
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.newPassword],
                        enableSuggestions: false,
                        autocorrect: false,
                        onFieldSubmitted: (_) {
                          if (!_isLoading) {
                            _submitSignup();
                          }
                        },
                        validator: _validatePassword,
                      ),
                      SizedBox(height: _isCompact ? 24 : 32),
                      // Primary button
                      SizedBox(
                        height: _buttonHeight,
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
                                color: primary.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitSignup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              disabledBackgroundColor: Colors.grey[300],
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Create Account',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Secondary action
                      Center(
                        child: TextButton(
                          onPressed: () => _setAuthState(AuthState.login),
                          child: RichText(
                            text: const TextSpan(
                              text: "Already have an account? ",
                              style: TextStyle(color: secondary, fontSize: 14),
                              children: [
                                TextSpan(
                                  text: 'Log In',
                                  style: TextStyle(
                                    color: primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
    );
  }

  Widget _buildLoginView() {
    return Stack(
      children: [
        // Atmospheric background
        Positioned.fill(
          child: Container(
            color: surface,
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
                      color: primaryFixed.withValues(alpha: 0.15),
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
                      color: const Color(0xFFCFE6F2).withValues(alpha: 0.2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Main content
        Form(
          key: _formKey,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(_outerPadding),
                child: Container(
                  decoration: BoxDecoration(
                    color: surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(_cardRadius),
                    boxShadow: [
                      BoxShadow(
                        color: onSurface.withValues(alpha: 0.04),
                        blurRadius: 48,
                        spreadRadius: -4,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: _isCompact ? 20 : 32, vertical: _isCompact ? 28 : 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildAuthHeader('Welcome Back', 'Please log in to continue.'),
                      TextFormField(
                        controller: _emailController,
                        decoration: _buildInputDecoration('Email Address'),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        validator: _validateEmail,
                      ),
                      SizedBox(height: _isCompact ? 16 : 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _passwordController,
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
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.password],
                              enableSuggestions: false,
                              autocorrect: false,
                              onFieldSubmitted: (_) {
                                if (!_isLoading) {
                                  _submitLogin();
                                }
                              },
                              validator: _validatePassword,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: _isCompact ? 16 : 20),
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
                                color: primary.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              disabledBackgroundColor: Colors.grey[300],
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Log In',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(height: _isCompact ? 20 : 24),
                      Center(
                        child: TextButton(
                          onPressed: () => _setAuthState(AuthState.signup),
                          child: RichText(
                            text: const TextSpan(
                              text: 'New to WellQueue? ',
                              style: TextStyle(color: secondary, fontSize: 14),
                              children: [
                                TextSpan(
                                  text: 'Create an account',
                                  style: TextStyle(
                                    color: primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surface,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: KeyedSubtree(
            key: ValueKey(_authState),
            child: switch (_authState) {
              AuthState.initial => _buildInitialView(),
              AuthState.signup => _buildSignupView(),
              AuthState.login => _buildLoginView(),
            },
          ),
        ),
      ),
    );
  }
}
