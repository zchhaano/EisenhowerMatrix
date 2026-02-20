import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';

/// Theme settings screen for selecting app theme.
class ThemeSettingsScreen extends ConsumerWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(settingsProvider).themeMode;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Theme',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose how the app appears on your device',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          _ThemeOption(
            icon: Icons.brightness_auto,
            title: 'System',
            description: 'Match your device settings',
            value: AppThemeMode.system,
            groupValue: currentTheme,
            onChanged: (value) {
              if (value != null) {
                ref.read(settingsProvider.notifier).updateThemeMode(value);
              }
            },
          ),
          _ThemeOption(
            icon: Icons.light_mode,
            title: 'Light',
            description: 'Always use light theme',
            value: AppThemeMode.light,
            groupValue: currentTheme,
            onChanged: (value) {
              if (value != null) {
                ref.read(settingsProvider.notifier).updateThemeMode(value);
              }
            },
          ),
          _ThemeOption(
            icon: Icons.dark_mode,
            title: 'Dark',
            description: 'Always use dark theme',
            value: AppThemeMode.dark,
            groupValue: currentTheme,
            onChanged: (value) {
              if (value != null) {
                ref.read(settingsProvider.notifier).updateThemeMode(value);
              }
            },
          ),

          const Padding(
            padding: EdgeInsets.all(24),
            child: Divider(),
          ),

          // Preview section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Preview',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _ThemePreview(mode: currentTheme),
          ),
        ],
      ),
    );
  }
}

/// Theme option radio tile.
class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String description;
  final AppThemeMode value;
  final AppThemeMode groupValue;
  final ValueChanged<AppThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = value == groupValue;

    return RadioListTile<AppThemeMode>(
      value: value,
      groupValue: groupValue,
      onChanged: (v) => onChanged(v!),
      title: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Text(
            title,
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(left: 48),
        child: Text(description),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }
}

/// Theme preview card.
class _ThemePreview extends StatelessWidget {
  const _ThemePreview({required this.mode});

  final AppThemeMode mode;

  @override
  Widget build(BuildContext context) {
    final isDark = mode == AppThemeMode.dark ||
        (mode == AppThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.black12,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Fake app bar
          Container(
            height: 56,
            color: isDark ? Colors.grey.shade900 : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 120,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          // Fake quadrant grid
          Container(
            color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _QuadrantPreview(
                        color: Colors.red,
                        isDark: isDark,
                        label: 'Do First',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _QuadrantPreview(
                        color: Colors.blue,
                        isDark: isDark,
                        label: 'Schedule',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _QuadrantPreview(
                        color: Colors.orange,
                        isDark: isDark,
                        label: 'Delegate',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _QuadrantPreview(
                        color: Colors.grey,
                        isDark: isDark,
                        label: 'Eliminate',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Quadrant preview for theme showcase.
class _QuadrantPreview extends StatelessWidget {
  const _QuadrantPreview({
    required this.color,
    required this.isDark,
    required this.label,
  });

  final Color color;
  final bool isDark;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: isDark ? color.withOpacity(0.3) : color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 2,
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
