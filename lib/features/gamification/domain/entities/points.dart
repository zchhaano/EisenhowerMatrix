/// Entity representing points/karma in the system
class Points {
  final int total;
  final int today;
  final int thisWeek;
  final int thisMonth;
  final DateTime lastUpdated;
  final int level;
  final int xpToNextLevel;

  const Points({
    required this.total,
    this.today = 0,
    this.thisWeek = 0,
    this.thisMonth = 0,
    required this.lastUpdated,
    this.level = 1,
    this.xpToNextLevel = 100,
  });

  Points copyWith({
    int? total,
    int? today,
    int? thisWeek,
    int? thisMonth,
    DateTime? lastUpdated,
    int? level,
    int? xpToNextLevel,
  }) {
    return Points(
      total: total ?? this.total,
      today: today ?? this.today,
      thisWeek: thisWeek ?? this.thisWeek,
      thisMonth: thisMonth ?? this.thisMonth,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      level: level ?? this.level,
      xpToNextLevel: xpToNextLevel ?? this.xpToNextLevel,
    );
  }

  /// Calculate progress to next level as a percentage
  double get progressToNextLevel {
    final currentLevelXp = total - xpToNextLevel;
    final totalLevelXp = xpToNextLevel * 2; // Assuming exponential scaling
    return (currentLevelXp / totalLevelXp).clamp(0.0, 1.0);
  }

  /// Alias for progressToNextLevel
  double get levelProgress => progressToNextLevel;

  /// Get the total XP needed for current level
  int get xpForCurrentLevel => (level - 1) * 100;

  /// Get the total XP needed for next level
  int get xpForNextLevel => level * 100;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Points &&
          runtimeType == other.runtimeType &&
          total == other.total &&
          level == other.level;

  @override
  int get hashCode => total.hashCode ^ level.hashCode;
}

/// Points awarded for different actions
class PointsReward {
  final int amount;
  final String reason;
  final DateTime awardedAt;
  final EisenhowerQuadrant? quadrant;

  const PointsReward({
    required this.amount,
    required this.reason,
    required this.awardedAt,
    this.quadrant,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PointsReward &&
          runtimeType == other.runtimeType &&
          amount == other.amount &&
          reason == other.reason &&
          awardedAt == other.awardedAt;

  @override
  int get hashCode => amount.hashCode ^ reason.hashCode ^ awardedAt.hashCode;
}

/// Eisenhower quadrants for points calculation
enum EisenhowerQuadrant {
  q1,
  q2,
  q3,
  q4,
}

extension EisenhowerQuadrantPoints on EisenhowerQuadrant {
  /// Points awarded for completing a task in this quadrant
  int get completionPoints {
    switch (this) {
      case EisenhowerQuadrant.q1:
        return 10; // Do First
      case EisenhowerQuadrant.q2:
        return 15; // Schedule - bonus for strategic work
      case EisenhowerQuadrant.q3:
        return 5; // Delegate
      case EisenhowerQuadrant.q4:
        return 3; // Delete
    }
  }

  /// Display name for the quadrant
  String get displayName {
    switch (this) {
      case EisenhowerQuadrant.q1:
        return 'Do First';
      case EisenhowerQuadrant.q2:
        return 'Schedule';
      case EisenhowerQuadrant.q3:
        return 'Delegate';
      case EisenhowerQuadrant.q4:
        return 'Delete';
    }
  }
}
