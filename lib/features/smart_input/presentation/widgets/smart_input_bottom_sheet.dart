import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../quadrant/domain/entities/task.dart' as quad;
import '../../../quadrant/domain/entities/quadrant.dart';
import '../../domain/services/nlp_parser.dart';
import '../providers/quick_capture_provider.dart';
import 'smart_input_field.dart';

/// Bottom sheet for smart input task capture
class SmartInputBottomSheet extends StatefulWidget {
  final String? initialText;
  final Function(quad.Task)? onCaptureComplete;
  final bool allowQuadrantEdit;

  const SmartInputBottomSheet({
    super.key,
    this.initialText,
    this.onCaptureComplete,
    this.allowQuadrantEdit = true,
  });

  @override
  State<SmartInputBottomSheet> createState() => _SmartInputBottomSheetState();
}

class _SmartInputBottomSheetState extends State<SmartInputBottomSheet> {
  late final TextEditingController _controller;
  NLPResult? _currentResult;
  QuadrantType? _selectedQuadrant;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    if (widget.initialText != null) {
      try {
        _currentResult = NLPParser.parse(widget.initialText!);
        _selectedQuadrant = _currentResult?.suggestedQuadrant;
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onResultChanged(NLPResult? result) {
    setState(() {
      _currentResult = result;
      _selectedQuadrant ??= result?.suggestedQuadrant;
    });
  }

  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    try {
      final result = _currentResult ?? NLPParser.parse(text);

      final provider = QuickCaptureProvider();
      final task = provider.createFromResult(result);

      // Allow quadrant override
      if (_selectedQuadrant != null) {
        final adjustedTask = task.moveTo(_selectedQuadrant!);
        widget.onCaptureComplete?.call(adjustedTask);
      } else {
        widget.onCaptureComplete?.call(task);
      }
    } catch (e) {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusXL),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(
                  top: AppConstants.spacingS,
                  bottom: AppConstants.spacingM,
                ),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceVariant
                      : AppColors.lightSurfaceVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingL,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.flash_on_rounded,
                      color: isDark
                          ? AppColors.darkPrimary
                          : AppColors.lightPrimary,
                    ),
                    const SizedBox(width: AppConstants.spacingS),
                    Text(
                      'Quick Capture',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Input section
              Padding(
                padding: const EdgeInsets.all(AppConstants.spacingL),
                child: SmartInputField(
                  controller: _controller,
                  hintText: 'Enter task, e.g., "Tomorrow urgent project report"',
                  maxLines: 3,
                  autoFocus: true,
                  onResultChanged: _onResultChanged,
                  onSubmitted: _handleSubmit,
                ),
              ),

              // Quadrant selector (if allowed)
              if (widget.allowQuadrantEdit && _currentResult != null)
                _buildQuadrantSelector(isDark),

              // Action buttons
              Padding(
                padding: const EdgeInsets.all(AppConstants.spacingL),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppConstants.spacingM,
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingM),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _currentResult != null ? _handleSubmit : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppConstants.spacingM,
                          ),
                          backgroundColor: isDark
                              ? AppColors.darkPrimary
                              : AppColors.lightPrimary,
                          foregroundColor: isDark
                              ? AppColors.darkOnPrimary
                              : AppColors.lightOnPrimary,
                        ),
                        child: const Text('Create Task'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuadrantSelector(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingL,
        vertical: AppConstants.spacingS,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Assign to Quadrant',
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          Wrap(
            spacing: AppConstants.spacingS,
            children: QuadrantType.values.map((quadrant) {
              final isSelected = _selectedQuadrant == quadrant;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedQuadrant = quadrant;
                  });
                },
                child: _QuadrantChip(
                  quadrant: quadrant,
                  isSelected: isSelected,
                  isDark: isDark,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _QuadrantChip extends StatelessWidget {
  final QuadrantType quadrant;
  final bool isSelected;
  final bool isDark;

  const _QuadrantChip({
    required this.quadrant,
    required this.isSelected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color = quadrant.color;
    final backgroundColor = quadrant.backgroundColor;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingM,
        vertical: AppConstants.spacingS,
      ),
      decoration: BoxDecoration(
        color: isSelected ? color : backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(
          color: isSelected ? color : color.withValues(alpha: 0.3),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getQuadrantIcon(quadrant),
            size: 16,
            color: isSelected
                ? (isDark ? Colors.black : Colors.white)
                : color,
          ),
          const SizedBox(width: AppConstants.spacingXS),
          Text(
            quadrant.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected
                  ? (isDark ? Colors.black : Colors.white)
                  : color,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getQuadrantIcon(QuadrantType quadrant) {
    switch (quadrant) {
      case QuadrantType.first:
        return Icons.flash_on_rounded;
      case QuadrantType.second:
        return Icons.calendar_today_rounded;
      case QuadrantType.third:
        return Icons.people_rounded;
      case QuadrantType.fourth:
        return Icons.delete_outline_rounded;
    }
  }
}
