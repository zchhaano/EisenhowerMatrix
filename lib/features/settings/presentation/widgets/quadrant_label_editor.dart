import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../../../../core/theme/app_colors.dart';

/// Widget for editing quadrant labels directly in place.
///
/// This can be used as a standalone widget or integrated into
/// the settings screen.
class QuadrantLabelEditor extends ConsumerStatefulWidget {
  const QuadrantLabelEditor({super.key});

  @override
  ConsumerState<QuadrantLabelEditor> createState() => _QuadrantLabelEditorState();
}

class _QuadrantLabelEditorState extends ConsumerState<QuadrantLabelEditor> {
  late TextEditingController _q1Controller;
  late TextEditingController _q2Controller;
  late TextEditingController _q3Controller;
  late TextEditingController _q4Controller;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final labels = ref.read(settingsProvider).quadrantLabels;
    _q1Controller = TextEditingController(text: labels.q1Label);
    _q2Controller = TextEditingController(text: labels.q2Label);
    _q3Controller = TextEditingController(text: labels.q3Label);
    _q4Controller = TextEditingController(text: labels.q4Label);
  }

  @override
  void dispose() {
    _q1Controller.dispose();
    _q2Controller.dispose();
    _q3Controller.dispose();
    _q4Controller.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    if (_isEditing) {
      // Cancel editing - restore original values
      _q1Controller.dispose();
      _q2Controller.dispose();
      _q3Controller.dispose();
      _q4Controller.dispose();
      _initControllers();
      setState(() => _isEditing = false);
    } else {
      setState(() => _isEditing = true);
    }
  }

  void _saveLabels() {
    final labels = QuadrantLabels(
      q1Label: _q1Controller.text.trim().isEmpty ? 'Do First' : _q1Controller.text.trim(),
      q2Label: _q2Controller.text.trim().isEmpty ? 'Schedule' : _q2Controller.text.trim(),
      q3Label: _q3Controller.text.trim().isEmpty ? 'Delegate' : _q3Controller.text.trim(),
      q4Label: _q4Controller.text.trim().isEmpty ? 'Eliminate' : _q4Controller.text.trim(),
    );
    ref.read(settingsProvider.notifier).updateQuadrantLabels(labels);
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final labels = ref.watch(settingsProvider).quadrantLabels;
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.label_outline,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Quadrant Labels',
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
                if (_isEditing)
                  Row(
                    children: [
                      TextButton(
                        onPressed: _toggleEdit,
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: _saveLabels,
                        child: const Text('Save'),
                      ),
                    ],
                  )
                else
                  TextButton.icon(
                    onPressed: _toggleEdit,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2,
              children: [
                _QuadrantLabelInput(
                  controller: _q1Controller,
                  label: labels.q1Label,
                  color: AppColors.q1Light,
                  isEditing: _isEditing,
                  description: 'Q1: Urgent + Important',
                ),
                _QuadrantLabelInput(
                  controller: _q2Controller,
                  label: labels.q2Label,
                  color: AppColors.q2Light,
                  isEditing: _isEditing,
                  description: 'Q2: Not Urgent + Important',
                ),
                _QuadrantLabelInput(
                  controller: _q3Controller,
                  label: labels.q3Label,
                  color: AppColors.q3Light,
                  isEditing: _isEditing,
                  description: 'Q3: Urgent + Not Important',
                ),
                _QuadrantLabelInput(
                  controller: _q4Controller,
                  label: labels.q4Label,
                  color: AppColors.q4Light,
                  isEditing: _isEditing,
                  description: 'Q4: Not Urgent + Not Important',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual quadrant label input field.
class _QuadrantLabelInput extends StatelessWidget {
  const _QuadrantLabelInput({
    required this.controller,
    required this.label,
    required this.color,
    required this.isEditing,
    required this.description,
  });

  final TextEditingController controller;
  final String label;
  final Color color;
  final bool isEditing;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.1),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          if (isEditing)
            TextField(
              controller: controller,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            )
          else
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}
