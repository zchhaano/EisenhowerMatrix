import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/quadrant.dart';
import '../../../../core/theme/app_colors.dart';

/// Individual quadrant card widget for the Eisenhower Matrix
class QuadrantCard extends StatefulWidget {
  final QuadrantType type;
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;

  const QuadrantCard({
    super.key,
    required this.type,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
  });

  @override
  State<QuadrantCard> createState() => _QuadrantCardState();
}

class _QuadrantCardState extends State<QuadrantCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;
  bool _isPressing = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onLongPress != null) {
      setState(() => _isPressing = true);
      _pressController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressing = false);
    _pressController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressing = false);
    _pressController.reverse();
  }

  void _handleLongPress() {
    setState(() => _isPressing = false);
    _pressController.reverse();
    // Provide haptic feedback
    HapticFeedback.mediumImpact();
    widget.onLongPress?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final qColor = AppColors.quadrantColor(widget.type.index, isDark);
    final qBgColor = AppColors.quadrantContainerColor(widget.type.index, isDark);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: qBgColor.withValues(
            alpha: widget.isSelected ? 0.8 : 1.0,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isSelected
                ? qColor
                : qColor.withValues(alpha: 0.3),
            width: widget.isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (widget.isSelected)
              BoxShadow(
                color: qColor.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            // Add subtle glow during press
            if (_isPressing)
              BoxShadow(
                color: qColor.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quadrant Header — long-press here for quick-add
            GestureDetector(
              onTap: widget.onTap,
              onLongPress: widget.onLongPress != null ? _handleLongPress : null,
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: qColor.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: qColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.type.label,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: qColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.type.labelZh,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: qColor.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _getIconForQuadrant(widget.type),
                      color: qColor,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            // Task Content Area — gestures handled by children (LongPressDraggable, etc.)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: widget.child,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForQuadrant(QuadrantType type) {
    switch (type) {
      case QuadrantType.first:
        return Icons.local_fire_department;
      case QuadrantType.second:
        return Icons.event;
      case QuadrantType.third:
        return Icons.people_outline;
      case QuadrantType.fourth:
        return Icons.delete_outline;
    }
  }
}
