import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GoogleSignInService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static SupabaseClient get _supabase => Supabase.instance.client;

  static bool _isInitialized = false;

  /// Initialize Google Sign-In with serverClientId
  static Future<void> initialize() async {
    try {
      if (!_isInitialized) {
        await _googleSignIn.initialize(
          serverClientId:
              '423369939213-dng2io3om413t78kc12cub5ng0q6d74b.apps.googleusercontent.com',
        );
        _isInitialized = true;
        debugPrint('Google Sign-In initialized with serverClientId');
      }
    } catch (e) {
      debugPrint('Google Sign-In initialization error: $e');
      rethrow;
    }
  }

  /// Perform Google Sign-In and return user data via Supabase
  static Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      debugPrint('Starting Google Sign-In flow...');

      await initialize();
      await _googleSignIn.signOut();

      debugPrint('Triggering Google Sign-In UI...');
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      debugPrint('Google user obtained: ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      debugPrint('Google auth obtained - idToken: ${googleAuth.idToken != null}');

      if (googleAuth.idToken == null) {
        throw Exception('No ID token received from Google');
      }

      // Sign in to Supabase with Google ID token
      debugPrint('Signing in to Supabase...');
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
      );

      final user = response.user;
      if (user == null) {
        debugPrint('Supabase user is null after sign-in');
        throw Exception('Failed to get user information from Supabase');
      }

      final String name = googleUser.displayName ?? 'User';
      final String email = googleUser.email;
      final String? photoUrl = googleUser.photoUrl;

      debugPrint('User details - Name: $name, Email: $email');

      // Upsert profile in Supabase
      await _supabase.from('profiles').upsert({
        'id': user.id,
        'full_name': name,
        'email': email,
        'avatar_url': photoUrl,
      });

      return {
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'userId': user.id,
        'googleUser': googleUser,
      };
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      rethrow;
    }
  }

  /// Check if user is currently signed in
  static Future<bool> isSignedIn() async {
    return _supabase.auth.currentUser != null;
  }

  /// Get current user data if signed in
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) return null;

    return {
      'name': currentUser.userMetadata?['full_name'],
      'email': currentUser.email,
      'photoUrl': currentUser.userMetadata?['avatar_url'],
      'id': currentUser.id,
    };
  }

  /// Sign out from Google and Supabase
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _supabase.auth.signOut();
      debugPrint('Signed out from Google and Supabase');
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }

  /// Disconnect user from app (revokes all permissions)
  static Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
      debugPrint('Disconnected from Google');
    } catch (e) {
      debugPrint('Error disconnecting: $e');
      rethrow;
    }
  }
}
