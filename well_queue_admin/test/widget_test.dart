// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:well_queue_admin/core/services/auth_service.dart';
import 'package:well_queue_admin/features/auth/presentation/login_screen.dart';

class _FakeAdminAuthService extends ChangeNotifier implements AdminAuthServiceBase {
  @override
  bool get loading => false;

  @override
  bool get initializing => false;

  @override
  String? get error => null;

  @override
  Map<String, dynamic>? get profile => null;

  @override
  String? get clinicId => null;

  @override
  bool get isAuthenticated => false;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> signIn(String email, String password, {required bool rememberDevice}) async {
    return false;
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<void> loadProfile() async {}

  @override
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
    return false;
  }
}

void main() {
  testWidgets('Admin app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AdminAuthServiceBase>.value(
        value: _FakeAdminAuthService(),
        child: const MaterialApp(home: AdminLoginScreen()),
      ),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
