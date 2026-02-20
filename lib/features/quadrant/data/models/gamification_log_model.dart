import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:drift/drift.dart' hide JsonKey;
import '../../../../core/database/database.dart';

part 'gamification_log_model.freezed.dart';

/// Gamification log entity model for tracking user achievements
@freezed
class GamificationLogModel with _$GamificationLogModel {
  const factory GamificationLogModel({
    required String id,
    required String userId,
    required GamificationLogType type,
    required int points,
    required String description,
    String? taskId,
    required DateTime createdAt,
    required SyncStatus syncStatus,
  }) = _GamificationLogModel;

  const GamificationLogModel._();

  /// Create from Drift GamificationLog
  factory GamificationLogModel.fromDrift(GamificationLog log) {
    return GamificationLogModel(
      id: log.id,
      userId: log.userId,
      type: log.type,
      points: log.points,
      description: log.description,
      taskId: log.taskId,
      createdAt: log.createdAt,
      syncStatus: log.syncStatus,
    );
  }

  /// Convert to Drift GamificationLogsCompanion
  GamificationLogsCompanion toDriftCompanion() {
    return GamificationLogsCompanion(
      id: Value(id),
      userId: Value(userId),
      type: Value(type),
      points: Value(points),
      description: Value(description),
      taskId: taskId != null ? Value(taskId!) : const Value.absent(),
      createdAt: Value(createdAt),
      syncStatus: Value(syncStatus),
    );
  }

  /// Check if needs sync
  bool get needsSync => syncStatus != SyncStatus.synced;

  /// Check if points were awarded (positive)
  bool get isAwarded => points > 0;

  /// Check if points were deducted (negative)
  bool get isDeducted => points < 0;

  /// Get display name for log type
  String get typeDisplayName {
    switch (type) {
      case GamificationLogType.taskCompleted:
        return 'Task Completed';
      case GamificationLogType.streakMilestone:
        return 'Streak Milestone';
      case GamificationLogType.quadrantCompleted:
        return 'Quadrant Completed';
      case GamificationLogType.levelUp:
        return 'Level Up';
      case GamificationLogType.bonusEarned:
        return 'Bonus Earned';
      case GamificationLogType.dailyGoal:
        return 'Daily Goal';
    }
  }

  /// Get icon name for the log type (for UI display)
  String get iconName {
    switch (type) {
      case GamificationLogType.taskCompleted:
        return 'check_circle';
      case GamificationLogType.streakMilestone:
        return 'local_fire_department';
      case GamificationLogType.quadrantCompleted:
        return 'grid_view';
      case GamificationLogType.levelUp:
        return 'trending_up';
      case GamificationLogType.bonusEarned:
        return 'stars';
      case GamificationLogType.dailyGoal:
        return 'flag';
    }
  }

  /// Get color code for the log type
  String get typeColor {
    switch (type) {
      case GamificationLogType.taskCompleted:
        return '#4CAF50';
      case GamificationLogType.streakMilestone:
        return '#FF5722';
      case GamificationLogType.quadrantCompleted:
        return '#2196F3';
      case GamificationLogType.levelUp:
        return '#9C27B0';
      case GamificationLogType.bonusEarned:
        return '#FFC107';
      case GamificationLogType.dailyGoal:
        return '#00BCD4';
    }
  }

  /// Mark as synced
  GamificationLogModel markAsSynced() {
    return copyWith(syncStatus: SyncStatus.synced);
  }

  /// Mark for sync
  GamificationLogModel markForSync() {
    return copyWith(syncStatus: SyncStatus.pending);
  }
}

/// Gamification log statistics
class GamificationStats {
  final int totalPointsEarned;
  final int totalPointsDeducted;
  final int netPoints;
  final int logsCount;
  final Map<GamificationLogType, int> pointsByType;
  final Map<GamificationLogType, int> countByType;

  const GamificationStats({
    required this.totalPointsEarned,
    required this.totalPointsDeducted,
    required this.netPoints,
    required this.logsCount,
    required this.pointsByType,
    required this.countByType,
  });

  /// Calculate from a list of logs
  factory GamificationStats.fromLogs(List<GamificationLogModel> logs) {
    int earned = 0;
    int deducted = 0;
    final pointsByType = <GamificationLogType, int>{};
    final countByType = <GamificationLogType, int>{};

    for (final log in logs) {
      if (log.isAwarded) {
        earned += log.points;
        pointsByType[log.type] = (pointsByType[log.type] ?? 0) + log.points;
      } else {
        deducted += log.points.abs();
      }
      countByType[log.type] = (countByType[log.type] ?? 0) + 1;
    }

    return GamificationStats(
      totalPointsEarned: earned,
      totalPointsDeducted: deducted,
      netPoints: earned - deducted,
      logsCount: logs.length,
      pointsByType: pointsByType,
      countByType: countByType,
    );
  }

