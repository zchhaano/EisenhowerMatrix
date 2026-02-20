import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/quadrant.dart';
import '../../domain/entities/task.dart';
import '../widgets/quadrant_grid.dart';
import '../widgets/task_creation_modal.dart';
import '../widgets/quick_add_bottom_sheet.dart';
import '../providers/task_provider.dart';
import '../../../../core/database/database.dart' hide Task;

/// Main home screen with the Eisenhower Matrix quadrants
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load tasks on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(taskListProvider.notifier).loadTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskListState = ref.watch(taskListProvider);
    final tasksByQuadrant = taskListState.tasksByQuadrant;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eisenhower Matrix'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterMenu(taskListState),
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortMenu,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: taskListState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : taskListState.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: ${taskListState.error}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.read(taskListProvider.notifier).loadTasks(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : QuadrantGrid(
                  tasksByQuadrant: tasksByQuadrant,
                  onTaskTap: _handleTaskTap,
                  onTaskEdit: _handleTaskEdit,
                  onTaskComplete: _handleTaskComplete,
                  onTaskDelete: _handleTaskDelete,
                  onTaskMove: _handleTaskMove,
                  onQuadrantTap: _handleQuadrantTap,
                  onQuadrantLongPress: _handleQuickAdd,
                  selectedQuadrant: null,
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showTaskCreationModal,
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
    );
  }

  void _handleTaskTap(Task task) {
    // TODO: Navigate to task detail screen
    _showTaskCreationModal(taskToEdit: task);
  }

  void _handleTaskEdit(Task task) {
    _showTaskCreationModal(taskToEdit: task);
  }

  void _handleTaskComplete(Task task) async {
    final success = await ref.read(taskListProvider.notifier).completeTask(task.id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(task.isCompleted ? 'Task uncompleted' : 'Task completed'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              // TODO: Implement undo
            },
          ),
        ),
      );
    }
  }

  void _handleTaskMove(Task task, QuadrantType newQuadrant) async {
    final success = await ref.read(taskListProvider.notifier).moveTaskToQuadrant(task.id, newQuadrant);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task "${task.title}" moved to ${newQuadrant.label}'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              // TODO: Implement undo move
            },
          ),
        ),
      );
    }
  }

  void _handleTaskDelete(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref.read(taskListProvider.notifier).deleteTask(task.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task "${task.title}" deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                ref.read(taskListProvider.notifier).restoreTask(task.id);
              },
            ),
          ),
        );
      }
    }
  }

  void _handleQuadrantTap(QuadrantType type) {
    // TODO: Handle quadrant tap - maybe show full screen view
  }

  void _handleQuickAdd(QuadrantType quadrant) async {
    await QuickAddBottomSheet.show(
      context: context,
      quadrant: quadrant,
      onSave: (title, description, dueDate, priority) async {
        await ref.read(taskListProvider.notifier).createTask(
          title: title,
          description: description,
          quadrant: quadrant,
          priority: priority,
          dueDate: dueDate,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Task added to ${quadrant.label}'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }

  Future<void> _showTaskCreationModal({Task? taskToEdit}) async {
    final result = await TaskCreationModal.show(
      context: context,
      initialQuadrant: taskToEdit?.quadrant,
      initialTitle: taskToEdit?.title,
      initialDescription: taskToEdit?.description,
      initialDueDate: taskToEdit?.dueDate,
      initialPriority: taskToEdit?.priority ?? 0,
      isEditing: taskToEdit != null,
    );

    if (result != null && mounted) {
      if (taskToEdit != null) {
        // Update existing task
        await ref.read(taskListProvider.notifier).updateTask(
          taskToEdit,
          title: result['title'],
          description: result['description'],
          quadrant: result['quadrant'],
          dueDate: result['dueDate'],
          priority: result['priority'],
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task updated')),
          );
        }
      } else {
        // Create new task
        await ref.read(taskListProvider.notifier).createTask(
          title: result['title'] ?? '',
          description: result['description'],
          quadrant: result['quadrant'] ?? QuadrantType.first,
          priority: result['priority'] ?? 0,
          dueDate: result['dueDate'],
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task created')),
          );
        }
      }
    }
  }

  void _showFilterMenu(TaskListState state) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(title: Text('Filter Tasks')),
            const Divider(),
            CheckboxListTile(
              title: const Text('Show completed'),
              value: state.filter.status == TaskStatus.completed,
              onChanged: (value) {
                Navigator.pop(context);
                // TODO: Implement filter
              },
            ),
            CheckboxListTile(
              title: const Text('Show overdue only'),
              value: state.filter.onlyOverdue ?? false,
              onChanged: (value) {
                Navigator.pop(context);
                ref.read(taskListProvider.notifier).toggleOverdueFilter();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSortMenu() {
    final currentSort = ref.read(taskListProvider).sortOption;
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(title: Text('Sort By')),
            const Divider(),
            RadioListTile<TaskSortOption>(
              title: const Text('Due Date (Earliest first)'),
              value: TaskSortOption.dueDateAsc,
              groupValue: currentSort,
              onChanged: (value) {
                Navigator.pop(context);
                if (value != null) {
                  ref.read(taskListProvider.notifier).setSortOption(value);
                }
              },
            ),
            RadioListTile<TaskSortOption>(
              title: const Text('Due Date (Latest first)'),
              value: TaskSortOption.dueDateDesc,
              groupValue: currentSort,
              onChanged: (value) {
                Navigator.pop(context);
                if (value != null) {
                  ref.read(taskListProvider.notifier).setSortOption(value);
                }
              },
            ),
            RadioListTile<TaskSortOption>(
              title: const Text('Priority (Highest first)'),
              value: TaskSortOption.priorityDesc,
              groupValue: currentSort,
              onChanged: (value) {
                Navigator.pop(context);
                if (value != null) {
                  ref.read(taskListProvider.notifier).setSortOption(value);
                }
              },
            ),
            RadioListTile<TaskSortOption>(
              title: const Text('Date Created'),
              value: TaskSortOption.createdAtDesc,
              groupValue: currentSort,
              onChanged: (value) {
                Navigator.pop(context);
                if (value != null) {
                  ref.read(taskListProvider.notifier).setSortOption(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
