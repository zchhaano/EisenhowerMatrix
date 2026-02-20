import 'package:drift/drift.dart';
import 'package:logger/logger.dart';
import '../../../../../core/database/database.dart';
import '../../models/gamification_log_model.dart';

/// Data Access Object for Gamification Logs
/// Handles all database operations related to gamification tracking
class GamificationLogDao {
  final AppDatabase _db;
  final Logger _logger;

  GamificationLogDao(this._db, this._logger);

  /// Get all logs for a user
  Future<List<GamificationLogModel>> getLogsForUser(
    String userId, {
    int? limit,
    int? offset,
  }) async {
    try {
      final query = _db.select(_db.gamificationLogs)
        ..where((tbl) => tbl.userId.equals(userId))
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);

      if (limit != null) {
        query.limit(limit, offset: offset);
      }

      final logs = await query.get();
      return logs.map((log) => GamificationLogModel.fromDrift(log)).toList();
    } catch (e) {
      _logger.e('Error getting logs for user $userId: $e');
      rethrow;
    }
  }

  /// Get logs by type
  Future<List<GamificationLogModel>> getLogsByType(
    String userId,
    GamificationLogType type, {
    int? limit,
  }) async {
    try {
      final query = _db.select(_db.gamificationLogs)
        ..where((tbl) => tbl.userId.equals(userId))
        ..where((tbl) => tbl.type.equals(type.name))
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);

      if (limit != null) {
        query.limit(limit);
      }

      final logs = await query.get();
      return logs.map((log) => GamificationLogModel.fromDrift(log)).toList();
    } catch (e) {
      _logger.e('Error getting logs for type $type: $e');
      rethrow;
    }
  }

  /// Get logs with filters
  Future<List<GamificationLogModel>> getLogsWithFilter(
    GamificationLogFilter filter, {
    int? limit,
    int? offset,
  }) async {
    try {
      final query = _db.select(_db.gamificationLogs)
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);

      if (filter.userId != null) {
        query.where((tbl) => tbl.userId.equals(filter.userId!));
      }

      if (filter.type != null) {
        query.where((tbl) => tbl.type.equals(filter.type!.name));
      }

      if (filter.startDate != null) {
        query.where((tbl) => tbl.createdAt.isBiggerOrEqualValue(filter.startDate!));
      }

      if (filter.endDate != null) {
        query.where((tbl) => tbl.createdAt.isSmallerThanValue(filter.endDate!));
      }

      if (filter.awardedOnly == true) {
        query.where((tbl) => tbl.points.isBiggerThanValue(0));
      }

      if (limit != null) {
        query.limit(limit, offset: offset);
      }

      final logs = await query.get();
      return logs.map((log) => GamificationLogModel.fromDrift(log)).toList();
    } catch (e) {
      _logger.e('Error getting logs with filter: $e');
      rethrow;
    }
  }

  /// Get log by ID
  Future<GamificationLogModel?> getLogById(String logId) async {
    try {
      final log = await (_db.select(_db.gamificationLogs)
            ..where((tbl) => tbl.id.equals(logId)))
          .getSingleOrNull();

      if (log == null) return null;
      return GamificationLogModel.fromDrift(log);
    } catch (e) {
      _logger.e('Error getting log $logId: $e');
      rethrow;
    }
  }

  /// Create a new gamification log
  Future<GamificationLogModel> createLog(GamificationLogModel log) async {
    try {
      final companion = log.toDriftCompanion();
      await _db.into(_db.gamificationLogs).insert(companion);
      _logger.i('Created gamification log ${log.id}');
      return log;
    } catch (e) {
      _logger.e('Error creating gamification log: $e');
      rethrow;
    }
  }

  /// Create log from event
  Future<GamificationLogModel> logEvent({
    required String userId,
    required GamificationLogType type,
    required int points,
    required String description,
    String? taskId,
  }) async {
    try {
      final log = GamificationLogModel(
        id: _generateUuid(),
        userId: userId,
        type: type,
        points: points,
        description: description,
        taskId: taskId,
        createdAt: DateTime.now(),
        syncStatus: SyncStatus.pending,
      );

      return await createLog(log);
    } catch (e) {
      _logger.e('Error logging event: $e');
      rethrow;
    }
  }

  /// Get logs needing sync
  Future<List<GamificationLogModel>> getLogsNeedingSync(String userId) async {
    try {
      final logs = await (_db.select(_db.gamificationLogs)
            ..where((tbl) => tbl.userId.equals(userId))
            ..where((tbl) => tbl.syncStatus.isNotIn([SyncStatus.synced.name]))
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)]))
          .get();

      return logs.map((log) => GamificationLogModel.fromDrift(log)).toList();
    } catch (e) {
      _logger.e('Error getting logs needing sync: $e');
      rethrow;
    }
  }

  /// Mark log as synced
  Future<void> markLogSynced(String logId) async {
    try {
      await (_db.update(_db.gamificationLogs)
            ..where((tbl) => tbl.id.equals(logId)))
          .write(GamificationLogsCompanion(
            syncStatus: const Value(SyncStatus.synced),
          ));
    } catch (e) {
      _logger.e('Error marking log $logId as synced: $e');
      rethrow;
    }
  }

  /// Bulk mark logs as synced
  Future<int> markLogsSynced(List<String> logIds) async {
    try {
      final count = await (_db.update(_db.gamificationLogs)
            ..where((tbl) => tbl.id.isIn(logIds)))
          .write(GamificationLogsCompanion(
            syncStatus: const Value(SyncStatus.synced),
          ));

      _logger.i('Marked $count logs as synced');
      return count;
    } catch (e) {
      _logger.e('Error marking logs as synced: $e');
      rethrow;
    }
  }

  /// Delete a log
  Future<void> deleteLog(String logId) async {
    try {
      await (_db.delete(_db.gamificationLogs)
            ..where((tbl) => tbl.id.equals(logId)))
          .go();

      _logger.i('Deleted gamification log $logId');
    } catch (e) {
      _logger.e('Error deleting log $logId: $e');
      rethrow;
    }
  }

  /// Get logs for a specific task
  Future<List<GamificationLogModel>> getLogsForTask(String taskId) async {
    try {
      final logs = await (_db.select(_db.gamificationLogs)
            ..where((tbl) => tbl.taskId.equals(taskId))
            ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
          .get();

      return logs.map((log) => GamificationLogModel.fromDrift(log)).toList();
    } catch (e) {
      _logger.e('Error getting logs for task $taskId: $e');
      rethrow;
    }
  }

  /// Calculate statistics for a user
  Future<GamificationStats> calculateStats(String userId) async {
    try {
      final logs = await getLogsForUser(userId);
      return GamificationStats.fromLogs(logs);
    } catch (e) {
      _logger.e('Error calculating stats for user $userId: $e');
      rethrow;
    }
  }

  /// Get points earned in date range
  Future<int> getPointsInDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final logs = await (_db.select(_db.gamificationLogs)
            ..where((tbl) => tbl.userId.equals(userId))
            ..where((tbl) => tbl.createdAt.isBiggerOrEqualValue(start))
            ..where((tbl) => tbl.createdAt.isSmallerThanValue(end))
            ..where((tbl) => tbl.points.isBiggerThanValue(0)))
          .get();

      return logs.fold<int>(0, (sum, log) => sum + log.points);
    } catch (e) {
      _logger.e('Error getting points in date range: $e');
      rethrow;
    }
  }

  /// Get total points for user
  Future<int> getTotalPoints(String userId) async {
    try {
      final result = await (_db.selectOnly(_db.gamificationLogs)
            ..addColumns([_db.gamificationLogs.points.sum()])
            ..where(_db.gamificationLogs.userId.equals(userId))
            ..where(_db.gamificationLogs.points.isBiggerThanValue(0)))
          .getSingleOrNull();

      final points = result?.read(_db.gamificationLogs.points.sum());
      return points ?? 0;
    } catch (e) {
      _logger.e('Error getting total points: $e');
      return 0;
    }
  }

  /// Get recent logs (last N days)
  Future<List<GamificationLogModel>> getRecentLogs(
    String userId, {
    int days = 7,
    int? limit,
  }) async {
    try {
      final cutoff = DateTime.now().subtract(Duration(days: days));

      final query = _db.select(_db.gamificationLogs)
        ..where((tbl) => tbl.userId.equals(userId))
        ..where((tbl) => tbl.createdAt.isBiggerOrEqualValue(cutoff))
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);

      if (limit != null) {
        query.limit(limit);
      }

      final logs = await query.get();
      return logs.map((log) => GamificationLogModel.fromDrift(log)).toList();
    } catch (e) {
      _logger.e('Error getting recent logs: $e');
      rethrow;
    }
  }

  /// Delete old logs (cleanup)
  Future<int> deleteOldLogs({
    int olderThanDays = 90,
    String? userId,
  }) async {
    try {
      final cutoff = DateTime.now().subtract(Duration(days: olderThanDays));

      final query = _db.delete(_db.gamificationLogs)
        ..where((tbl) => tbl.createdAt.isSmallerThanValue(cutoff));

      if (userId != null) {
        query.where((tbl) => tbl.userId.equals(userId));
      }

      final count = await query.go();
      _logger.i('Deleted $count old gamification logs');
      return count;
    } catch (e) {
      _logger.e('Error deleting old logs: $e');
      rethrow;
    }
  }

  /// Get log count for user
  Future<int> getLogCount(String userId) async {
    try {
      return await (_db.select(_db.gamificationLogs)
            ..where((tbl) => tbl.userId.equals(userId)))
          .get()
          .then((list) => list.length);
    } catch (e) {
      _logger.e('Error getting log count: $e');
      rethrow;
    }
  }

  /// Get logs grouped by type with counts
  Future<Map<GamificationLogType, int>> getLogsByTypeCount(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final query = _db.select(_db.gamificationLogs)
        ..where((tbl) => tbl.userId.equals(userId));

      if (startDate != null) {
        query.where((tbl) => tbl.createdAt.isBiggerOrEqualValue(startDate));
      }
      if (endDate != null) {
        query.where((tbl) => tbl.createdAt.isSmallerThanValue(endDate));
      }

      final logs = await query.get();

      final counts = <GamificationLogType, int>{};
      for (final log in logs) {
        counts[log.type] = (counts[log.type] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      _logger.e('Error getting logs by type count: $e');
      rethrow;
    }
  }

  /// Simple UUID generator
  String _generateUuid() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch % 10000;
    return '$timestamp-$random-${timestamp % 1000}';
  }
}
