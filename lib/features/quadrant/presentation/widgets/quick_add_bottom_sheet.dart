import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/quadrant.dart';
import '../../../smart_input/domain/services/nlp_parser.dart';

/// Quick-add bottom sheet for fast task creation via long-press
class QuickAddBottomSheet extends StatefulWidget {
  final QuadrantType quadrant;
  final Function(String title, String? description, DateTime? dueDate, int priority) onSave;
  final VoidCallback? onVoiceInput;

  const QuickAddBottomSheet({
    super.key,
    required this.quadrant,
    required this.onSave,
    this.onVoiceInput,
  });

  /// Show the quick-add bottom sheet
  static Future<void> show({
    required BuildContext context,
    required QuadrantType quadrant,
    required Function(String title, String? description, DateTime? dueDate, int priority) onSave,
    VoidCallback? onVoiceInput,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickAddBottomSheet(
        quadrant: quadrant,
        onSave: onSave,
        onVoiceInput: onVoiceInput,
      ),
    );
  }

  @override
  State<QuickAddBottomSheet> createState() => _QuickAddBottomSheetState();
}

class _QuickAddBottomSheetState extends State<QuickAddBottomSheet> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isLoading = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    // Auto-focus the text field when the sheet opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSave() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      HapticFeedback.lightImpact();
      return;
    }

    setState(() => _isLoading = true);

    // Parse the input using NLP
    final result = NLPParser.parse(text);

    widget.onSave(
      result.title,
      result.description,
      result.suggestedDueDate,
      result.suggestedPriority,
    );

    setState(() => _isLoading = false);
    Navigator.of(context).pop();
  }

  void _handleVoiceInput() {
    setState(() => _isListening = !_isListening);
    widget.onVoiceInput?.call();
  }

  void _handleCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: widget.quadrant.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Add to ${widget.quadrant.label}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  widget.quadrant.labelZh,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: widget.quadrant.color,
                  ),
                ),
              ],
            ),
          ),

          // Text input
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleSave(),
                    decoration: InputDecoration(
                      hintText: 'Enter task title...',
                      hintStyle: TextStyle(
                        color: theme.hintColor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.dividerColor,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.dividerColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: widget.quadrant.color,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Voice input button
                if (widget.onVoiceInput != null)
                  IconButton(
                    onPressed: _handleVoiceInput,
                    icon: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: _isListening
                          ? widget.quadrant.color
                          : theme.iconTheme.color,
                    ),
                    tooltip: 'Voice input',
                  ),
              ],
            ),
          ),

          // Hint text
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Text(
              'Tip: Use natural language like "明天开会 高优" for quick parsing',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isLoading ? null : _handleCancel,
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.quadrant.color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text('Add Task'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
