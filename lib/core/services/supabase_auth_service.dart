import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase authentication service for Zenslam
/// Replaces Firebase Auth + custom API auth flow
class SupabaseAuthService {
  static SupabaseClient get _client => Supabase.instance.client;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static bool _isGoogleInitialized = false;

  // ─── Email/Password Auth ─────────────────────────────────────────────────

  /// Register with email and password
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: name != null ? {'full_name': name} : null,
    );
    if (response.user != null && name != null) {
      await _client.from('profiles').upsert({
        'id': response.user!.id,
        'full_name': name,
        'email': email,
      });
    }
    return response;
  }

  /// Sign in with email and password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Send password reset email
  static Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  /// Update password (after reset or from settings)
  static Future<UserResponse> updatePassword(String newPassword) async {
    return await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  // ─── Google Sign-In ──────────────────────────────────────────────────────

  /// Initialize Google Sign-In
  static Future<void> _initializeGoogle() async {
    if (!_isGoogleInitialized) {
      await _googleSignIn.initialize(
        serverClientId:
            '423369939213-dng2io3om413t78kc12cub5ng0q6d74b.apps.googleusercontent.com',
      );
      _isGoogleInitialized = true;
    }
  }

  /// Sign in with Google via Supabase
  static Future<AuthResponse> signInWithGoogle() async {
    try {
      debugPrint('Starting Google Sign-In flow...');
      await _initializeGoogle();
      await _googleSignIn.signOut();

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw Exception('No ID token received from Google');
      }

      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
      );

      if (response.user != null) {
        await _client.from('profiles').upsert({
          'id': response.user!.id,
          'full_name': googleUser.displayName ?? 'User',
          'email': googleUser.email,
          'avatar_url': googleUser.photoUrl,
        });
      }

      debugPrint('Google Sign-In successful: ${googleUser.email}');
      return response;
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      rethrow;
    }
  }

  // ─── Session Management ──────────────────────────────────────────────────

  /// Get current user
  static User? get currentUser => _client.auth.currentUser;

  /// Get current session
  static Session? get currentSession => _client.auth.currentSession;

  /// Check if user is signed in
  static bool get isSignedIn => _client.auth.currentUser != null;

  /// Get access token
  static String? get accessToken => _client.auth.currentSession?.accessToken;

  /// Sign out
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _client.auth.signOut();
    debugPrint('Signed out');
  }

  /// Listen to auth state changes
  static Stream<AuthState> get onAuthStateChange =>
      _client.auth.onAuthStateChange;

  // ─── Profile Management ──────────────────────────────────────────────────

  /// Get user profile from profiles table
  static Future<Map<String, dynamic>?> getProfile() async {
    final user = currentUser;
    if (user == null) return null;

    final data = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();
    return data;
  }

  /// Update user profile
  static Future<void> updateProfile(Map<String, dynamic> updates) async {
    final user = currentUser;
    if (user == null) throw Exception('Not authenticated');

    await _client.from('profiles').update(updates).eq('id', user.id);
  }

  /// Delete account
  static Future<void> deleteAccount() async {
    final user = currentUser;
    if (user == null) throw Exception('Not authenticated');

    // Delete profile data first
    await _client.from('profiles').delete().eq('id', user.id);
    await _client.from('favorites').delete().eq('user_id', user.id);
    await _client.from('user_preferences').delete().eq('user_id', user.id);

    // Sign out (account deletion requires admin/server-side action)
    await signOut();
  }
}
