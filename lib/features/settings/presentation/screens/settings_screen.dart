import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/settings_provider.dart';
import 'theme_settings.dart';
import 'notification_settings.dart';

/// Main settings screen for the app.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Account Section
          _SectionHeader(title: 'Account', icon: Icons.person_outline),
          _SettingsTile(
            icon: Icons.edit_outlined,
            title: 'Edit Profile',
            onTap: () {
              // TODO: Navigate to profile edit
            },
          ),
          _SettingsTile(
            icon: Icons.lock_outline,
            title: 'Change Password',
            onTap: () {
              // TODO: Navigate to password change
            },
          ),
          _SettingsTile(
            icon: Icons.logout,
            title: 'Sign Out',
            titleColor: Colors.red,
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                // TODO: Sign out via auth provider
              }
            },
          ),

          const Divider(height: 32),

          // Appearance Section
          _SectionHeader(title: 'Appearance', icon: Icons.palette_outlined),
          _SettingsTile(
            icon: Icons.light_mode_outlined,
            title: 'Theme',
            subtitle: _getThemeLabel(settings.themeMode),
            trailing: _ThemeIndicator(mode: settings.themeMode),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ThemeSettingsScreen()),
              );
            },
          ),
          _SwitchTile(
            icon: Icons.animation_outlined,
            title: 'Enable Animations',
            subtitle: 'Animate transitions and interactions',
            value: settings.enableAnimations,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).toggleAnimations();
            },
          ),
          _SwitchTile(
            icon: Icons.vibration_outlined,
            title: 'Haptic Feedback',
            subtitle: 'Vibrate on interactions',
            value: settings.hapticFeedback,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).toggleHapticFeedback();
            },
          ),

          const Divider(height: 32),

          // Matrix Section
          _SectionHeader(title: 'Eisenhower Matrix', icon: Icons.dashboard_outlined),
          _SettingsTile(
            icon: Icons.label_outline,
            title: 'Quadrant Labels',
            subtitle: 'Customize quadrant names',
            onTap: () {
              // Show quadrant label editor
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) => const _QuadrantLabelSheet(),
              );
            },
          ),
          _SwitchTile(
            icon: Icons.check_circle_outline,
            title: 'Show Completed Tasks',
            subtitle: 'Display completed tasks in the matrix',
            value: settings.showCompletedTasks,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).toggleShowCompletedTasks();
            },
          ),

          const Divider(height: 32),

          // Notifications Section
          _SectionHeader(title: 'Notifications', icon: Icons.notifications_outlined),
          _SwitchTile(
            icon: Icons.notifications_active_outlined,
            title: 'Enable Notifications',
            subtitle: 'Receive task reminders',
            value: settings.notifications.enabled,
            onChanged: (value) {
              final updated = settings.notifications.copyWith(enabled: value);
              ref.read(settingsProvider.notifier).updateNotificationSettings(updated);
            },
          ),
          _SettingsTile(
            icon: Icons.access_time,
            title: 'Quiet Hours',
            subtitle: _getQuietHoursLabel(settings.notifications.quietHours),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()),
              );
            },
          ),

          const Divider(height: 32),

          // About Section
          _SectionHeader(title: 'About', icon: Icons.info_outline),
          _SettingsTile(
            icon: Icons.description_outlined,
            title: 'Privacy Policy',
            onTap: () {
              // TODO: Navigate to privacy policy
            },
          ),
          _SettingsTile(
            icon: Icons.gavel_outlined,
            title: 'Terms of Service',
            onTap: () {
              // TODO: Navigate to terms
            },
          ),
          _SettingsTile(
            icon: Icons.code,
            title: 'App Version',
            subtitle: '1.0.0',
            onTap: null,
          ),
        ],
      ),
    );
  }

  String _getThemeLabel(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return 'System';
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
    }
  }

  String _getQuietHoursLabel(QuietHours hours) {
    if (!hours.enabled) return 'Disabled';
    return '${hours.startHour.toString().padLeft(2, '0')}:${hours.startMinute.toString().padLeft(2, '0')} - '
           '${hours.endHour.toString().padLeft(2, '0')}:${hours.endMinute.toString().padLeft(2, '0')}';
  }
}

