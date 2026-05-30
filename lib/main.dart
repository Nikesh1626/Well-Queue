import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/supabase_config.dart';
import 'core/services/auth_service.dart';
import 'core/services/queue_service.dart';
import 'core/services/clinic_service.dart';
import 'core/services/geofencing_service.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/auth/presentation/auth_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/location_access/presentation/location_access_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Supabase
    await SupabaseConfig.initialize();
    debugPrint('Supabase initialized successfully');
  } catch (e) {
    debugPrint('Error initializing Supabase: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Service
        ChangeNotifierProvider(create: (_) => AuthService()),
        // Queue Service
        ChangeNotifierProvider(create: (_) => QueueService()),
        // Clinic Service
        ChangeNotifierProvider(create: (_) => ClinicService()),
        // Geofencing Service
        ChangeNotifierProvider(create: (_) => GeofencingService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'WellQueue',
        theme: AppTheme.light,
        home: const _AppRouter(),
      ),
    );
  }
}

/// Main router that handles navigation based on auth state.
class _AppRouter extends StatefulWidget {
  const _AppRouter();

  @override
  State<_AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<_AppRouter> {
  bool? _seenOnboarding;
  @override
  void initState() {
    super.initState();
    // Initialize auth service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthService>().initialize();
    });
    // Load persistent onboarding flag
    () async {
      final prefs = await SharedPreferences.getInstance();
      final seen = prefs.getBool('seen_onboarding') ?? false;
      setState(() => _seenOnboarding = seen);
    }();
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    // Show loading screen while initializing
    if (authService.isLoading && authService.currentUser == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // No user logged in - show onboarding first unless already seen
    if (authService.currentUser == null) {
      if (_seenOnboarding == null) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return _seenOnboarding! ? const AuthScreen() : const OnboardingScreen();
    }

    return const LocationAccessScreen();
  }
}
