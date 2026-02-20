import 'package:flutter/material.dart';
import '../../domain/entities/quadrant.dart';

/// Bottom sheet modal for creating/editing tasks
class TaskCreationModal extends StatefulWidget {
  final QuadrantType? initialQuadrant;
  final String? initialTitle;
  final String? initialDescription;
  final DateTime? initialDueDate;
  final int initialPriority;
  final bool isEditing;
  final String? parentTaskId; // For subtasks

  const TaskCreationModal({
    super.key,
    this.initialQuadrant,
    this.initialTitle,
    this.initialDescription,
    this.initialDueDate,
    this.initialPriority = 0,
    this.isEditing = false,
    this.parentTaskId,
  });

  /// Show the modal and return the task data if confirmed
  static Future<Map<String, dynamic>?> show({
    required BuildContext context,
    QuadrantType? initialQuadrant,
    String? initialTitle,
    String? initialDescription,
    DateTime? initialDueDate,
    int initialPriority = 0,
    bool isEditing = false,
    String? parentTaskId,
  }) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskCreationModal(
        initialQuadrant: initialQuadrant,
        initialTitle: initialTitle,
        initialDescription: initialDescription,
        initialDueDate: initialDueDate,
        initialPriority: initialPriority,
        isEditing: isEditing,
        parentTaskId: parentTaskId,
      ),
    );
  }

  @override
  State<TaskCreationModal> createState() => _TaskCreationModalState();
}

class _TaskCreationModalState extends State<TaskCreationModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  QuadrantType? _selectedQuadrant;
  DateTime? _dueDate;
  int _priority = 0;
  final List<SubtaskItem> _subtasks = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _descriptionController = TextEditingController(text: widget.initialDescription);
    _selectedQuadrant = widget.initialQuadrant;
    _dueDate = widget.initialDueDate;
    _priority = widget.initialPriority;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addSubtask() {
    setState(() {
      _subtasks.add(SubtaskItem());
    });
  }

  void _removeSubtask(int index) {
    setState(() {
      _subtasks.removeAt(index);
    });
  }

  void _updateSubtaskTitle(int index, String title) {
    setState(() {
      _subtasks[index].title = title;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    widget.isEditing ? 'Edit Task' : 'Create New Task',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Task Title
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Task Title',
                      hintText: 'What needs to be done?',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.edit_outlined),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a task title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      hintText: 'Add more details...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description_outlined),
                    ),
                    maxLines: 3,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  // Quadrant Selection
                  _buildQuadrantSelector(theme),
                  const SizedBox(height: 16),
                  // Due Date
                  _buildDueDateSelector(theme),
                  const SizedBox(height: 16),
                  // Priority
                  _buildPrioritySelector(theme),
                  const SizedBox(height: 16),
                  // Subtasks section
                  _buildSubtasksSection(theme),
                  const SizedBox(height: 24),
                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _handleSubmit,
                          child: Text(widget.isEditing ? 'Save' : 'Create'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuadrantSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quadrant',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: QuadrantType.values.map((type) {
            final isSelected = _selectedQuadrant == type;
            return FilterChip(
              label: Text(type.label),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedQuadrant = selected ? type : null;
                });
              },
              selectedColor: type.color.withOpacity(0.3),
              checkmarkColor: type.color,
              avatar: CircleAvatar(
                backgroundColor: type.color,
                child: Icon(
                  _getQuadrantIcon(type),
                  color: Colors.white,
                  size: 16,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDueDateSelector(ThemeData theme) {
    return InkWell(
      onTap: _pickDueDate,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _dueDate != null
                    ? 'Due: ${_formatDate(_dueDate!)}'
                    : 'No due date',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            if (_dueDate != null)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _dueDate = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtasksSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Subtasks',
              style: theme.textTheme.titleSmall,
            ),
            TextButton.icon(
              onPressed: _addSubtask,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_subtasks.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'No subtasks yet. Tap "Add" to create one.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          )
        else
          ..._subtasks.asMap().entries.map((entry) {
            final index = entry.key;
            final subtask = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    subtask.isCompleted
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 20,
                    color: subtask.isCompleted ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      initialValue: subtask.title,
                      decoration: InputDecoration(
                        hintText: 'Subtask ${index + 1}',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onChanged: (value) => _updateSubtaskTitle(index, value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () => _removeSubtask(index),
                    tooltip: 'Remove subtask',
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildPrioritySelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(4, (index) {
            final priority = index + 1;
            final isSelected = _priority == priority;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text('P$priority'),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _priority = selected ? priority : 0;
                  });
                },
                selectedColor: Colors.orange.withOpacity(0.3),
                avatar: isSelected
                    ? const Icon(Icons.flag, size: 16)
                    : const Icon(Icons.outlined_flag, size: 16),
              ),
            );
          }),
        ),
      ],
    );
  }

  IconData _getQuadrantIcon(QuadrantType type) {
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

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );

    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedQuadrant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a quadrant')),
      );
      return;
    }

    Navigator.pop(context, {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'quadrant': _selectedQuadrant,
      'dueDate': _dueDate,
      'priority': _priority,
      'subtasks': _subtasks.where((s) => s.title.isNotEmpty).toList(),
    });
  }
}

/// Subtask item for the task creation modal
class SubtaskItem {
  String title;
  bool isCompleted;

  SubtaskItem({
    this.title = '',
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'isCompleted': isCompleted,
    };
  }
}
