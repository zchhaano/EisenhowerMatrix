import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App theme mode options.
enum AppThemeMode {
  /// Follow system theme
  system,

  /// Always light theme
  light,

  /// Always dark theme
  dark,
}

/// Quadrant label configuration.
class QuadrantLabels {
  const QuadrantLabels({
    this.q1Label = 'Do First',
    this.q2Label = 'Schedule',
    this.q3Label = 'Delegate',
    this.q4Label = 'Eliminate',
  });

  final String q1Label;
  final String q2Label;
  final String q3Label;
  final String q4Label;

  QuadrantLabels copyWith({
    String? q1Label,
    String? q2Label,
    String? q3Label,
    String? q4Label,
  }) {
    return QuadrantLabels(
      q1Label: q1Label ?? this.q1Label,
      q2Label: q2Label ?? this.q2Label,
      q3Label: q3Label ?? this.q3Label,
      q4Label: q4Label ?? this.q4Label,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'q1Label': q1Label,
      'q2Label': q2Label,
      'q3Label': q3Label,
      'q4Label': q4Label,
    };
  }

  factory QuadrantLabels.fromJson(Map<String, dynamic> json) {
    return QuadrantLabels(
      q1Label: json['q1Label'] as String? ?? 'Do First',
      q2Label: json['q2Label'] as String? ?? 'Schedule',
      q3Label: json['q3Label'] as String? ?? 'Delegate',
      q4Label: json['q4Label'] as String? ?? 'Eliminate',
    );
  }

  List<String> toList() => [q1Label, q2Label, q3Label, q4Label];
}

/// Quiet hours configuration.
class QuietHours {
  const QuietHours({
    this.enabled = false,
    this.startHour = 22,
    this.startMinute = 0,
    this.endHour = 8,
    this.endMinute = 0,
  });

  final bool enabled;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;

  QuietHours copyWith({
    bool? enabled,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
  }) {
    return QuietHours(
      enabled: enabled ?? this.enabled,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'startHour': startHour,
      'startMinute': startMinute,
      'endHour': endHour,
      'endMinute': endMinute,
    };
  }

  factory QuietHours.fromJson(Map<String, dynamic> json) {
    return QuietHours(
      enabled: json['enabled'] as bool? ?? false,
      startHour: json['startHour'] as int? ?? 22,
      startMinute: json['startMinute'] as int? ?? 0,
      endHour: json['endHour'] as int? ?? 8,
      endMinute: json['endMinute'] as int? ?? 0,
    );
  }

  /// Returns true if current time is within quiet hours.
  bool isQuietNow() {
    if (!enabled) return false;

    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;
    final startMinutes = startHour * 60 + startMinute;
    final endMinutes = endHour * 60 + endMinute;

    // Handle overnight quiet hours (e.g., 22:00 to 08:00)
    if (startMinutes > endMinutes) {
      return currentMinutes >= startMinutes || currentMinutes < endMinutes;
    } else {
      return currentMinutes >= startMinutes && currentMinutes < endMinutes;
    }
  }
}

/// Notification settings.
class NotificationSettings {
  const NotificationSettings({
    this.enabled = true,
    this.taskReminders = true,
    this.quietHours = const QuietHours(),
    this.reminderTimeHours = 9, // 9 AM
    this.reminderTimeMinutes = 0,
  });

  final bool enabled;
  final bool taskReminders;
  final QuietHours quietHours;
  final int reminderTimeHours;
  final int reminderTimeMinutes;

  NotificationSettings copyWith({
    bool? enabled,
    bool? taskReminders,
    QuietHours? quietHours,
    int? reminderTimeHours,
    int? reminderTimeMinutes,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      taskReminders: taskReminders ?? this.taskReminders,
      quietHours: quietHours ?? this.quietHours,
      reminderTimeHours: reminderTimeHours ?? this.reminderTimeHours,
      reminderTimeMinutes: reminderTimeMinutes ?? this.reminderTimeMinutes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'taskReminders': taskReminders,
      'quietHours': quietHours.toJson(),
      'reminderTimeHours': reminderTimeHours,
      'reminderTimeMinutes': reminderTimeMinutes,
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      enabled: json['enabled'] as bool? ?? true,
      taskReminders: json['taskReminders'] as bool? ?? true,
      quietHours: json['quietHours'] is Map
          ? QuietHours.fromJson(json['quietHours'] as Map<String, dynamic>)
          : const QuietHours(),
      reminderTimeHours: json['reminderTimeHours'] as int? ?? 9,
      reminderTimeMinutes: json['reminderTimeMinutes'] as int? ?? 0,
    );
  }
}

/// Application settings state.
class AppSettings {
  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.quadrantLabels = const QuadrantLabels(),
    this.notifications = const NotificationSettings(),
    this.showCompletedTasks = true,
    this.enableAnimations = true,
    this.hapticFeedback = true,
  });

  final AppThemeMode themeMode;
  final QuadrantLabels quadrantLabels;
  final NotificationSettings notifications;
  final bool showCompletedTasks;
  final bool enableAnimations;
  final bool hapticFeedback;

  AppSettings copyWith({
    AppThemeMode? themeMode,
    QuadrantLabels? quadrantLabels,
    NotificationSettings? notifications,
    bool? showCompletedTasks,
    bool? enableAnimations,
    bool? hapticFeedback,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      quadrantLabels: quadrantLabels ?? this.quadrantLabels,
      notifications: notifications ?? this.notifications,
      showCompletedTasks: showCompletedTasks ?? this.showCompletedTasks,
      enableAnimations: enableAnimations ?? this.enableAnimations,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.name,
      'quadrantLabels': quadrantLabels.toJson(),
      'notifications': notifications.toJson(),
      'showCompletedTasks': showCompletedTasks,
      'enableAnimations': enableAnimations,
      'hapticFeedback': hapticFeedback,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: json['themeMode'] is String
          ? AppThemeMode.values.firstWhere(
              (e) => e.name == json['themeMode'],
              orElse: () => AppThemeMode.system,
            )
          : AppThemeMode.system,
      quadrantLabels: json['quadrantLabels'] is Map
          ? QuadrantLabels.fromJson(json['quadrantLabels'] as Map<String, dynamic>)
          : const QuadrantLabels(),
      notifications: json['notifications'] is Map
          ? NotificationSettings.fromJson(json['notifications'] as Map<String, dynamic>)
          : const NotificationSettings(),
      showCompletedTasks: json['showCompletedTasks'] as bool? ?? true,
      enableAnimations: json['enableAnimations'] as bool? ?? true,
      hapticFeedback: json['hapticFeedback'] as bool? ?? true,
    );
  }
}

