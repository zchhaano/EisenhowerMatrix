import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:drift/drift.dart' hide JsonKey;
import '../../../../core/database/database.dart';
import 'tag_model.dart';

part 'task_model.freezed.dart';

/// Task entity model with domain-specific behavior
/// This extends the generated Drift Task class with additional methods
@freezed
class TaskModel with _$TaskModel {
  const factory TaskModel({
    required String id,
    required String title,
    String? description,
    required TaskQuadrant quadrant,
    required TaskPriority priority,
    required TaskStatus status,
    DateTime? dueDate,
    DateTime? completedAt,
    String? parentTaskId,
    required String userId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required SyncStatus syncStatus,
    int? remoteVersion,
    DateTime? serverTimestamp,
    List<TagModel>? tags,
  }) = _TaskModel;

  const TaskModel._();

  /// Create from Drift Task
  factory TaskModel.fromDrift(Task task, [List<TagModel>? tags]) {
    return TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      quadrant: task.quadrant,
      priority: task.priority,
      status: task.status,
      dueDate: task.dueDate,
      completedAt: task.completedAt,
      parentTaskId: task.parentTaskId,
      userId: task.userId,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
      syncStatus: task.syncStatus,
      remoteVersion: task.remoteVersion,
      serverTimestamp: task.serverTimestamp,
      tags: tags,
    );
  }

  /// Convert to Drift TasksCompanion for database operations
  TasksCompanion toDriftCompanion() {
    return TasksCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      quadrant: Value(quadrant),
      priority: Value(priority),
      status: Value(status),
      dueDate: dueDate != null ? Value(dueDate!) : const Value.absent(),
      completedAt: completedAt != null ? Value(completedAt!) : const Value.absent(),
      parentTaskId: parentTaskId != null ? Value(parentTaskId!) : const Value.absent(),
      userId: Value(userId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
      remoteVersion: remoteVersion != null ? Value(remoteVersion!) : const Value.absent(),
      serverTimestamp: serverTimestamp != null ? Value(serverTimestamp!) : const Value.absent(),
    );
  }

  /// Check if task is overdue
  bool get isOverdue {
    if (dueDate == null || status == TaskStatus.completed) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  /// Check if task is deleted
  bool get isDeleted => status == TaskStatus.deleted;

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
    if (dueDate == null || status == TaskStatus.completed) return false;
    final now = DateTime.now();
    final dueSoon = now.add(const Duration(days: 3));
    return dueDate!.isBefore(dueSoon);
  }

  /// Check if task has subtasks
  bool get hasSubtasks => parentTaskId != null;

  /// Check if task is in urgent quadrant (Q1)
  bool get isUrgentAndImportant => quadrant == TaskQuadrant.q1;

  /// Check if task is important but not urgent (Q2)
  bool get isImportantNotUrgent => quadrant == TaskQuadrant.q2;

  /// Check if task is urgent but not important (Q3)
  bool get isUrgentNotImportant => quadrant == TaskQuadrant.q3;

  /// Check if task is neither urgent nor important (Q4)
  bool get isNeitherUrgentNorImportant => quadrant == TaskQuadrant.q4;

  /// Get priority weight for sorting
  int get priorityWeight {
    switch (priority) {
      case TaskPriority.urgent:
        return 4;
      case TaskPriority.high:
        return 3;
      case TaskPriority.medium:
        return 2;
      case TaskPriority.low:
        return 1;
    }
  }

  /// Check if task needs sync
  bool get needsSync => syncStatus != SyncStatus.synced;

  /// Calculate days until due
  int? get daysUntilDue {
    if (dueDate == null) return null;
    final now = DateTime.now();
    final difference = dueDate!.difference(now).inDays;
    return difference;
  }

  /// Get display name for quadrant
  String get quadrantDisplayName {
    switch (quadrant) {
      case TaskQuadrant.q1:
        return 'Do First';
      case TaskQuadrant.q2:
        return 'Schedule';
      case TaskQuadrant.q3:
        return 'Delegate';
      case TaskQuadrant.q4:
        return 'Eliminate';
    }
  }

  /// Get display name for priority
  String get priorityDisplayName {
    switch (priority) {
      case TaskPriority.urgent:
        return 'Urgent';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }

  /// Create copy with completion status
  TaskModel markAsCompleted() {
    return copyWith(
      status: TaskStatus.completed,
      completedAt: DateTime.now(),
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pending,
    );
  }

  /// Create copy with in-progress status
  TaskModel markAsInProgress() {
    return copyWith(
      status: TaskStatus.inProgress,
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pending,
    );
  }

  /// Create copy with pending status
  TaskModel markAsPending() {
    return copyWith(
      status: TaskStatus.pending,
      completedAt: null,
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pending,
    );
  }

  /// Move to different quadrant
  TaskModel moveToQuadrant(TaskQuadrant newQuadrant) {
    return copyWith(
      quadrant: newQuadrant,
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pending,
    );
  }

  /// Update priority
  TaskModel updatePriority(TaskPriority newPriority) {
    return copyWith(
      priority: newPriority,
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pending,
    );
  }

  /// Mark for sync
  TaskModel markForSync() {
    return copyWith(syncStatus: SyncStatus.pending);
  }

  /// Mark as synced
  TaskModel markAsSynced(int? version) {
    return copyWith(
      syncStatus: SyncStatus.synced,
      remoteVersion: version ?? remoteVersion,
      serverTimestamp: DateTime.now(),
    );
  }

  /// Mark as conflict
  TaskModel markAsConflict() {
    return copyWith(syncStatus: SyncStatus.conflict);
  }

  /// Soft delete the task
  TaskModel markAsDeleted() {
    return copyWith(
      status: TaskStatus.deleted,
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pending,
    );
  }

  /// Restore a deleted task
  TaskModel restore() {
    return copyWith(
      status: TaskStatus.pending,
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pending,
    );
  }
}

