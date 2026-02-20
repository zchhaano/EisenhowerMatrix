import 'package:equatable/equatable.dart';

/// Entity representing a user achievement
class Achievement extends Equatable {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int points;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final AchievementCategory category;
  final int progress;
  final int maxProgress;
  final List<AchievementTier> tiers;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.points,
    this.isUnlocked = false,
    this.unlockedAt,
    required this.category,
    this.progress = 0,
    this.maxProgress = 1,
    this.tiers = const [],
  });

  double get progressPercentage => maxProgress > 0
      ? (progress / maxProgress).clamp(0.0, 1.0)
      : 0.0;

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    int? points,
    bool? isUnlocked,
    DateTime? unlockedAt,
    AchievementCategory? category,
    int? progress,
    int? maxProgress,
    List<AchievementTier>? tiers,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      points: points ?? this.points,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      category: category ?? this.category,
      progress: progress ?? this.progress,
      maxProgress: maxProgress ?? this.maxProgress,
      tiers: tiers ?? this.tiers,
    );
  }

  @override
  List<Object?> get props => [
    id, title, description, icon, points, isUnlocked,
    unlockedAt, category, progress, maxProgress, tiers,
  ];
}

/// Categories of achievements
enum AchievementCategory {
  productivity,
  consistency,
  mastery,
  social,
  special,
}

/// Tier system for progressive achievements
class AchievementTier {
  final int level;
  final String name;
  final int points;
  final String? icon;
  final int requirement;

  const AchievementTier({
    required this.level,
    required this.name,
    required this.points,
    this.icon,
    required this.requirement,
  });
}

/// Predefined achievement definitions
class Achievements {
  static const List<Achievement> all = [
    // Productivity achievements
    Achievement(
      id: 'first_task',
      title: 'First Steps',
      description: 'Complete your first task',
      icon: '🎯',
      points: 10,
      category: AchievementCategory.productivity,
      maxProgress: 1,
    ),
    Achievement(
      id: 'q1_master',
      title: 'Do First Champion',
      description: 'Complete 50 Q1 (Do First) tasks',
      icon: '🔥',
      points: 100,
      category: AchievementCategory.productivity,
      maxProgress: 50,
    ),
    Achievement(
      id: 'strategist',
      title: 'Strategic Planner',
      description: 'Complete 30 Q2 (Schedule) tasks',
      icon: '📋',
      points: 150,
      category: AchievementCategory.productivity,
      maxProgress: 30,
    ),
    Achievement(
      id: 'delegation_pro',
      title: 'Delegation Pro',
      description: 'Delegate 20 tasks successfully',
      icon: '🤝',
      points: 75,
      category: AchievementCategory.productivity,
      maxProgress: 20,
    ),
    Achievement(
      id: 'declutterer',
      title: 'Master Declutterer',
      description: 'Delete 100 unnecessary tasks',
      icon: '🗑️',
      points: 50,
      category: AchievementCategory.productivity,
      maxProgress: 100,
    ),

    // Consistency achievements
    Achievement(
      id: 'streak_3',
      title: 'Building Momentum',
      description: 'Complete tasks for 3 days in a row',
      icon: '🌱',
      points: 25,
      category: AchievementCategory.consistency,
      maxProgress: 3,
    ),
    Achievement(
      id: 'streak_7',
      title: 'Week Warrior',
      description: 'Complete tasks for 7 days in a row',
      icon: '⚡',
      points: 100,
      category: AchievementCategory.consistency,
      maxProgress: 7,
    ),
    Achievement(
      id: 'streak_30',
      title: 'Monthly Master',
      description: 'Complete tasks for 30 days in a row',
      icon: '🏆',
      points: 500,
      category: AchievementCategory.consistency,
      maxProgress: 30,
    ),
    Achievement(
      id: 'streak_90',
      title: 'Quarter Champion',
      description: 'Complete tasks for 90 days in a row',
      icon: '👑',
      points: 2000,
      category: AchievementCategory.consistency,
      maxProgress: 90,
    ),

    // Mastery achievements
    Achievement(
      id: 'level_5',
      title: 'Rising Star',
      description: 'Reach level 5',
      icon: '⭐',
      points: 50,
      category: AchievementCategory.mastery,
      maxProgress: 5,
    ),
    Achievement(
      id: 'level_10',
      title: 'Achiever',
      description: 'Reach level 10',
      icon: '🌟',
      points: 150,
      category: AchievementCategory.mastery,
      maxProgress: 10,
    ),
    Achievement(
      id: 'level_25',
      title: 'Expert',
      description: 'Reach level 25',
      icon: '💫',
      points: 500,
      category: AchievementCategory.mastery,
      maxProgress: 25,
    ),
    Achievement(
      id: 'points_1000',
      title: 'Point Collector',
      description: 'Earn 1000 total points',
      icon: '💰',
      points: 200,
      category: AchievementCategory.mastery,
      maxProgress: 1000,
    ),
    Achievement(
      id: 'points_10000',
      title: 'Point Tycoon',
      description: 'Earn 10,000 total points',
      icon: '💎',
      points: 1000,
      category: AchievementCategory.mastery,
      maxProgress: 10000,
    ),

    // Special achievements
    Achievement(
      id: 'perfect_day',
      title: 'Perfect Day',
      description: 'Complete all planned tasks in a day',
      icon: '✨',
      points: 50,
      category: AchievementCategory.special,
      maxProgress: 1,
    ),
    Achievement(
      id: 'early_bird',
      title: 'Early Bird',
      description: 'Complete a task before 8 AM',
      icon: '🐦',
      points: 25,
      category: AchievementCategory.special,
      maxProgress: 1,
    ),
    Achievement(
      id: 'night_owl',
      title: 'Night Owl',
      description: 'Complete a task after 10 PM',
      icon: '🦉',
      points: 25,
      category: AchievementCategory.special,
      maxProgress: 1,
    ),
    Achievement(
      id: 'speed_demon',
      title: 'Speed Demon',
      description: 'Complete 5 tasks in one hour',
      icon: '⏱️',
      points: 75,
      category: AchievementCategory.special,
      maxProgress: 5,
    ),
  ];
}

/// User's achievement progress
class AchievementProgress {
  final String achievementId;
  final int progress;
  final DateTime? lastUpdated;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const AchievementProgress({
    required this.achievementId,
    this.progress = 0,
    this.lastUpdated,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  AchievementProgress copyWith({
    String? achievementId,
    int? progress,
    DateTime? lastUpdated,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return AchievementProgress(
      achievementId: achievementId ?? this.achievementId,
      progress: progress ?? this.progress,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}
