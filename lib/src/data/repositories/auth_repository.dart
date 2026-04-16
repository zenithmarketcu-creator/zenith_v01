// lib/src/data/repositories/auth_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../datasources/supabase_client.dart';
import '../models/user_model.dart';

class AuthRepository {
  final _client = SupabaseService.client;

  // ─── Sign Up ────────────────────────────────────────────────
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );

    if (res.user == null) {
      throw Exception('Sign up failed: no user returned');
    }

    // Profile is created automatically via trigger.
    // Fetch to return complete profile.
    await Future.delayed(const Duration(milliseconds: 500));
    return _fetchProfile(res.user!.id, email);
  }

  // ─── Sign In ────────────────────────────────────────────────
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final res = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (res.user == null) {
      throw Exception('Sign in failed: invalid credentials');
    }

    return _fetchProfile(res.user!.id, email);
  }

  // ─── Sign Out ───────────────────────────────────────────────
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // ─── Current Session ────────────────────────────────────────
  Future<UserModel?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return _fetchProfile(user.id, user.email ?? '');
  }

  // ─── Update Address ─────────────────────────────────────────
  Future<void> updateAddress({required String address}) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    await _client
        .from('profiles')
        .update({'address': address}).eq('id', userId);
  }

  // ─── Stream auth state changes ──────────────────────────────
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // ─── Private helpers ────────────────────────────────────────
  Future<UserModel> _fetchProfile(String userId, String email) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle(); // Cambia .single() por .maybeSingle()

    if (data == null) {
      // Si no existe el perfil, podrías crear uno básico o lanzar un error controlado
      throw Exception('No se encontró el perfil del usuario');
    }

    return UserModel.fromMap({...data, 'email': email});
  }
}
