import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/quadrant.dart';
import '../../domain/entities/task.dart';
import 'task_card.dart';

/// Draggable wrapper for task cards enabling drag and drop between quadrants
class DraggableTaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onComplete;
  final VoidCallback? onDelete;
  final bool isDragging;
  final bool compactMode;
  final double? itemHeight;

  const DraggableTaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onEdit,
    this.onComplete,
    this.onDelete,
    this.isDragging = false,
    this.compactMode = false,
    this.itemHeight,
  });

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<Task>(
      data: task,
      onDragStarted: () {
        HapticFeedback.mediumImpact();
      },
      onDragEnd: (details) {
        // Drag ended - no additional action needed
      },
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: task.quadrant.color.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            task.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.4,
        child: TaskCard(
          task: task,
          onTap: onTap,
          onEdit: onEdit,
          onComplete: onComplete,
          onDelete: onDelete,
          isDragging: true,
          compactMode: compactMode,
          itemHeight: itemHeight,
        ),
      ),
      child: TaskCard(
        key: Key('task_${task.id}'),
        task: task,
        onTap: onTap,
        onEdit: onEdit,
        onComplete: onComplete,
        onDelete: onDelete,
        isDragging: isDragging,
        compactMode: compactMode,
        itemHeight: itemHeight,
      ),
    );
  }
}

/// Drop zone for tasks - wraps quadrant content to accept dropped tasks
class TaskDropZone extends StatelessWidget {
  final Widget child;
  final QuadrantType quadrantType;
  final Function(Task, QuadrantType) onTaskDropped;
  final bool isActive;

  const TaskDropZone({
    super.key,
    required this.child,
    required this.quadrantType,
    required this.onTaskDropped,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<Task>(
      onWillAcceptWithDetails: (details) {
        return isActive && details.data.quadrant != quadrantType;
      },
      onAcceptWithDetails: (details) {
        HapticFeedback.mediumImpact(); // Add haptic feedback on accept
        onTaskDropped(details.data, quadrantType);
      },
      onMove: (details) {},
      onLeave: (data) {},
      builder: (context, candidateData, rejectedData) {
        final isDraggingOver = candidateData.isNotEmpty;
        return Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isDraggingOver
                    ? quadrantType.color.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: isDraggingOver
                    ? Border.all(
                        color: quadrantType.color,
                        width: 2,
                      )
                    : null,
              ),
              child: child,
            ),
            if (isDraggingOver)
              Positioned.fill(
                child: Center(
                  child: AnimatedScale(
                    scale: isDraggingOver ? 1.2 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.add_task,
                      size: 64,
                      color: quadrantType.color.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
