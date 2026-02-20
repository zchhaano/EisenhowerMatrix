import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../../auth/domain/entities/auth_user.dart' as local;
import '../../../auth/domain/repositories/auth_repository.dart';

/// Supabase implementation of [AuthRepository].
///
/// Handles authentication operations using Supabase backend.
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._supabase);

  final supabase.SupabaseClient _supabase;

  @override
  local.AuthUser? get currentUser {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    return local.AuthUser(
      id: user.id,
      email: user.email,
      displayName: user.userMetadata?['display_name'] as String?,
      photoUrl: user.userMetadata?['avatar_url'] as String?,
      emailVerified: user.emailConfirmedAt != null,
      providers: user.appMetadata['providers'] != null
          ? List<String>.from(user.appMetadata['providers'] as List)
          : [],
    );
  }

  @override
  Stream<local.AuthUser?> get authStateChanges {
    return _supabase.auth.onAuthStateChange.map((state) {
      final user = state.session?.user;
      if (user == null) return null;
      return local.AuthUser(
        id: user.id,
        email: user.email,
        displayName: user.userMetadata?['display_name'] as String?,
        photoUrl: user.userMetadata?['avatar_url'] as String?,
        emailVerified: user.emailConfirmedAt != null,
      );
    });
  }

  @override
  Future<local.AuthUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw AuthException('Sign in failed', 'No user returned');
    }

    return local.AuthUser(
      id: user.id,
      email: user.email,
      displayName: user.userMetadata?['display_name'] as String?,
      photoUrl: user.userMetadata?['avatar_url'] as String?,
      emailVerified: user.emailConfirmedAt != null,
    );
  }

  @override
  Future<local.AuthUser> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        if (displayName != null) 'display_name': displayName,
      },
    );

    final user = response.user;
    if (user == null) {
      throw AuthException('Sign up failed', 'No user returned');
    }

    return local.AuthUser(
      id: user.id,
      email: user.email,
      displayName: displayName,
      photoUrl: user.userMetadata?['avatar_url'] as String?,
      emailVerified: user.emailConfirmedAt != null,
    );
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    await _supabase.auth.updateUser(
      supabase.UserAttributes(password: newPassword),
    );
  }

  @override
  Future<local.AuthUser> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        supabase.OAuthProvider.google,
      );
      // OAuth is async, user will be available in the stream
      final user = currentUser;
      if (user == null) {
        throw AuthException('Google Sign In', 'User not available');
      }
      return user;
    } catch (e) {
      throw AuthException('Google Sign In', e.toString());
    }
  }

  @override
  Future<local.AuthUser> signInWithApple() async {
    try {
      await _supabase.auth.signInWithOAuth(
        supabase.OAuthProvider.apple,
      );
      final user = currentUser;
      if (user == null) {
        throw AuthException('Apple Sign In', 'User not available');
      }
      return user;
    } catch (e) {
      throw AuthException('Apple Sign In', e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  @override
  Future<void> updateDisplayName(String displayName) async {
    await _supabase.auth.updateUser(
      supabase.UserAttributes(data: {'display_name': displayName}),
    );
  }
}

/// Custom auth exception for user-friendly error messages.
class AuthException implements Exception {
  AuthException(this.message, [this.details]);

  final String message;
  final String? details;

  @override
  String toString() => 'AuthException: $message${details != null ? ' - $details' : ''}';
}
