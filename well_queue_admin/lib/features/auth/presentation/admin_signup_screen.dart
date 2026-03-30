import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../../core/services/auth_service.dart';

class AdminSignupScreen extends StatefulWidget {
  const AdminSignupScreen({super.key});

  @override
  State<AdminSignupScreen> createState() => _AdminSignupScreenState();
}

class _AdminSignupScreenState extends State<AdminSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _clinicName = TextEditingController();
  final _clinicAddress = TextEditingController();
  final _clinicEmail = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  double? _latitude;
  double? _longitude;
  bool _fetchingLocation = false;

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

  Future<void> _detectLocation() async {
    setState(() => _fetchingLocation = true);
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        await Geolocator.openLocationSettings();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enable location service and try again.')),
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
        desiredAccuracy: LocationAccuracy.best,
      );

      if (!mounted) return;
      setState(() {
        _latitude = pos.latitude;
        _longitude = pos.longitude;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Location captured: ${pos.latitude.toStringAsFixed(6)}, ${pos.longitude.toStringAsFixed(6)}',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get location: $e')),
      );
    } finally {
      if (mounted) setState(() => _fetchingLocation = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture precise clinic location.')),
      );
      return;
    }

    final auth = context.read<AdminAuthService>();
    final ok = await auth.createAdminProfile(
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      clinicName: _clinicName.text.trim(),
      clinicAddress: _clinicAddress.text.trim(),
      latitude: _latitude!,
      longitude: _longitude!,
      clinicEmail: _clinicEmail.text.trim(),
      password: _password.text,
    );

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin profile created. Please sign in with email/password.')),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Failed to create admin profile')),
      );
    }
  }

  String? _required(String? v, String field) {
    if (v == null || v.trim().isEmpty) return '$field is required';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AdminAuthService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Create Admin Profile')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                TextFormField(
                  controller: _firstName,
                  decoration: const InputDecoration(labelText: 'First Name'),
                  validator: (v) => _required(v, 'First name'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _lastName,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                  validator: (v) => _required(v, 'Last name'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _clinicName,
                  decoration: const InputDecoration(labelText: 'Clinic Name'),
                  validator: (v) => _required(v, 'Clinic name'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _clinicAddress,
                  decoration: const InputDecoration(labelText: 'Clinic Address'),
                  validator: (v) => _required(v, 'Clinic address'),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.teal.shade200),
                    color: Colors.teal.shade50,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Location', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _fetchingLocation ? null : _detectLocation,
                        icon: const Icon(Icons.my_location),
                        label: Text(_fetchingLocation
                            ? 'Detecting...'
                            : 'Detect precise location'),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _latitude == null
                            ? 'No location captured yet.'
                            : 'Captured: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}\nThis exact point will appear as clinic pin in user app map.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _clinicEmail,
                  decoration: const InputDecoration(labelText: 'Clinic Admin Email'),
                  validator: (v) => _required(v, 'Clinic email'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) return 'Password must be at least 6 chars';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirmPassword,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Confirm Password'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Confirm password is required';
                    if (v != _password.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: auth.loading ? null : _submit,
                  child: auth.loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Create Admin Profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
