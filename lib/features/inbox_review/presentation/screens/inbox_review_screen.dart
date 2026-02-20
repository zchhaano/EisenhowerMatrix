import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../quadrant/domain/entities/quadrant.dart';
import '../../domain/entities/inbox_task.dart';
import '../widgets/swipeable_card.dart';
import '../providers/inbox_provider.dart';
import 'dart:async';

/// Main inbox review screen
///
/// Features:
/// - Tinder-style card swiping for quick categorization
/// - Swipe UP → Q1 (Do First)
/// - Swipe DOWN → Delete
/// - Swipe LEFT → Q3 (Delegate)
/// - Swipe RIGHT → Q2 (Schedule)
class InboxReviewScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final Function(InboxTask, QuadrantType)? onTaskAssigned;

  const InboxReviewScreen({
    super.key,
    this.onBack,
    this.onTaskAssigned,
  });

  @override
  State<InboxReviewScreen> createState() => _InboxReviewScreenState();
}

class _InboxReviewScreenState extends State<InboxReviewScreen> {
  late final InboxProvider _provider;
  final StreamController<int> _remainingCountController = StreamController<int>.broadcast();

  @override
  void initState() {
    super.initState();
    _provider = InboxProvider();
    _loadSampleData();
  }

  @override
  void dispose() {
    _provider.dispose();
    _remainingCountController.close();
    super.dispose();
  }

  void _loadSampleData() {
    // Load sample inbox tasks
    _provider.loadSampleData();
    _emitRemainingCount();
  }

  void _emitRemainingCount() {
    _remainingCountController.add(_provider.unprocessedCount);
  }

  void _handleSwipe(InboxTask task, SwipeDirection direction) {
    QuadrantType? quadrant;
    bool shouldDelete = false;

    switch (direction) {
      case SwipeDirection.up:
        quadrant = QuadrantType.first; // Q1: Do First
        break;
      case SwipeDirection.right:
        quadrant = QuadrantType.second; // Q2: Schedule
        break;
      case SwipeDirection.left:
        quadrant = QuadrantType.third; // Q3: Delegate
        break;
      case SwipeDirection.down:
        shouldDelete = true;
        break;
    }

    if (shouldDelete) {
      _provider.deleteTask(task.id);
    } else if (quadrant != null) {
      final processed = task.markProcessed(quadrant);
      _provider.updateTask(processed);
      widget.onTaskAssigned?.call(task, quadrant);
    }

    _emitRemainingCount();

    // Show confirmation snackbar
    _showActionSnackbar(direction, quadrant);
  }

