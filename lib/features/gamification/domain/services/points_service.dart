import '../entities/points.dart';
import '../entities/achievement.dart';

/// Service for calculating and managing points
class PointsService {
  /// Points awarded for completing a task in each quadrant
  static const Map<EisenhowerQuadrant, int> quadrantPoints = {
    EisenhowerQuadrant.q1: 10,  // Do First
    EisenhowerQuadrant.q2: 15,  // Schedule - bonus for strategic work
    EisenhowerQuadrant.q3: 5,   // Delegate
    EisenhowerQuadrant.q4: 3,   // Delete
  };

  /// Points required for each level (exponential scaling)
  static const int baseXpPerLevel = 100;

  /// Calculate points for completing a task
  static int calculatePointsForTask({
    required EisenhowerQuadrant quadrant,
    required Duration timeToComplete,
    bool? wasOverdue,
    int? priority,
  }) {
    int points = quadrantPoints[quadrant] ?? 5;

    // Priority bonus
    if (priority != null && priority > 0) {
      points += (priority * 2);
    }

    // Speed bonus (completed within estimated time)
    // This would require having an estimated time for the task
    // For now, we just use the base points

    return points;
  }

  /// Calculate total points for a day
  static int calculateDailyPoints({
    required int tasksCompleted,
    required Map<EisenhowerQuadrant, int> quadrantBreakdown,
    bool hadPerfectDay = false,
  }) {
    int points = 0;

    // Points for each quadrant
    for (final entry in quadrantBreakdown.entries) {
      points += (quadrantPoints[entry.key] ?? 0) * entry.value;
    }

    // Perfect day bonus
    if (hadPerfectDay) {
      points += 50;
    }

    // Productivity bonus (completed 5+ tasks)
    if (tasksCompleted >= 5) {
      points += 25;
    }

    // High productivity bonus (completed 10+ tasks)
    if (tasksCompleted >= 10) {
      points += 50;
    }

    return points;
  }

  /// Calculate level from total XP
  static int calculateLevel(int totalXp) {
    return (totalXp / baseXpPerLevel).floor() + 1;
  }

  /// Calculate XP needed to reach the next level
  static int xpToNextLevel(int totalXp) {
    final currentLevel = calculateLevel(totalXp);
    final xpForNextLevel = currentLevel * baseXpPerLevel;
    return xpForNextLevel - totalXp;
  }

  /// Calculate XP progress within current level
  static double levelProgress(int totalXp) {
    final currentLevel = calculateLevel(totalXp);
    final xpAtCurrentLevelStart = (currentLevel - 1) * baseXpPerLevel;
    final xpInCurrentLevel = totalXp - xpAtCurrentLevelStart;
    return (xpInCurrentLevel / baseXpPerLevel).clamp(0.0, 1.0);
  }

  /// Points awarded for streaks
  static int calculateStreakBonus(int streakDays) {
    switch (streakDays) {
      case 7:
        return 50;
      case 30:
        return 200;
      case 90:
        return 500;
      default:
        return 0;
    }
  }

  /// Check if a streak milestone is reached
  static bool isStreakMilestone(int streakDays) {
    return [7, 30, 90].contains(streakDays);
  }

  /// Get next streak milestone
  static int? getNextStreakMilestone(int currentStreak) {
    if (currentStreak < 7) return 7;
    if (currentStreak < 30) return 30;
    if (currentStreak < 90) return 90;
    return null; // All milestones achieved
  }

  /// Points awarded for achievements
  static int getPointsForAchievement(String achievementId) {
    final achievement = Achievements.all
        .where((a) => a.id == achievementId)
        .firstOrNull;
    return achievement?.points ?? 0;
  }

  /// Calculate points multiplier based on performance
  static double calculatePointsMultiplier({
    required int tasksCompletedToday,
    required int currentStreak,
    required bool isPerfectDay,
  }) {
    double multiplier = 1.0;

    // Streak multiplier
    if (currentStreak >= 30) {
      multiplier += 0.5;
    } else if (currentStreak >= 14) {
      multiplier += 0.3;
    } else if (currentStreak >= 7) {
      multiplier += 0.15;
    } else if (currentStreak >= 3) {
      multiplier += 0.05;
    }

    // Perfect day multiplier
    if (isPerfectDay) {
      multiplier += 0.25;
    }

    // High productivity multiplier
    if (tasksCompletedToday >= 10) {
      multiplier += 0.2;
    } else if (tasksCompletedToday >= 5) {
      multiplier += 0.1;
    }

    return multiplier;
  }

  /// Apply multiplier to base points
  static int applyMultiplier(int basePoints, double multiplier) {
    return (basePoints * multiplier).round();
  }

  /// Create a points reward record
  static PointsReward createReward({
    required int amount,
    required String reason,
    EisenhowerQuadrant? quadrant,
  }) {
    return PointsReward(
      amount: amount,
      reason: reason,
      awardedAt: DateTime.now(),
      quadrant: quadrant,
    );
  }

  /// Get reason text for task completion
  static String getTaskCompletionReason(EisenhowerQuadrant quadrant) {
    switch (quadrant) {
      case EisenhowerQuadrant.q1:
        return 'Completed Do First task';
      case EisenhowerQuadrant.q2:
        return 'Completed Scheduled task';
      case EisenhowerQuadrant.q3:
        return 'Delegated task';
      case EisenhowerQuadrant.q4:
        return 'Deleted unnecessary task';
    }
  }

  /// Get reason text for streak bonus
  static String getStreakBonusReason(int streakDays) {
    return '$streakDays day streak bonus!';
  }

  /// Get reason text for achievement
  static String getAchievementReason(String achievementTitle) {
    return 'Unlocked: $achievementTitle';
  }

  /// Deduct points (for penalties if needed)
  static int calculatePenalty({
    required bool wasOverdue,
    required Duration howOverdue,
  }) {
    if (!wasOverdue) return 0;

    // 5 points penalty per day overdue, max 50
    final daysOverdue = howOverdue.inDays;
    if (daysOverdue == 0) return 5;

    return -(daysOverdue * 5).clamp(5, 50);
  }
}
