import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../quadrant/domain/entities/quadrant.dart';
import '../../domain/entities/inbox_task.dart';

/// Direction of swipe gesture
enum SwipeDirection {
  left,
  right,
  up,
  down,
}

/// Callback type for swipe actions
typedef SwipeCallback = void Function(InboxTask task, SwipeDirection direction);

/// Callback type for undo action
typedef UndoCallback = void Function();

/// Tinder-style swipeable card for inbox review
///
/// Features:
/// - Swipe in 4 directions for different quadrants
/// - Visual feedback during swipe
/// - Snap back animation
/// - Haptic feedback on completion
class SwipeableInboxCard extends StatefulWidget {
  final InboxTask task;
  final SwipeCallback onSwipe;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onUndo;

  const SwipeableInboxCard({
    super.key,
    required this.task,
    required this.onSwipe,
    this.onEdit,
    this.onDelete,
    this.onUndo,
  });

  @override
  State<SwipeableInboxCard> createState() => _SwipeableInboxCardState();
}

class _SwipeableInboxCardState extends State<SwipeableInboxCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;
  double _currentAngle = 0;

  // Thresholds for swipe detection (in pixels)
  static const double _swipeThreshold = 80.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handlePanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
      // Calculate rotation based on horizontal movement
      _currentAngle = _dragOffset.dx * 0.001;
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });

    final dx = _dragOffset.dx.abs();
    final dy = _dragOffset.dy.abs();

    // Determine which direction was swiped
    SwipeDirection? direction;
    double maxDistance = 0;

    if (dx > dy) {
      // Horizontal swipe
      if (_dragOffset.dx > _swipeThreshold) {
        direction = SwipeDirection.right;
        maxDistance = _dragOffset.dx;
      } else if (_dragOffset.dx < -_swipeThreshold) {
        direction = SwipeDirection.left;
        maxDistance = -_dragOffset.dx;
      }
    } else {
      // Vertical swipe
      if (_dragOffset.dy > _swipeThreshold) {
        direction = SwipeDirection.down;
        maxDistance = _dragOffset.dy;
      } else if (_dragOffset.dy < -_swipeThreshold) {
        direction = SwipeDirection.up;
        maxDistance = -_dragOffset.dy;
      }
    }

    if (direction != null) {
      // Trigger swipe completion
      _animateOut(direction);
    } else {
      // Snap back
      _animateReset();
    }
  }

  void _animateOut(SwipeDirection direction) {
    _animationController.forward(from: 0.0).then((_) {
      // Show undo snackbar
      if (widget.onUndo != null) {
        _showUndoSnackBar(direction);
      }

      widget.onSwipe(widget.task, direction);

      // Reset for next card
      setState(() {
        _dragOffset = Offset.zero;
        _currentAngle = 0;
      });
      _animationController.reset();
    });
  }

  void _showUndoSnackBar(SwipeDirection direction) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(_getSwipeMessage(direction)),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.yellow,
          onPressed: () {
            widget.onUndo?.call();
          },
        ),
      ),
    );
  }

  String _getSwipeMessage(SwipeDirection direction) {
    switch (direction) {
      case SwipeDirection.up:
        return 'Task moved to Q1 (Do First)';
      case SwipeDirection.right:
        return 'Task moved to Q2 (Schedule)';
      case SwipeDirection.down:
        return 'Task moved to Q4 (Eliminate)';
      case SwipeDirection.left:
        return 'Task moved to Q3 (Delegate)';
    }
  }

  void _animateReset() {
    _animationController.forward(from: 0.0).then((_) {
      setState(() {
        _dragOffset = Offset.zero;
        _currentAngle = 0;
      });
      _animationController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: _dragOffset,
            child: Transform.rotate(
              angle: _currentAngle,
              child: Container(
                width: 340,
                height: 420,
                margin: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingL,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? AppColors.shadowDark : AppColors.shadowLight,
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  child: Stack(
                    children: [
                      // Background swipe indicators
                      _buildSwipeIndicators(),

                      // Main card content
                      _buildCardContent(context, isDark),

                      // Overlay indicators when dragging
                      if (_isDragging) _buildDragOverlay(context, isDark),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSwipeIndicators() {
    return Stack(
      children: [
        // Up indicator (Q1 - Red)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: [
                  AppColors.q1Light.withOpacity(0.8),
                  AppColors.q1Light.withOpacity(0),
                ],
              ),
            ),
          ),
        ),

        // Right indicator (Q2 - Blue)
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          child: Container(
            width: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.center,
                colors: [
                  AppColors.q2Light.withOpacity(0.8),
                  AppColors.q2Light.withOpacity(0),
                ],
              ),
            ),
          ),
        ),

        // Left indicator (Q3 - Yellow)
        Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          child: Container(
            width: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.center,
                colors: [
                  AppColors.q3Light.withOpacity(0.8),
                  AppColors.q3Light.withOpacity(0),
                ],
              ),
            ),
          ),
        ),

        // Down indicator (Delete - Gray)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.center,
                colors: [
                  AppColors.q4Light.withOpacity(0.8),
                  AppColors.q4Light.withOpacity(0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardContent(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with suggested quadrant
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingS,
                  vertical: AppConstants.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: _getSuggestedQuadrantColor().withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  border: Border.all(
                    color: _getSuggestedQuadrantColor().withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getSuggestedQuadrantIcon(),
                      size: 14,
                      color: _getSuggestedQuadrantColor(),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getSuggestedQuadrantLabel(),
                      style: TextStyle(
                        fontSize: 11,
                        color: _getSuggestedQuadrantColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                _formatCreatedAt(widget.task.createdAt),
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spacingL),

          // Title
          Text(
            widget.task.title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              height: 1.3,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          // Description
          if (widget.task.description != null) ...[
            const SizedBox(height: AppConstants.spacingM),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  widget.task.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],

          const Spacer(),

          // Tags row
          if (widget.task.tags.isNotEmpty || widget.task.dueDate != null)
            Wrap(
              spacing: AppConstants.spacingS,
              children: [
                // Urgent tag
                if (widget.task.tags.contains('urgent'))
                  _buildTag(
                    icon: Icons.warning_rounded,
                    label: '紧急',
                    color: AppColors.q1Light,
                  ),

                // Important tag
                if (widget.task.tags.contains('important'))
                  _buildTag(
                    icon: Icons.star_rounded,
                    label: '重要',
                    color: AppColors.q2Light,
                  ),

                // Due date tag
                if (widget.task.dueDate != null)
                  _buildTag(
                    icon: Icons.calendar_today_rounded,
                    label: _formatDueDate(widget.task.dueDate!),
                    color: AppColors.info,
                  ),
              ],
            ),

          // Priority indicator
          if (widget.task.priority > 0)
            Positioned(
              top: AppConstants.spacingL,
              right: AppConstants.spacingL,
              child: _buildPriorityIndicator(widget.task.priority),
            ),
        ],
      ),
    );
  }

  Widget _buildDragOverlay(BuildContext context, bool isDark) {
    final dx = _dragOffset.dx;
    final dy = _dragOffset.dy;

    // Determine dominant direction
    String? overlayIcon;
    Color? overlayColor;
    double opacity = 0.0;

    if (dy < -dx.abs() && dy < -dy.abs()) {
      // Up
      overlayIcon = '↑';
      overlayColor = AppColors.q1Light;
      opacity = (dy.abs() / _swipeThreshold).clamp(0.0, 1.0);
    } else if (dx > dy.abs() && dx > dx.abs()) {
      // Right
      overlayIcon = '→';
      overlayColor = AppColors.q2Light;
      opacity = (dx.abs() / _swipeThreshold).clamp(0.0, 1.0);
    } else if (dx < -dy.abs() && dx < -dx.abs()) {
      // Left
      overlayIcon = '←';
      overlayColor = AppColors.q3Light;
      opacity = (dx.abs() / _swipeThreshold).clamp(0.0, 1.0);
    } else if (dy > dx.abs() && dy > dy.abs()) {
      // Down
      overlayIcon = '↓';
      overlayColor = AppColors.q4Light;
      opacity = (dy.abs() / _swipeThreshold).clamp(0.0, 1.0);
    }

    if (overlayIcon == null) return const SizedBox.shrink();

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: overlayColor?.withOpacity(opacity * 0.2),
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        child: Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: overlayColor?.withOpacity(opacity * 0.9),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                overlayIcon,
                style: TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingS,
        vertical: AppConstants.spacingXS,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityIndicator(int priority) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          (priority ?? 0).clamp(0, 3),
          (index) => Padding(
            padding: const EdgeInsets.only(right: 1),
            child: Icon(
              Icons.star,
              size: 10,
              color: index < priority ? Colors.amber : Colors.grey[300],
            ),
          ),
        ),
      ),
    );
  }

  Color _getSuggestedQuadrantColor() {
    switch (widget.task.suggestedQuadrant) {
      case QuadrantType.first:
        return AppColors.q1Light;
      case QuadrantType.second:
        return AppColors.q2Light;
      case QuadrantType.third:
        return AppColors.q3Light;
      case QuadrantType.fourth:
        return AppColors.q4Light;
      default:
        return AppColors.q2Light;
    }
  }

  IconData _getSuggestedQuadrantIcon() {
    switch (widget.task.suggestedQuadrant) {
      case QuadrantType.first:
        return Icons.flash_on_rounded;
      case QuadrantType.second:
        return Icons.calendar_today_rounded;
      case QuadrantType.third:
        return Icons.people_rounded;
      case QuadrantType.fourth:
        return Icons.delete_outline_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  String _getSuggestedQuadrantLabel() {
    switch (widget.task.suggestedQuadrant) {
      case QuadrantType.first:
        return 'Q1 立即做';
      case QuadrantType.second:
        return 'Q2 计划做';
      case QuadrantType.third:
        return 'Q3 委派做';
      case QuadrantType.fourth:
        return 'Q4 待定';
      default:
        return '未分类';
    }
  }

  String _formatCreatedAt(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    if (diff.inDays == 1) return '昨天';
    if (diff.inDays < 7) return '${diff.inDays}天前';

    return '${date.month}/${date.day}';
  }

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(date.year, date.month, date.day);
    final diff = targetDay.difference(today).inDays;

    if (diff == 0) return '今天';
    if (diff == 1) return '明天';
    if (diff == 2) return '后天';
    if (diff > 2 && diff <= 7) return '周${date.weekday}';

    return '${date.month}/${date.day}';
  }
}