  void _showActionSnackbar(SwipeDirection direction, QuadrantType? quadrant) {
    String message;
    Color? color;

    switch (direction) {
      case SwipeDirection.up:
        message = 'Moved to Q1: Do First';
        color = AppColors.q1Light;
        break;
      case SwipeDirection.right:
        message = 'Moved to Q2: Schedule';
        color = AppColors.q2Light;
        break;
      case SwipeDirection.left:
        message = 'Moved to Q3: Delegate';
        color = AppColors.q3Light;
        break;
      case SwipeDirection.down:
        message = 'Task deleted';
        color = AppColors.q4Light;
        break;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(milliseconds: 800),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: _buildAppBar(context, isDark),
      body: Column(
        children: [
          // Instructions bar
          _buildInstructionsBar(context, isDark),

          // Card stack
          Expanded(
            child: AnimatedBuilder(
              animation: _provider,
              builder: (context, child) {
                final unprocessedTasks = _provider.unprocessedTasks;

                if (unprocessedTasks.isEmpty) {
                  return _buildEmptyState(context, isDark);
                }

                return Stack(
                  children: [
                    // Background cards (for depth effect)
                    for (int i = unprocessedTasks.length - 1;
                         i >= unprocessedTasks.length - 3 && i >= 0;
                         i--)
                      Positioned.fill(
                        child: Center(
                          child: Transform.scale(
                            scale: 0.9 - (unprocessedTasks.length - 1 - i) * 0.05,
                            child: Opacity(
                              opacity: 0.3,
                              child: _buildCardPlaceholder(context, i, isDark),
                            ),
                          ),
                        ),
                      ),

                    // Top swipeable card
                    Positioned.fill(
                      child: Center(
                        child: SwipeableInboxCard(
                          task: unprocessedTasks.last,
                          onSwipe: _handleSwipe,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Bottom action bar
          _buildActionBar(context, isDark),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      elevation: 0,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: widget.onBack ?? () => Navigator.pop(context),
      ),
      title: const Text('Inbox Review'),
      actions: [
        // Settings button
        IconButton(
          icon: const Icon(Icons.tune_rounded),
          onPressed: () => _showFilterDialog(context, isDark),
        ),
      ],
    );
  }

  Widget _buildInstructionsBar(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.shadowDark : AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInstruction(
            context: context,
            icon: Icons.arrow_upward_rounded,
            label: 'Q1',
            color: AppColors.q1Light,
            isDark: isDark,
          ),
          _buildInstruction(
            context: context,
            icon: Icons.arrow_forward_rounded,
            label: 'Q2',
            color: AppColors.q2Light,
            isDark: isDark,
          ),
          _buildInstruction(
            context: context,
            icon: Icons.arrow_back_rounded,
            label: 'Q3',
            color: AppColors.q3Light,
            isDark: isDark,
          ),
          _buildInstruction(
            context: context,
            icon: Icons.arrow_downward_rounded,
            label: 'Delete',
            color: AppColors.q4Light,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildInstruction({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCardPlaceholder(BuildContext context, int index, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 64,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
          const SizedBox(height: AppConstants.spacingM),
          Text(
            'Inbox is empty!',
            style: theme.textTheme.titleLarge?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            'All tasks have been processed',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.shadowDark : AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Skip button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _provider.skipCurrentTask(),
                icon: const Icon(Icons.skip_next_rounded),
                label: const Text('Skip'),
              ),
            ),
            const SizedBox(width: AppConstants.spacingM),

            // Edit button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showEditDialog(context, isDark),
                icon: const Icon(Icons.edit_rounded),
                label: const Text('Edit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter & Sort'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filter by:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppConstants.spacingS),
            Wrap(
              spacing: AppConstants.spacingS,
              children: InboxFilter.values.map((filter) {
                return ChoiceChip(
                  label: Text(filter.label),
                  selected: _provider.state.filter == filter,
                  onSelected: (selected) {
                    setState(() => _provider.setFilter(filter));
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: AppConstants.spacingM),
            const Text('Sort by:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppConstants.spacingS),
            Wrap(
              spacing: AppConstants.spacingS,
              children: InboxSort.values.map((sort) {
                return ChoiceChip(
                  label: Text(sort.label),
                  selected: _provider.state.sort == sort,
                  onSelected: (selected) {
                    setState(() => _provider.setSort(sort));
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, bool isDark) {
    final currentTask = _provider.currentTask;
    if (currentTask == null) return;

    // Simple edit dialog
    showDialog(
      context: context,
      builder: (context) => _EditTaskDialog(
        task: currentTask,
        onSave: (updatedTask) {
          _provider.updateTask(updatedTask);
        },
      ),
    );
  }
}

class _EditTaskDialog extends StatefulWidget {
  final InboxTask task;
  final Function(InboxTask) onSave;

  const _EditTaskDialog({
    required this.task,
    required this.onSave,
  });

  @override
  State<_EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<_EditTaskDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  QuadrantType? _selectedQuadrant;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descController = TextEditingController(text: widget.task.description);
    _selectedQuadrant = widget.task.suggestedQuadrant;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Task'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppConstants.spacingM),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppConstants.spacingM),
            const Text('Assign to Quadrant:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppConstants.spacingS),
            Wrap(
              spacing: AppConstants.spacingS,
              children: QuadrantType.values.map((quadrant) {
                final isSelected = _selectedQuadrant == quadrant;
                return FilterChip(
                  label: Text(quadrant.label),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedQuadrant = selected ? quadrant : null;
                    });
                  },
                  selectedColor: quadrant.color.withOpacity(0.3),
                  checkmarkColor: quadrant.color,
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.trim().isEmpty) return;

            final updated = widget.task.copyWith(
              title: _titleController.text.trim(),
              description: _descController.text.trim().isEmpty
                  ? null
                  : _descController.text.trim(),
              suggestedQuadrant: _selectedQuadrant,
            );

            widget.onSave(updated);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
