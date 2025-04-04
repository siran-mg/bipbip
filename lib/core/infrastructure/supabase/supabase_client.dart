import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Initializes Supabase client
class SupabaseClientInitializer {
  /// Initialize Supabase
  static Future<void> initialize() async {
    await supabase.Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );
  }

  /// Get the Supabase client instance
  static supabase.SupabaseClient get instance =>
      supabase.Supabase.instance.client;
}
