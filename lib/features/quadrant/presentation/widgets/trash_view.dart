import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task.dart';
import '../providers/task_provider.dart';

/// Trash view for deleted tasks
class TrashView extends ConsumerStatefulWidget {
  const TrashView({super.key});

  @override
  ConsumerState<TrashView> createState() => _TrashViewState();
}

class _TrashViewState extends ConsumerState<TrashView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trash'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Empty Trash',
            onPressed: _showEmptyTrashDialog,
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final notifier = ref.watch(taskListProvider.notifier);

          return FutureBuilder<List<Task>>(
            future: notifier.getDeletedTasks(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete_outline,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Trash is empty',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final tasks = snapshot.data!;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return _buildDeletedTaskCard(context, task, theme);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDeletedTaskCard(BuildContext context, Task task, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          Icons.restore_from_trash,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: TextDecoration.lineThrough,
            color: Colors.grey.shade600,
          ),
        ),
        subtitle: Text(
          'Deleted ${_formatDeletionTime(task.updatedAt ?? task.createdAt)}',
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 12,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.restore),
              tooltip: 'Restore',
              color: Colors.green,
              onPressed: () => _restoreTask(context, task),
            ),
            IconButton(
              icon: const Icon(Icons.delete_forever),
              tooltip: 'Delete Forever',
              color: theme.colorScheme.error,
              onPressed: () => _permanentDelete(context, task),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDeletionTime(DateTime deletedAt) {
    final now = DateTime.now();
    final diff = now.difference(deletedAt);

    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${deletedAt.month}/${deletedAt.day}';
  }

  Future<void> _restoreTask(BuildContext context, Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Task'),
        content: Text('Restore "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(taskListProvider.notifier).restoreTask(task.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task "${task.title}" restored')),
        );
        setState(() {}); // Refresh
      }
    }
  }

  Future<void> _permanentDelete(BuildContext context, Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permanently Delete'),
        content: const Text(
          'This action cannot be undone. Permanently delete this task?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(taskListProvider.notifier).permanentDeleteTask(task.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task permanently deleted')),
        );
        setState(() {}); // Refresh
      }
    }
  }

  Future<void> _showEmptyTrashDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Empty Trash'),
        content: const Text(
          'Permanently delete all tasks in trash? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Empty'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final notifier = ref.read(taskListProvider.notifier);
      final tasks = await notifier.getDeletedTasks();

      for (final task in tasks) {
        await notifier.permanentDeleteTask(task.id);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${tasks.length} tasks permanently deleted')),
        );
        setState(() {}); // Refresh
      }
    }
  }
}
