import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:drift/drift.dart' hide JsonKey;
import 'dart:math' as math;
import '../../../../core/database/database.dart';

part 'user_model.freezed.dart';

/// User entity model with domain-specific behavior
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String displayName,
    required String email,
    String? avatarUrl,
    required int level,
    required int experiencePoints,
    required int pointsToNextLevel,
    required int streak,
    required int longestStreak,
    required int totalTasksCompleted,
    required int totalPointsEarned,
    required DateTime createdAt,
    required DateTime lastActiveAt,
    required SyncStatus syncStatus,
  }) = _UserModel;

  const UserModel._();

  /// Create from Drift User
  factory UserModel.fromDrift(User user) {
    return UserModel(
      id: user.id,
      displayName: user.displayName,
      email: user.email,
      avatarUrl: user.avatarUrl,
      level: user.level,
      experiencePoints: user.experiencePoints,
      pointsToNextLevel: user.pointsToNextLevel,
      streak: user.streak,
      longestStreak: user.longestStreak,
      totalTasksCompleted: user.totalTasksCompleted,
      totalPointsEarned: user.totalPointsEarned,
      createdAt: user.createdAt,
      lastActiveAt: user.lastActiveAt,
      syncStatus: user.syncStatus,
    );
  }

  /// Convert to Drift UsersCompanion
  UsersCompanion toDriftCompanion() {
    return UsersCompanion(
      id: Value(id),
      displayName: Value(displayName),
      email: Value(email),
      avatarUrl: avatarUrl != null ? Value(avatarUrl!) : const Value.absent(),
      level: Value(level),
      experiencePoints: Value(experiencePoints),
      pointsToNextLevel: Value(pointsToNextLevel),
      streak: Value(streak),
      longestStreak: Value(longestStreak),
      totalTasksCompleted: Value(totalTasksCompleted),
      totalPointsEarned: Value(totalPointsEarned),
      createdAt: Value(createdAt),
      lastActiveAt: Value(lastActiveAt),
      syncStatus: Value(syncStatus),
    );
  }

  /// Calculate progress to next level (0.0 to 1.0)
  double get levelProgress {
    if (pointsToNextLevel == 0) return 1.0;
    return experiencePoints / pointsToNextLevel;
  }

  /// Calculate progress percentage
  int get levelProgressPercent => (levelProgress * 100).clamp(0, 100).toInt();

  /// Check if user has active streak (at least 1 day)
  bool get hasActiveStreak => streak > 0;

  /// Check if user is on a hot streak (7+ days)
  bool get isOnHotStreak => streak >= 7;

  /// Get streak title based on days
  String get streakTitle {
    if (streak >= 30) return 'Legendary';
    if (streak >= 21) return 'Epic';
    if (streak >= 14) return 'Amazing';
    if (streak >= 7) return 'Hot';
    if (streak >= 3) return 'Building';
    if (streak >= 1) return 'Active';
    return 'Start Your Streak';
  }

  /// Check if needs sync
  bool get needsSync => syncStatus != SyncStatus.synced;

  /// Calculate total level milestone (every 10 levels)
  bool get isLevelMilestone => level % 10 == 0;

  /// Get level title based on level
  String get levelTitle {
    if (level >= 100) return 'Master';
    if (level >= 75) return 'Expert';
    if (level >= 50) return 'Advanced';
    if (level >= 25) return 'Skilled';
    if (level >= 10) return 'Intermediate';
    return 'Beginner';
  }

  /// Add experience points
  UserModel addExperience(int points) {
    final newExp = experiencePoints + points;
    final newTotalPoints = totalPointsEarned + points;

    // Check if level up
    if (newExp >= pointsToNextLevel) {
      return _levelUp(newExp, newTotalPoints);
    }

    return copyWith(
      experiencePoints: newExp,
      totalPointsEarned: newTotalPoints,
      syncStatus: SyncStatus.pending,
    );
  }

  /// Increment streak
  UserModel incrementStreak() {
    final newStreak = streak + 1;
    return copyWith(
      streak: newStreak,
      longestStreak: newStreak > longestStreak ? newStreak : longestStreak,
      syncStatus: SyncStatus.pending,
    );
  }

  /// Reset streak
  UserModel resetStreak() {
    return copyWith(
      streak: 0,
      syncStatus: SyncStatus.pending,
    );
  }

  /// Increment completed tasks count
  UserModel incrementCompletedTasks() {
    return copyWith(
      totalTasksCompleted: totalTasksCompleted + 1,
      syncStatus: SyncStatus.pending,
    );
  }

  /// Update last active timestamp
  UserModel updateLastActive() {
    return copyWith(
      lastActiveAt: DateTime.now(),
    );
  }

  /// Mark as synced
  UserModel markAsSynced() {
    return copyWith(
      syncStatus: SyncStatus.synced,
    );
  }

  /// Handle level up logic
  UserModel _levelUp(int newExp, int newTotalPoints) {
    final remainingExp = newExp - pointsToNextLevel;
    final newLevel = level + 1;
    final newPointsToNext = _calculatePointsForLevel(newLevel + 1);

    return copyWith(
      level: newLevel,
      experiencePoints: remainingExp,
      pointsToNextLevel: newPointsToNext,
      totalPointsEarned: newTotalPoints,
      syncStatus: SyncStatus.pending,
    );
  }

  /// Calculate points needed for a given level
  int _calculatePointsForLevel(int targetLevel) {
    // Base formula: 100 * level^1.5 (rounded up)
    return (100 * math.pow(targetLevel, 1.5)).ceil();
  }

  /// Update profile info
  UserModel updateProfile({
    String? displayName,
    String? avatarUrl,
  }) {
    return copyWith(
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      syncStatus: SyncStatus.pending,
    );
  }
}

