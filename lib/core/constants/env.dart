/// Environment configuration for the Eisenhower Matrix app.
///
/// This file manages environment-specific settings such as API endpoints,
/// feature flags, and debug configurations.
class Env {
  Env._();

  // Environment
  static const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';
  static bool get isTesting => environment == 'testing';

  // API Configuration
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  // Feature Flags
  static const bool enableAnalytics = bool.fromEnvironment(
    'ENABLE_ANALYTICS',
    defaultValue: false,
  );

  static const bool enableCrashlytics = bool.fromEnvironment(
    'ENABLE_CRASHLYTICS',
    defaultValue: false,
  );

  static const bool enableOfflineMode = bool.fromEnvironment(
    'ENABLE_OFFLINE_MODE',
    defaultValue: true,
  );

  // Debug Settings
  static const bool debugMode = bool.fromEnvironment(
    'DEBUG_MODE',
    defaultValue: true,
  );

  static const bool logNetworkRequests = bool.fromEnvironment(
    'LOG_NETWORK_REQUESTS',
    defaultValue: false,
  );

  // Cache Settings
  static const int cacheMaxAgeMinutes = 30;
  static const int cacheMaxSizeMB = 50;

  // Sync Settings
  static const Duration syncInterval = Duration(minutes: 5);
  static const Duration syncTimeout = Duration(seconds: 30);

  /// Validates that all required environment variables are set.
  static bool get isValid {
    if (isProduction) {
      return supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
    }
    return true; // Allow missing values in development
  }

  /// Gets a list of missing required configuration.
  static List<String> get missingConfig {
    final missing = <String>[];

    if (isProduction) {
      if (supabaseUrl.isEmpty) {
        missing.add('SUPABASE_URL');
      }
      if (supabaseAnonKey.isEmpty) {
        missing.add('SUPABASE_ANON_KEY');
      }
    }

    return missing;
  }
}
