import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminAuthService extends ChangeNotifier {
  final _client = Supabase.instance.client;
  static const _rememberKey = 'remember_device_30_days';
  static const _rememberAtKey = 'remember_device_at';

  bool _loading = false;
  bool _initializing = true;
  String? _error;
  Map<String, dynamic>? _profile;

  bool get loading => _loading;
  bool get initializing => _initializing;
  String? get error => _error;
  User? get user => _client.auth.currentUser;
  Map<String, dynamic>? get profile => _profile;
  bool get isAuthenticated => user != null;

  Future<void> initialize() async {
    try {
      if (user != null) {
        await _enforceRememberPolicy();
        if (user != null) {
          await loadProfile();
          if (!isProfileAdmin()) {
            await signOut();
            _error = 'This account is not authorized for clinic admin app.';
          }
        }
      }
    } finally {
      _initializing = false;
      notifyListeners();
    }
  }

  Future<bool> signIn(
    String email,
    String password, {
    required bool rememberDevice,
  }) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      await _client.auth.signInWithPassword(email: email, password: password);
      await loadProfile();

      if (!isProfileAdmin()) {
        await _client.auth.signOut();
        _error = 'This account is not authorized for clinic admin app.';
        notifyListeners();
        return false;
      }

      await _setRememberPolicy(rememberDevice);

      return true;
    } catch (e) {
      _error = _mapAuthError(e);
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  bool isProfileAdmin() {
    final role = (_profile?['role'] as String?) ?? '';
    return ['admin', 'super_admin', 'clinic_manager'].contains(role);
  }

  Future<void> loadProfile() async {
    final uid = user?.id;
    if (uid == null) return;

    final row = await _client.from('users').select().eq('id', uid).maybeSingle();
    _profile = row;
    notifyListeners();
  }

  Future<bool> createAdminProfile({
    required String firstName,
    required String lastName,
    required String clinicName,
    required String clinicAddress,
    required double latitude,
    required double longitude,
    required String clinicEmail,
    required String password,
  }) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      final signUpRes = await _client.auth.signUp(
        email: clinicEmail,
        password: password,
      );

      final uid = signUpRes.user?.id;
      if (uid == null) {
        _error = 'Unable to create admin auth account.';
        return false;
      }

      await _client.from('users').upsert({
        'id': uid,
        'email': clinicEmail,
        'first_name': firstName,
        'last_name': lastName,
        'role': 'admin',
        'created_at': DateTime.now().toIso8601String(),
      });

      final clinicInsert = await _client
          .from('clinics')
          .insert({
            'name': clinicName,
            'address': clinicAddress,
            'latitude': latitude,
            'longitude': longitude,
            'wait_time_minutes': 0,
            'rating': 0,
            'services': <String>[],
            'email': clinicEmail,
            'admin_id': uid,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select('id')
          .single();

      final clinicId = clinicInsert['id'];
      if (clinicId != null) {
        try {
          await _client.from('admin_users').insert({
            'user_id': uid,
            'clinic_id': clinicId,
            'role': 'manager',
            'created_at': DateTime.now().toIso8601String(),
          });
        } catch (_) {
          // Optional mapping insert; continue even if this table policy is stricter.
        }
      }

      // Enforce explicit sign-in by email/password after signup as requested.
      await signOut();
      return true;
    } catch (e) {
      _error = _mapAuthError(e);
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _setRememberPolicy(bool rememberDevice) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberKey, rememberDevice);
    await prefs.setString(_rememberAtKey, DateTime.now().toIso8601String());
  }

  Future<void> _enforceRememberPolicy() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool(_rememberKey) ?? false;
    final rememberAtRaw = prefs.getString(_rememberAtKey);

    if (!remember) {
      await signOut();
      return;
    }

    if (rememberAtRaw == null) {
      await signOut();
      return;
    }

    final rememberAt = DateTime.tryParse(rememberAtRaw);
    if (rememberAt == null) {
      await signOut();
      return;
    }

    final diff = DateTime.now().difference(rememberAt);
    if (diff > const Duration(days: 30)) {
      await signOut();
      _error = 'Session expired. Please sign in again.';
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_rememberKey);
    await prefs.remove(_rememberAtKey);
    _profile = null;
    notifyListeners();
  }

  String _mapAuthError(Object error) {
    if (error is AuthException) {
      if (error.statusCode == '429') {
        return 'Too many signup/login attempts. Supabase email rate limit reached. Please wait and try again, or increase Auth rate limits in Supabase dashboard for development.';
      }
      if (error.message.isNotEmpty) {
        return error.message;
      }
    }
    return error.toString();
  }
}