/// Section header widget.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Standard settings tile.
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.titleColor,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color? titleColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveTitleColor = titleColor ?? theme.colorScheme.onSurface;

    return ListTile(
      leading: Icon(icon, color: onTap == null ? Colors.grey : null),
      title: Text(
        title,
        style: TextStyle(color: effectiveTitleColor),
      ),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ??
          (onTap != null
              ? Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withOpacity(0.5))
              : null),
      onTap: onTap,
    );
  }
}

/// Switch settings tile.
class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.value,
    this.subtitle,
    this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final String? subtitle;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      value: value,
      onChanged: onChanged,
    );
  }
}

/// Theme mode indicator widget.
class _ThemeIndicator extends StatelessWidget {
  const _ThemeIndicator({required this.mode});

  final AppThemeMode mode;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          switch (mode) {
            AppThemeMode.system => Icons.brightness_auto,
            AppThemeMode.light => Icons.light_mode,
            AppThemeMode.dark => Icons.dark_mode,
          },
          size: 20,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 4),
        Icon(
          Icons.chevron_right,
          size: 20,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        ),
      ],
    );
  }
}

/// Quadrant label bottom sheet.
class _QuadrantLabelSheet extends ConsumerStatefulWidget {
  const _QuadrantLabelSheet();

  @override
  ConsumerState<_QuadrantLabelSheet> createState() => _QuadrantLabelSheetState();
}

class _QuadrantLabelSheetState extends ConsumerState<_QuadrantLabelSheet> {
  late TextEditingController _q1Controller;
  late TextEditingController _q2Controller;
  late TextEditingController _q3Controller;
  late TextEditingController _q4Controller;

  @override
  void initState() {
    super.initState();
    final labels = ref.read(settingsProvider).quadrantLabels;
    _q1Controller = TextEditingController(text: labels.q1Label);
    _q2Controller = TextEditingController(text: labels.q2Label);
    _q3Controller = TextEditingController(text: labels.q3Label);
    _q4Controller = TextEditingController(text: labels.q4Label);
  }

  @override
  void dispose() {
    _q1Controller.dispose();
    _q2Controller.dispose();
    _q3Controller.dispose();
    _q4Controller.dispose();
    super.dispose();
  }

  void _saveLabels() {
    final labels = QuadrantLabels(
      q1Label: _q1Controller.text.trim().isEmpty ? 'Do First' : _q1Controller.text.trim(),
      q2Label: _q2Controller.text.trim().isEmpty ? 'Schedule' : _q2Controller.text.trim(),
      q3Label: _q3Controller.text.trim().isEmpty ? 'Delegate' : _q3Controller.text.trim(),
      q4Label: _q4Controller.text.trim().isEmpty ? 'Eliminate' : _q4Controller.text.trim(),
    );
    ref.read(settingsProvider.notifier).updateQuadrantLabels(labels);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Customize Quadrant Labels',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          _QuadrantLabelField(
            controller: _q1Controller,
            label: 'Q1 (Urgent + Important)',
            color: AppColors.q1Light,
          ),
          const SizedBox(height: 16),
          _QuadrantLabelField(
            controller: _q2Controller,
            label: 'Q2 (Not Urgent + Important)',
            color: AppColors.q2Light,
          ),
          const SizedBox(height: 16),
          _QuadrantLabelField(
            controller: _q3Controller,
            label: 'Q3 (Urgent + Not Important)',
            color: AppColors.q3Light,
          ),
          const SizedBox(height: 16),
          _QuadrantLabelField(
            controller: _q4Controller,
            label: 'Q4 (Not Urgent + Not Important)',
            color: AppColors.q4Light,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: _saveLabels,
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Individual quadrant label field.
class _QuadrantLabelField extends StatelessWidget {
  const _QuadrantLabelField({
    required this.controller,
    required this.label,
    required this.color,
  });

  final TextEditingController controller;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Container(
          width: 4,
          margin: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(4),
            ),
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
