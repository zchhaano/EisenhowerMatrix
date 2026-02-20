import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/quadrant.dart';
import '../../../../core/database/database.dart' hide Task;

/// Fixed default user UUID (used before auth is implemented)
const _defaultUserId = '00000000-0000-0000-0000-000000000000';

/// Task filter state
class TaskFilterState {
  final TaskQuadrant? quadrant;
  final TaskPriority? priority;
  final TaskStatus? status;
  final DateTime? dueBefore;
  final String? searchTerm;
  final List<String>? tagIds;
  final bool? onlyOverdue;
  final bool? onlyDueToday;

  const TaskFilterState({
    this.quadrant,
    this.priority,
    this.status,
    this.dueBefore,
    this.searchTerm,
    this.tagIds,
    this.onlyOverdue,
    this.onlyDueToday,
  });

  TaskFilterState copyWith({
    TaskQuadrant? quadrant,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueBefore,
    String? searchTerm,
    List<String>? tagIds,
    bool? onlyOverdue,
    bool? onlyDueToday,
    bool clearQuadrant = false,
    bool clearPriority = false,
    bool clearStatus = false,
    bool clearDueBefore = false,
    bool clearSearchTerm = false,
    bool clearOnlyOverdue = false,
    bool clearOnlyDueToday = false,
  }) {
    return TaskFilterState(
      quadrant: clearQuadrant ? null : (quadrant ?? this.quadrant),
      priority: clearPriority ? null : (priority ?? this.priority),
      status: clearStatus ? null : (status ?? this.status),
      dueBefore: clearDueBefore ? null : (dueBefore ?? this.dueBefore),
      searchTerm: clearSearchTerm ? null : (searchTerm ?? this.searchTerm),
      tagIds: tagIds ?? this.tagIds,
      onlyOverdue: clearOnlyOverdue ? null : (onlyOverdue ?? this.onlyOverdue),
      onlyDueToday: clearOnlyDueToday ? null : (onlyDueToday ?? this.onlyDueToday),
    );
  }

  bool get hasActiveFilters =>
      quadrant != null ||
      priority != null ||
      status != null ||
      dueBefore != null ||
      (searchTerm?.isNotEmpty ?? false) ||
      (tagIds?.isNotEmpty ?? false) ||
      onlyOverdue == true ||
      onlyDueToday == true;

  static const empty = TaskFilterState();
}

/// Task sort options
enum TaskSortOption {
  dueDateAsc,
  dueDateDesc,
  priorityAsc,
  priorityDesc,
  createdAtAsc,
  createdAtDesc,
  titleAsc,
  titleDesc,
}

/// Task list state
class TaskListState {
  final List<Task> tasks;
  final bool isLoading;
  final String? error;
  final TaskFilterState filter;
  final TaskSortOption sortOption;

  const TaskListState({
    this.tasks = const [],
    this.isLoading = false,
    this.error,
    this.filter = TaskFilterState.empty,
    this.sortOption = TaskSortOption.dueDateAsc,
  });

  TaskListState copyWith({
    List<Task>? tasks,
    bool? isLoading,
    String? error,
    TaskFilterState? filter,
    TaskSortOption? sortOption,
  }) {
    return TaskListState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filter: filter ?? this.filter,
      sortOption: sortOption ?? this.sortOption,
    );
  }

  /// Get tasks grouped by quadrant
  Map<QuadrantType, List<Task>> get tasksByQuadrant {
    final result = <QuadrantType, List<Task>>{
      QuadrantType.first: [],
      QuadrantType.second: [],
      QuadrantType.third: [],
      QuadrantType.fourth: [],
    };

    for (final task in tasks) {
      result[task.quadrant]?.add(task);
    }

    return result;
  }
}

/// Task list notifier
class TaskListNotifier extends StateNotifier<TaskListState> {
  final AppDatabase _db;

  TaskListNotifier(this._db) : super(const TaskListState()) {
    loadTasks();
  }

