import 'dart:async';
import 'package:drift/drift.dart';
import '../../../../core/database/database.dart';

/// Sync status for tracking sync operations
enum SyncOperationStatus {
  idle,
  syncing,
  success,
  error,
}

/// Result of a sync operation
class SyncResult {
  final bool success;
  final int itemsSynced;
  final int conflicts;
  final String? errorMessage;

  const SyncResult({
    required this.success,
    this.itemsSynced = 0,
    this.conflicts = 0,
    this.errorMessage,
  });
}

/// Conflict resolution strategy
enum ConflictResolutionStrategy {
  localWins,
  remoteWins,
  merge,
  manual,
}

/// Background sync service for offline-first architecture
class SyncService {
  final AppDatabase _db;
  final Duration _syncInterval;
  final int _maxRetries;
  final Duration _baseRetryDelay;

  Timer? _syncTimer;
  bool _isSyncing = false;
  int _retryCount = 0;
  final _syncStatusController = StreamController<SyncOperationStatus>.broadcast();
  final _syncResultController = StreamController<SyncResult>.broadcast();

  SyncService({
    required AppDatabase database,
    Duration syncInterval = const Duration(minutes: 5),
    int maxRetries = 5,
    Duration baseRetryDelay = const Duration(seconds: 1),
  })  : _db = database,
        _syncInterval = syncInterval,
        _maxRetries = maxRetries,
        _baseRetryDelay = baseRetryDelay;

  /// Stream of sync status changes
  Stream<SyncOperationStatus> get syncStatus => _syncStatusController.stream;

  /// Stream of sync results
  Stream<SyncResult> get syncResults => _syncResultController.stream;

  /// Whether a sync is currently in progress
  bool get isSyncing => _isSyncing;

  /// Start periodic sync
  void startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(_syncInterval, (_) => sync());
    // Perform initial sync
    sync();
  }

  /// Stop periodic sync
  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Perform a full sync
  Future<SyncResult> sync() async {
    if (_isSyncing) {
      return const SyncResult(success: false, errorMessage: 'Sync already in progress');
    }

    _isSyncing = true;
    _syncStatusController.add(SyncOperationStatus.syncing);

    try {
      // Get pending items from sync queue
      final pendingItems = await (_db.select(_db.syncQueue)
        ..where((q) => q.status.equals('pending') | q.status.equals('failed'))
        ..orderBy([
          (q) => OrderingTerm.desc(q.priority),
          (q) => OrderingTerm.asc(q.queuedAt),
        ])
      ).get();

      if (pendingItems.isEmpty) {
        _isSyncing = false;
        _syncStatusController.add(SyncOperationStatus.idle);
        return const SyncResult(success: true, itemsSynced: 0);
      }

      int synced = 0;
      int conflicts = 0;

      for (final item in pendingItems) {
        final result = await _syncItem(item);
        if (result.success) {
          synced++;
          _retryCount = 0;
        } else if (result.conflicts > 0) {
          conflicts++;
        } else {
          // Handle failure with exponential backoff
          await _handleSyncFailure(item);
        }
      }

      _isSyncing = false;
      final result = SyncResult(
        success: true,
        itemsSynced: synced,
        conflicts: conflicts,
      );
      _syncStatusController.add(SyncOperationStatus.success);
      _syncResultController.add(result);
      return result;
    } catch (e) {
      _isSyncing = false;
      _syncStatusController.add(SyncOperationStatus.error);
      final result = SyncResult(success: false, errorMessage: e.toString());
      _syncResultController.add(result);
      return result;
    }
  }

  /// Sync a single item
  Future<SyncResult> _syncItem(SyncQueueData item) async {
    try {
      switch (item.operation) {
        case SyncOperationType.create:
          return await _handleCreate(item);
        case SyncOperationType.update:
          return await _handleUpdate(item);
        case SyncOperationType.delete:
          return await _handleDelete(item);
      }
    } catch (e) {
      return SyncResult(success: false, errorMessage: e.toString());
    }
  }

  /// Handle create operation
  Future<SyncResult> _handleCreate(SyncQueueData item) async {
    // TODO: Implement actual API call to Supabase
    // For now, mark as completed
    await (_db.update(_db.syncQueue)..where((q) => q.id.equals(item.id))).write(
      SyncQueueCompanion(
        status: const Value('completed'),
      ),
    );
    return const SyncResult(success: true, itemsSynced: 1);
  }

  /// Handle update operation
  Future<SyncResult> _handleUpdate(SyncQueueData item) async {
    // TODO: Check for conflicts with server version
    // TODO: Implement actual API call to Supabase
    await (_db.update(_db.syncQueue)..where((q) => q.id.equals(item.id))).write(
      SyncQueueCompanion(
        status: const Value('completed'),
      ),
    );
    return const SyncResult(success: true, itemsSynced: 1);
  }

  /// Handle delete operation
  Future<SyncResult> _handleDelete(SyncQueueData item) async {
    // TODO: Implement actual API call to Supabase
    await (_db.update(_db.syncQueue)..where((q) => q.id.equals(item.id))).write(
      SyncQueueCompanion(
        status: const Value('completed'),
      ),
    );
    return const SyncResult(success: true, itemsSynced: 1);
  }

  /// Handle sync failure with exponential backoff
  Future<void> _handleSyncFailure(SyncQueueData item) async {
    _retryCount++;

    if (_retryCount >= _maxRetries) {
      // Mark as failed
      await (_db.update(_db.syncQueue)..where((q) => q.id.equals(item.id))).write(
        SyncQueueCompanion(
          status: const Value('failed'),
          retryCount: Value(_retryCount),
          lastAttemptAt: Value(DateTime.now()),
          lastError: const Value('Max retries exceeded'),
        ),
      );
      return;
    }

    // Update retry count
    await (_db.update(_db.syncQueue)..where((q) => q.id.equals(item.id))).write(
      SyncQueueCompanion(
        retryCount: Value(_retryCount),
        lastAttemptAt: Value(DateTime.now()),
      ),
    );

    // Exponential backoff delay
    final delay = _baseRetryDelay * (1 << _retryCount);
    await Future.delayed(delay);
  }

  /// Add item to sync queue
  Future<void> queueSync({
    required String entityType,
    required String entityId,
    required SyncOperationType operation,
    required String payload,
    int priority = 0,
    String? userId,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    await _db.into(_db.syncQueue).insert(
      SyncQueueCompanion(
        id: Value(id),
        entityType: Value(entityType),
        entityId: Value(entityId),
        operation: Value(operation),
        payload: Value(payload),
        priority: Value(priority),
        userId: Value(userId),
        queuedAt: Value(DateTime.now()),
        status: const Value('pending'),
        retryCount: const Value(0),
      ),
    );

    // Trigger immediate sync if not already syncing
    if (!_isSyncing) {
      sync();
    }
  }

  /// Resolve conflict manually
  Future<void> resolveConflict({
    required String entityId,
    required ConflictResolutionStrategy strategy,
    String? mergedData,
  }) async {
    // TODO: Implement conflict resolution
  }

  /// Get pending sync count
  Future<int> getPendingSyncCount() async {
    final query = _db.select(_db.syncQueue)
      ..where((q) => q.status.equals('pending') | q.status.equals('failed'));
    return (await query.get()).length;
  }

  /// Clear completed sync items
  Future<void> clearCompletedSyncs() async {
    await (_db.delete(_db.syncQueue)..where((q) => q.status.equals('completed'))).go();
  }

  /// Dispose resources
  void dispose() {
    stopPeriodicSync();
    _syncStatusController.close();
    _syncResultController.close();
  }
}