/// Settings repository for persisting app settings.
class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;
  static const String _settingsKey = 'app_settings';

  AppSettings loadSettings() {
    final jsonString = _prefs.getString(_settingsKey);
    if (jsonString == null) return const AppSettings();
    try {
      final json = {
        'themeMode': _prefs.getString('theme_mode'),
        'showCompletedTasks': _prefs.getBool('show_completed_tasks'),
        'enableAnimations': _prefs.getBool('enable_animations'),
        'hapticFeedback': _prefs.getBool('haptic_feedback'),
        'quadrantLabels': {
          'q1Label': _prefs.getString('q1_label'),
          'q2Label': _prefs.getString('q2_label'),
          'q3Label': _prefs.getString('q3_label'),
          'q4Label': _prefs.getString('q4_label'),
        },
        'notifications': {
          'enabled': _prefs.getBool('notifications_enabled'),
          'taskReminders': _prefs.getBool('task_reminders'),
          'quietHours': {
            'enabled': _prefs.getBool('quiet_hours_enabled'),
            'startHour': _prefs.getInt('quiet_hours_start_hour'),
            'startMinute': _prefs.getInt('quiet_hours_start_minute'),
            'endHour': _prefs.getInt('quiet_hours_end_hour'),
            'endMinute': _prefs.getInt('quiet_hours_end_minute'),
          },
          'reminderTimeHours': _prefs.getInt('reminder_time_hours'),
          'reminderTimeMinutes': _prefs.getInt('reminder_time_minutes'),
        },
      };
      return AppSettings.fromJson(json);
    } catch (e) {
      return const AppSettings();
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _prefs.setString('theme_mode', settings.themeMode.name);
    await _prefs.setBool('show_completed_tasks', settings.showCompletedTasks);
    await _prefs.setBool('enable_animations', settings.enableAnimations);
    await _prefs.setBool('haptic_feedback', settings.hapticFeedback);

    final labels = settings.quadrantLabels;
    await _prefs.setString('q1_label', labels.q1Label);
    await _prefs.setString('q2_label', labels.q2Label);
    await _prefs.setString('q3_label', labels.q3Label);
    await _prefs.setString('q4_label', labels.q4Label);

    final notifs = settings.notifications;
    await _prefs.setBool('notifications_enabled', notifs.enabled);
    await _prefs.setBool('task_reminders', notifs.taskReminders);

    final quiet = notifs.quietHours;
    await _prefs.setBool('quiet_hours_enabled', quiet.enabled);
    await _prefs.setInt('quiet_hours_start_hour', quiet.startHour);
    await _prefs.setInt('quiet_hours_start_minute', quiet.startMinute);
    await _prefs.setInt('quiet_hours_end_hour', quiet.endHour);
    await _prefs.setInt('quiet_hours_end_minute', quiet.endMinute);

    await _prefs.setInt('reminder_time_hours', notifs.reminderTimeHours);
    await _prefs.setInt('reminder_time_minutes', notifs.reminderTimeMinutes);
  }
}

/// Settings state notifier.
class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier(this._repository) : super(_repository.loadSettings());

  final SettingsRepository _repository;

  Future<void> updateThemeMode(AppThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _repository.saveSettings(state);
  }

  Future<void> updateQuadrantLabels(QuadrantLabels labels) async {
    state = state.copyWith(quadrantLabels: labels);
    await _repository.saveSettings(state);
  }

  Future<void> updateNotificationSettings(NotificationSettings notifications) async {
    state = state.copyWith(notifications: notifications);
    await _repository.saveSettings(state);
  }

  Future<void> toggleShowCompletedTasks() async {
    state = state.copyWith(showCompletedTasks: !state.showCompletedTasks);
    await _repository.saveSettings(state);
  }

  Future<void> toggleAnimations() async {
    state = state.copyWith(enableAnimations: !state.enableAnimations);
    await _repository.saveSettings(state);
  }

  Future<void> toggleHapticFeedback() async {
    state = state.copyWith(hapticFeedback: !state.hapticFeedback);
    await _repository.saveSettings(state);
  }
}

/// Provider for SharedPreferences.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be initialized in main');
});

/// Provider for settings repository.
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(sharedPreferencesProvider));
});

/// Provider for app settings.
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier(ref.watch(settingsRepositoryProvider));
});

/// Provider for theme mode.
final themeModeProvider = Provider<AppThemeMode>((ref) {
  return ref.watch(settingsProvider).themeMode;
});

/// Provider for quadrant labels.
final quadrantLabelsProvider = Provider<QuadrantLabels>((ref) {
  return ref.watch(settingsProvider).quadrantLabels;
});

/// Provider for notification settings.
final notificationSettingsProvider = Provider<NotificationSettings>((ref) {
  return ref.watch(settingsProvider).notifications;
});