  /// Empty stats
  static const empty = GamificationStats(
    totalPointsEarned: 0,
    totalPointsDeducted: 0,
    netPoints: 0,
    logsCount: 0,
    pointsByType: {},
    countByType: {},
  );
}

/// Point rewards configuration
class PointRewards {
  /// Points for completing a task
  static const int taskCompleted = 10;

  /// Points bonus for completing in Q1 (urgent & important)
  static const int taskQ1Bonus = 5;

  /// Points bonus for completing in Q2 (important)
  static const int taskQ2Bonus = 3;

  /// Points for completing a subtask
  static const int subtaskCompleted = 5;

  /// Points for completing all tasks in a quadrant
  static const int quadrantCleared = 50;

  /// Points for streak milestones
  static const Map<int, int> streakMilestones = {
    3: 15,   // 3 day streak
    7: 50,   // 1 week
    14: 100, // 2 weeks
    30: 250, // 1 month
    100: 1000, // 100 days
  };

  /// Points for level up (base points)
  static const int levelUpBase = 100;

  /// Daily goal completion bonus
  static const int dailyGoalCompleted = 25;

  /// Points for completing tasks on time
  static const int onTimeCompletion = 5;

  /// Points deduction for missing due date
  static const int missedDeadline = -10;

  /// Calculate points for task completion based on quadrant
  static int forTaskQuadrant(TaskQuadrant quadrant) {
    switch (quadrant) {
      case TaskQuadrant.q1:
        return taskCompleted + taskQ1Bonus;
      case TaskQuadrant.q2:
        return taskCompleted + taskQ2Bonus;
      case TaskQuadrant.q3:
        return taskCompleted;
      case TaskQuadrant.q4:
        return taskCompleted;
    }
  }

  /// Get streak milestone reward
  static int? getStreakReward(int streakDays) {
    return streakMilestones[streakDays];
  }

  /// Check if streak has a milestone
  static bool hasMilestone(int streakDays) {
    return streakMilestones.containsKey(streakDays);
  }

  /// Calculate level up points
  static int levelUpPoints(int newLevel) {
    return levelUpBase * (newLevel ~/ 10); // Bonus every 10 levels
  }

  /// Generate description for task completion
  static String taskCompletedDescription(TaskQuadrant quadrant, {bool isSubtask = false}) {
    final baseDesc = isSubtask ? 'Subtask completed' : 'Task completed';
    switch (quadrant) {
      case TaskQuadrant.q1:
        return '$baseDesc in Do First (Q1)';
      case TaskQuadrant.q2:
        return '$baseDesc in Schedule (Q2)';
      case TaskQuadrant.q3:
        return '$baseDesc in Delegate (Q3)';
      case TaskQuadrant.q4:
        return '$baseDesc in Eliminate (Q4)';
    }
  }

  /// Generate streak milestone description
  static String streakMilestoneDescription(int days) {
    return '$days day streak! Keep it going!';
  }

  /// Generate level up description
  static String levelUpDescription(int newLevel) {
    return 'Reached Level $newLevel!';
  }

  /// Generate quadrant cleared description
  static String quadrantClearedDescription(TaskQuadrant quadrant) {
    return 'Cleared ${_quadrantName(quadrant)} quadrant!';
  }

  static String _quadrantName(TaskQuadrant quadrant) {
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

  /// Generate daily goal description
  static String dailyGoalDescription(int tasksCompleted, int goal) {
    return 'Daily goal reached: $tasksCompleted/$tasksCompleted tasks';
  }

  /// Generate bonus description
  static String bonusDescription(String reason) {
    return 'Bonus: $reason';
  }
}

/// Gamification log list filter
class GamificationLogFilter {
  final String? userId;
  final GamificationLogType? type;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? awardedOnly;

  const GamificationLogFilter({
    this.userId,
    this.type,
    this.startDate,
    this.endDate,
    this.awardedOnly,
  });

  /// Check if filter has any active constraints
  bool get hasFilters =>
      userId != null ||
      type != null ||
      startDate != null ||
      endDate != null ||
      awardedOnly != null;

  /// Empty filter
  static const empty = GamificationLogFilter();
}
