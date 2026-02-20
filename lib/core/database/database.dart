import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// Enum for task quadrant (Eisenhower Matrix)
enum TaskQuadrant {
  q1, // Urgent & Important - Do First
  q2, // Not Urgent & Important - Schedule
  q3, // Urgent & Not Important - Delegate
  q4, // Not Urgent & Not Important - Delete
}

/// Enum for task priority
enum TaskPriority {
  low,
  medium,
  high,
  urgent,
}

/// Enum for task status
enum TaskStatus {
  pending,
  inProgress,
  completed,
  deleted,
}

/// Enum for sync status
enum SyncStatus {
  synced,
  pending,
  conflict,
}

/// Enum for gamification log type
enum GamificationLogType {
  taskCompleted,
  streakMilestone,
  quadrantCompleted,
  levelUp,
  bonusEarned,
  dailyGoal,
}

/// Enum for sync queue operation type
enum SyncOperationType {
  create,
  update,
  delete,
}

// ============================================
// VALUE TYPE CONVERTERS FOR ENUMS
// ============================================

/// Type converter for TaskQuadrant
class TaskQuadrantConverter extends TypeConverter<TaskQuadrant, String> {
  const TaskQuadrantConverter();

  @override
  TaskQuadrant fromSql(String fromDb) {
    return TaskQuadrant.values.firstWhere(
      (e) => e.name == fromDb,
      orElse: () => TaskQuadrant.q1,
    );
  }

  @override
  String toSql(TaskQuadrant value) => value.name;
}

/// Type converter for TaskPriority
class TaskPriorityConverter extends TypeConverter<TaskPriority, String> {
  const TaskPriorityConverter();

  @override
  TaskPriority fromSql(String fromDb) {
    return TaskPriority.values.firstWhere(
      (e) => e.name == fromDb,
      orElse: () => TaskPriority.medium,
    );
  }

  @override
  String toSql(TaskPriority value) => value.name;
}

/// Type converter for TaskStatus
class TaskStatusConverter extends TypeConverter<TaskStatus, String> {
  const TaskStatusConverter();

  @override
  TaskStatus fromSql(String fromDb) {
    return TaskStatus.values.firstWhere(
      (e) => e.name == fromDb,
      orElse: () => TaskStatus.pending,
    );
  }

  @override
  String toSql(TaskStatus value) => value.name;
}

/// Type converter for SyncStatus
class SyncStatusConverter extends TypeConverter<SyncStatus, String> {
  const SyncStatusConverter();

  @override
  SyncStatus fromSql(String fromDb) {
    return SyncStatus.values.firstWhere(
      (e) => e.name == fromDb,
      orElse: () => SyncStatus.synced,
    );
  }

  @override
  String toSql(SyncStatus value) => value.name;
}

/// Type converter for GamificationLogType
class GamificationLogTypeConverter extends TypeConverter<GamificationLogType, String> {
  const GamificationLogTypeConverter();

  @override
  GamificationLogType fromSql(String fromDb) {
    return GamificationLogType.values.firstWhere(
      (e) => e.name == fromDb,
      orElse: () => GamificationLogType.taskCompleted,
    );
  }

  @override
  String toSql(GamificationLogType value) => value.name;
}

/// Type converter for SyncOperationType
class SyncOperationTypeConverter extends TypeConverter<SyncOperationType, String> {
  const SyncOperationTypeConverter();

  @override
  SyncOperationType fromSql(String fromDb) {
    return SyncOperationType.values.firstWhere(
      (e) => e.name == fromDb,
      orElse: () => SyncOperationType.create,
    );
  }

  @override
  String toSql(SyncOperationType value) => value.name;
}

// ============================================
// TABLE DEFINITIONS
// ============================================

/// Tasks table - stores all user tasks
class Tasks extends Table {
  @override
  String get tableName => 'tasks';

  /// Primary key - UUID
  TextColumn get id => text().withLength(min: 36, max: 36)();

  /// Task title
  TextColumn get title => text().withLength(min: 1, max: 200)();

  /// Optional description
  TextColumn get description => text().nullable()();

