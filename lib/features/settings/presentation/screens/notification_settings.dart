import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';

/// Notification settings screen.
class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifications = settings.notifications;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: SwitchListTile(
                title: const Text('Enable Notifications'),
                subtitle: const Text('Receive task reminders and updates'),
                value: notifications.enabled,
                onChanged: (value) {
                  final updated = notifications.copyWith(enabled: value);
                  ref.read(settingsProvider.notifier).updateNotificationSettings(updated);
                },
              ),
            ),
          ),

          if (notifications.enabled) ...[
            // Task Reminders
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                'TASK REMINDERS',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: SwitchListTile(
                title: const Text('Task Reminders'),
                subtitle: const Text('Get reminded about upcoming tasks'),
                value: notifications.taskReminders,
                onChanged: (value) {
                  final updated = notifications.copyWith(taskReminders: value);
                  ref.read(settingsProvider.notifier).updateNotificationSettings(updated);
                },
              ),
            ),

            // Reminder Time
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: const Text('Reminder Time'),
                subtitle: Text(
                  '${notifications.reminderTimeHours.toString().padLeft(2, '0')}:'
                  '${notifications.reminderTimeMinutes.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectReminderTime(context, ref, notifications),
              ),
            ),

            const SizedBox(height: 16),

            // Quiet Hours
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                'QUIET HOURS',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Enable Quiet Hours'),
                    subtitle: Text(
                      notifications.quietHours.enabled
                          ? 'No notifications during set hours'
                          : 'Notifications 24/7',
                    ),
                    value: notifications.quietHours.enabled,
                    onChanged: (value) {
                      final updatedQuiet = notifications.quietHours.copyWith(enabled: value);
                      final updated = notifications.copyWith(quietHours: updatedQuiet);
                      ref.read(settingsProvider.notifier).updateNotificationSettings(updated);
                    },
                  ),
                  if (notifications.quietHours.enabled) ...[
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('Start Time'),
                      subtitle: Text(
                        '${notifications.quietHours.startHour.toString().padLeft(2, '0')}:'
                        '${notifications.quietHours.startMinute.toString().padLeft(2, '0')}',
                      ),
                      trailing: const Icon(Icons.bedtime_outlined),
                      onTap: () => _selectQuietHours(
                        context,
                        ref,
                        notifications,
                        isStart: true,
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('End Time'),
                      subtitle: Text(
                        '${notifications.quietHours.endHour.toString().padLeft(2, '0')}:'
                        '${notifications.quietHours.endMinute.toString().padLeft(2, '0')}',
                      ),
                      trailing: const Icon(Icons.wb_sunny_outlined),
                      onTap: () => _selectQuietHours(
                        context,
                        ref,
                        notifications,
                        isStart: false,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Info card
            if (notifications.quietHours.enabled &&
                notifications.quietHours.isQuietNow())
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  color: theme.colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Quiet hours are currently active. '
                            'You won\'t receive notifications until '
                            '${notifications.quietHours.endHour}:'
                            '${notifications.quietHours.endMinute.toString().padLeft(2, '0')}.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ] else
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Notifications are disabled',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enable notifications to receive task reminders',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _selectReminderTime(
    BuildContext context,
    WidgetRef ref,
    NotificationSettings notifications,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: notifications.reminderTimeHours,
        minute: notifications.reminderTimeMinutes,
      ),
    );

    if (picked != null && context.mounted) {
      final updated = notifications.copyWith(
        reminderTimeHours: picked.hour,
        reminderTimeMinutes: picked.minute,
      );
      ref.read(settingsProvider.notifier).updateNotificationSettings(updated);
    }
  }

  Future<void> _selectQuietHours(
    BuildContext context,
    WidgetRef ref,
    NotificationSettings notifications,
    {required bool isStart}
  ) async {
    final TimeOfDay initialTime = isStart
        ? TimeOfDay(
            hour: notifications.quietHours.startHour,
            minute: notifications.quietHours.startMinute,
          )
        : TimeOfDay(
            hour: notifications.quietHours.endHour,
            minute: notifications.quietHours.endMinute,
          );

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null && context.mounted) {
      final updatedQuiet = isStart
          ? notifications.quietHours.copyWith(
              startHour: picked.hour,
              startMinute: picked.minute,
            )
          : notifications.quietHours.copyWith(
              endHour: picked.hour,
              endMinute: picked.minute,
            );

      final updated = notifications.copyWith(quietHours: updatedQuiet);
      ref.read(settingsProvider.notifier).updateNotificationSettings(updated);
    }
  }
}
