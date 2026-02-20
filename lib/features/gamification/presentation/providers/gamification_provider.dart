import 'package:flutter/foundation.dart';
import '../../domain/entities/points.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/services/points_service.dart';
import '../../domain/services/streak_service.dart';

/// State management provider for gamification features
class GamificationProvider extends ChangeNotifier {
  Points _points = Points(
    total: 0,
    today: 0,
    thisWeek: 0,
    thisMonth: 0,
    lastUpdated: DateTime.now(),
    level: 1,
    xpToNextLevel: 100,
  );

  StreakInfo _streakInfo = const StreakInfo(
    currentStreak: 0,
    longestStreak: 0,
    lastStreakDate: null,
    isActive: false,
  );

  List<Achievement> _achievements = Achievements.all.map((a) => a.copyWith(
    progress: 0,
    isUnlocked: false,
  )).toList();

  List<PointsReward> _recentRewards = [];

  // Getters
  Points get points => _points;
  StreakInfo get streakInfo => _streakInfo;
  List<Achievement> get achievements => _achievements;
  List<PointsReward> get recentRewards => _recentRewards;
  bool get hasActiveStreak => _streakInfo.isActive && _streakInfo.currentStreak > 0;

  // Filtered getters
  List<Achievement> get unlockedAchievements =>
      _achievements.where((a) => a.isUnlocked).toList();

  List<Achievement> get lockedAchievements =>
      _achievements.where((a) => !a.isUnlocked).toList();

  List<Achievement> get inProgressAchievements =>
      _achievements.where((a) => !a.isUnlocked && a.progress > 0).toList();

  /// Initialize the provider with existing data
  Future<void> initialize({
    Points? initialPoints,
    StreakInfo? initialStreak,
    List<Achievement>? initialAchievements,
  }) async {
    if (initialPoints != null) {
      _points = initialPoints;
    }
    if (initialStreak != null) {
      _streakInfo = initialStreak;
    }
    if (initialAchievements != null) {
      _achievements = initialAchievements;
    }
    notifyListeners();
  }

  /// Award points for task completion
  void awardTaskPoints({
    required EisenhowerQuadrant quadrant,
    Duration? timeToComplete,
    bool? wasOverdue,
  }) {
    final basePoints = PointsService.calculatePointsForTask(
      quadrant: quadrant,
      timeToComplete: timeToComplete ?? Duration.zero,
      wasOverdue: wasOverdue,
    );

    final multiplier = PointsService.calculatePointsMultiplier(
      tasksCompletedToday: _points.today,
      currentStreak: _streakInfo.currentStreak,
      isPerfectDay: false,
    );

    final finalPoints = PointsService.applyMultiplier(basePoints, multiplier);

    _addPoints(finalPoints, PointsService.getTaskCompletionReason(quadrant), quadrant);
  }

  /// Award streak bonus points
  void awardStreakBonus(int streakDays) {
    if (!StreakService.justReachedMilestone(streakDays - 1, streakDays)) {
      return;
    }

    final bonus = PointsService.calculateStreakBonus(streakDays);
    if (bonus > 0) {
      _addPoints(bonus, PointsService.getStreakBonusReason(streakDays), null);
    }
  }

  /// Award achievement points
  void awardAchievement(String achievementId) {
    final achievement = _achievements
        .where((a) => a.id == achievementId)
        .firstOrNull;

    if (achievement == null || achievement.isUnlocked) {
      return;
    }

    final points = achievement.points;
    final updatedAchievement = achievement.copyWith(
      isUnlocked: true,
      unlockedAt: DateTime.now(),
    );

    final index = _achievements.indexWhere((a) => a.id == achievementId);
    if (index >= 0) {
      _achievements[index] = updatedAchievement;
    }

    _addPoints(
      points,
      PointsService.getAchievementReason(achievement.title),
      null,
    );
  }

  /// Update achievement progress
  void updateAchievementProgress(String achievementId, int progress) {
    final index = _achievements.indexWhere((a) => a.id == achievementId);
    if (index < 0) return;

    final achievement = _achievements[index];

    // Don't update if already unlocked
    if (achievement.isUnlocked) return;

    final newProgress = progress.clamp(0, achievement.maxProgress);
    final isUnlocked = newProgress >= achievement.maxProgress;

    final updated = achievement.copyWith(
      progress: newProgress,
      isUnlocked: isUnlocked,
      unlockedAt: isUnlocked ? DateTime.now() : null,
    );

    _achievements[index] = updated;

    if (isUnlocked && !achievement.isUnlocked) {
      // Auto-award points for newly unlocked achievement
      _addPoints(
        updated.points,
        PointsService.getAchievementReason(updated.title),
        null,
      );
    }

    notifyListeners();
  }

  /// Increment achievement progress by 1
  void incrementAchievementProgress(String achievementId) {
    final index = _achievements.indexWhere((a) => a.id == achievementId);
    if (index < 0) return;

    final achievement = _achievements[index];
    updateAchievementProgress(achievementId, achievement.progress + 1);
  }

