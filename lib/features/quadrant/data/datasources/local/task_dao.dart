import 'package:drift/drift.dart';
import 'package:logger/logger.dart';
import '../../../../../core/database/database.dart';
import '../../models/tag_model.dart';
import '../../models/task_model.dart';

/// Data Access Object for Tasks
/// Handles all database operations related to tasks
class TaskDao {
  final AppDatabase _db;
  final Logger _logger;

  TaskDao(this._db, this._logger);

  /// Get all tasks for a user
  Future<List<TaskModel>> getTasksForUser(String userId) async {
    try {
      final tasks = await (_db.select(_db.tasks)
            ..where((tbl) => tbl.userId.equals(userId))
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)]))
          .get();

      return tasks.map((task) => TaskModel.fromDrift(task)).toList();
    } catch (e) {
      _logger.e('Error getting tasks for user $userId: $e');
      rethrow;
    }
  }

  /// Get tasks by quadrant
  Future<List<TaskModel>> getTasksByQuadrant(
    String userId,
    TaskQuadrant quadrant, {
    TaskStatus? status,
  }) async {
    try {
      final query = _db.select(_db.tasks)
        ..where((tbl) => tbl.userId.equals(userId))
        ..where((tbl) => tbl.quadrant.equals(quadrant.name));

      if (status != null) {
        query.where((tbl) => tbl.status.equals(status.name));
      }

      query.orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)]);

      final tasks = await query.get();
      return tasks.map((task) => TaskModel.fromDrift(task)).toList();
    } catch (e) {
      _logger.e('Error getting tasks for quadrant $quadrant: $e');
      rethrow;
    }
  }

  /// Get tasks with filters
  Future<List<TaskModel>> getTasksWithFilter(
    String userId,
    TaskFilter filter, {
    int? limit,
    int? offset,
    TaskSortOption sortBy = TaskSortOption.createdAtDesc,
  }) async {
    try {
      var query = _db.select(_db.tasks)
        ..where((tbl) => tbl.userId.equals(userId));

      if (filter.quadrant != null) {
        query = query..where((tbl) => tbl.quadrant.equals(filter.quadrant!.name));
      }

      if (filter.priority != null) {
        query = query..where((tbl) => tbl.priority.equals(filter.priority!.name));
      }

      if (filter.status != null) {
        query = query..where((tbl) => tbl.status.equals(filter.status!.name));
      }

      if (filter.onlySubtasks == true) {
        query = query..where((tbl) => tbl.parentTaskId.isNotNull());
      }

      if (filter.onlyParentTasks == true) {
        query = query..where((tbl) => tbl.parentTaskId.isNull());
      }

      if (filter.dueBefore != null) {
        query = query..where((tbl) => tbl.dueDate.isSmallerThanValue(filter.dueBefore!));
      }

      if (filter.dueAfter != null) {
        query = query..where((tbl) => tbl.dueDate.isBiggerThanValue(filter.dueAfter!));
      }

      if (filter.searchTerm != null && filter.searchTerm!.isNotEmpty) {
        final searchTerm = '%${filter.searchTerm}%';
        query = query..where((tbl) =>
          tbl.title.like(searchTerm) |
          tbl.description.like(searchTerm)
        );
      }

      // Apply ordering based on sort option
      switch (sortBy) {
        case TaskSortOption.createdAtAsc:
          query = query..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
          break;
        case TaskSortOption.createdAtDesc:
          query = query..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
          break;
        case TaskSortOption.updatedAtAsc:
          query = query..orderBy([(t) => OrderingTerm.asc(t.updatedAt)]);
          break;
        case TaskSortOption.updatedAtDesc:
          query = query..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);
          break;
        case TaskSortOption.dueDateAsc:
          query = query..orderBy([
            (t) => OrderingTerm.asc(t.dueDate),
            (t) => OrderingTerm.asc(t.priority),
          ]);
          break;
        case TaskSortOption.dueDateDesc:
          query = query..orderBy([
            (t) => OrderingTerm.desc(t.dueDate),
            (t) => OrderingTerm.desc(t.priority),
          ]);
          break;
        case TaskSortOption.priorityAsc:
          query = query..orderBy([(t) => OrderingTerm.asc(t.priority)]);
          break;
        case TaskSortOption.priorityDesc:
          query = query..orderBy([(t) => OrderingTerm.desc(t.priority)]);
          break;
        case TaskSortOption.titleAsc:
          query = query..orderBy([(t) => OrderingTerm.asc(t.title)]);
          break;
        case TaskSortOption.titleDesc:
          query = query..orderBy([(t) => OrderingTerm.desc(t.title)]);
          break;
      }

      final tasks = await query.get();
      return tasks.map((task) => TaskModel.fromDrift(task)).toList();
    } catch (e) {
      _logger.e('Error getting tasks with filter: $e');
      rethrow;
    }
  }

  /// Get task by ID
  Future<TaskModel?> getTaskById(String taskId) async {
    try {
      final task = await (_db.select(_db.tasks)
            ..where((tbl) => tbl.id.equals(taskId)))
          .getSingleOrNull();

      if (task == null) return null;

      final tags = await _getTagsForTask(taskId);
      return TaskModel.fromDrift(task, tags);
    } catch (e) {
      _logger.e('Error getting task $taskId: $e');
      rethrow;
    }
  }

  /// Get subtasks for a parent task
  Future<List<TaskModel>> getSubtasks(String parentTaskId) async {
    try {
      final tasks = await (_db.select(_db.tasks)
            ..where((tbl) => tbl.parentTaskId.equals(parentTaskId))
            ..where((tbl) => tbl.status.isNotIn([TaskStatus.deleted.name]))
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)]))
          .get();

      return tasks.map((task) => TaskModel.fromDrift(task)).toList();
    } catch (e) {
      _logger.e('Error getting subtasks for $parentTaskId: $e');
      rethrow;
    }
  }

  /// Create a new task
  Future<TaskModel> createTask(TaskModel task) async {
    try {
      final companion = task.toDriftCompanion();
      await _db.into(_db.tasks).insert(companion);

      if (task.tags != null && task.tags!.isNotEmpty) {
        await _addTagsToTask(task.id, task.tags!);
      }

      _logger.i('Created task ${task.id}');
      return task;
    } catch (e) {
      _logger.e('Error creating task: $e');
      rethrow;
    }
  }

  /// Update an existing task
  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      final companion = task.toDriftCompanion();
      await (_db.update(_db.tasks)
            ..where((tbl) => tbl.id.equals(task.id)))
          .write(companion);

      if (task.tags != null) {
        await _updateTaskTags(task.id, task.tags!);
      }

      _logger.i('Updated task ${task.id}');
      return task;
    } catch (e) {
      _logger.e('Error updating task ${task.id}: $e');
      rethrow;
    }
  }

  /// Delete a task (soft delete)
  Future<void> deleteTask(String taskId) async {
    try {
      await (_db.update(_db.tasks)
            ..where((tbl) => tbl.id.equals(taskId)))
          .write(TasksCompanion(
            status: const Value(TaskStatus.deleted),
            updatedAt: Value(DateTime.now()),
            syncStatus: const Value(SyncStatus.pending),
          ));

      _logger.i('Soft deleted task $taskId');
    } catch (e) {
      _logger.e('Error deleting task $taskId: $e');
      rethrow;
    }
  }

  /// Permanently delete a task
  Future<void> permanentDeleteTask(String taskId) async {
    try {
      await (_db.delete(_db.tasks)
            ..where((tbl) => tbl.id.equals(taskId)))
          .go();

      _logger.i('Permanently deleted task $taskId');
    } catch (e) {
      _logger.e('Error permanently deleting task $taskId: $e');
      rethrow;
    }
  }

  /// Get tasks that need syncing
  Future<List<TaskModel>> getTasksNeedingSync(String userId) async {
    try {
      final tasks = await (_db.select(_db.tasks)
            ..where((tbl) => tbl.userId.equals(userId))
            ..where((tbl) => tbl.syncStatus.isNotIn([SyncStatus.synced.name]))
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.updatedAt)]))
          .get();

      return tasks.map((task) => TaskModel.fromDrift(task)).toList();
    } catch (e) {
      _logger.e('Error getting tasks needing sync: $e');
      rethrow;
    }
  }

  /// Get overdue tasks
  Future<List<TaskModel>> getOverdueTasks(String userId) async {
    try {
      final now = DateTime.now();
      final tasks = await (_db.select(_db.tasks)
            ..where((tbl) => tbl.userId.equals(userId))
            ..where((tbl) => tbl.dueDate.isSmallerThanValue(now))
            ..where((tbl) => tbl.status.isNotIn([
                  TaskStatus.completed.name,
                  TaskStatus.deleted.name,
                ]))
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.dueDate)]))
          .get();

      return tasks.map((task) => TaskModel.fromDrift(task)).toList();
    } catch (e) {
      _logger.e('Error getting overdue tasks: $e');
      rethrow;
    }
  }

  /// Get tasks due today
  Future<List<TaskModel>> getTasksDueToday(String userId) async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      final tasks = await (_db.select(_db.tasks)
            ..where((tbl) => tbl.userId.equals(userId))
            ..where((tbl) => tbl.dueDate.isBiggerOrEqualValue(todayStart))
            ..where((tbl) => tbl.dueDate.isSmallerThanValue(todayEnd))
            ..where((tbl) => tbl.status.isNotIn([
                  TaskStatus.completed.name,
                  TaskStatus.deleted.name,
                ]))
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.dueDate)]))
          .get();

      return tasks.map((task) => TaskModel.fromDrift(task)).toList();
    } catch (e) {
      _logger.e('Error getting tasks due today: $e');
      rethrow;
    }
  }

  /// Get tasks due soon (within specified days)
  Future<List<TaskModel>> getTasksDueSoon(
    String userId, {
    int days = 3,
  }) async {
    try {
      final now = DateTime.now();
      final dueSoon = now.add(Duration(days: days));

      final tasks = await (_db.select(_db.tasks)
            ..where((tbl) => tbl.userId.equals(userId))
            ..where((tbl) => tbl.dueDate.isBiggerOrEqualValue(now))
            ..where((tbl) => tbl.dueDate.isSmallerThanValue(dueSoon))
            ..where((tbl) => tbl.status.isNotIn([
                  TaskStatus.completed.name,
                  TaskStatus.deleted.name,
                ]))
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.dueDate)]))
          .get();

      return tasks.map((task) => TaskModel.fromDrift(task)).toList();
    } catch (e) {
      _logger.e('Error getting tasks due soon: $e');
      rethrow;
    }
  }

  /// Count tasks by quadrant for a user
  Future<Map<TaskQuadrant, int>> countTasksByQuadrant(
    String userId, {
    TaskStatus? status,
  }) async {
    try {
      final counts = <TaskQuadrant, int>{};

      for (final quadrant in TaskQuadrant.values) {
        final query = _db.select(_db.tasks)
          ..where((tbl) => tbl.userId.equals(userId))
          ..where((tbl) => tbl.quadrant.equals(quadrant.name));

        if (status != null) {
          query.where((tbl) => tbl.status.equals(status.name));
        }

        final count = await query.get().then((list) => list.length);
        counts[quadrant] = count;
      }

      return counts;
    } catch (e) {
      _logger.e('Error counting tasks by quadrant: $e');
      rethrow;
    }
  }

  /// Mark task as completed
  Future<TaskModel> markTaskCompleted(String taskId) async {
    try {
      final now = DateTime.now();
      await (_db.update(_db.tasks)
            ..where((tbl) => tbl.id.equals(taskId)))
          .write(TasksCompanion(
            status: const Value(TaskStatus.completed),
            completedAt: Value(now),
            updatedAt: Value(now),
            syncStatus: const Value(SyncStatus.pending),
          ));

      final updatedTask = await getTaskById(taskId);
      if (updatedTask == null) {
        throw Exception('Task not found after update');
      }

      _logger.i('Marked task $taskId as completed');
      return updatedTask;
    } catch (e) {
      _logger.e('Error marking task $taskId as completed: $e');
      rethrow;
    }
  }

  /// Bulk update task sync status
  Future<int> updateTasksSyncStatus(
    List<String> taskIds,
    SyncStatus status,
  ) async {
    try {
      final count = await (_db.update(_db.tasks)
            ..where((tbl) => tbl.id.isIn(taskIds)))
          .write(TasksCompanion(
            syncStatus: Value(status),
            updatedAt: Value(DateTime.now()),
          ));

      _logger.i('Updated sync status for $count tasks');
      return count;
    } catch (e) {
      _logger.e('Error updating tasks sync status: $e');
      rethrow;
    }
  }

  /// Get task count for user
  Future<int> getTaskCount(
    String userId, {
    TaskStatus? status,
    bool includeDeleted = false,
  }) async {
    try {
      final query = _db.select(_db.tasks)
        ..where((tbl) => tbl.userId.equals(userId));

      if (status != null) {
        query.where((tbl) => tbl.status.equals(status.name));
      }

      if (!includeDeleted) {
        query.where((tbl) => tbl.status.isNotIn([TaskStatus.deleted.name]));
      }

      return await query.get().then((list) => list.length);
    } catch (e) {
      _logger.e('Error getting task count: $e');
      rethrow;
    }
  }

  /// Search tasks by text
  Future<List<TaskModel>> searchTasks(
    String userId,
    String query, {
    int limit = 20,
  }) async {
    try {
      final searchTerm = '%$query%';

      final tasks = await (_db.select(_db.tasks)
            ..where((tbl) => tbl.userId.equals(userId))
            ..where((tbl) =>
              tbl.title.like(searchTerm) |
              tbl.description.like(searchTerm)
            )
            ..where((tbl) => tbl.status.isNotIn([TaskStatus.deleted.name]))
            ..limit(limit)
            ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)]))
          .get();

      return tasks.map((task) => TaskModel.fromDrift(task)).toList();
    } catch (e) {
      _logger.e('Error searching tasks: $e');
      rethrow;
    }
  }

  /// Get tags for a task
  Future<List<TagModel>> _getTagsForTask(String taskId) async {
    try {
      final query = _db.select(_db.tags).join([
        innerJoin(
          _db.taskTags,
          _db.taskTags.tagId.equalsExp(_db.tags.id),
        ),
      ])
        ..where(_db.taskTags.taskId.equals(taskId));

      final results = await query.get();
      return results.map((row) {
        final tag = row.readTable(_db.tags);
        return TagModel.fromDrift(tag);
      }).toList();
    } catch (e) {
      _logger.e('Error getting tags for task $taskId: $e');
      return [];
    }
  }

  /// Add tags to a task
  Future<void> _addTagsToTask(String taskId, List<TagModel> tags) async {
    try {
      for (final tag in tags) {
        await _db.into(_db.taskTags).insert(
          TaskTagsCompanion(
            taskId: Value(taskId),
            tagId: Value(tag.id),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    } catch (e) {
      _logger.e('Error adding tags to task $taskId: $e');
      rethrow;
    }
  }

  /// Update task tags
  Future<void> _updateTaskTags(String taskId, List<TagModel> tags) async {
    try {
      await (_db.delete(_db.taskTags)
            ..where((tbl) => tbl.taskId.equals(taskId)))
          .go();

      await _addTagsToTask(taskId, tags);
    } catch (e) {
      _logger.e('Error updating tags for task $taskId: $e');
      rethrow;
    }
  }

  /// Get deleted tasks for trash view
  Future<List<TaskModel>> getDeletedTasks(String userId) async {
    try {
      final tasks = await (_db.select(_db.tasks)
            ..where((tbl) => tbl.userId.equals(userId))
            ..where((tbl) => tbl.status.equals(TaskStatus.deleted.name))
            ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)])
          ).get();

      return tasks.map((task) => TaskModel.fromDrift(task)).toList();
    } catch (e) {
      _logger.e('Error getting deleted tasks: $e');
      rethrow;
    }
  }

  /// Restore a deleted task
  Future<void> restoreTask(String taskId) async {
    try {
      await (_db.update(_db.tasks)
            ..where((tbl) => tbl.id.equals(taskId)))
          .write(TasksCompanion(
            status: const Value(TaskStatus.pending),
            updatedAt: Value(DateTime.now()),
            syncStatus: const Value(SyncStatus.pending),
          ));

      _logger.i('Restored task $taskId');
    } catch (e) {
      _logger.e('Error restoring task $taskId: $e');
      rethrow;
    }
  }

  /// Get subtask completion count
  Future<Map<String, int>> getSubtaskCompletionCount(String parentTaskId) async {
    try {
      final subtasks = await (_db.select(_db.tasks)
            ..where((tbl) => tbl.parentTaskId.equals(parentTaskId))
            ..where((tbl) => tbl.status.isNotIn([TaskStatus.deleted.name]))
          ).get();

      final completed = subtasks.where((t) => t.status == TaskStatus.completed).length;
      return {
        'total': subtasks.length,
        'completed': completed,
      };
    } catch (e) {
      _logger.e('Error getting subtask completion count: $e');
      return {'total': 0, 'completed': 0};
    }
  }

  /// Create subtask
  Future<TaskModel> createSubtask(TaskModel subtask) async {
    try {
      if (subtask.parentTaskId == null) {
        throw Exception('Subtask must have a parentTaskId');
      }
      return await createTask(subtask);
    } catch (e) {
      _logger.e('Error creating subtask: $e');
      rethrow;
    }
  }

  /// Count overdue tasks
  Future<int> countOverdueTasks(String userId) async {
    try {
      final now = DateTime.now();
      final tasks = await (_db.select(_db.tasks)
            ..where((tbl) => tbl.userId.equals(userId))
            ..where((tbl) => tbl.dueDate.isSmallerThanValue(now))
            ..where((tbl) => tbl.status.isNotIn([
                  TaskStatus.completed.name,
                  TaskStatus.deleted.name,
                ])))
          .get();

      return tasks.length;
    } catch (e) {
      _logger.e('Error counting overdue tasks: $e');
      return 0;
    }
  }
}