  /// Load tasks with current filter and sort
  Future<void> loadTasks() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Build query based on filter
      var query = _db.select(_db.tasks);

      // Apply filters
      if (state.filter.quadrant != null) {
        query.where((t) => t.quadrant.equals(state.filter.quadrant!.name));
      }
      if (state.filter.priority != null) {
        query.where((t) => t.priority.equals(state.filter.priority!.name));
      }
      if (state.filter.status != null) {
        query.where((t) => t.status.equals(state.filter.status!.name));
      }
      if (state.filter.searchTerm?.isNotEmpty ?? false) {
        final term = '%${state.filter.searchTerm}%';
        query.where((t) => t.title.like(term) | t.description.like(term));
      }

      // Apply overdue filter
      if (state.filter.onlyOverdue == true) {
        final now = DateTime.now();
        query.where((t) => t.dueDate.isSmallerThanValue(now));
      }

      // Apply due today filter
      if (state.filter.onlyDueToday == true) {
        final now = DateTime.now();
        final todayStart = DateTime(now.year, now.month, now.day);
        final todayEnd = todayStart.add(const Duration(days: 1));
        query.where((t) => t.dueDate.isBiggerOrEqualValue(todayStart));
        query.where((t) => t.dueDate.isSmallerThanValue(todayEnd));
      }

      // Exclude deleted tasks from normal view
      query.where((t) => t.status.isNotIn([TaskStatus.deleted.name]));

      // Apply sorting
      switch (state.sortOption) {
        case TaskSortOption.dueDateAsc:
          query.orderBy([(t) => OrderingTerm.asc(t.dueDate)]);
          break;
        case TaskSortOption.dueDateDesc:
          query.orderBy([(t) => OrderingTerm.desc(t.dueDate)]);
          break;
        case TaskSortOption.priorityAsc:
          query.orderBy([(t) => OrderingTerm.asc(t.priority)]);
          break;
        case TaskSortOption.priorityDesc:
          query.orderBy([(t) => OrderingTerm.desc(t.priority)]);
          break;
        case TaskSortOption.createdAtAsc:
          query.orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
          break;
        case TaskSortOption.createdAtDesc:
          query.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
          break;
        case TaskSortOption.titleAsc:
          query.orderBy([(t) => OrderingTerm.asc(t.title)]);
          break;
        case TaskSortOption.titleDesc:
          query.orderBy([(t) => OrderingTerm.desc(t.title)]);
          break;
      }

      final tasks = await query.get();

      // Convert to domain entities
      final domainTasks = tasks.map((t) => Task(
        id: t.id,
        title: t.title,
        description: t.description,
        quadrant: _mapQuadrant(t.quadrant),
        priority: _mapPriority(t.priority),
        isCompleted: t.status == TaskStatus.completed,
        isDeleted: t.status == TaskStatus.deleted,
        dueDate: t.dueDate,
        completedAt: t.completedAt,
        createdAt: t.createdAt,
        updatedAt: t.updatedAt,
        parentTaskId: t.parentTaskId,
      )).toList();

