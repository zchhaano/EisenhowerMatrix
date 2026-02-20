import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/quadrant.dart';
import '../../../../core/theme/app_colors.dart';

/// Task card widget with swipe actions
class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onComplete;
  final VoidCallback? onDelete;
  final bool isDragging;
  final List<Task>? subtasks;
  final int? completedSubtasks;
  /// When true, hides secondary details to fit more tasks in a quadrant
  final bool compactMode;
  /// Fixed height for the card (used for auto-resize layout)
  final double? itemHeight;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onEdit,
    this.onComplete,
    this.onDelete,
    this.isDragging = false,
    this.subtasks,
    this.completedSubtasks,
    this.compactMode = false,
    this.itemHeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final qColor = AppColors.quadrantColor(task.quadrant.index, isDark);

    // Check if task is overdue - use the entity's isOverdue property
    final isOverdue = task.isOverdue;

    // Compact vertical padding
    final verticalPad = compactMode ? 0.0 : 4.0;
    // In compact mode, show only title (no subtitle)
    final Widget cardContent = Opacity(
      opacity: isDragging ? 0.7 : 1.0,
      child: ListTile(
        dense: compactMode,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: verticalPad,
        ),
        leading: _buildLeading(context),
        title: Text(
          task.title,
          style: theme.textTheme.bodyMedium?.copyWith(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted
                ? (isDark ? Colors.grey.shade500 : Colors.grey.shade500)
                : null,
            fontWeight: FontWeight.w500,
            fontSize: compactMode ? 13 : null,
          ),
          maxLines: compactMode ? 1 : 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: compactMode
            ? null
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (task.description != null && task.description!.isNotEmpty)
                    Text(
                      task.description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (subtasks != null && subtasks!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _buildSubtaskProgress(context),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildDueDateIndicator(context),
                      const SizedBox(width: 8),
                      _buildPriorityIndicator(context),
                    ],
                  ),
                ],
              ),
        trailing: compactMode ? null : _buildTrailing(context),
        onTap: onTap,
      ),
    );

    final container = Container(
      height: itemHeight,
      margin: EdgeInsets.only(bottom: compactMode ? 4 : 8),
      decoration: BoxDecoration(
        color: task.isCompleted
            ? (isDark ? Colors.grey.shade800 : Colors.grey.shade200)
            : theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: task.isCompleted
              ? (isDark ? Colors.grey.shade700 : Colors.grey.shade300)
              : isOverdue
                  ? Colors.red.withOpacity(0.5)
                  : qColor.withOpacity(0.3),
          width: isOverdue ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isOverdue
                ? Colors.red.withOpacity(0.15)
                : Colors.black.withOpacity(0.05),
            blurRadius: isOverdue ? 6 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: cardContent,
    );

    return SwipeActionCell(
      key: Key(task.id),
      backgroundColor: Colors.transparent,
      leadingActions: [
        SwipeAction(
          title: 'Complete',
          onTap: (handler) async {
            handler(false);
            onComplete?.call();
          },
          color: Colors.green,
          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        ),
      ],
      trailingActions: [
        SwipeAction(
          title: 'Edit',
          onTap: (handler) async {
            handler(false);
            onEdit?.call();
          },
          color: Colors.blue,
          icon: const Icon(Icons.edit_outlined, color: Colors.white),
        ),
        SwipeAction(
          title: 'Delete',
          onTap: (handler) async {
            handler(false);
            onDelete?.call();
          },
          color: Colors.red,
          icon: const Icon(Icons.delete_outline, color: Colors.white),
        ),
      ],
      child: container,
    );
  }

  Widget _buildSubtaskProgress(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final qColor = AppColors.quadrantColor(task.quadrant.index, isDark);
    final totalSubtasks = subtasks?.length ?? 0;
    final completed = completedSubtasks ?? 0;

    if (totalSubtasks == 0) return const SizedBox.shrink();

    final progress = totalSubtasks > 0 ? completed / totalSubtasks : 0.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 12,
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        ),
        const SizedBox(width: 4),
        Text(
          '$completed/$totalSubtasks',
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress == 1.0 ? Colors.green : qColor,
              ),
              minHeight: 4,
            ),
          ),
        ),
      ],
    );
  }

  Widget? _buildLeading(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final qColor = AppColors.quadrantColor(task.quadrant.index, isDark);

    return Checkbox(
      value: task.isCompleted,
      onChanged: (_) => onComplete?.call(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      side: BorderSide(
        color: qColor.withOpacity(0.5),
        width: 2,
      ),
      activeColor: qColor,
    );
  }

  Widget? _buildTrailing(BuildContext context) {
    return Icon(
      Icons.drag_indicator,
      color: Colors.grey.shade400,
      size: 20,
    );
  }

  Widget _buildDueDateIndicator(BuildContext context) {
    if (task.dueDate == null) return const SizedBox.shrink();

    final isOverdue = task.isOverdue;
    final isDueToday = task.isDueToday;

    Color color = Colors.grey.shade600;
    if (isOverdue) {
      color = Colors.red;
    } else if (isDueToday) {
      color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: isOverdue
          ? BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            )
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOverdue ? Icons.warning : Icons.schedule,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            _formatDueDate(task.dueDate!),
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityIndicator(BuildContext context) {
    if (task.priority == 0) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final qColor = AppColors.quadrantColor(task.quadrant.index, isDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: qColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getPriorityIcon(task.priority),
            size: 12,
            color: qColor,
          ),
          const SizedBox(width: 2),
          Text(
            'P${task.priority}',
            style: TextStyle(
              fontSize: 10,
              color: qColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icons.flag;
      case 2:
        return Icons.outlined_flag;
      default:
        return Icons.outlined_flag;
    }
  }

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Tomorrow';
    } else if (difference.inDays == -1) {
      return 'Yesterday';
    } else if (difference.inDays < 7 && difference.inDays > -7) {
      return '${date.day}/${date.month}';
    } else {
      return '${date.month}/${date.day}';
    }
  }
}
