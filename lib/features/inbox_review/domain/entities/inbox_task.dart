import '../../../quadrant/domain/entities/quadrant.dart';

/// Task in the inbox awaiting review
///
/// Inbox tasks are created from quick capture before being
/// sorted into quadrants via the review flow
class InboxTask {
  final String id;
  final String title;
  final String? description;
  final DateTime createdAt;
  final DateTime? dueDate;
  final List<String> tags;
  final int priority;
  final bool isProcessed;
  final QuadrantType? suggestedQuadrant;

  const InboxTask({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
    this.dueDate,
    this.tags = const [],
    this.priority = 0,
    this.isProcessed = false,
    this.suggestedQuadrant,
  });

  /// Create from a map (for database storage)
  factory InboxTask.fromJson(Map<String, dynamic> json) {
    return InboxTask(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      tags: List<String>.from(json['tags'] as List? ?? []),
      priority: json['priority'] as int? ?? 0,
      isProcessed: json['isProcessed'] as bool? ?? false,
      suggestedQuadrant: json['suggestedQuadrant'] != null
          ? QuadrantType.values[json['suggestedQuadrant'] as int]
          : null,
    );
  }

  /// Convert to map (for database storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'tags': tags,
      'priority': priority,
      'isProcessed': isProcessed,
      'suggestedQuadrant': suggestedQuadrant?.index,
    };
  }

  /// Create a copy with modified fields
  InboxTask copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? dueDate,
    List<String>? tags,
    int? priority,
    bool? isProcessed,
    QuadrantType? suggestedQuadrant,
    bool clearQuadrant = false,
  }) {
    return InboxTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      tags: tags ?? this.tags,
      priority: priority ?? this.priority,
      isProcessed: isProcessed ?? this.isProcessed,
      suggestedQuadrant: clearQuadrant ? null : (suggestedQuadrant ?? this.suggestedQuadrant),
    );
  }

  /// Mark as processed with a specific quadrant
  InboxTask markProcessed(QuadrantType quadrant) {
    return copyWith(
      isProcessed: true,
      suggestedQuadrant: quadrant,
    );
  }

  /// Mark as processed (will be deleted)
  InboxTask markAsDeleted() {
    return copyWith(isProcessed: true);
  }

  /// Reset processed state
  InboxTask resetProcessed() {
    return copyWith(isProcessed: false, clearQuadrant: true);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InboxTask &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'InboxTask(id: $id, title: $title, priority: $priority, '
        'suggestedQuadrant: $suggestedQuadrant)';
  }
}

/// Filter options for inbox tasks
enum InboxFilter {
  all,
  unprocessed,
  processed,
  urgent,
  important,
}

/// Sort options for inbox tasks
enum InboxSort {
  createdAt,
  priority,
  dueDate,
  suggestedQuadrant,
}

/// Extension to provide labels for filters
extension InboxFilterX on InboxFilter {
  String get label {
    switch (this) {
      case InboxFilter.all:
        return '全部';
      case InboxFilter.unprocessed:
        return '未处理';
      case InboxFilter.processed:
        return '已处理';
      case InboxFilter.urgent:
        return '紧急';
      case InboxFilter.important:
        return '重要';
    }
  }
}

/// Extension to provide labels for sort options
extension InboxSortX on InboxSort {
  String get label {
    switch (this) {
      case InboxSort.createdAt:
        return '创建时间';
      case InboxSort.priority:
        return '优先级';
      case InboxSort.dueDate:
        return '截止日期';
      case InboxSort.suggestedQuadrant:
        return '建议象限';
    }
  }
}
