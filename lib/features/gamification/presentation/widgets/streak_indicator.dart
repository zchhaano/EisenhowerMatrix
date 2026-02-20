import 'package:flutter/material.dart';
import '../../domain/services/streak_service.dart';
import '../providers/gamification_provider.dart';
import 'package:provider/provider.dart';

/// Widget displaying the user's streak information
class StreakIndicator extends StatelessWidget {
  final bool showMilestone;
  final bool showDeadline;
  final bool showLongest;

  const StreakIndicator({
    super.key,
    this.showMilestone = true,
    this.showDeadline = true,
    this.showLongest = false,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GamificationProvider>();
    final streakInfo = provider.streakInfo;
    final theme = Theme.of(context);

    final hasStreak = streakInfo.currentStreak > 0;

    return Card(
      elevation: 0,
      color: hasStreak
          ? Colors.orange.shade50
          : theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _buildStreakIcon(context, streakInfo.currentStreak),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasStreak ? 'Current Streak' : 'Start Your Streak',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            '${streakInfo.currentStreak}',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: hasStreak ? Colors.orange : theme.colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'day${streakInfo.currentStreak == 1 ? '' : 's'}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: hasStreak ? Colors.orange.shade700 : theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (showLongest && streakInfo.longestStreak > 0)
                  _buildLongestBadge(context, streakInfo.longestStreak),
              ],
            ),
            if (showMilestone && hasStreak) ...[
              const SizedBox(height: 16),
              _buildMilestoneProgress(context, streakInfo.currentStreak),
            ],
            if (showDeadline && hasStreak) ...[
              const SizedBox(height: 12),
              _buildDeadlineInfo(context, provider),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStreakIcon(BuildContext context, int streakDays) {
    if (streakDays == 0) {
      return Icon(
        Icons.local_fire_department_outlined,
        size: 40,
        color: Colors.grey.shade400,
      );
    }

    Color fireColor;
    if (streakDays >= 90) {
      fireColor = Colors.purple;
    } else if (streakDays >= 30) {
      fireColor = Colors.red;
    } else if (streakDays >= 14) {
      fireColor = Colors.orange;
    } else if (streakDays >= 7) {
      fireColor = Colors.deepOrange;
    } else {
      fireColor = Colors.orange.shade300;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        if (streakDays >= 30)
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: fireColor.withOpacity(0.2),
            ),
          ),
        Icon(
          _getFireIcon(streakDays),
          size: 40,
          color: fireColor,
        ),
      ],
    );
  }

  IconData _getFireIcon(int streakDays) {
    if (streakDays >= 90) return Icons.whatshot;
    if (streakDays >= 30) return Icons.local_fire_department;
    if (streakDays >= 14) return Icons.local_fire_department_rounded;
    if (streakDays >= 7) return Icons.local_fire_department;
    return Icons.local_fire_department_outlined;
  }

  Widget _buildLongestBadge(BuildContext context, int longestStreak) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events, size: 14, color: Colors.amber.shade700),
          const SizedBox(width: 4),
          Text(
            'Best: $longestStreak',
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.amber.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneProgress(BuildContext context, int currentStreak) {
    final theme = Theme.of(context);
    final milestone = StreakService.getNextMilestone(currentStreak);
    final previousMilestone = _getPreviousMilestone(currentStreak);
    final range = milestone.days - previousMilestone;
    final progress = currentStreak - previousMilestone;
    final progressRatio = progress / range;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Next milestone: ${milestone.title}',
              style: theme.textTheme.labelSmall,
            ),
            Text(
              '$progress/${range} days',
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
              height: 6,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progressRatio.clamp(0.0, 1.0),
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.shade300,
                      Colors.deepOrange,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ],
        ),
        Text(
          '+${milestone.bonus} bonus points',
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.orange.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  int _getPreviousMilestone(int currentStreak) {
    if (currentStreak >= 30) return 30;
    if (currentStreak >= 7) return 7;
    return 0;
  }

  Widget _buildDeadlineInfo(BuildContext context, GamificationProvider provider) {
    final theme = Theme.of(context);
    final daysRemaining = provider.getDaysRemaining();
    final deadline = provider.getStreakDeadline();

    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (daysRemaining > 1) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = '$daysRemaining days to keep streak';
    } else if (daysRemaining == 1) {
      statusColor = Colors.orange;
      statusIcon = Icons.warning;
      statusText = 'Complete a task tomorrow to keep streak!';
    } else {
      statusColor = Colors.red;
      statusIcon = Icons.error;
      statusText = 'Complete a task today to save your streak!';
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, size: 18, color: statusColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              statusText,
              style: theme.textTheme.labelSmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact streak display for smaller spaces
class CompactStreakIndicator extends StatelessWidget {
  final bool showFireIcon;

  const CompactStreakIndicator({
    super.key,
    this.showFireIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GamificationProvider>();
    final streakInfo = provider.streakInfo;
    final theme = Theme.of(context);
    final streakDays = streakInfo.currentStreak;

    if (streakDays == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade300,
            Colors.deepOrange,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showFireIcon) ...[
            Icon(
              _getFireIcon(streakDays),
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            '$streakDays',
            style: theme.textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            ' day${streakDays == 1 ? '' : 's'}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFireIcon(int streakDays) {
    if (streakDays >= 90) return Icons.whatshot;
    if (streakDays >= 30) return Icons.local_fire_department;
    if (streakDays >= 14) return Icons.local_fire_department_rounded;
    if (streakDays >= 7) return Icons.local_fire_department;
    return Icons.local_fire_department_outlined;
  }
}

/// Animated streak counter for milestones
class StreakMilestoneCelebration extends StatelessWidget {
  final StreakMilestone milestone;
  final VoidCallback? onDismiss;

  const StreakMilestoneCelebration({
    super.key,
    required this.milestone,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(32),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.whatshot,
                    size: 64,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Milestone Reached!',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    milestone.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${milestone.days} day streak!',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: Text(
                      '+${milestone.bonus} Bonus Points',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.amber.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: onDismiss,
                    child: const Text('Awesome!'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Streak flame animation widget
class StreakFlameAnimation extends StatefulWidget {
  final int streakDays;

  const StreakFlameAnimation({
    super.key,
    required this.streakDays,
  });

  @override
  State<StreakFlameAnimation> createState() => _StreakFlameAnimationState();
}

class _StreakFlameAnimationState extends State<StreakFlameAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _flickerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _flickerAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value * _flickerAnimation.value,
          child: child,
        );
      },
      child: Icon(
        _getFireIcon(),
        size: 48,
        color: _getFireColor(),
      ),
    );
  }

  IconData _getFireIcon() {
    if (widget.streakDays >= 90) return Icons.whatshot;
    if (widget.streakDays >= 30) return Icons.local_fire_department;
    if (widget.streakDays >= 14) return Icons.local_fire_department_rounded;
    return Icons.local_fire_department;
  }

  Color _getFireColor() {
    if (widget.streakDays >= 90) return Colors.purple;
    if (widget.streakDays >= 30) return Colors.red;
    if (widget.streakDays >= 14) return Colors.orange;
    return Colors.orange.shade300;
  }
}
