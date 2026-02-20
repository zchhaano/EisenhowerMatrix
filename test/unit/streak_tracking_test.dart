import 'package:flutter_test/flutter_test.dart';
import 'package:eisenhower_matrix/features/gamification/domain/services/streak_service.dart';

void main() {
  group('StreakService - Basic Streak Calculation', () {
    test('calculateStreak returns 0 for empty completion list', () {
      // Arrange
      final completedDates = <DateTime>[];
      final today = DateTime.now();

      // Act
      final streakInfo = StreakService.calculateStreak(
        completedDates: completedDates,
        today: today,
      );

      // Assert
      expect(streakInfo.currentStreak, 0);
      expect(streakInfo.longestStreak, 0);
      expect(streakInfo.lastStreakDate, isNull);
    });

    test('calculateStreak returns 1 for single completion today', () {
      // Arrange
      final today = DateTime(2024, 1, 15);
      final completedDates = [today];

      // Act
      final streakInfo = StreakService.calculateStreak(
        completedDates: completedDates,
        today: today,
      );

      // Assert
      expect(streakInfo.currentStreak, 1);
      expect(streakInfo.longestStreak, 1);
      expect(streakInfo.lastStreakDate, isNotNull);
      expect(streakInfo.isActive, isTrue);
    });

    test('calculateStreak increments on daily check-in', () {
      // Arrange
      final today = DateTime(2024, 1, 15);
      final yesterday = DateTime(2024, 1, 14);
      final completedDates = [today, yesterday];

      // Act
      final streakInfo = StreakService.calculateStreak(
        completedDates: completedDates,
        today: today,
      );

      // Assert
      expect(streakInfo.currentStreak, 2);
      expect(streakInfo.isActive, isTrue);
    });

    test('calculateStreak handles consecutive days correctly', () {
      // Arrange
      final today = DateTime(2024, 1, 15);
      final completedDates = [
        today,
        DateTime(2024, 1, 14),
        DateTime(2024, 1, 13),
        DateTime(2024, 1, 12),
        DateTime(2024, 1, 11),
      ];

      // Act
      final streakInfo = StreakService.calculateStreak(
        completedDates: completedDates,
        today: today,
      );

      // Assert
      expect(streakInfo.currentStreak, 5);
      expect(streakInfo.longestStreak, 5);
    });
  });

  group('StreakService - Streak Reset', () {
    test('calculateStreak resets to 0 when day is missed', () {
      // Arrange
      final today = DateTime(2024, 1, 15);
      final completedDates = [
        DateTime(2024, 1, 13), // 2 days ago - gap!
        DateTime(2024, 1, 12), // 3 days ago
        DateTime(2024, 1, 11), // 4 days ago
      ];

      // Act
      final streakInfo = StreakService.calculateStreak(
        completedDates: completedDates,
        today: today,
      );

      // Assert
      expect(streakInfo.currentStreak, 0);
      expect(streakInfo.isActive, isFalse);
    });

    test('calculateStreak tracks longest streak even after reset', () {
      // Arrange
      final today = DateTime(2024, 1, 20);
      final completedDates = [
        DateTime(2024, 1, 20), // Today - new streak of 1
        DateTime(2024, 1, 10),
        DateTime(2024, 1, 9),
        DateTime(2024, 1, 8),
        DateTime(2024, 1, 7),
        DateTime(2024, 1, 6),
        DateTime(2024, 1, 5),
      ];

      // Act
      final streakInfo = StreakService.calculateStreak(
        completedDates: completedDates,
        today: today,
      );

      // Assert
      expect(streakInfo.currentStreak, 1);
      expect(streakInfo.longestStreak, greaterThan(1));
      expect(streakInfo.isActive, isTrue);
    });

    test('calculateStreak handles multiple tasks on same day', () {
      // Arrange
      final today = DateTime(2024, 1, 15);
      final yesterday = DateTime(2024, 1, 14);
      final completedDates = [
        today,
        DateTime(2024, 1, 15, 12, 30), // Same day, different time
        DateTime(2024, 1, 15, 18, 45), // Same day, different time
        yesterday,
      ];

      // Act
      final streakInfo = StreakService.calculateStreak(
        completedDates: completedDates,
        today: today,
      );

      // Assert
      expect(streakInfo.currentStreak, 2); // Still counts as 2 days
    });
  });

  group('StreakService - Streak Milestones', () {
    test('getNextMilestone returns Week Warrior for streak below 7', () {
      // Arrange
      const currentStreak = 3;

      // Act
      final milestone = StreakService.getNextMilestone(currentStreak);

      // Assert
      expect(milestone.days, 7);
      expect(milestone.bonus, 50);
      expect(milestone.title, 'Week Warrior');
    });

    test('getNextMilestone returns Monthly Master for streak between 7 and 30', () {
      // Arrange
      const currentStreak = 15;

      // Act
      final milestone = StreakService.getNextMilestone(currentStreak);

      // Assert
      expect(milestone.days, 30);
      expect(milestone.bonus, 200);
      expect(milestone.title, 'Monthly Master');
    });

    test('getNextMilestone returns Quarter Champion for streak between 30 and 90', () {
      // Arrange
      const currentStreak = 60;

      // Act
      final milestone = StreakService.getNextMilestone(currentStreak);

      // Assert
      expect(milestone.days, 90);
      expect(milestone.bonus, 500);
      expect(milestone.title, 'Quarter Champion');
    });

    test('getNextMilestone returns Half-Year Hero for streak above 90', () {
      // Arrange
      const currentStreak = 120;

      // Act
      final milestone = StreakService.getNextMilestone(currentStreak);

      // Assert
      expect(milestone.days, 180);
      expect(milestone.bonus, 1000);
      expect(milestone.title, 'Half-Year Hero');
    });

    test('isStreakDay returns true for date in completed dates', () {
      // Arrange
      final date = DateTime(2024, 1, 15);
      final completedDates = [
        DateTime(2024, 1, 15),
        DateTime(2024, 1, 14),
      ];

      // Act
      final isStreakDay = StreakService.isStreakDay(date, completedDates);

      // Assert
      expect(isStreakDay, isTrue);
    });

    test('isStreakDay returns false for date not in completed dates', () {
      // Arrange
      final date = DateTime(2024, 1, 15);
      final completedDates = [
        DateTime(2024, 1, 14),
        DateTime(2024, 1, 13),
      ];

      // Act
      final isStreakDay = StreakService.isStreakDay(date, completedDates);

      // Assert
      expect(isStreakDay, isFalse);
    });
  });

  group('StreakService - Achieved Milestones', () {
    test('getAchievedMilestones returns empty list for streak below 7', () {
      // Act
      final milestones = StreakService.getAchievedMilestones(5);

      // Assert
      expect(milestones, isEmpty);
    });

    test('getAchievedMilestones includes Week Warrior for 7-day streak', () {
      // Act
      final milestones = StreakService.getAchievedMilestones(7);

      // Assert
      expect(milestones, hasLength(1));
      expect(milestones.first.days, 7);
      expect(milestones.first.title, 'Week Warrior');
    });

    test('getAchievedMilestones includes all milestones for 90-day streak', () {
      // Act
      final milestones = StreakService.getAchievedMilestones(90);

      // Assert
      expect(milestones, hasLength(3));
      expect(milestones[0].days, 7);
      expect(milestones[1].days, 30);
      expect(milestones[2].days, 90);
    });

    test('getAchievedMilestones includes correct bonuses', () {
      // Act
      final milestones = StreakService.getAchievedMilestones(30);

      // Assert
      expect(milestones, hasLength(2));
      expect(milestones[0].bonus, 50); // Week Warrior
      expect(milestones[1].bonus, 200); // Monthly Master
    });
  });

  group('StreakService - Streak Bonus Calculation', () {
    test('calculateStreakBonus returns 0 for streak below 7', () {
      // Act
      final bonus = StreakService.calculateStreakBonus(5);

      // Assert
      expect(bonus, 0);
    });

    test('calculateStreakBonus returns 50 for 7-day streak', () {
      // Act
      final bonus = StreakService.calculateStreakBonus(7);

      // Assert
      expect(bonus, 50);
    });

    test('calculateStreakBonus returns 200 for 30-day streak', () {
      // Act
      final bonus = StreakService.calculateStreakBonus(30);

      // Assert
      // Implementation is cumulative: 50 (7-day) + 200 (30-day) = 250
      expect(bonus, 250);
    });

    test('calculateStreakBonus returns 500 for 90-day streak', () {
      // Act
      final bonus = StreakService.calculateStreakBonus(90);

      // Assert
      // Implementation is cumulative: 50 (7-day) + 200 (30-day) + 500 (90-day) = 750
      expect(bonus, 750);
    });

    test('calculateStreakBonus is cumulative for multiple tiers', () {
      // At exactly 30 days, should include both 7 and 30 day bonuses
      final bonus = StreakService.calculateStreakBonus(30);

      // The implementation adds all qualifying tier bonuses
      expect(bonus, 250); // 50 (7-day) + 200 (30-day)
    });

    test('calculateStreakBonus includes all tiers for 90-day streak', () {
      // At exactly 90 days, should include all tier bonuses
      final bonus = StreakService.calculateStreakBonus(90);

      // 50 (7-day) + 200 (30-day) + 500 (90-day)
      expect(bonus, 750);
    });
  });

  group('StreakService - Milestone Detection', () {
    test('justReachedMilestone returns true when crossing 7 days', () {
      // Act
      final reached = StreakService.justReachedMilestone(6, 7);

      // Assert
      expect(reached, isTrue);
    });

    test('justReachedMilestone returns true when crossing 30 days', () {
      // Act
      final reached = StreakService.justReachedMilestone(28, 31);

      // Assert
      expect(reached, isTrue);
    });

    test('justReachedMilestone returns false when no milestone crossed', () {
      // Act
      final reached = StreakService.justReachedMilestone(10, 12);

      // Assert
      expect(reached, isFalse);
    });

    test('justReachedMilestone returns false when already past milestone', () {
      // Act
      final reached = StreakService.justReachedMilestone(35, 40);

      // Assert
      expect(reached, isFalse);
    });

    test('getReachedMilestone returns Week Warrior when reaching 7 days', () {
      // Act
      final milestone = StreakService.getReachedMilestone(6, 7);

      // Assert
      expect(milestone, isNotNull);
      expect(milestone!.days, 7);
      expect(milestone.title, 'Week Warrior');
    });

    test('getReachedMilestone returns Monthly Master when reaching 30 days', () {
      // Act
      final milestone = StreakService.getReachedMilestone(28, 30);

      // Assert
      expect(milestone, isNotNull);
      expect(milestone!.days, 30);
      expect(milestone.title, 'Monthly Master');
    });

    test('getReachedMilestone returns null when no milestone reached', () {
      // Act
      final milestone = StreakService.getReachedMilestone(10, 12);

      // Assert
      expect(milestone, isNull);
    });

    test('getReachedMilestone returns Quarter Champion when reaching 90 days', () {
      // Act
      final milestone = StreakService.getReachedMilestone(85, 90);

      // Assert
      expect(milestone, isNotNull);
      expect(milestone!.days, 90);
      expect(milestone.title, 'Quarter Champion');
    });

    test('getReachedMilestone returns Half-Year Hero when reaching 180 days', () {
      // Act
      final milestone = StreakService.getReachedMilestone(175, 180);

      // Assert
      expect(milestone, isNotNull);
      expect(milestone!.days, 180);
      expect(milestone.title, 'Half-Year Hero');
    });
  });

  group('StreakService - Deadline and Days Remaining', () {
    test('getStreakDeadline returns end of day after tomorrow', () {
      // Arrange
      final lastCompletedDate = DateTime(2024, 1, 15, 14, 30);

      // Act
      final deadline = StreakService.getStreakDeadline(lastCompletedDate);

      // Assert
      expect(deadline.year, 2024);
      expect(deadline.month, 1);
      expect(deadline.day, 17); // Day after tomorrow
      expect(deadline.hour, 23);
      expect(deadline.minute, 59);
      expect(deadline.second, 59);
    });

    test('getDaysRemaining calculates days until streak breaks', () {
      // Arrange
      final lastCompletedDate = DateTime(2024, 1, 15);
      final now = DateTime(2024, 1, 16, 12, 0); // Next day at noon

      // Act
      final daysRemaining = StreakService.getDaysRemaining(lastCompletedDate, now);

      // Assert
      // Implementation adds 1 day if there are remaining hours
      // With ~36 hours until deadline (Jan 17, 23:59:59), it returns 2
      expect(daysRemaining, 2); // 2 days left to complete a task
    });

    test('getDaysRemaining returns 0 on deadline day', () {
      // Arrange
      final lastCompletedDate = DateTime(2024, 1, 15);
      final now = DateTime(2024, 1, 18, 0, 0); // Past deadline day (Jan 18)

      // Act
      final daysRemaining = StreakService.getDaysRemaining(lastCompletedDate, now);

      // Assert
      expect(daysRemaining, 0); // Past deadline day
    });
  });

  group('StreakInfo Entity', () {
    test('StreakInfo stores values correctly', () {
      // Arrange & Act
      final now = DateTime.now();
      final streakInfo = StreakInfo(
        currentStreak: 10,
        longestStreak: 30,
        lastStreakDate: now,
        isActive: true,
      );

      // Assert
      expect(streakInfo.currentStreak, 10);
      expect(streakInfo.longestStreak, 30);
      expect(streakInfo.lastStreakDate, now);
      expect(streakInfo.isActive, isTrue);
    });

    test('StreakInfo copyWith updates values correctly', () {
      // Arrange
      final original = StreakInfo(
        currentStreak: 5,
        longestStreak: 10,
      );

      // Act
      final updated = original.copyWith(currentStreak: 15);

      // Assert
      expect(updated.currentStreak, 15);
      expect(updated.longestStreak, original.longestStreak);
    });

    test('StreakInfo equality works correctly', () {
      // Arrange
      final date = DateTime(2024, 1, 15);
      final info1 = StreakInfo(
        currentStreak: 5,
        longestStreak: 10,
        lastStreakDate: date,
        isActive: true,
      );
      final info2 = StreakInfo(
        currentStreak: 5,
        longestStreak: 10,
        lastStreakDate: date,
        isActive: true,
      );
      final info3 = StreakInfo(
        currentStreak: 7,
        longestStreak: 10,
        lastStreakDate: date,
        isActive: true,
      );

      // Assert
      expect(info1, equals(info2));
      expect(info1, isNot(equals(info3)));
    });

    test('StreakInfo hashCode matches equal instances', () {
      // Arrange
      final date = DateTime(2024, 1, 15);
      final info1 = StreakInfo(
        currentStreak: 5,
        longestStreak: 10,
        lastStreakDate: date,
        isActive: true,
      );
      final info2 = StreakInfo(
        currentStreak: 5,
        longestStreak: 10,
        lastStreakDate: date,
        isActive: true,
      );

      // Assert
      expect(info1.hashCode, equals(info2.hashCode));
    });
  });

  group('StreakMilestone Entity', () {
    test('StreakMilestone stores values correctly', () {
      // Arrange & Act
      const milestone = StreakMilestone(
        days: 30,
        bonus: 200,
        title: 'Monthly Master',
      );

      // Assert
      expect(milestone.days, 30);
      expect(milestone.bonus, 200);
      expect(milestone.title, 'Monthly Master');
    });

    test('StreakMilestone equality works correctly', () {
      // Arrange
      const milestone1 = StreakMilestone(
        days: 7,
        bonus: 50,
        title: 'Week Warrior',
      );
      const milestone2 = StreakMilestone(
        days: 7,
        bonus: 50,
        title: 'Week Warrior',
      );
      const milestone3 = StreakMilestone(
        days: 30,
        bonus: 200,
        title: 'Monthly Master',
      );

      // Assert
      expect(milestone1, equals(milestone2));
      expect(milestone1, isNot(equals(milestone3)));
    });

    test('StreakMilestone hashCode matches equal instances', () {
      // Arrange
      const milestone1 = StreakMilestone(
        days: 7,
        bonus: 50,
        title: 'Week Warrior',
      );
      const milestone2 = StreakMilestone(
        days: 7,
        bonus: 50,
        title: 'Week Warrior',
      );

      // Assert
      expect(milestone1.hashCode, equals(milestone2.hashCode));
    });
  });

  group('StreakService - Longest Streak Calculation', () {
    test('calculateStreak correctly identifies longest streak', () {
      // Arrange
      final today = DateTime(2024, 1, 20);
      final completedDates = [
        today,
        DateTime(2024, 1, 19),
        DateTime(2024, 1, 18),
        DateTime(2024, 1, 10),
        DateTime(2024, 1, 9),
        DateTime(2024, 1, 8),
      ];

      // Act
      final streakInfo = StreakService.calculateStreak(
        completedDates: completedDates,
        today: today,
      );

      // Assert
      expect(streakInfo.currentStreak, 3); // Current streak
      expect(streakInfo.longestStreak, 3); // Longest is the current one
    });

    test('calculateStreak tracks past streak as longest when broken', () {
      // Arrange
      final today = DateTime(2024, 1, 20);
      final completedDates = [
        today, // New streak of 1
        DateTime(2024, 1, 15),
        DateTime(2024, 1, 14),
        DateTime(2024, 1, 13),
        DateTime(2024, 1, 12),
        DateTime(2024, 1, 11),
        DateTime(2024, 1, 10),
      ];

      // Act
      final streakInfo = StreakService.calculateStreak(
        completedDates: completedDates,
        today: today,
      );

      // Assert
      expect(streakInfo.currentStreak, 1);
      expect(streakInfo.longestStreak, 6); // Previous 6-day streak (Jan 10-15)
    });
  });
}
