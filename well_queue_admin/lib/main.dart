import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/supabase_config.dart';
import 'core/services/auth_service.dart';
import 'core/theme/admin_theme.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminAuthService()..initialize(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'WellQueue Clinic Admin',
        theme: AdminTheme.light,
        home: const _AdminRouter(),
      ),
    );
  }
}

class _AdminRouter extends StatelessWidget {
  const _AdminRouter();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AdminAuthService>();
    if (!auth.isAuthenticated) return const AdminLoginScreen();
    return const AdminDashboardScreen();
  }
}
