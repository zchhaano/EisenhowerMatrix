import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';
import '../../features/quadrant/data/datasources/local/task_dao.dart';
import '../../features/quadrant/data/datasources/local/user_dao.dart';
import '../../features/quadrant/data/datasources/local/tag_dao.dart';
import '../../features/quadrant/data/datasources/local/gamification_log_dao.dart';
import '../../features/quadrant/data/datasources/local/sync_queue_dao.dart';
import 'database.dart';

part 'database_provider.g.dart';

@riverpod
Logger logger(LoggerRef ref) {
  return Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
  );
}

@riverpod
AppDatabase database(DatabaseRef ref) {
  final db = AppDatabase.instance;
  ref.onDispose(() {
    db.close();
  });
  return db;
}

@riverpod
TaskDao taskDao(TaskDaoRef ref) {
  final db = ref.watch(databaseProvider);
  final log = ref.watch(loggerProvider);
  return TaskDao(db, log);
}

@riverpod
UserDao userDao(UserDaoRef ref) {
  final db = ref.watch(databaseProvider);
  final log = ref.watch(loggerProvider);
  return UserDao(db, log);
}

@riverpod
TagDao tagDao(TagDaoRef ref) {
  final db = ref.watch(databaseProvider);
  final log = ref.watch(loggerProvider);
  return TagDao(db, log);
}

@riverpod
GamificationLogDao gamificationLogDao(GamificationLogDaoRef ref) {
  final db = ref.watch(databaseProvider);
  final log = ref.watch(loggerProvider);
  return GamificationLogDao(db, log);
}

@riverpod
SyncQueueDao syncQueueDao(SyncQueueDaoRef ref) {
  final db = ref.watch(databaseProvider);
  final log = ref.watch(loggerProvider);
  return SyncQueueDao(db, log);
}

enum DatabaseInitState {
  initializing,
  initialized,
  error,
}

@riverpod
class DatabaseInit extends _$DatabaseInit {
  @override
  DatabaseInitState build() {
    _initializeDatabase();
    return DatabaseInitState.initializing;
  }

  Future<void> _initializeDatabase() async {
    try {
      final db = ref.read(databaseProvider);
      await db.select(db.users).get();
      state = DatabaseInitState.initialized;
    } catch (e, st) {
      final log = ref.read(loggerProvider);
      log.e('Database initialization failed', error: e, stackTrace: st);
      state = DatabaseInitState.error;
    }
  }

  Future<void> retry() async {
    state = DatabaseInitState.initializing;
    await _initializeDatabase();
  }
}

@riverpod
DatabaseInfo databaseInfo(DatabaseInfoRef ref) {
  final db = ref.watch(databaseProvider);
  return DatabaseInfo(
    schemaVersion: db.schemaVersion,
    databaseName: 'eisenhower_matrix',
  );
}

class DatabaseInfo {
  final int schemaVersion;
  final String databaseName;

  const DatabaseInfo({
    required this.schemaVersion,
    required this.databaseName,
  });

  @override
  String toString() => 'DatabaseInfo(name: $databaseName, version: $schemaVersion)';
}

@riverpod
bool isDatabaseReady(IsDatabaseReadyRef ref) {
  final initState = ref.watch(databaseInitProvider);
  return initState == DatabaseInitState.initialized;
}

@riverpod
Future<bool> checkDatabaseConnectivity(CheckDatabaseConnectivityRef ref) async {
  try {
    final db = ref.read(databaseProvider);
    await db.select(db.users).get();
    return true;
  } catch (e) {
    ref.read(loggerProvider).w('Database connectivity check failed: $e');
    return false;
  }
}

@riverpod
Future<DatabaseStats> getDatabaseStats(GetDatabaseStatsRef ref) async {
  final db = ref.read(databaseProvider);

  try {
    final taskCount = await db.select(db.tasks).get().then((l) => l.length);
    final userCount = await db.select(db.users).get().then((l) => l.length);
    final tagCount = await db.select(db.tags).get().then((l) => l.length);
    final logCount = await db.select(db.gamificationLogs).get().then((l) => l.length);
    final queueCount = await db.select(db.syncQueue).get().then((l) => l.length);

    return DatabaseStats(
      taskCount: taskCount,
      userCount: userCount,
      tagCount: tagCount,
      gamificationLogCount: logCount,
      syncQueueCount: queueCount,
    );
  } catch (e) {
    ref.read(loggerProvider).e('Error getting database stats: $e');
    return DatabaseStats.empty;
  }
}

class DatabaseStats {
  final int taskCount;
  final int userCount;
  final int tagCount;
  final int gamificationLogCount;
  final int syncQueueCount;

  const DatabaseStats({
    required this.taskCount,
    required this.userCount,
    required this.tagCount,
    required this.gamificationLogCount,
    required this.syncQueueCount,
  });

  static const DatabaseStats empty = DatabaseStats(
    taskCount: 0,
    userCount: 0,
    tagCount: 0,
    gamificationLogCount: 0,
    syncQueueCount: 0,
  );

  int get totalRecords =>
      taskCount + userCount + tagCount + gamificationLogCount + syncQueueCount;

  @override
  String toString() {
    return 'DatabaseStats(tasks: $taskCount, users: $userCount, tags: $tagCount, '
           'logs: $gamificationLogCount, queue: $syncQueueCount)';
  }
}

/// Provider for creating in-memory database for testing
@riverpod
AppDatabase testDatabase(TestDatabaseRef ref) {
  return AppDatabase.connect(NativeDatabase.memory());
}