/// User statistics summary
class UserStats {
  final int level;
  final int experiencePoints;
  final int pointsToNextLevel;
  final int streak;
  final int longestStreak;
  final int totalTasksCompleted;
  final int totalPointsEarned;
  final int tasksThisWeek;
  final int tasksThisMonth;
  final int tasksInQuadrant1;
  final int tasksInQuadrant2;
  final int tasksInQuadrant3;
  final int tasksInQuadrant4;

  const UserStats({
    required this.level,
    required this.experiencePoints,
    required this.pointsToNextLevel,
    required this.streak,
    required this.longestStreak,
    required this.totalTasksCompleted,
    required this.totalPointsEarned,
    this.tasksThisWeek = 0,
    this.tasksThisMonth = 0,
    this.tasksInQuadrant1 = 0,
    this.tasksInQuadrant2 = 0,
    this.tasksInQuadrant3 = 0,
    this.tasksInQuadrant4 = 0,
  });

  /// Calculate completion rate for each quadrant
  double get quadrant1Rate => _safeRate(tasksInQuadrant1);
  double get quadrant2Rate => _safeRate(tasksInQuadrant2);
  double get quadrant3Rate => _safeRate(tasksInQuadrant3);
  double get quadrant4Rate => _safeRate(tasksInQuadrant4);

  double _safeRate(int count) {
    if (totalTasksCompleted == 0) return 0.0;
    return count / totalTasksCompleted;
  }

  /// Get most productive quadrant
  String get mostProductiveQuadrant {
    int maxTasks = 0;
    String quadrant = 'Q1';

    if (tasksInQuadrant2 > maxTasks) {
      maxTasks = tasksInQuadrant2;
      quadrant = 'Q2';
    }
    if (tasksInQuadrant3 > maxTasks) {
      maxTasks = tasksInQuadrant3;
      quadrant = 'Q3';
    }
    if (tasksInQuadrant4 > maxTasks) {
      maxTasks = tasksInQuadrant4;
      quadrant = 'Q4';
    }

    return quadrant;
  }
}
