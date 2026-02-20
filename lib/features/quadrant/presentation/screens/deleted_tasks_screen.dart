import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task.dart';
import '../providers/task_provider.dart';

/// Screen for viewing and restoring deleted tasks
class DeletedTasksScreen extends ConsumerStatefulWidget {
  const DeletedTasksScreen({super.key});

  @override
  ConsumerState<DeletedTasksScreen> createState() => _DeletedTasksScreenState();
}

class _DeletedTasksScreenState extends ConsumerState<DeletedTasksScreen> {
  List<Task> _deletedTasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeletedTasks();
  }

  Future<void> _loadDeletedTasks() async {
    setState(() => _isLoading = true);
    final notifier = ref.read(taskListProvider.notifier);
    final tasks = await notifier.getDeletedTasks();
    if (mounted) {
      setState(() {
        _deletedTasks = tasks;
        _isLoading = false;
      });
    }
  }

  Future<void> _restoreTask(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Task'),
        content: Text('Restore "${task.title}" to your active tasks?'),
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

    if (confirmed == true) {
      final notifier = ref.read(taskListProvider.notifier);
      await notifier.restoreTask(task.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task "${task.title}" restored')),
        );
        _loadDeletedTasks();
      }
    }
  }

  Future<void> _permanentDelete(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permanently Delete'),
        content: const Text(
          'This action cannot be undone. The task will be permanently deleted.',
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
            child: const Text('Delete Forever'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final notifier = ref.read(taskListProvider.notifier);
      await notifier.permanentDeleteTask(task.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task permanently deleted')),
        );
        _loadDeletedTasks();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deleted Tasks'),
        actions: [
          if (_deletedTasks.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Empty Trash',
              onPressed: () => _showEmptyTrashDialog(),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _deletedTasks.isEmpty
              ? _buildEmptyState(theme)
              : _buildTaskList(theme),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
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
            'No deleted tasks',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tasks you delete will appear here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _deletedTasks.length,
      itemBuilder: (context, index) {
        final task = _deletedTasks[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
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
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (task.description != null && task.description!.isNotEmpty)
                  Text(
                    task.description!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  'Deleted ${_formatDeletionTime(task)}',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.restore),
                  tooltip: 'Restore',
                  color: Colors.green,
                  onPressed: () => _restoreTask(task),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever),
                  tooltip: 'Delete Forever',
                  color: theme.colorScheme.error,
                  onPressed: () => _permanentDelete(task),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDeletionTime(Task task) {
    final updatedAt = task.updatedAt ?? task.createdAt;
    final now = DateTime.now();
    final diff = now.difference(updatedAt);

    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${updatedAt.month}/${updatedAt.day}';
  }

  Future<void> _showEmptyTrashDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Empty Trash'),
        content: Text(
          'Permanently delete all ${_deletedTasks.length} tasks? This action cannot be undone.',
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
            child: const Text('Empty Trash'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final notifier = ref.read(taskListProvider.notifier);
      for (final task in _deletedTasks) {
        await notifier.permanentDeleteTask(task.id);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_deletedTasks.length} tasks permanently deleted')),
      );
      _loadDeletedTasks();
    }
  }
}