  /// Eisenhower Matrix quadrant (Q1-Q4)
  TextColumn get quadrant => text().map(const TaskQuadrantConverter())();

  /// Task priority
  TextColumn get priority => text().map(const TaskPriorityConverter())();

  /// Task status
  TextColumn get status => text().map(const TaskStatusConverter()).withDefault(const Constant('pending'))();

  /// Due date (optional)
  DateTimeColumn get dueDate => dateTime().nullable()();

  /// Completion timestamp
  DateTimeColumn get completedAt => dateTime().nullable()();

  /// Parent task ID for subtasks (optional)
  TextColumn get parentTaskId => text().nullable().references(Tasks, #id, onDelete: KeyAction.cascade)();

  /// User ID who owns this task
  TextColumn get userId => text().withLength(min: 36, max: 36).references(Users, #id, onDelete: KeyAction.cascade)();

  /// Creation timestamp
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Last update timestamp
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  /// Sync status for offline-first
  TextColumn get syncStatus => text().map(const SyncStatusConverter()).withDefault(const Constant('synced'))();

  /// Remote server version for conflict resolution
  IntColumn get remoteVersion => integer().nullable()();

  /// Server timestamp for ordering
  DateTimeColumn get serverTimestamp => dateTime().nullable()();

  /// Set primary key
  @override
  Set<Column> get primaryKey => {id};
}

/// Users table - stores user profiles
class Users extends Table {
  @override
  String get tableName => 'users';

  /// Primary key - UUID
  TextColumn get id => text().withLength(min: 36, max: 36)();

  /// Display name
  TextColumn get displayName => text().withLength(min: 1, max: 100)();

  /// Email address
  TextColumn get email => text().withLength(min: 1, max: 255).unique()();

  /// Profile image URL (optional)
  TextColumn get avatarUrl => text().nullable()();

  /// Current level
  IntColumn get level => integer().withDefault(const Constant(1))();

  /// Current experience points
  IntColumn get experiencePoints => integer().withDefault(const Constant(0))();

  /// Points needed for next level
  IntColumn get pointsToNextLevel => integer().withDefault(const Constant(100))();

  /// Current streak days
  IntColumn get streak => integer().withDefault(const Constant(0))();

  /// Longest streak achieved
  IntColumn get longestStreak => integer().withDefault(const Constant(0))();

  /// Total tasks completed
  IntColumn get totalTasksCompleted => integer().withDefault(const Constant(0))();

  /// Total points earned
  IntColumn get totalPointsEarned => integer().withDefault(const Constant(0))();

  /// Account creation timestamp
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Last active timestamp
  DateTimeColumn get lastActiveAt => dateTime().withDefault(currentDateAndTime)();

  /// Sync status
  TextColumn get syncStatus => text().map(const SyncStatusConverter()).withDefault(const Constant('synced'))();

  /// Set primary key
  @override
  Set<Column> get primaryKey => {id};
}

/// Tags table - stores task tags
class Tags extends Table {
  @override
  String get tableName => 'tags';

  /// Primary key - UUID
  TextColumn get id => text().withLength(min: 36, max: 36)();

  /// Tag name
  TextColumn get name => text().withLength(min: 1, max: 50)();

  /// Tag color (hex code)
  TextColumn get color => text().withLength(min: 7, max: 7).withDefault(const Constant('#3498db'))();

  /// User ID who owns this tag
  TextColumn get userId => text().withLength(min: 36, max: 36).references(Users, #id, onDelete: KeyAction.cascade)();

  /// Creation timestamp
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Sync status
  TextColumn get syncStatus => text().map(const SyncStatusConverter()).withDefault(const Constant('synced'))();

  /// Set primary key
  @override
  Set<Column> get primaryKey => {id};
}

/// Task-Tags junction table (many-to-many relationship)
class TaskTags extends Table {
  @override
  String get tableName => 'task_tags';

  /// Task ID
  TextColumn get taskId => text().references(Tasks, #id, onDelete: KeyAction.cascade)();

  /// Tag ID
  TextColumn get tagId => text().references(Tags, #id, onDelete: KeyAction.cascade)();

  /// Set composite primary key
  @override
  Set<Column> get primaryKey => {taskId, tagId};
}

/// Gamification logs table - tracks points and achievements
class GamificationLogs extends Table {
  @override
  String get tableName => 'gamification_logs';

  /// Primary key - UUID
  TextColumn get id => text().withLength(min: 36, max: 36)();

  /// User ID
  TextColumn get userId => text().withLength(min: 36, max: 36).references(Users, #id, onDelete: KeyAction.cascade)();

  /// Log type
  TextColumn get type => text().map(const GamificationLogTypeConverter())();

  /// Points awarded/deducted
  IntColumn get points => integer()();

  /// Description of the event
  TextColumn get description => text().withLength(min: 1, max: 500)();

  /// Related task ID (optional)
  TextColumn get taskId => text().nullable().references(Tasks, #id, onDelete: KeyAction.setNull)();

  /// Timestamp
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Sync status
  TextColumn get syncStatus => text().map(const SyncStatusConverter()).withDefault(const Constant('synced'))();

  /// Set primary key
  @override
  Set<Column> get primaryKey => {id};
}

/// Sync queue table - manages offline sync operations
class SyncQueue extends Table {
  @override
  String get tableName => 'sync_queue';

  /// Primary key - UUID
  TextColumn get id => text().withLength(min: 36, max: 36)();

  /// Entity type (task, tag, user, etc.)
  TextColumn get entityType => text().withLength(min: 1, max: 50)();

  /// Entity ID
  TextColumn get entityId => text().withLength(min: 36, max: 36)();

  /// Operation type
  TextColumn get operation => text().map(const SyncOperationTypeConverter())();

  /// JSON payload of the entity data
  TextColumn get payload => text()();

  /// Priority (higher = process first)
  IntColumn get priority => integer().withDefault(const Constant(0))();

  /// Number of retry attempts
  IntColumn get retryCount => integer().withDefault(const Constant(0))();

  /// Error message if last attempt failed
  TextColumn get lastError => text().nullable()();

  /// Timestamp when queued
  DateTimeColumn get queuedAt => dateTime().withDefault(currentDateAndTime)();

  /// Timestamp of last attempt
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();

  /// Status (pending, processing, completed, failed)
  TextColumn get status => text().withLength(min: 1, max: 20).withDefault(const Constant('pending'))();

  /// User ID for personal queue
  TextColumn get userId => text().withLength(min: 36, max: 36).nullable()();

  /// Set primary key
  @override
  Set<Column> get primaryKey => {id};
}

// ============================================
// DATABASE CLASS
// ============================================

/// Main database class for Eisenhower Matrix App
/// Uses Drift ORM for offline-first SQLite database
@DriftDatabase(tables: [
  Tasks,
  Users,
  Tags,
  GamificationLogs,
  TaskTags,
  SyncQueue,
])
class AppDatabase extends _$AppDatabase {
  /// Singleton instance
  static AppDatabase? _instance;

  /// Get singleton instance
  static AppDatabase get instance {
    _instance ??= AppDatabase._internal();
    return _instance!;
  }

  /// Internal constructor
  AppDatabase._internal() : super(_openConnection());

  /// Constructor for testing with custom executor
  AppDatabase.connect(QueryExecutor e) : super(e);

  /// Database schema version
  @override
  int get schemaVersion => 1;

  /// Migration logic for schema changes
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Add future migrations here
      },
      beforeOpen: (OpeningDetails details) async {
        // Enable foreign keys
        await customStatement('PRAGMA foreign_keys = ON');

        // Seed default user for offline-first mode (before auth is implemented)
        const defaultUserId = '00000000-0000-0000-0000-000000000000';
        await customStatement(
          "INSERT OR IGNORE INTO users (id, display_name, email, level, experience_points, points_to_next_level, streak, longest_streak, total_tasks_completed, total_points_earned, sync_status) "
          "VALUES ('$defaultUserId', 'Default User', 'default@local', 1, 0, 100, 0, 0, 0, 0, 'synced')",
        );
      },
    );
  }

  /// Open database connection using drift_flutter
  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'eisenhower_matrix');
  }

  /// Close database connection
  @override
  Future<void> close() async {
    await super.close();
  }
}
