import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

/// Auth state enum for tracking authentication status.
enum AuthStatus {
  /// Initial state, checking authentication status.
  initial,

  /// Authentication is in progress.
  loading,

  /// User is authenticated.
  authenticated,

  /// User is not authenticated.
  unauthenticated,

  /// Authentication failed with an error.
  error,
}

/// Authentication state class.
class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  final AuthStatus status;
  final AuthUser? user;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Notifier class for managing authentication state.
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._authRepository) : super(const AuthState()) {
    _init();
  }

  final AuthRepository _authRepository;

  void _init() {
    // Set initial state from current user
    final currentUser = _authRepository.currentUser;
    if (currentUser != null) {
      state = AuthState(status: AuthStatus.authenticated, user: currentUser);
    } else {
      state = AuthState(status: AuthStatus.unauthenticated);
    }

    // Listen to auth state changes
    _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    });
  }

  /// Sign in with email and password.
  Future<bool> signInWithEmail(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final user = await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = AuthState(status: AuthStatus.authenticated, user: user);
      return true;
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        user: state.user,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Create account with email and password.
  Future<bool> signUpWithEmail(String email, String password, {String? displayName}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final user = await _authRepository.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
      state = AuthState(status: AuthStatus.authenticated, user: user);
      return true;
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        user: state.user,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Sign in with Google.
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final user = await _authRepository.signInWithGoogle();
      state = AuthState(status: AuthStatus.authenticated, user: user);
      return true;
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        user: state.user,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Sign in with Apple.
  Future<bool> signInWithApple() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final user = await _authRepository.signInWithApple();
      state = AuthState(status: AuthStatus.authenticated, user: user);
      return true;
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        user: state.user,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Send password reset email.
  Future<bool> sendPasswordReset(String email) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _authRepository.sendPasswordResetEmail(email);
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return true;
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        user: state.user,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Sign out.
  Future<void> signOut() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _authRepository.signOut();
      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        user: state.user,
        errorMessage: e.toString(),
      );
    }
  }

  /// Clear error state.
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Provider for Supabase auth repository.
///
/// This should be overridden in the main app initialization.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  throw UnimplementedError('authRepositoryProvider must be overridden');
});

/// Provider for auth state notifier.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

/// Provider for current auth status.
final authStatusProvider = Provider<AuthStatus>((ref) {
  return ref.watch(authProvider).status;
});

/// Provider for current authenticated user.
final currentUserProvider = Provider<AuthUser?>((ref) {
  return ref.watch(authProvider).user;
});

/// Provider for auth error message.
final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).errorMessage;
});
