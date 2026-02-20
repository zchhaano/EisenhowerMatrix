import 'package:flutter/material.dart';
import '../../domain/entities/task_suggestion.dart';
import '../../domain/services/ai_service.dart';

/// Widget displaying AI-generated task suggestions
class AISuggestionCard extends StatelessWidget {
  final TaskSuggestion suggestion;
  final VoidCallback? onApplySuggestion;
  final VoidCallback? onDismiss;
  final VoidCallback? onAlternativeSelected;

  const AISuggestionCard({
    super.key,
    required this.suggestion,
    this.onApplySuggestion,
    this.onDismiss,
    this.onAlternativeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quadrantColor = _getQuadrantColor(suggestion.recommendedQuadrant);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: quadrantColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Suggestion',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: quadrantColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        suggestion.recommendedQuadrant.displayName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: quadrantColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onDismiss != null)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onDismiss,
                    tooltip: 'Dismiss',
                  ),
              ],
            ),
            const Divider(height: 24),
            Text(
              suggestion.suggestedTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            if (suggestion.reasoning != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      suggestion.reasoning!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (suggestion.estimatedDuration != null)
                  _buildInfoChip(
                    context,
                    icon: Icons.schedule,
                    label: _formatDuration(suggestion.estimatedDuration!),
                  ),
                _buildInfoChip(
                  context,
                  icon: Icons.psychology,
                  label: '${(suggestion.confidence * 100).toInt()}% confidence',
                ),
                ...suggestion.tags.map((tag) => _buildTagChip(context, tag)),
              ],
            ),
            if (suggestion.alternativeTitles.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Alternative titles:',
                style: theme.textTheme.labelSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: suggestion.alternativeTitles.map((alt) {
                  return ActionChip(
                    label: Text(alt),
                    onPressed: onAlternativeSelected,
                  );
                }).toList(),
              ),
            ],
            if (onApplySuggestion != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onApplySuggestion,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Apply Suggestion'),
                style: FilledButton.styleFrom(
                  backgroundColor: quadrantColor.withOpacity(0.2),
                  foregroundColor: quadrantColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    final theme = Theme.of(context);
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      labelStyle: theme.textTheme.bodySmall,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildTagChip(BuildContext context, String tag) {
    return Chip(
      label: Text(tag),
      labelStyle: const TextStyle(fontSize: 12),
      visualDensity: VisualDensity.compact,
      side: BorderSide.none,
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
    );
  }

  Color _getQuadrantColor(EisenhowerQuadrant quadrant) {
    switch (quadrant) {
      case EisenhowerQuadrant.q1:
        return const Color(0xFFE53935); // Red
      case EisenhowerQuadrant.q2:
        return const Color(0xFF43A047); // Green
      case EisenhowerQuadrant.q3:
        return const Color(0xFFFB8C00); // Orange
      case EisenhowerQuadrant.q4:
        return const Color(0xFF757575); // Gray
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
    return '${duration.inMinutes}m';
  }
}

/// Compact version of AI suggestion for inline display
class CompactAISuggestion extends StatelessWidget {
  final TaskSuggestion suggestion;
  final VoidCallback? onTap;

  const CompactAISuggestion({
    super.key,
    required this.suggestion,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quadrantColor = _getQuadrantColor(suggestion.recommendedQuadrant);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: quadrantColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: quadrantColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.psychology,
              size: 16,
              color: quadrantColor,
            ),
            const SizedBox(width: 8),
            Text(
              suggestion.recommendedQuadrant.displayName,
              style: theme.textTheme.labelSmall?.copyWith(
                color: quadrantColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getQuadrantColor(EisenhowerQuadrant quadrant) {
    switch (quadrant) {
      case EisenhowerQuadrant.q1:
        return const Color(0xFFE53935);
      case EisenhowerQuadrant.q2:
        return const Color(0xFF43A047);
      case EisenhowerQuadrant.q3:
        return const Color(0xFFFB8C00);
      case EisenhowerQuadrant.q4:
        return const Color(0xFF757575);
    }
  }
}
