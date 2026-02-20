import 'package:flutter/material.dart';
import '../../domain/entities/quadrant.dart';
import '../../domain/entities/task.dart';
import 'draggable_task_card.dart';

/// Minimum height per task card before we give up fitting and allow scrolling
const double _kMinTaskHeight = 40.0;

/// Normal height of a task card (full mode)
const double _kNormalTaskHeight = 72.0;

/// Height of a task card in compact mode
const double _kCompactTaskHeight = 48.0;

/// Number of tasks below which we always use normal mode
const int _kAlwaysNormalThreshold = 3;

/// List of tasks in a quadrant, auto-resizing to fit all tasks without scrolling.
class TaskList extends StatelessWidget {
  final QuadrantType quadrantType;
  final List<Task> tasks;
  final Function(Task) onTaskTap;
  final Function(Task) onTaskEdit;
  final Function(Task) onTaskComplete;
  final Function(Task) onTaskDelete;
  final bool enableDragAndDrop;

  const TaskList({
    super.key,
    required this.quadrantType,
    required this.tasks,
    required this.onTaskTap,
    required this.onTaskEdit,
    required this.onTaskComplete,
    required this.onTaskDelete,
    this.enableDragAndDrop = true,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return _buildEmptyState(context);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final count = tasks.length;

        // Spacing between items already accounted for in itemHeight
        // Decide sizing mode based on available space and count
        final bool forceNormal = count <= _kAlwaysNormalThreshold;

        double? itemHeight;
        bool compactMode = false;
        bool scrollable = false;

        if (forceNormal) {
          // Always render normally for small number of tasks
          // Allow scrolling if they happen to overflow (very constrained space)
          scrollable = true;
        } else {
          // Try to fit all tasks — first attempt normal, then compact, then scroll
          final fitsNormal =
              availableHeight >= count * _kNormalTaskHeight;
          final fitsCompact =
              availableHeight >= count * _kCompactTaskHeight;
          final fitsMinimum =
              availableHeight >= count * _kMinTaskHeight;

          if (fitsNormal) {
            // Distribute full height evenly
            itemHeight = availableHeight / count;
            compactMode = false;
          } else if (fitsCompact) {
            // Use even distribution in compact mode
            itemHeight = availableHeight / count;
            compactMode = true;
          } else if (fitsMinimum) {
            // Floor at minimum height, compact mode
            itemHeight = _kMinTaskHeight;
            compactMode = true;
          } else {
            // Tasks exceed minimum — fall back to scrolling
            scrollable = true;
            compactMode = true;
          }
        }

        return ListView.builder(
          padding: const EdgeInsets.all(4),
          shrinkWrap: true,
          physics: scrollable
              ? const AlwaysScrollableScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          itemCount: count,
          itemBuilder: (context, index) {
            final task = tasks[index];
            if (enableDragAndDrop) {
              return DraggableTaskCard(
                task: task,
                onTap: () => onTaskTap(task),
                onEdit: () => onTaskEdit(task),
                onComplete: () => onTaskComplete(task),
                onDelete: () => onTaskDelete(task),
                compactMode: compactMode,
                itemHeight: itemHeight,
              );
            }
            return DraggableTaskCard(
              task: task,
              onTap: () => onTaskTap(task),
              onEdit: () => onTaskEdit(task),
              onComplete: () => onTaskComplete(task),
              onDelete: () => onTaskDelete(task),
              compactMode: compactMode,
              itemHeight: itemHeight,
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getEmptyIcon(),
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'No tasks yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add a task to get started',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getEmptyIcon() {
    switch (quadrantType) {
      case QuadrantType.first:
        return Icons.local_fire_department_outlined;
      case QuadrantType.second:
        return Icons.event_outlined;
      case QuadrantType.third:
        return Icons.people_outline;
      case QuadrantType.fourth:
        return Icons.delete_outline;
    }
  }
}
