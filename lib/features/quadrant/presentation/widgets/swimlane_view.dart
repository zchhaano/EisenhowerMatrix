import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/quadrant.dart';
import '../../domain/entities/task.dart';
import '../widgets/quadrant_card.dart';
import '../widgets/task_list.dart';
import '../widgets/draggable_task_card.dart';

/// Horizontal scroll view for mobile - alternative to grid
class SwimlaneView extends StatelessWidget {
  final Map<QuadrantType, List<Task>> tasksByQuadrant;
  final Function(Task) onTaskTap;
  final Function(Task) onTaskEdit;
  final Function(Task) onTaskComplete;
  final Function(Task) onTaskDelete;
  final Function(Task, QuadrantType) onTaskMove;
  final Function(QuadrantType) onQuadrantTap;
  final QuadrantType? selectedQuadrant;
  final bool enableDragAndDrop;

  const SwimlaneView({
    super.key,
    required this.tasksByQuadrant,
    required this.onTaskTap,
    required this.onTaskEdit,
    required this.onTaskComplete,
    required this.onTaskDelete,
    required this.onTaskMove,
    required this.onQuadrantTap,
    this.selectedQuadrant,
    this.enableDragAndDrop = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab bar for quadrant selection — also act as cross-quadrant drop targets
        _buildTabBar(context),
        const SizedBox(height: 16),
        // Selected quadrant content
        Expanded(
          child: _buildSelectedQuadrant(context),
        ),
      ],
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: QuadrantType.values.length,
        itemBuilder: (context, index) {
          final type = QuadrantType.values[index];
          final isSelected = selectedQuadrant == type;
          final taskCount = tasksByQuadrant[type]?.length ?? 0;

          // Each tab is also a DragTarget — drop a task here to move it
          return DragTarget<Task>(
            onWillAcceptWithDetails: (details) =>
                enableDragAndDrop && details.data.quadrant != type,
            onAcceptWithDetails: (details) {
              HapticFeedback.mediumImpact();
              onTaskMove(details.data, type);
              // Also switch to the target quadrant so user sees the result
              onQuadrantTap(type);
            },
            builder: (context, candidateData, rejectedData) {
              final isDraggingOver = candidateData.isNotEmpty;
              return GestureDetector(
                onTap: () => onQuadrantTap(type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDraggingOver
                        ? type.color.withOpacity(0.4)
                        : isSelected
                            ? type.color
                            : type.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: type.color,
                      width: isDraggingOver ? 2.5 : (isSelected ? 2 : 1),
                    ),
                    boxShadow: isDraggingOver
                        ? [
                            BoxShadow(
                              color: type.color.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isDraggingOver)
                        Icon(Icons.add_circle_outline,
                            color: Colors.white, size: 16)
                      else
                        Text(
                          type.label,
                          style: TextStyle(
                            color: isSelected ? Colors.white : type.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      Text(
                        taskCount == 1 ? '1 task' : '$taskCount tasks',
                        style: TextStyle(
                          color: isDraggingOver
                              ? Colors.white70
                              : isSelected
                                  ? Colors.white70
                                  : type.color.withOpacity(0.7),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSelectedQuadrant(BuildContext context) {
    final type = selectedQuadrant ?? QuadrantType.first;
    final taskList = TaskList(
      quadrantType: type,
      tasks: tasksByQuadrant[type] ?? [],
      onTaskTap: onTaskTap,
      onTaskEdit: onTaskEdit,
      onTaskComplete: onTaskComplete,
      onTaskDelete: onTaskDelete,
      enableDragAndDrop: enableDragAndDrop,
    );

    return QuadrantCard(
      type: type,
      isSelected: true,
      child: enableDragAndDrop
          ? TaskDropZone(
              quadrantType: type,
              onTaskDropped: onTaskMove,
              child: taskList,
            )
          : taskList,
    );
  }
}
