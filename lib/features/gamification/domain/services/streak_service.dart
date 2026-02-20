import '../entities/points.dart';

/// Service for tracking and managing user streaks
class StreakService {
  /// Calculate the current streak based on completed task dates
  static StreakInfo calculateStreak({
    required List<DateTime> completedDates,
    required DateTime today,
  }) {
    if (completedDates.isEmpty) {
      return const StreakInfo(
        currentStreak: 0,
        longestStreak: 0,
        lastStreakDate: null,
      );
    }

    // Sort dates in descending order (most recent first)
    final sortedDates = completedDates.toList()
      ..sort((a, b) => b.compareTo(a));

    // Normalize dates to midnight for comparison
    final normalizedDates = sortedDates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList();

    // Find the last streak date
    DateTime? lastStreakDate = normalizedDates.first;

    // Check if streak is still active (completed today or yesterday)
    final todayNormalized = DateTime(today.year, today.month, today.day);
    final yesterday = todayNormalized.subtract(const Duration(days: 1));

    if (lastStreakDate.isBefore(yesterday)) {
      // Streak is broken
      return StreakInfo(
        currentStreak: 0,
        longestStreak: _calculateLongestStreak(normalizedDates),
        lastStreakDate: lastStreakDate,
        isActive: false,
      );
    }

    // Calculate current streak
    int currentStreak = 0;
    DateTime checkDate = todayNormalized;

    for (final date in normalizedDates) {
      if (date.isAtSameMomentAs(checkDate) ||
          date.isAtSameMomentAs(checkDate.subtract(const Duration(days: 1)))) {
        currentStreak++;
        checkDate = date.subtract(const Duration(days: 1));
      } else if (date.isBefore(checkDate.subtract(const Duration(days: 1)))) {
        break;
      }
    }

    return StreakInfo(
      currentStreak: currentStreak,
      longestStreak: _calculateLongestStreak(normalizedDates),
      lastStreakDate: lastStreakDate,
      isActive: currentStreak > 0,
    );
  }

  /// Calculate the longest streak from a list of dates
  static int _calculateLongestStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;

    // Sort dates ascending
    dates.sort((a, b) => a.compareTo(b));

    int longestStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < dates.length; i++) {
      final diff = dates[i].difference(dates[i - 1]).inDays;

      if (diff == 0) {
        // Same day, skip
        continue;
      } else if (diff == 1) {
        // Consecutive day
        currentStreak++;
      } else {
        // Streak broken
        longestStreak = longestStreak > currentStreak
            ? longestStreak
            : currentStreak;
        currentStreak = 1;
      }
    }

    return longestStreak > currentStreak ? longestStreak : currentStreak;
  }

  /// Check if a date contributes to a streak
  static bool isStreakDay(DateTime date, List<DateTime> completedDates) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final normalizedCompleted = completedDates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();

    return normalizedCompleted.contains(normalizedDate);
  }

  /// Get the next date that will break the streak
  static DateTime getStreakDeadline(DateTime lastCompletedDate) {
    // Streak breaks if no task completed by end of tomorrow
    return DateTime(
      lastCompletedDate.year,
      lastCompletedDate.month,
      lastCompletedDate.day + 2,
      23, 59, 59,
    );
  }

  /// Calculate days remaining to maintain streak
  static int getDaysRemaining(DateTime lastCompletedDate, DateTime now) {
    final deadline = getStreakDeadline(lastCompletedDate);
    final diff = deadline.difference(now);
    return diff.inDays + (diff.inHours > 0 ? 1 : 0);
  }

  /// Get streak milestone information
  static StreakMilestone getNextMilestone(int currentStreak) {
    if (currentStreak < 7) {
      return const StreakMilestone(
        days: 7,
        bonus: 50,
        title: 'Week Warrior',
      );
    } else if (currentStreak < 30) {
      return const StreakMilestone(
        days: 30,
        bonus: 200,
        title: 'Monthly Master',
      );
    } else if (currentStreak < 90) {
      return const StreakMilestone(
        days: 90,
        bonus: 500,
        title: 'Quarter Champion',
      );
    } else {
      return const StreakMilestone(
        days: 180,
        bonus: 1000,
        title: 'Half-Year Hero',
      );
    }
  }

  /// Get all achieved milestones for a streak
  static List<StreakMilestone> getAchievedMilestones(int streakDays) {
    final milestones = <StreakMilestone>[];

    if (streakDays >= 7) {
      milestones.add(const StreakMilestone(
        days: 7,
        bonus: 50,
        title: 'Week Warrior',
      ));
    }
    if (streakDays >= 30) {
      milestones.add(const StreakMilestone(
        days: 30,
        bonus: 200,
        title: 'Monthly Master',
      ));
    }
    if (streakDays >= 90) {
      milestones.add(const StreakMilestone(
        days: 90,
        bonus: 500,
        title: 'Quarter Champion',
      ));
    }

    return milestones;
  }

  /// Calculate streak bonus points
  static int calculateStreakBonus(int streakDays) {
    int bonus = 0;

    if (streakDays >= 90) bonus += 500;
    if (streakDays >= 30) bonus += 200;
    if (streakDays >= 7) bonus += 50;

    return bonus;
  }

  /// Check if a milestone was just reached
  static bool justReachedMilestone(int previousStreak, int currentStreak) {
    final milestones = [7, 30, 90, 180];
    for (final milestone in milestones) {
      if (previousStreak < milestone && currentStreak >= milestone) {
        return true;
      }
    }
    return false;
  }

  /// Get the milestone that was just reached
  static StreakMilestone? getReachedMilestone(
    int previousStreak,
    int currentStreak,
  ) {
    final milestones = [
      const StreakMilestone(days: 7, bonus: 50, title: 'Week Warrior'),
      const StreakMilestone(days: 30, bonus: 200, title: 'Monthly Master'),
      const StreakMilestone(days: 90, bonus: 500, title: 'Quarter Champion'),
      const StreakMilestone(days: 180, bonus: 1000, title: 'Half-Year Hero'),
    ];

    for (final milestone in milestones) {
      if (previousStreak < milestone.days && currentStreak >= milestone.days) {
        return milestone;
      }
    }
    return null;
  }
}

/// Information about a user's streak
class StreakInfo {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastStreakDate;
  final bool isActive;

  const StreakInfo({
    required this.currentStreak,
    required this.longestStreak,
    this.lastStreakDate,
    this.isActive = true,
  });

  StreakInfo copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastStreakDate,
    bool? isActive,
  }) {
    return StreakInfo(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastStreakDate: lastStreakDate ?? this.lastStreakDate,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreakInfo &&
          runtimeType == other.runtimeType &&
          currentStreak == other.currentStreak &&
          longestStreak == other.longestStreak &&
          lastStreakDate == other.lastStreakDate &&
          isActive == other.isActive;

  @override
  int get hashCode =>
      currentStreak.hashCode ^
      longestStreak.hashCode ^
      lastStreakDate.hashCode ^
      isActive.hashCode;
}

/// Represents a streak milestone achievement
class StreakMilestone {
  final int days;
  final int bonus;
  final String title;

  const StreakMilestone({
    required this.days,
    required this.bonus,
    required this.title,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreakMilestone &&
          runtimeType == other.runtimeType &&
          days == other.days &&
          bonus == other.bonus &&
          title == other.title;

  @override
  int get hashCode => days.hashCode ^ bonus.hashCode ^ title.hashCode;
}
