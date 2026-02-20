import 'package:flutter/material.dart';
import '../../domain/entities/points.dart';
import '../providers/gamification_provider.dart';
import 'package:provider/provider.dart';

/// Widget displaying points with level information
class PointsDisplay extends StatelessWidget {
  final bool showLevel;
  final bool showProgressBar;
  final bool showDailyPoints;

  const PointsDisplay({
    super.key,
    this.showLevel = true,
    this.showProgressBar = true,
    this.showDailyPoints = false,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GamificationProvider>();
    final points = provider.points;
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.stars_rounded,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Points',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        '${points.total}',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (showLevel) _buildLevelBadge(context, points),
              ],
            ),
            if (showProgressBar) ...[
              const SizedBox(height: 16),
              _buildProgressBar(context, points),
            ],
            if (showDailyPoints) ...[
              const SizedBox(height: 12),
              _buildDailyStats(context, points),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLevelBadge(BuildContext context, Points points) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.military_tech, size: 16, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            'Lvl $points.level',
            style: theme.textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, Points points) {
    final theme = Theme.of(context);
    final progress = points.levelProgress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Level Progress',
              style: theme.textTheme.labelSmall,
            ),
            Text(
              '${(points.total - points.xpForCurrentLevel)}/${points.xpForNextLevel - points.xpForCurrentLevel} XP',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDailyStats(BuildContext context, Points points) {
    final theme = Theme.of(context);

    return Row(
      children: [
        _buildStatChip(
          context,
          icon: Icons.today,
          label: 'Today',
          value: points.today.toString(),
        ),
        const SizedBox(width: 8),
        _buildStatChip(
          context,
          icon: Icons.calendar_view_week,
          label: 'Week',
          value: points.thisWeek.toString(),
        ),
        const SizedBox(width: 8),
        _buildStatChip(
          context,
          icon: Icons.calendar_month,
          label: 'Month',
          value: points.thisMonth.toString(),
        ),
      ],
    );
  }

  Widget _buildStatChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.6)),
          const SizedBox(width: 4),
          Text(
            '$label: $value',
            style: theme.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

/// Compact points display for smaller spaces
class CompactPointsDisplay extends StatelessWidget {
  final bool showLevel;

  const CompactPointsDisplay({
    super.key,
    this.showLevel = true,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GamificationProvider>();
    final points = provider.points;
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.stars_rounded,
          color: theme.colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 6),
        Text(
          '${points.total}',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (showLevel) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Lvl $points.level',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Animated points counter for when points change
class AnimatedPointsCounter extends StatelessWidget {
  final int points;
  final String? label;
  final TextStyle? style;

  const AnimatedPointsCounter({
    super.key,
    required this.points,
    this.label,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultStyle = style ?? theme.textTheme.headlineSmall?.copyWith(
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.bold,
    );

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '+$points',
            style: defaultStyle,
          ),
          if (label != null)
            Text(
              label!,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
        ],
      ),
    );
  }
}

/// Points awarded popup overlay
class PointsAwardedOverlay extends StatelessWidget {
  final int points;
  final String reason;
  final VoidCallback? onDismiss;

  const PointsAwardedOverlay({
    super.key,
    required this.points,
    required this.reason,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      top: 60,
      left: 16,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.stars_rounded,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '+$points Points',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      reason,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: onDismiss,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
