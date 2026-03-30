import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart';
import '../constants/supabase_schema.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  AppUser? _currentUser;
  bool _isLoading = false;
  String? _error;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => currentUser != null;

  /// Initialize auth service by checking if user is already logged in
  Future<void> initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      final session = _supabase.auth.currentSession;
      if (session != null) {
        await _loadUserProfile(session.user.id);
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Auth initialization error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign up with email and password
  Future<bool> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Sign up user with Supabase Auth
      final AuthResponse res = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (res.user != null) {
        // Create user profile in users table
        await _createUserProfile(
          userId: res.user!.id,
          email: email,
          firstName: firstName,
          lastName: lastName,
        );

        // Load the user profile
        await _loadUserProfile(res.user!.id);
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      debugPrint('Sign up error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final AuthResponse res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.session != null) {
        await _loadUserProfile(res.user!.id);
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      debugPrint('Sign in error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabase.auth.signOut();
      _currentUser = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Sign out error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    String? phone,
    int? age,
  }) async {
    if (_currentUser == null) {
      _error = 'No user logged in';
      return false;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _supabase.from(SupabaseSchema.usersTable).update(
        {
          SupabaseSchema.userFirstName: firstName,
          SupabaseSchema.userLastName: lastName,
          if (phone != null) SupabaseSchema.userPhone: phone,
          if (age != null) SupabaseSchema.userAge: age,
          SupabaseSchema.userUpdatedAt: DateTime.now().toIso8601String(),
        },
      ).eq(SupabaseSchema.userId, _currentUser!.id);

      // Reload user profile
      await _loadUserProfile(_currentUser!.id);
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Update profile error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create user profile in the users table
  Future<void> _createUserProfile({
    required String userId,
    required String email,
    required String firstName,
    required String lastName,
  }) async {
    try {
      await _supabase.from(SupabaseSchema.usersTable).insert(
        {
          SupabaseSchema.userId: userId,
          SupabaseSchema.userEmail: email,
          SupabaseSchema.userFirstName: firstName,
          SupabaseSchema.userLastName: lastName,
          SupabaseSchema.userRole: SupabaseSchema.roleUser,
          SupabaseSchema.userCreatedAt: DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint('Error creating user profile: $e');
      // If the user already exists, that's fine
    }
  }

  /// Load user profile from database
  Future<void> _loadUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from(SupabaseSchema.usersTable)
          .select()
          .eq(SupabaseSchema.userId, userId)
          .single();

      _currentUser = AppUser.fromJson(response);
      debugPrint('User profile loaded: ${_currentUser?.fullName}');
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      // Create a basic user if profile doesn't exist
      final authUser = _supabase.auth.currentUser;
      if (authUser != null) {
        await _createUserProfile(
          userId: authUser.id,
          email: authUser.email ?? '',
          firstName: authUser.email?.split('@').first ?? 'User',
          lastName: '',
        );
        await _loadUserProfile(userId);
      }
    }
  }

  /// Password reset
  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _supabase.auth.resetPasswordForEmail(email);
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Password reset error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update password
  Future<bool> updatePassword(String newPassword) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Update password error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
