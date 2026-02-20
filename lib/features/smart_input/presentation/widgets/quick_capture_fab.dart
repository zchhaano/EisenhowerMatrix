import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import 'smart_input_bottom_sheet.dart';

/// Quick Capture Floating Action Button
///
/// Provides fast task entry with:
/// - Tap to open quick capture modal
/// - Long press for voice input (if supported)
class QuickCaptureFab extends StatefulWidget {
  final VoidCallback? onCaptureComplete;
  final String? heroTag;

  const QuickCaptureFab({
    super.key,
    this.onCaptureComplete,
    this.heroTag,
  });

  @override
  State<QuickCaptureFab> createState() => _QuickCaptureFabState();
}

class _QuickCaptureFabState extends State<QuickCaptureFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  void _handleTap() {
    _showQuickCaptureSheet();
  }

  Future<void> _handleLongPress() async {
    // Voice input feature - could be expanded with speech_to_text package
    setState(() => _isListening = true);

    // Simulate voice input (replace with actual speech recognition)
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isListening = false);
      // Show quick capture with simulated voice result
      _showQuickCaptureSheet(initialText: 'Voice input task');
    }
  }

  void _showQuickCaptureSheet({String? initialText}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SmartInputBottomSheet(
        initialText: initialText,
        onCaptureComplete: (task) {
          Navigator.pop(context);
          widget.onCaptureComplete?.call();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onLongPress: _handleLongPress,
        child: FloatingActionButton.extended(
          heroTag: widget.heroTag ?? 'quick_capture_fab',
          onPressed: _isListening ? null : _handleTap,
          backgroundColor: _isListening
              ? AppColors.error
              : (isDark ? AppColors.darkPrimary : AppColors.lightPrimary),
          foregroundColor: _isListening
              ? AppColors.q1OnLight
              : (isDark ? AppColors.darkOnPrimary : AppColors.lightOnPrimary),
          elevation: _isListening ? 8 : 4,
          icon: _isListening
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.add_task_rounded),
          label: Text(_isListening ? 'Listening...' : 'Quick Capture'),
          extendedPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingM,
            vertical: AppConstants.spacingS,
          ),
        ),
      ),
    );
  }
}

/// Compact version of QuickCaptureFab for smaller screens
class QuickCaptureFabSmall extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? heroTag;

  const QuickCaptureFabSmall({
    super.key,
    this.onPressed,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: heroTag ?? 'quick_capture_fab_small',
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => SmartInputBottomSheet(
            onCaptureComplete: (task) {
              Navigator.pop(context);
              onPressed?.call();
            },
          ),
        );
      },
      child: const Icon(Icons.add),
    );
  }
}
