import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/quadrant/presentation/screens/home_screen.dart';
import '../../features/quadrant/presentation/screens/deleted_tasks_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/account_settings_screen.dart';
import '../../features/inbox_review/presentation/screens/inbox_review_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';

/// Application router configuration for the Eisenhower Matrix app.
///
/// Defines all routes and navigation patterns using GoRouter.
class AppRouter {
  AppRouter._();

  /// The initial route location.
  static const String initialLocation = '/matrix';

  /// Router key for navigation.
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// GoRouter configuration.
  static GoRouter createRouter() {
    return GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: initialLocation,
      debugLogDiagnostics: true,
      routes: [
        // Auth routes
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          name: 'signup',
          builder: (context, state) => const SignupScreen(),
        ),

        // Main app routes
        GoRoute(
          path: '/matrix',
          name: 'matrix',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/inbox',
          name: 'inbox',
          builder: (context, state) => const InboxReviewScreen(),
        ),
        GoRoute(
          path: '/trash',
          name: 'trash',
          builder: (context, state) => const DeletedTasksScreen(),
        ),

        // Settings routes
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/settings/account',
          name: 'account-settings',
          builder: (context, state) => const AccountSettingsScreen(),
        ),
      ],
      errorBuilder: (context, state) => ErrorPage(error: state.error),
    );
  }

  /// Navigate to the matrix view.
  static void goToMatrix(BuildContext context) {
    context.go('/matrix');
  }

  /// Navigate to the inbox view.
  static void goToInbox(BuildContext context) {
    context.go('/inbox');
  }

  /// Navigate to trash.
  static void goToTrash(BuildContext context) {
    context.push('/trash');
  }

  /// Navigate to settings.
  static void goToSettings(BuildContext context) {
    context.push('/settings');
  }

  /// Navigate to account settings.
  static void goToAccountSettings(BuildContext context) {
    context.push('/settings/account');
  }

  /// Navigate to login.
  static void goToLogin(BuildContext context) {
    context.go('/login');
  }

  /// Navigate to signup.
  static void goToSignup(BuildContext context) {
    context.go('/signup');
  }
}

/// Error page displayed when navigation fails.
class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key, this.error});

  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                error?.toString() ?? 'An unknown error occurred',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/matrix'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