      state = state.copyWith(tasks: domainTasks, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Set filter
  void setFilter(TaskFilterState filter) {
    state = state.copyWith(filter: filter);
    loadTasks();
  }

  /// Set overdue filter
  void toggleOverdueFilter() {
    final newFilter = state.filter.copyWith(
      onlyOverdue: state.filter.onlyOverdue == null ? true : null,
      clearOnlyOverdue: state.filter.onlyOverdue != null,
    );
    state = state.copyWith(filter: newFilter);
    loadTasks();
  }

  /// Toggle showing completed tasks
  void toggleCompletedFilter() {
    final isCurrentlyShowingCompleted = state.filter.status == TaskStatus.completed;
    final newFilter = isCurrentlyShowingCompleted
        ? state.filter.copyWith(clearStatus: true)
        : state.filter.copyWith(status: TaskStatus.completed);
    state = state.copyWith(filter: newFilter);
    loadTasks();
  }

  /// Undo last action
  Future<bool> undoLastAction() async {
    if (_lastDeletedTaskId != null) {
      final success = await restoreTask(_lastDeletedTaskId!);
      if (success) {
        _lastDeletedTaskId = null;
      }
      return success;
    }
    return false;
  }

  String? _lastDeletedTaskId;

  /// Clear all filters
  void clearFilters() {
    state = state.copyWith(filter: TaskFilterState.empty);
    loadTasks();
  }

  /// Set sort option
  void setSortOption(TaskSortOption option) {
    state = state.copyWith(sortOption: option);
    loadTasks();
  }

  /// Create new task
  Future<Task?> createTask({
    required String title,
    String? description,
    required QuadrantType quadrant,
    int priority = 1,
    DateTime? dueDate,
  }) async {
    try {
      final id = const Uuid().v4();
      final now = DateTime.now();

      await _db.into(_db.tasks).insert(
        TasksCompanion(
          id: Value(id),
          title: Value(title),
          description: Value(description),
          quadrant: Value(_quadrantToDb(quadrant)),
          priority: Value(_priorityToDb(priority)),
          userId: const Value(_defaultUserId),
          status: const Value(TaskStatus.pending),
          syncStatus: const Value(SyncStatus.pending),
          dueDate: Value(dueDate),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      await loadTasks();
      return state.tasks.firstWhere((t) => t.id == id);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Update task
  Future<bool> updateTask(Task task, {
    String? title,
    String? description,
    QuadrantType? quadrant,
    int? priority,
    bool? isCompleted,
    DateTime? dueDate,
  }) async {
    try {
      final updatedTask = task.copyWith(
        title: title ?? task.title,
        description: description ?? task.description,
        quadrant: quadrant ?? task.quadrant,
        priority: priority ?? task.priority,
        isCompleted: isCompleted ?? task.isCompleted,
        dueDate: dueDate ?? task.dueDate,
        updatedAt: DateTime.now(),
      );

      // Update in database
      await (_db.update(_db.tasks)..where((t) => t.id.equals(task.id))).write(
        TasksCompanion(
          title: Value(updatedTask.title),
          description: Value(updatedTask.description),
          quadrant: Value(_quadrantToDb(updatedTask.quadrant)),
          priority: Value(_priorityToDb(updatedTask.priority)),
          status: Value(updatedTask.isCompleted ? TaskStatus.completed : TaskStatus.pending),
          dueDate: Value(updatedTask.dueDate),
          updatedAt: Value(DateTime.now()),
        ),
      );

      await loadTasks();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Delete task (soft delete)
  Future<bool> deleteTask(String taskId) async {
    try {
      _lastDeletedTaskId = taskId;
      await (_db.update(_db.tasks)..where((t) => t.id.equals(taskId))).write(
        TasksCompanion(
          status: const Value(TaskStatus.deleted),
          updatedAt: Value(DateTime.now()),
        ),
      );

      await loadTasks();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      _lastDeletedTaskId = null;
      return false;
    }
  }

  /// Restore soft deleted task
  Future<bool> restoreTask(String taskId) async {
    try {
      await (_db.update(_db.tasks)..where((t) => t.id.equals(taskId))).write(
        TasksCompanion(
          status: const Value(TaskStatus.pending),
          updatedAt: Value(DateTime.now()),
        ),
      );

      await loadTasks();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Get deleted tasks
  Future<List<Task>> getDeletedTasks() async {
    try {
      final tasks = await (_db.select(_db.tasks)
        ..where((t) => t.status.equals(TaskStatus.deleted.name))
        ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
      ).get();

      return tasks.map((t) => Task(
        id: t.id,
        title: t.title,
        description: t.description,
        quadrant: _mapQuadrant(t.quadrant),
        priority: _mapPriority(t.priority),
        isCompleted: t.status == TaskStatus.completed,
        isDeleted: true,
        dueDate: t.dueDate,
        completedAt: t.completedAt,
        createdAt: t.createdAt,
        updatedAt: t.updatedAt,
      )).toList();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return [];
    }
  }

  /// Permanently delete task
  Future<bool> permanentDeleteTask(String taskId) async {
    try {
      await (_db.delete(_db.tasks)..where((t) => t.id.equals(taskId))).go();
      await loadTasks();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Toggle task completion status
  Future<bool> completeTask(String taskId) async {
    try {
      // Read current task to check status
      final task = await (_db.select(_db.tasks)..where((t) => t.id.equals(taskId))).getSingleOrNull();
      if (task == null) return false;

      final isCurrentlyCompleted = task.status == TaskStatus.completed;

      await (_db.update(_db.tasks)..where((t) => t.id.equals(taskId))).write(
        TasksCompanion(
          status: Value(isCurrentlyCompleted ? TaskStatus.pending : TaskStatus.completed),
          completedAt: isCurrentlyCompleted ? const Value(null) : Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );

      await loadTasks();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Uncomplete task (undo completion)
  Future<bool> uncompleteTask(String taskId) async {
    try {
      await (_db.update(_db.tasks)..where((t) => t.id.equals(taskId))).write(
        TasksCompanion(
          status: const Value(TaskStatus.pending),
          completedAt: const Value(null),
          updatedAt: Value(DateTime.now()),
        ),
      );

      await loadTasks();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Move task to different quadrant
  Future<bool> moveTaskToQuadrant(String taskId, QuadrantType newQuadrant) async {
    try {
      await (_db.update(_db.tasks)..where((t) => t.id.equals(taskId))).write(
        TasksCompanion(
          quadrant: Value(_quadrantToDb(newQuadrant)),
          updatedAt: Value(DateTime.now()),
        ),
      );

      await loadTasks();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Mapping helpers
  QuadrantType _mapQuadrant(TaskQuadrant q) {
    switch (q) {
      case TaskQuadrant.q1: return QuadrantType.first;
      case TaskQuadrant.q2: return QuadrantType.second;
      case TaskQuadrant.q3: return QuadrantType.third;
      case TaskQuadrant.q4: return QuadrantType.fourth;
    }
  }

  TaskQuadrant _quadrantToDb(QuadrantType q) {
    switch (q) {
      case QuadrantType.first: return TaskQuadrant.q1;
      case QuadrantType.second: return TaskQuadrant.q2;
      case QuadrantType.third: return TaskQuadrant.q3;
      case QuadrantType.fourth: return TaskQuadrant.q4;
    }
  }

  int _mapPriority(TaskPriority p) {
    switch (p) {
      case TaskPriority.low: return 0;
      case TaskPriority.medium: return 1;
      case TaskPriority.high: return 2;
      case TaskPriority.urgent: return 3;
    }
  }

  TaskPriority _priorityToDb(int p) {
    switch (p) {
      case 0: return TaskPriority.low;
      case 1: return TaskPriority.medium;
      case 2: return TaskPriority.high;
      case 3: return TaskPriority.urgent;
      default: return TaskPriority.medium;
    }
  }
}

/// Providers
final taskListProvider = StateNotifierProvider<TaskListNotifier, TaskListState>((ref) {
  return TaskListNotifier(AppDatabase.instance);
});

final tasksByQuadrantProvider = Provider<Map<QuadrantType, List<Task>>>((ref) {
  return ref.watch(taskListProvider).tasksByQuadrant;
});

final taskFilterProvider = Provider<TaskFilterState>((ref) {
  return ref.watch(taskListProvider).filter;
});

final taskSortOptionProvider = Provider<TaskSortOption>((ref) {
  return ref.watch(taskListProvider).sortOption;
});

final filteredTasksCountProvider = Provider<int>((ref) {
  return ref.watch(taskListProvider).tasks.length;
});

/// Provider for overdue tasks
final overdueTasksProvider = Provider<List<Task>>((ref) {
  return ref.watch(taskListProvider).tasks.where((t) => t.isOverdue).toList();
});
