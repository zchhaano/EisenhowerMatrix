import 'quadrant.dart';

/// Task entity for the Eisenhower Matrix
class Task {
  final String id;
  final String title;
  final String? description;
  final QuadrantType quadrant;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final DateTime? updatedAt;
  final int priority;
  final List<String> tags;
  final String? projectId;
  final String? parentTaskId;
  final bool isDeleted;

  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.quadrant,
    this.isCompleted = false,
    required this.createdAt,
    this.dueDate,
    this.completedAt,
    this.updatedAt,
    this.priority = 0,
    this.tags = const [],
    this.projectId,
    this.parentTaskId,
    this.isDeleted = false,
  });

  /// Check if task is overdue
  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  /// Check if task is due today
  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  /// Check if task is due soon (within 3 days)
  bool get isDueSoon {
    if (dueDate == null || isCompleted) return false;
    final now = DateTime.now();
    final difference = dueDate!.difference(now);
    return difference.inDays > 0 && difference.inDays <= 3;
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    QuadrantType? quadrant,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? dueDate,
    DateTime? completedAt,
    DateTime? updatedAt,
    int? priority,
    List<String>? tags,
    String? projectId,
    String? parentTaskId,
    bool? isDeleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      quadrant: quadrant ?? this.quadrant,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      projectId: projectId ?? this.projectId,
      parentTaskId: parentTaskId ?? this.parentTaskId,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  /// Create a completed copy of this task
  Task markCompleted() {
    return copyWith(isCompleted: true);
  }

  /// Create an uncompleted copy of this task
  Task markUncompleted() {
    return copyWith(isCompleted: false);
  }

  /// Move task to a different quadrant
  Task moveTo(QuadrantType newQuadrant) {
    return copyWith(quadrant: newQuadrant);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
