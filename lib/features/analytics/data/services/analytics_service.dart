import 'package:drift/drift.dart';
import '../../../../core/database/database.dart';

/// Time period for analytics
enum AnalyticsPeriod {
  today,
  thisWeek,
  thisMonth,
  lastWeek,
  lastMonth,
  custom,
}

/// Quadrant statistics
class QuadrantStats {
  final int quadrant;
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final double completionRate;
  final int totalPoints;

  const QuadrantStats({
    required this.quadrant,
    this.totalTasks = 0,
    this.completedTasks = 0,
    this.pendingTasks = 0,
    this.completionRate = 0.0,
    this.totalPoints = 0,
  });
}

/// Energy distribution across quadrants
class EnergyDistribution {
  final Map<int, double> percentages;
  final int totalTasks;
  final DateTime periodStart;
  final DateTime periodEnd;

  const EnergyDistribution({
    required this.percentages,
    required this.totalTasks,
    required this.periodStart,
    required this.periodEnd,
  });

  /// Ideal distribution for comparison
  static const Map<int, double> idealDistribution = {
    1: 0.20, // 20% Q1 (Urgent + Important)
    2: 0.40, // 40% Q2 (Important, Not Urgent) - should be highest
    3: 0.25, // 25% Q3 (Urgent, Not Important)
    4: 0.15, // 15% Q4 (Neither)
  };
}

/// Daily completion data for heatmap
class DailyCompletionData {
  final DateTime date;
  final int completedTasks;
  final int totalTasks;
  final double completionRate;

  const DailyCompletionData({
    required this.date,
    this.completedTasks = 0,
    this.totalTasks = 0,
    this.completionRate = 0.0,
  });
}

/// Analytics service for productivity insights
class AnalyticsService {
  final AppDatabase _db;

  AnalyticsService({required AppDatabase database}) : _db = database;

  /// Get quadrant statistics for a period
  Future<Map<int, QuadrantStats>> getQuadrantStats({
    required DateTime start,
    required DateTime end,
    required String userId,
  }) async {
    final stats = <int, QuadrantStats>{};

    for (var q = 1; q <= 4; q++) {
      final quadrant = TaskQuadrant.values[q - 1];

      final totalTasksQuery = _db.select(_db.tasks)
        ..where((t) =>
            t.userId.equals(userId) &
            t.quadrant.equals(quadrant.name) &
            t.createdAt.isBiggerOrEqualValue(start) &
            t.createdAt.isSmallerOrEqualValue(end));
      final totalTasks = (await totalTasksQuery.get()).length;

      final completedTasksQuery = _db.select(_db.tasks)
        ..where((t) =>
            t.userId.equals(userId) &
            t.quadrant.equals(quadrant.name) &
            t.status.equals(TaskStatus.completed.name) &
            t.completedAt.isBiggerOrEqualValue(start) &
            t.completedAt.isSmallerOrEqualValue(end));
      final completedTasks = (await completedTasksQuery.get()).length;

      final points = await _getQuadrantPoints(q, start, end, userId);

      stats[q] = QuadrantStats(
        quadrant: q,
        totalTasks: totalTasks,
        completedTasks: completedTasks,
        pendingTasks: totalTasks - completedTasks,
        completionRate: totalTasks > 0 ? completedTasks / totalTasks : 0.0,
        totalPoints: points,
      );
    }

    return stats;
  }

  /// Get total points earned in a quadrant
  Future<int> _getQuadrantPoints(
    int quadrant,
    DateTime start,
    DateTime end,
    String userId,
  ) async {
    final query = _db.select(_db.gamificationLogs)
      ..where((g) =>
          g.userId.equals(userId) &
          g.type.equals(GamificationLogType.taskCompleted.name) &
          g.createdAt.isBiggerOrEqualValue(start) &
          g.createdAt.isSmallerOrEqualValue(end));

    final points = await query.get();
    return points.fold<int>(0, (sum, log) => sum + log.points);
  }

  /// Get energy distribution for a period
  Future<EnergyDistribution> getEnergyDistribution({
    required DateTime start,
    required DateTime end,
    required String userId,
  }) async {
    final stats = await getQuadrantStats(
      start: start,
      end: end,
      userId: userId,
    );

    final totalTasks = stats.values.fold(0, (sum, s) => sum + s.totalTasks);

    final percentages = <int, double>{};
    for (var q = 1; q <= 4; q++) {
      percentages[q] = totalTasks > 0
          ? (stats[q]?.totalTasks ?? 0) / totalTasks
          : 0.0;
    }

    return EnergyDistribution(
      percentages: percentages,
      totalTasks: totalTasks,
      periodStart: start,
      periodEnd: end,
    );
  }

  /// Get daily completion data for heatmap
  Future<List<DailyCompletionData>> getCompletionHeatmap({
    required DateTime start,
    required DateTime end,
    required String userId,
  }) async {
    final data = <DailyCompletionData>[];
    var current = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);

    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      final dayStart = current;
      final dayEnd = current.add(const Duration(days: 1));

