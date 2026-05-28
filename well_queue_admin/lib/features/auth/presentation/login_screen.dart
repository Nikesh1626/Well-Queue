import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
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

  bool get _isCompact => MediaQuery.sizeOf(context).width < 390;

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
    
    final auth = context.read<AdminAuthServiceBase>();
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
    final auth = context.watch<AdminAuthServiceBase>();
    
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
                padding: EdgeInsets.all(_isCompact ? 16 : 24),
                child: Form(
                  key: _formKey,
                  child: Container(
                    decoration: BoxDecoration(
                      color: surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(_isCompact ? 24 : 32),
                      boxShadow: [
                        BoxShadow(
                          color: onSurface.withAlpha((0.04 * 255).toInt()),
                          blurRadius: 48,
                          spreadRadius: -4,
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(horizontal: _isCompact ? 20 : 32, vertical: _isCompact ? 30 : 48),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Brand header
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
                          'WellQueue Admin',
                          style: TextStyle(
                            fontSize: _isCompact ? 24 : 28,
                            fontWeight: FontWeight.w800,
                            color: onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Clinic Administration Portal',
                          style: TextStyle(
                            fontSize: _isCompact ? 14 : 16,
                            color: secondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: _isCompact ? 24 : 32),
                        // Email field
                        TextFormField(
                          controller: _email,
                          decoration: _buildInputDecoration('Email Address'),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          validator: _validateEmail,
                        ),
                        SizedBox(height: _isCompact ? 16 : 20),
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
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          enableSuggestions: false,
                          autocorrect: false,
                          onFieldSubmitted: (_) {
                            if (!auth.loading) {
                              _submit();
                            }
                          },
                          validator: _validatePassword,
                        ),
                        SizedBox(height: _isCompact ? 12 : 16),
                        // Remember device checkbox
                        SizedBox(
                          height: _isCompact ? 34 : 36,
                          child: CheckboxListTile(
                            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                            contentPadding: EdgeInsets.zero,
                            value: _rememberDevice,
                            onChanged: (v) => setState(() => _rememberDevice = v ?? true),
                            title: Text(
                              'Remember this device for 30 days',
                              style: TextStyle(
                                fontSize: _isCompact ? 13 : 14,
                                color: onSurface,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: _isCompact ? 20 : 24),
                        // Primary button
                        SizedBox(
                          height: _isCompact ? 52 : 56,
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
                            child: Semantics(
                              button: true,
                              label: 'Sign in to admin account',
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
                        ),
                        SizedBox(height: _isCompact ? 20 : 24),
                        // Footer message
                        Center(
                          child: Column(
                            children: [
                              Text(
                                'New to WellQueue Administration?',
                                style: TextStyle(
                                  fontSize: _isCompact ? 13 : 14,
                                  color: secondary,
                                ),
                              ),
                              SizedBox(height: _isCompact ? 10 : 12),
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
  final _latitude = TextEditingController();
  final _longitude = TextEditingController();
  final _clinicEmail = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _detectingLocation = false;
  bool _geocodingAddress = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  bool get _isCompact => MediaQuery.sizeOf(context).width < 390;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _clinicName.dispose();
    _clinicAddress.dispose();
    _latitude.dispose();
    _longitude.dispose();
    _clinicEmail.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  String? _validateCoordinate(String? value, double min, double max, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    final parsed = double.tryParse(value.trim());
    if (parsed == null) return 'Enter a valid $label';
    if (parsed < min || parsed > max) return '$label must be between $min and $max';
    return null;
  }

  Future<void> _detectLocation() async {
    setState(() => _detectingLocation = true);
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enable location services and try again.')),
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied.')),
        );
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _latitude.text = pos.latitude.toStringAsFixed(6);
      _longitude.text = pos.longitude.toStringAsFixed(6);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to detect location: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _detectingLocation = false);
      }
    }
  }

  Future<void> _geocodeAddress() async {
    final address = _clinicAddress.text.trim();
    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter clinic address to locate.')),
      );
      return;
    }

    setState(() => _geocodingAddress = true);
    try {
      final locations = await locationFromAddress(address);
      if (locations.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to locate this address.')),
        );
        return;
      }

      final location = locations.first;
      _latitude.text = location.latitude.toStringAsFixed(6);
      _longitude.text = location.longitude.toStringAsFixed(6);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to locate address: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _geocodingAddress = false);
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final latitude = double.tryParse(_latitude.text.trim());
    final longitude = double.tryParse(_longitude.text.trim());
    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a valid clinic location.')),
      );
      return;
    }

    final auth = context.read<AdminAuthServiceBase>();
    final ok = await auth.createAdminProfile(
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      clinicName: _clinicName.text.trim(),
      clinicAddress: _clinicAddress.text.trim(),
      latitude: latitude,
      longitude: longitude,
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
    final auth = context.watch<AdminAuthServiceBase>();
    return Scaffold(
      appBar: AppBar(title: const Text('Create Admin Profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(_isCompact ? 12 : 16),
          children: [
            Container(
              padding: EdgeInsets.all(_isCompact ? 14 : 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(_isCompact ? 16 : 20),
                border: Border.all(color: const Color(0xFFE3ECEB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Create clinic admin account', style: TextStyle(fontSize: _isCompact ? 16 : 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('Fill profile, clinic details, and location to complete onboarding.'),
                ],
              ),
            ),
            SizedBox(height: _isCompact ? 12 : 14),
            const Text('Owner Details', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _firstName,
              decoration: const InputDecoration(labelText: 'First Name'),
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.givenName],
              validator: (v) => (v == null || v.trim().isEmpty) ? 'First name is required' : null,
            ),
            SizedBox(height: _isCompact ? 10 : 12),
            TextFormField(
              controller: _lastName,
              decoration: const InputDecoration(labelText: 'Last Name'),
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.familyName],
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Last name is required' : null,
            ),
            SizedBox(height: _isCompact ? 10 : 12),
            const Text('Clinic Details', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _clinicName,
              decoration: const InputDecoration(labelText: 'Clinic Name'),
              textInputAction: TextInputAction.next,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Clinic name is required' : null,
            ),
            SizedBox(height: _isCompact ? 10 : 12),
            TextFormField(
              controller: _clinicAddress,
              decoration: const InputDecoration(labelText: 'Clinic Address'),
              textInputAction: TextInputAction.next,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Clinic address is required' : null,
            ),
            SizedBox(height: _isCompact ? 10 : 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Clinic Location',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: _isCompact ? 13 : 14),
                ),
                Wrap(
                  spacing: _isCompact ? 4 : 8,
                  children: [
                    TextButton.icon(
                      onPressed: _detectingLocation ? null : _detectLocation,
                      icon: const Icon(Icons.my_location, size: 18),
                      label: Text(_detectingLocation ? 'Detecting...' : 'Use GPS'),
                    ),
                    TextButton.icon(
                      onPressed: _geocodingAddress ? null : _geocodeAddress,
                      icon: const Icon(Icons.map_outlined, size: 18),
                      label: Text(_geocodingAddress ? 'Locating...' : 'From Address'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _latitude,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              decoration: const InputDecoration(labelText: 'Latitude'),
              textInputAction: TextInputAction.next,
              validator: (v) => _validateCoordinate(v, -90, 90, 'Latitude'),
            ),
            SizedBox(height: _isCompact ? 10 : 12),
            TextFormField(
              controller: _longitude,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              decoration: const InputDecoration(labelText: 'Longitude'),
              textInputAction: TextInputAction.next,
              validator: (v) => _validateCoordinate(v, -180, 180, 'Longitude'),
            ),
            SizedBox(height: _isCompact ? 10 : 12),
            TextFormField(
              controller: _clinicEmail,
              decoration: const InputDecoration(labelText: 'Clinic Email'),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required';
                final okEmail = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim());
                return okEmail ? null : 'Please enter a valid email';
              },
            ),
            SizedBox(height: _isCompact ? 10 : 12),
            TextFormField(
              controller: _password,
              obscureText: !_showPassword,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              enableSuggestions: false,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _showPassword = !_showPassword),
                  icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                ),
              ),
              validator: (v) => (v == null || v.length < 6) ? 'Password must be at least 6 characters' : null,
            ),
            SizedBox(height: _isCompact ? 10 : 12),
            TextFormField(
              controller: _confirmPassword,
              obscureText: !_showConfirmPassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              enableSuggestions: false,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                  icon: Icon(_showConfirmPassword ? Icons.visibility : Icons.visibility_off),
                ),
              ),
              onFieldSubmitted: (_) {
                if (!auth.loading) {
                  _submit();
                }
              },
              validator: (v) => v != _password.text ? 'Passwords do not match' : null,
            ),
            SizedBox(height: _isCompact ? 16 : 20),
            Semantics(
              button: true,
              label: 'Create admin account',
              child: ElevatedButton(
                onPressed: auth.loading ? null : _submit,
                style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(_isCompact ? 48 : 52)),
                child: Text(auth.loading ? 'Creating...' : 'Create Admin Account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
