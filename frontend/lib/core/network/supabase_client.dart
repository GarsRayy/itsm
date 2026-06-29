import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase client initialization and accessor.
///
/// Call [SupabaseConfig.initialize] once in `main()` before `runApp()`.
/// Access the client instance via [SupabaseConfig.client].
abstract final class SupabaseConfig {
  static const String _supabaseUrl = 'https://fbgziyguyhlpadqtokjv.supabase.co';
  static const String _supabaseAnonKey = 'sb_publishable_8IybeypENbDfl4UvhZ88jA_K853YWgm';

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