/// Task list filter options
class TaskFilter {
  final TaskQuadrant? quadrant;
  final TaskPriority? priority;
  final TaskStatus? status;
  final DateTime? dueBefore;
  final DateTime? dueAfter;
  final String? searchTerm;
  final List<String>? tagIds;
  final bool? onlySubtasks;
  final bool? onlyParentTasks;
  final bool? onlyOverdue;
  final bool? onlyDueToday;

  const TaskFilter({
    this.quadrant,
    this.priority,
    this.status,
    this.dueBefore,
    this.dueAfter,
    this.searchTerm,
    this.tagIds,
    this.onlySubtasks,
    this.onlyParentTasks,
    this.onlyOverdue,
    this.onlyDueToday,
  });

  /// Empty filter (no constraints)
  static const empty = TaskFilter();

  /// Check if filter has any active constraints
  bool get hasFilters =>
      quadrant != null ||
      priority != null ||
      status != null ||
      dueBefore != null ||
      dueAfter != null ||
      searchTerm != null ||
      (tagIds != null && tagIds!.isNotEmpty) ||
      onlySubtasks != null ||
      onlyParentTasks != null ||
      onlyOverdue != null ||
      onlyDueToday != null;

  /// Create copy with modified fields
  TaskFilter copyWith({
    TaskQuadrant? quadrant,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueBefore,
    DateTime? dueAfter,
    String? searchTerm,
    List<String>? tagIds,
    bool? onlySubtasks,
    bool? onlyParentTasks,
    bool? onlyOverdue,
    bool? onlyDueToday,
  }) {
    return TaskFilter(
      quadrant: quadrant ?? this.quadrant,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueBefore: dueBefore ?? this.dueBefore,
      dueAfter: dueAfter ?? this.dueAfter,
      searchTerm: searchTerm ?? this.searchTerm,
      tagIds: tagIds ?? this.tagIds,
      onlySubtasks: onlySubtasks ?? this.onlySubtasks,
      onlyParentTasks: onlyParentTasks ?? this.onlyParentTasks,
      onlyOverdue: onlyOverdue ?? this.onlyOverdue,
      onlyDueToday: onlyDueToday ?? this.onlyDueToday,
    );
  }
}

/// Task sort options
enum TaskSortOption {
  createdAtAsc,
  createdAtDesc,
  updatedAtAsc,
  updatedAtDesc,
  dueDateAsc,
  dueDateDesc,
  priorityAsc,
  priorityDesc,
  titleAsc,
  titleDesc,
}

/// Task list result with pagination
class TaskListResult {
  final List<TaskModel> tasks;
  final int totalCount;
  final int? nextPageToken;

  const TaskListResult({
    required this.tasks,
    required this.totalCount,
    this.nextPageToken,
  });

  /// Check if there are more results
  bool get hasMoreResults => nextPageToken != null;
}
