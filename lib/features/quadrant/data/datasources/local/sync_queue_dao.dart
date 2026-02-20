import 'package:drift/drift.dart';
import 'package:logger/logger.dart';
import '../../../../../core/database/database.dart';

/// Sync queue item model for domain layer
class SyncQueueItemModel {
  final String id;
  final String entityType;
  final String entityId;
  final SyncOperationType operation;
  final String payload;
  final int priority;
  final int retryCount;
  final String? lastError;
  final DateTime queuedAt;
  final DateTime? lastAttemptAt;
  final String status;
  final String? userId;

  const SyncQueueItemModel({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payload,
    required this.priority,
    required this.retryCount,
    this.lastError,
    required this.queuedAt,
    this.lastAttemptAt,
    required this.status,
    this.userId,
  });

  factory SyncQueueItemModel.fromDrift(SyncQueueData item) {
    return SyncQueueItemModel(
      id: item.id,
      entityType: item.entityType,
      entityId: item.entityId,
      operation: item.operation,
      payload: item.payload,
      priority: item.priority,
      retryCount: item.retryCount,
      lastError: item.lastError,
      queuedAt: item.queuedAt,
      lastAttemptAt: item.lastAttemptAt,
      status: item.status,
      userId: item.userId,
    );
  }
}

/// Sync queue status
class SyncQueueStatus {
  static const String pending = 'pending';
  static const String processing = 'processing';
  static const String completed = 'completed';
  static const String failed = 'failed';
}

/// Data Access Object for Sync Queue
/// Manages offline sync operations queue
class SyncQueueDao {
  final AppDatabase _db;
  final Logger _logger;

  SyncQueueDao(this._db, this._logger);

  /// Add item to sync queue
  Future<void> enqueue({
    required String entityType,
    required String entityId,
    required SyncOperationType operation,
    required String payload,
    int priority = 0,
    String? userId,
  }) async {
    try {
      await _db.into(_db.syncQueue).insert(
        SyncQueueCompanion(
          id: Value(_generateUuid()),
          entityType: Value(entityType),
          entityId: Value(entityId),
          operation: Value(operation),
          payload: Value(payload),
          priority: Value(priority),
          status: const Value(SyncQueueStatus.pending),
          userId: Value(userId),
        ),
        mode: InsertMode.replace,
      );

      _logger.i('Enqueued $operation on $entityType:$entityId');
    } catch (e) {
      _logger.e('Error enqueuing sync item: $e');
      rethrow;
    }
  }

  /// Get next pending items (ordered by priority)
  Future<List<SyncQueueItemModel>> getPendingItems({
    int? limit,
    String? userId,
  }) async {
    try {
      final query = _db.select(_db.syncQueue)
        ..where((tbl) => tbl.status.equals(SyncQueueStatus.pending))
        ..orderBy([
          (tbl) => OrderingTerm.desc(tbl.priority),
          (tbl) => OrderingTerm.asc(tbl.queuedAt),
        ]);

      if (userId != null) {
        query.where((tbl) => tbl.userId.equals(userId));
      }

      if (limit != null) {
        query.limit(limit);
      }

      final items = await query.get();
      return items.map((item) => SyncQueueItemModel.fromDrift(item)).toList();
    } catch (e) {
      _logger.e('Error getting pending items: $e');
      rethrow;
    }
  }

