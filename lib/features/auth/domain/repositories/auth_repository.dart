import '../entities/auth_user.dart';

/// Authentication repository interface.
///
/// Abstract contract for authentication operations.
/// Implemented by data layer repositories (e.g., Supabase).
abstract class AuthRepository {
  /// Currently authenticated user, or null if not signed in.
  AuthUser? get currentUser;

  /// Stream of authentication state changes.
  Stream<AuthUser?> get authStateChanges;

  /// Sign in with email and password.
  Future<AuthUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Create a new account with email and password.
  Future<AuthUser> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  });

  /// Send password reset email to the user.
  Future<void> sendPasswordResetEmail(String email);

  /// Update the user's password.
  Future<void> updatePassword(String newPassword);

  /// Sign in with Google OAuth.
  Future<AuthUser> signInWithGoogle();

  /// Sign in with Apple OAuth.
  Future<AuthUser> signInWithApple();

  /// Sign out the current user.
  Future<void> signOut();

  /// Update the user's display name.
  Future<void> updateDisplayName(String displayName);
}
