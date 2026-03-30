import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase initialization and configuration
/// This should be called in main.dart before runApp()
class SupabaseConfig {
  // TODO: Replace with your actual Supabase credentials
  static const String supabaseUrl = 'https://btfqhxqfwgbbicmlwfjn.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ0ZnFoeHFmd2diYmljbWx3ZmpuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ4NTMxMzgsImV4cCI6MjA5MDQyOTEzOH0.koFrGjfvGk5na5vlded9Y5g6K8YYUfVEXjy0x3Iuzrk';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => client.auth;
  static RealtimeClient get realtime => client.realtime;
}