  /// Get items by entity
  Future<List<SyncQueueItemModel>> getItemsByEntity({
    required String entityType,
    required String entityId,
  }) async {
    try {
      final items = await (_db.select(_db.syncQueue)
            ..where((tbl) => tbl.entityType.equals(entityType))
            ..where((tbl) => tbl.entityId.equals(entityId))
            ..where((tbl) => tbl.status.isNotIn([
                  SyncQueueStatus.completed,
                ]))
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.queuedAt)]))
          .get();

      return items.map((item) => SyncQueueItemModel.fromDrift(item)).toList();
    } catch (e) {
      _logger.e('Error getting items for entity $entityType:$entityId: $e');
      rethrow;
    }
  }

  /// Get item by ID
  Future<SyncQueueItemModel?> getItemById(String itemId) async {
    try {
      final item = await (_db.select(_db.syncQueue)
            ..where((tbl) => tbl.id.equals(itemId)))
          .getSingleOrNull();

      if (item == null) return null;
      return SyncQueueItemModel.fromDrift(item);
    } catch (e) {
      _logger.e('Error getting sync queue item $itemId: $e');
      rethrow;
    }
  }

  /// Mark item as processing
  Future<void> markAsProcessing(String itemId) async {
    try {
      await (_db.update(_db.syncQueue)
            ..where((tbl) => tbl.id.equals(itemId)))
          .write(SyncQueueCompanion(
            status: const Value(SyncQueueStatus.processing),
            lastAttemptAt: Value(DateTime.now()),
          ));
    } catch (e) {
      _logger.e('Error marking item $itemId as processing: $e');
      rethrow;
    }
  }

  /// Mark item as completed
  Future<void> markAsCompleted(String itemId) async {
    try {
      await (_db.update(_db.syncQueue)
            ..where((tbl) => tbl.id.equals(itemId)))
          .write(const SyncQueueCompanion(
            status: Value(SyncQueueStatus.completed),
          ));

      _logger.i('Marked sync queue item $itemId as completed');
    } catch (e) {
      _logger.e('Error marking item $itemId as completed: $e');
      rethrow;
    }
  }

  /// Mark item as failed
  Future<void> markAsFailed(String itemId, String error) async {
    try {
      // Get current item to increment retry count
      final item = await getItemById(itemId);
      final newRetryCount = (item?.retryCount ?? 0) + 1;

      await (_db.update(_db.syncQueue)
            ..where((tbl) => tbl.id.equals(itemId)))
          .write(SyncQueueCompanion(
            status: const Value(SyncQueueStatus.failed),
            lastError: Value(error),
            retryCount: Value(newRetryCount),
          ));

      _logger.w('Marked sync queue item $itemId as failed: $error');
    } catch (e) {
      _logger.e('Error marking item $itemId as failed: $e');
      rethrow;
    }
  }

  /// Retry failed items
  Future<void> retryFailedItems({String? userId}) async {
    try {
      final query = _db.update(_db.syncQueue)
        ..where((tbl) => tbl.status.equals(SyncQueueStatus.failed));

      if (userId != null) {
        query.where((tbl) => tbl.userId.equals(userId));
      }

      await query.write(const SyncQueueCompanion(
        status: Value(SyncQueueStatus.pending),
        lastError: Value(null),
      ));

      _logger.i('Retried failed sync queue items');
    } catch (e) {
      _logger.e('Error retrying failed items: $e');
      rethrow;
    }
  }

  /// Update item payload
  Future<void> updatePayload(String itemId, String newPayload) async {
    try {
      await (_db.update(_db.syncQueue)
            ..where((tbl) => tbl.id.equals(itemId)))
          .write(SyncQueueCompanion(
            payload: Value(newPayload),
            status: const Value(SyncQueueStatus.pending),
          ));
    } catch (e) {
      _logger.e('Error updating payload for item $itemId: $e');
      rethrow;
    }
  }

  /// Delete item
  Future<void> deleteItem(String itemId) async {
    try {
      await (_db.delete(_db.syncQueue)
            ..where((tbl) => tbl.id.equals(itemId)))
          .go();

      _logger.i('Deleted sync queue item $itemId');
    } catch (e) {
      _logger.e('Error deleting sync queue item $itemId: $e');
      rethrow;
    }
  }

  /// Clear completed items
  Future<int> clearCompleted({DateTime? olderThan}) async {
    try {
      final query = _db.delete(_db.syncQueue)
        ..where((tbl) => tbl.status.equals(SyncQueueStatus.completed));

      if (olderThan != null) {
        query.where((tbl) => tbl.queuedAt.isSmallerThanValue(olderThan));
      }

      final count = await query.go();
      _logger.i('Cleared $count completed sync queue items');
      return count;
    } catch (e) {
      _logger.e('Error clearing completed items: $e');
      rethrow;
    }
  }

  /// Clear failed items
  Future<int> clearFailedItems({String? userId}) async {
    try {
      final query = _db.delete(_db.syncQueue)
        ..where((tbl) => tbl.status.equals(SyncQueueStatus.failed));

      if (userId != null) {
        query.where((tbl) => tbl.userId.equals(userId));
      }

      final count = await query.go();
      _logger.i('Cleared $count failed sync queue items');
      return count;
    } catch (e) {
      _logger.e('Error clearing failed items: $e');
      rethrow;
    }
  }

  /// Get queue statistics
  Future<SyncQueueStats> getStats({String? userId}) async {
    try {
      final query = _db.select(_db.syncQueue);

      if (userId != null) {
        query.where((tbl) => tbl.userId.equals(userId));
      }

      final items = await query.get();

      int pending = 0;
      int processing = 0;
      int failed = 0;

      for (final item in items) {
        switch (item.status) {
          case SyncQueueStatus.pending:
            pending++;
            break;
          case SyncQueueStatus.processing:
            processing++;
            break;
          case SyncQueueStatus.failed:
            failed++;
            break;
        }
      }

      return SyncQueueStats(
        pendingCount: pending,
        processingCount: processing,
        failedCount: failed,
        totalCount: items.length,
      );
    } catch (e) {
      _logger.e('Error getting sync queue stats: $e');
      rethrow;
    }
  }

  /// Get all items for a user
  Future<List<SyncQueueItemModel>> getAllItems({
    String? userId,
    String? status,
    int? limit,
    int? offset,
  }) async {
    try {
      final query = _db.select(_db.syncQueue)
        ..orderBy([
          (tbl) => OrderingTerm.desc(tbl.priority),
          (tbl) => OrderingTerm.asc(tbl.queuedAt),
        ]);

      if (userId != null) {
        query.where((tbl) => tbl.userId.equals(userId));
      }

      if (status != null) {
        query.where((tbl) => tbl.status.equals(status));
      }

      if (limit != null) {
        query.limit(limit, offset: offset);
      }

      final items = await query.get();
      return items.map((item) => SyncQueueItemModel.fromDrift(item)).toList();
    } catch (e) {
      _logger.e('Error getting all sync queue items: $e');
      rethrow;
    }
  }

  /// Remove items for a specific entity
  Future<int> removeItemsForEntity({
    required String entityType,
    required String entityId,
  }) async {
    try {
      final count = await (_db.delete(_db.syncQueue)
            ..where((tbl) => tbl.entityType.equals(entityType))
            ..where((tbl) => tbl.entityId.equals(entityId)))
          .go();

      _logger.i('Removed $count sync queue items for $entityType:$entityId');
      return count;
    } catch (e) {
      _logger.e('Error removing items for entity: $e');
      rethrow;
    }
  }

  /// Reset stuck processing items (back to pending)
  Future<int> resetStuckItems({Duration? stuckTimeout}) async {
    try {
      final timeout = stuckTimeout ?? const Duration(minutes: 30);
      final cutoff = DateTime.now().subtract(timeout);

      final count = await (_db.update(_db.syncQueue)
            ..where((tbl) => tbl.status.equals(SyncQueueStatus.processing))
            ..where((tbl) =>
              tbl.lastAttemptAt.isSmallerThanValue(cutoff) |
              tbl.lastAttemptAt.isNull()
            ))
          .write(const SyncQueueCompanion(
            status: Value(SyncQueueStatus.pending),
          ));

      _logger.i('Reset $count stuck sync queue items');
      return count;
    } catch (e) {
      _logger.e('Error resetting stuck items: $e');
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

/// Sync queue statistics
class SyncQueueStats {
  final int pendingCount;
  final int processingCount;
  final int failedCount;
  final int totalCount;

  const SyncQueueStats({
    required this.pendingCount,
    required this.processingCount,
    required this.failedCount,
    required this.totalCount,
  });

  @override
  String toString() {
    return 'SyncQueueStats(total: $totalCount, pending: $pendingCount, '
           'processing: $processingCount, failed: $failedCount)';
  }
}
