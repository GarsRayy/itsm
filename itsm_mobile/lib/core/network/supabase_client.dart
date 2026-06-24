import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase client initialization and accessor.
///
/// Call [SupabaseConfig.initialize] once in `main()` before `runApp()`.
/// Access the client instance via [SupabaseConfig.client].
abstract final class SupabaseConfig {
  // TODO: Replace with your actual Supabase project credentials.
  static const String _supabaseUrl = 'https://YOUR_PROJECT_ID.supabase.co';
  static const String _supabaseAnonKey = 'YOUR_ANON_KEY';

  /// Initialize the Supabase SDK. Must be called before any Supabase usage.
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      publishableKey: _supabaseAnonKey,
    );
  }

  /// The singleton Supabase client instance.
  static SupabaseClient get client => Supabase.instance.client;
}