  /// Update streak information
  void updateStreak(List<DateTime> completedDates) {
    final newStreak = StreakService.calculateStreak(
      completedDates: completedDates,
      today: DateTime.now(),
    );

    final previousStreak = _streakInfo.currentStreak;
    _streakInfo = newStreak;

    // Check for streak milestone
    if (newStreak.currentStreak > previousStreak) {
      awardStreakBonus(newStreak.currentStreak);
    }

    notifyListeners();
  }

  /// Reset daily points (call at start of new day)
  void resetDailyPoints() {
    _points = _points.copyWith(
      today: 0,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
  }

  /// Reset weekly points (call at start of new week)
  void resetWeeklyPoints() {
    _points = _points.copyWith(
      thisWeek: 0,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
  }

  /// Reset monthly points (call at start of new month)
  void resetMonthlyPoints() {
    _points = _points.copyWith(
      thisMonth: 0,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
  }

  /// Add points internally
  void _addPoints(int amount, String reason, EisenhowerQuadrant? quadrant) {
    final reward = PointsReward(
      amount: amount,
      reason: reason,
      awardedAt: DateTime.now(),
      quadrant: quadrant,
    );

    _recentRewards.insert(0, reward);
    if (_recentRewards.length > 50) {
      _recentRewards = _recentRewards.take(50).toList();
    }

    final newTotal = _points.total + amount;
    final newLevel = PointsService.calculateLevel(newTotal);
    final newXpToNext = PointsService.xpToNextLevel(newTotal);

    // Check for level up
    if (newLevel > _points.level) {
      // Level up achievement
      final levelAchievement = _achievements
          .where((a) => a.id == 'level_$newLevel')
          .firstOrNull;
      if (levelAchievement != null && !levelAchievement.isUnlocked) {
        awardAchievement('level_$newLevel');
      }
    }

    // Update points based on milestone
    final pointsAchievement = _achievements
        .where((a) =>
            a.id == 'points_1000' || a.id == 'points_10000')
        .firstOrNull;

    if (pointsAchievement?.id == 'points_1000' && newTotal >= 1000) {
      awardAchievement('points_1000');
    } else if (pointsAchievement?.id == 'points_10000' && newTotal >= 10000) {
      awardAchievement('points_10000');
    }

    _points = _points.copyWith(
      total: newTotal,
      today: _points.today + amount,
      thisWeek: _points.thisWeek + amount,
      thisMonth: _points.thisMonth + amount,
      lastUpdated: DateTime.now(),
      level: newLevel,
      xpToNextLevel: newXpToNext,
    );

    notifyListeners();
  }

  /// Get achievement by ID
  Achievement? getAchievement(String id) {
    return _achievements.where((a) => a.id == id).firstOrNull;
  }

  /// Get achievements by category
  List<Achievement> getAchievementsByCategory(AchievementCategory category) {
    return _achievements.where((a) => a.category == category).toList();
  }

  /// Clear recent rewards
  void clearRecentRewards() {
    _recentRewards = [];
    notifyListeners();
  }

  /// Get streak deadline
  DateTime? getStreakDeadline() {
    if (_streakInfo.lastStreakDate == null) return null;
    return StreakService.getStreakDeadline(_streakInfo.lastStreakDate!);
  }

  /// Get days remaining to maintain streak
  int getDaysRemaining() {
    if (_streakInfo.lastStreakDate == null) return 0;
    return StreakService.getDaysRemaining(
      _streakInfo.lastStreakDate!,
      DateTime.now(),
    );
  }

  /// Get next streak milestone
  StreakMilestone getNextStreakMilestone() {
    return StreakService.getNextMilestone(_streakInfo.currentStreak);
  }

  /// Get all achieved streak milestones
  List<StreakMilestone> getAchievedStreakMilestones() {
    return StreakService.getAchievedMilestones(_streakInfo.currentStreak);
  }

  /// Check if today's tasks are all complete (for perfect day achievement)
  void checkPerfectDay({
    required int plannedTasks,
    required int completedTasks,
  }) {
    if (plannedTasks > 0 && plannedTasks == completedTasks) {
      awardAchievement('perfect_day');
    }
  }

  /// Reset all data (for testing or logout)
  void reset() {
    _points = Points(
      total: 0,
      today: 0,
      thisWeek: 0,
      thisMonth: 0,
      lastUpdated: DateTime.now(),
      level: 1,
      xpToNextLevel: 100,
    );

    _streakInfo = const StreakInfo(
      currentStreak: 0,
      longestStreak: 0,
      lastStreakDate: null,
      isActive: false,
    );

    _achievements = Achievements.all.map((a) => a.copyWith(
      progress: 0,
      isUnlocked: false,
    )).toList();

    _recentRewards = [];

    notifyListeners();
  }
}
