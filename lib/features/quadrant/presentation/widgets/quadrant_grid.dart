import 'package:flutter/material.dart';
import '../../domain/entities/quadrant.dart';
import '../../domain/entities/task.dart';
import '../widgets/quadrant_card.dart';
import '../widgets/task_list.dart';
import '../widgets/draggable_task_card.dart';

/// Resizable 2x2 grid layout for the four quadrants with draggable center point
class QuadrantGrid extends StatefulWidget {
  final Map<QuadrantType, List<Task>> tasksByQuadrant;
  final Function(Task) onTaskTap;
  final Function(Task) onTaskEdit;
  final Function(Task) onTaskComplete;
  final Function(Task) onTaskDelete;
  final Function(Task, QuadrantType) onTaskMove;
  final Function(QuadrantType) onQuadrantTap;
  final Function(QuadrantType)? onQuadrantLongPress;
  final QuadrantType? selectedQuadrant;
  final bool enableDragAndDrop;

  const QuadrantGrid({
    super.key,
    required this.tasksByQuadrant,
    required this.onTaskTap,
    required this.onTaskEdit,
    required this.onTaskComplete,
    required this.onTaskDelete,
    required this.onTaskMove,
    required this.onQuadrantTap,
    this.onQuadrantLongPress,
    this.selectedQuadrant,
    this.enableDragAndDrop = true,
  });

  @override
  State<QuadrantGrid> createState() => _QuadrantGridState();
}

class _QuadrantGridState extends State<QuadrantGrid> {
  // Split ratios (0.0 to 1.0)
  double _horizontalSplit = 0.5; // Vertical divider position
  double _verticalSplit = 0.5;   // Horizontal divider position

  static const double _minQuadrantSize = 0.2; // Minimum 20% for each quadrant
  static const double _maxQuadrantSize = 0.8; // Maximum 80% for each quadrant
  static const double _dividerThickness = 4.0;
  static const double _handleSize = 32.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use a 2x2 grid for larger screens
        if (constraints.maxWidth > 600) {
          return _buildDesktopGrid(context);
        }
        // Stack vertically for mobile with resizable quadrants
        return _buildResizableGrid(context, constraints);
      },
    );
  }

  Widget _buildDesktopGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      padding: const EdgeInsets.all(16),
      children: QuadrantType.values.map((type) {
        final taskList = TaskList(
          quadrantType: type,
          tasks: widget.tasksByQuadrant[type] ?? [],
          onTaskTap: widget.onTaskTap,
          onTaskEdit: widget.onTaskEdit,
          onTaskComplete: widget.onTaskComplete,
          onTaskDelete: widget.onTaskDelete,
          enableDragAndDrop: widget.enableDragAndDrop,
        );

        return QuadrantCard(
          type: type,
          isSelected: widget.selectedQuadrant == type,
          onTap: () => widget.onQuadrantTap(type),
          onLongPress: widget.onQuadrantLongPress != null
              ? () => widget.onQuadrantLongPress!(type)
              : null,
          child: widget.enableDragAndDrop
              ? TaskDropZone(
                  quadrantType: type,
                  onTaskDropped: widget.onTaskMove,
                  child: taskList,
                )
              : taskList,
        );
      }).toList(),
    );
  }

  Widget _buildResizableGrid(BuildContext context, BoxConstraints constraints) {
    final totalWidth = constraints.maxWidth;
    final totalHeight = constraints.maxHeight;

    return Stack(
      children: [
        // Q1 - Top Left (Do)
        Positioned(
          left: 0,
          top: 0,
          width: totalWidth * _horizontalSplit - _dividerThickness / 2,
          height: totalHeight * _verticalSplit - _dividerThickness / 2,
          child: _buildQuadrant(QuadrantType.first),
        ),
        // Q2 - Top Right (Schedule)
        Positioned(
          left: totalWidth * _horizontalSplit + _dividerThickness / 2,
          top: 0,
          width: totalWidth * (1 - _horizontalSplit) - _dividerThickness / 2,
          height: totalHeight * _verticalSplit - _dividerThickness / 2,
          child: _buildQuadrant(QuadrantType.second),
        ),
        // Q3 - Bottom Left (Delegate)
        Positioned(
          left: 0,
          top: totalHeight * _verticalSplit + _dividerThickness / 2,
          width: totalWidth * _horizontalSplit - _dividerThickness / 2,
          height: totalHeight * (1 - _verticalSplit) - _dividerThickness / 2,
          child: _buildQuadrant(QuadrantType.third),
        ),
        // Q4 - Bottom Right (Delete)
        Positioned(
          left: totalWidth * _horizontalSplit + _dividerThickness / 2,
          top: totalHeight * _verticalSplit + _dividerThickness / 2,
          width: totalWidth * (1 - _horizontalSplit) - _dividerThickness / 2,
          height: totalHeight * (1 - _verticalSplit) - _dividerThickness / 2,
          child: _buildQuadrant(QuadrantType.fourth),
        ),
        // Vertical Divider Line
        Positioned(
          left: totalWidth * _horizontalSplit - _dividerThickness / 2,
          top: 0,
          width: _dividerThickness,
          height: totalHeight,
          child: Container(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          ),
        ),
        // Horizontal Divider Line
        Positioned(
          left: 0,
          top: totalHeight * _verticalSplit - _dividerThickness / 2,
          width: totalWidth,
          height: _dividerThickness,
          child: Container(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          ),
        ),
        // Center Draggable Handle
        Positioned(
          left: totalWidth * _horizontalSplit - _handleSize / 2,
          top: totalHeight * _verticalSplit - _handleSize / 2,
          width: _handleSize,
          height: _handleSize,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                // Update horizontal split
                final newHorizontal = _horizontalSplit + details.delta.dx / totalWidth;
                _horizontalSplit = newHorizontal.clamp(_minQuadrantSize, _maxQuadrantSize);

                // Update vertical split
                final newVertical = _verticalSplit + details.delta.dy / totalHeight;
                _verticalSplit = newVertical.clamp(_minQuadrantSize, _maxQuadrantSize);
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.open_with,
                size: 16,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuadrant(QuadrantType type) {
    final taskList = TaskList(
      quadrantType: type,
      tasks: widget.tasksByQuadrant[type] ?? [],
      onTaskTap: widget.onTaskTap,
      onTaskEdit: widget.onTaskEdit,
      onTaskComplete: widget.onTaskComplete,
      onTaskDelete: widget.onTaskDelete,
      enableDragAndDrop: widget.enableDragAndDrop,
    );

    return Padding(
      padding: const EdgeInsets.all(4),
      child: QuadrantCard(
        type: type,
        isSelected: widget.selectedQuadrant == type,
        onTap: () => widget.onQuadrantTap(type),
        onLongPress: widget.onQuadrantLongPress != null
            ? () => widget.onQuadrantLongPress!(type)
            : null,
        child: widget.enableDragAndDrop
            ? TaskDropZone(
                quadrantType: type,
                onTaskDropped: widget.onTaskMove,
                child: taskList,
              )
            : taskList,
      ),
    );
  }
}