      final totalTasksQuery = _db.select(_db.tasks)
        ..where((t) =>
            t.userId.equals(userId) &
            t.createdAt.isBiggerOrEqualValue(dayStart) &
            t.createdAt.isSmallerThanValue(dayEnd));
      final totalTasks = (await totalTasksQuery.get()).length;

      final completedTasksQuery = _db.select(_db.tasks)
        ..where((t) =>
            t.userId.equals(userId) &
            t.status.equals(TaskStatus.completed.name) &
            t.completedAt.isBiggerOrEqualValue(dayStart) &
            t.completedAt.isSmallerThanValue(dayEnd));
      final completedTasks = (await completedTasksQuery.get()).length;

      data.add(DailyCompletionData(
        date: current,
        completedTasks: completedTasks,
        totalTasks: totalTasks,
        completionRate: totalTasks > 0 ? completedTasks / totalTasks : 0.0,
      ));

      current = current.add(const Duration(days: 1));
    }

    return data;
  }

  /// Get productivity score (0-100)
  Future<int> getProductivityScore({
    required DateTime start,
    required DateTime end,
    required String userId,
  }) async {
    final distribution = await getEnergyDistribution(
      start: start,
      end: end,
      userId: userId,
    );

    // Calculate score based on how close to ideal distribution
    double score = 100.0;

    for (var q = 1; q <= 4; q++) {
      final actual = distribution.percentages[q] ?? 0.0;
      final ideal = EnergyDistribution.idealDistribution[q] ?? 0.0;
      final diff = (actual - ideal).abs();
      score -= diff * 50; // Penalize deviation from ideal
    }

    return score.clamp(0, 100).toInt();
  }

  /// Get weekly summary
  Future<Map<String, dynamic>> getWeeklySummary({
    required String userId,
  }) async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartNormalized = DateTime(weekStart.year, weekStart.month, weekStart.day);

    final stats = await getQuadrantStats(
      start: weekStartNormalized,
      end: now,
      userId: userId,
    );

    final distribution = await getEnergyDistribution(
      start: weekStartNormalized,
      end: now,
      userId: userId,
    );

    final productivityScore = await getProductivityScore(
      start: weekStartNormalized,
      end: now,
      userId: userId,
    );

    final totalCompleted = stats.values.fold(0, (sum, s) => sum + s.completedTasks);
    final totalPoints = stats.values.fold(0, (sum, s) => sum + s.totalPoints);

    return {
      'totalCompleted': totalCompleted,
      'totalPoints': totalPoints,
      'productivityScore': productivityScore,
      'quadrantStats': stats,
      'energyDistribution': distribution,
      'mostProductiveQuadrant': _getMostProductiveQuadrant(stats),
      'improvementAreas': _getImprovementAreas(distribution),
    };
  }

  /// Get most productive quadrant
  int _getMostProductiveQuadrant(Map<int, QuadrantStats> stats) {
    var maxCompleted = 0;
    var mostProductive = 2; // Default to Q2

    stats.forEach((quadrant, stat) {
      if (stat.completedTasks > maxCompleted) {
        maxCompleted = stat.completedTasks;
        mostProductive = quadrant;
      }
    });

    return mostProductive;
  }

  /// Get areas for improvement
  List<String> _getImprovementAreas(EnergyDistribution distribution) {
    final improvements = <String>[];

    // Check Q2 investment
    final q2Percentage = distribution.percentages[2] ?? 0.0;
    if (q2Percentage < 0.30) {
      improvements.add('Increase investment in Q2 (Important but Not Urgent) tasks');
    }

    // Check Q1 overload
    final q1Percentage = distribution.percentages[1] ?? 0.0;
    if (q1Percentage > 0.35) {
      improvements.add('Reduce Q1 (Urgent + Important) overload by better planning');
    }

    // Check Q4 waste
    final q4Percentage = distribution.percentages[4] ?? 0.0;
    if (q4Percentage > 0.20) {
      improvements.add('Eliminate more Q4 (Not Important, Not Urgent) activities');
    }

    return improvements;
  }

  /// Get time-of-day productivity pattern
  Future<Map<int, int>> getProductivityByHour({
    required String userId,
    required int daysBack,
  }) async {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: daysBack));

    final query = _db.select(_db.tasks)
      ..where((t) =>
          t.userId.equals(userId) &
          t.status.equals(TaskStatus.completed.name) &
          t.completedAt.isBiggerOrEqualValue(start));

    final tasks = await query.get();

    final hourCounts = <int, int>{};
    for (var i = 0; i < 24; i++) {
      hourCounts[i] = 0;
    }

    for (final task in tasks) {
      if (task.completedAt != null) {
        final hour = task.completedAt!.hour;
        hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
      }
    }

    return hourCounts;
  }
}
