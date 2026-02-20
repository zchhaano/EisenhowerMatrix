import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../quadrant/domain/entities/quadrant.dart';
import '../../domain/services/nlp_parser.dart';

/// Smart input field with NLP suggestions and real-time parsing
///
/// Features:
/// - Real-time NLP parsing as user types
/// - Visual feedback for detected attributes (urgency, importance, dates)
/// - Suggestions for quadrant placement
/// - Tag chips display
class SmartInputField extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final int maxLines;
  final VoidCallback? onSubmitted;
  final ValueChanged<NLPResult?>? onResultChanged;
  final bool autoFocus;
  final bool showSuggestions;
  final InputDecoration? decoration;

  const SmartInputField({
    super.key,
    required this.controller,
    this.hintText,
    this.maxLines = 1,
    this.onSubmitted,
    this.onResultChanged,
    this.autoFocus = false,
    this.showSuggestions = true,
    this.decoration,
  });

  @override
  State<SmartInputField> createState() => _SmartInputFieldState();
}

class _SmartInputFieldState extends State<SmartInputField> {
  late final FocusNode _focusNode;
  NLPResult? _currentResult;
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final text = widget.controller.text.trim();
    setState(() {
      if (text.isEmpty) {
        _currentResult = null;
        _showResults = false;
      } else {
        try {
          _currentResult = NLPParser.parse(text);
          _showResults = true;
        } catch (_) {
          _currentResult = null;
        }
      }
    });
    widget.onResultChanged?.call(_currentResult);
  }

  void _handleSubmit() {
    if (_currentResult != null) {
      widget.onSubmitted?.call();
      widget.controller.clear();
      setState(() {
        _currentResult = null;
        _showResults = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          autofocus: widget.autoFocus,
          maxLines: widget.maxLines,
          textCapitalization: TextCapitalization.sentences,
          decoration: widget.decoration ??
              InputDecoration(
            hintText: widget.hintText ?? '输入任务，如: "明天完成紧急的项目报告"',
            hintStyle: TextStyle(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            filled: true,
            fillColor: isDark
                ? AppColors.darkSurfaceVariant
                : AppColors.lightSurfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusL),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusL),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusL),
              borderSide: BorderSide(
                color: isDark
                    ? AppColors.darkPrimary
                    : AppColors.lightPrimary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingM,
              vertical: AppConstants.spacingM,
            ),
            suffixIcon: _currentResult != null
                ? IconButton(
                    icon: const Icon(Icons.send_rounded),
                    onPressed: _handleSubmit,
                  )
                : null,
          ),
          onSubmitted: (_) => _handleSubmit(),
        ),
        if (widget.showSuggestions && _showResults && _currentResult != null)
          _buildSuggestions(context, isDark),
      ],
    );
  }

  Widget _buildSuggestions(BuildContext context, bool isDark) {
    final result = _currentResult!;
    final chips = <Widget>[];

    // Urgency tag
    if (result.detectedTags.contains('urgent')) {
      chips.add(_buildChip(
        context: context,
        icon: Icons.warning_rounded,
        label: '紧急',
        color: AppColors.q1Light,
        isDark: isDark,
      ));
    }

    // Importance tag
    if (result.detectedTags.contains('important')) {
      chips.add(_buildChip(
        context: context,
        icon: Icons.star_rounded,
        label: '重要',
        color: AppColors.q2Light,
        isDark: isDark,
      ));
    }

    // Due date tag
    if (result.suggestedDueDate != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final targetDay = DateTime(
        result.suggestedDueDate!.year,
        result.suggestedDueDate!.month,
        result.suggestedDueDate!.day,
      );
      final diff = targetDay.difference(today).inDays;

      String dateLabel;
      if (diff == 0) {
        dateLabel = '今天';
      } else if (diff == 1) {
        dateLabel = '明天';
      } else if (diff == 2) {
        dateLabel = '后天';
      } else {
        dateLabel = '${result.suggestedDueDate!.month}月${result.suggestedDueDate!.day}日';
      }

      chips.add(_buildChip(
        context: context,
        icon: Icons.calendar_today_rounded,
        label: dateLabel,
        color: AppColors.info,
        isDark: isDark,
      ));
    }

    // Suggested quadrant
    if (result.suggestedQuadrant != null) {
      String quadrantLabel;
      Color quadrantColor;

      switch (result.suggestedQuadrant!) {
        case QuadrantType.first:
          quadrantLabel = 'Q1 立即做';
          quadrantColor = AppColors.q1Light;
          break;
        case QuadrantType.second:
          quadrantLabel = 'Q2 计划做';
          quadrantColor = AppColors.q2Light;
          break;
        case QuadrantType.third:
          quadrantLabel = 'Q3 委派做';
          quadrantColor = AppColors.q3Light;
          break;
        case QuadrantType.fourth:
          quadrantLabel = 'Q4 待定/删除';
          quadrantColor = AppColors.q4Light;
          break;
      }

      chips.add(_buildChip(
        context: context,
        icon: Icons.dashboard_rounded,
        label: quadrantLabel,
        color: quadrantColor,
        isDark: isDark,
      ));
    }

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(top: AppConstants.spacingS),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingS,
        vertical: AppConstants.spacingXS,
      ),
      child: Wrap(
        spacing: AppConstants.spacingS,
        runSpacing: AppConstants.spacingS,
        children: chips,
      ),
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Chip(
      avatar: Icon(
        icon,
        size: 16,
        color: isDark ? Colors.white : color,
      ),
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 12,
        color: isDark ? Colors.white : color,
        fontWeight: FontWeight.w500,
      ),
      backgroundColor: isDark ? color.withValues(alpha: 0.2) : color.withValues(alpha: 0.1),
      side: BorderSide(
        color: color.withValues(alpha: 0.3),
        width: 1,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingS,
        vertical: 0,
      ),
      visualDensity: VisualDensity.compact,
    );
  }
}

/// Multiline version of SmartInputField for detailed task entry
class SmartInputTextArea extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final int maxLines;
  final int minLines;
  final VoidCallback? onSubmitted;
  final ValueChanged<NLPResult?>? onResultChanged;

  const SmartInputTextArea({
    super.key,
    required this.controller,
    this.hintText,
    this.maxLines = 5,
    this.minLines = 3,
    this.onSubmitted,
    this.onResultChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SmartInputField(
      controller: controller,
      hintText: hintText,
      maxLines: maxLines,
      onSubmitted: onSubmitted,
      onResultChanged: onResultChanged,
      showSuggestions: true,
    );
  }
}
