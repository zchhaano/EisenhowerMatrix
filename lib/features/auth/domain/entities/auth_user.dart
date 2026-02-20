/// Authentication user entity.
///
/// Represents a logged-in user in the application.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.emailVerified = false,
    this.providers = const [],
  });

  /// Unique user identifier from auth provider.
  final String id;

  /// User's email address.
  final String? email;

  /// Display name (optional).
  final String? displayName;

  /// Profile photo URL (optional).
  final String? photoUrl;

  /// Whether the email has been verified.
  final bool emailVerified;

  /// List of authentication providers linked to this account.
  final List<String> providers;
}
