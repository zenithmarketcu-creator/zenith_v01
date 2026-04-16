// lib/src/data/datasources/supabase_client.dart
import 'package:supabase_flutter/supabase_flutter.dart';

/// Single access point to the Supabase client.
/// Usage: SupabaseService.client
class SupabaseService {
  SupabaseService._();

  static SupabaseClient get client => Supabase.instance.client;

  static User? get currentUser => client.auth.currentUser;

  static String? get currentUserId => client.auth.currentUser?.id;

  static bool get isLoggedIn => client.auth.currentUser != null;

  /// Storage URL helper
  static String storageUrl(String bucket, String path) {
    return client.storage.from(bucket).getPublicUrl(path);
  }
}
