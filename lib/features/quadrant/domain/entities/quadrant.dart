import 'package:flutter/material.dart';

/// Quadrant type for the Eisenhower Matrix
enum QuadrantType {
  /// Q1: Urgent + Important - Do First / 立即做
  first,

  /// Q2: Not Urgent + Important - Schedule / 计划做
  second,

  /// Q3: Urgent + Not Important - Delegate / 委派做
  third,

  /// Q4: Not Urgent + Not Important - Delete / 删除
  fourth,
}

/// Extension on QuadrantType to provide display properties
extension QuadrantTypeX on QuadrantType {
  /// English label for the quadrant
  String get label {
    switch (this) {
      case QuadrantType.first:
        return 'Do First';
      case QuadrantType.second:
        return 'Schedule';
      case QuadrantType.third:
        return 'Delegate';
      case QuadrantType.fourth:
        return 'Delete';
    }
  }

  /// Chinese label for the quadrant
  String get labelZh {
    switch (this) {
      case QuadrantType.first:
        return '立即做';
      case QuadrantType.second:
        return '计划做';
      case QuadrantType.third:
        return '委派做';
      case QuadrantType.fourth:
        return '删除';
    }
  }

  /// Full bilingual label
  String get fullLabel => '$label\n$labelZh';

  /// Description for the quadrant
  String get description {
    switch (this) {
      case QuadrantType.first:
        return 'Urgent & Important';
      case QuadrantType.second:
        return 'Important, Not Urgent';
      case QuadrantType.third:
        return 'Urgent, Not Important';
      case QuadrantType.fourth:
        return 'Neither Urgent nor Important';
    }
  }

  /// Color associated with the quadrant
  Color get color {
    switch (this) {
      case QuadrantType.first:
        return const Color(0xFFEF5350); // Red
      case QuadrantType.second:
        return const Color(0xFF42A5F5); // Blue
      case QuadrantType.third:
        return const Color(0xFFFFA726); // Orange
      case QuadrantType.fourth:
        return const Color(0xFF66BB6A); // Green
    }
  }

  /// Lighter background color for the quadrant
  Color get backgroundColor {
    switch (this) {
      case QuadrantType.first:
        return const Color(0xFFFFEBEE);
      case QuadrantType.second:
        return const Color(0xFFE3F2FD);
      case QuadrantType.third:
        return const Color(0xFFFFF3E0);
      case QuadrantType.fourth:
        return const Color(0xFFE8F5E9);
    }
  }

  /// Icon for the quadrant
  String get iconAsset {
    switch (this) {
      case QuadrantType.first:
        return 'assets/icons/q1_fire.svg';
      case QuadrantType.second:
        return 'assets/icons/q2_calendar.svg';
      case QuadrantType.third:
        return 'assets/icons/q3_people.svg';
      case QuadrantType.fourth:
        return 'assets/icons/q4_trash.svg';
    }
  }

  /// Get the index (0-3) of this quadrant
  int get index {
    switch (this) {
      case QuadrantType.first:
        return 0;
      case QuadrantType.second:
        return 1;
      case QuadrantType.third:
        return 2;
      case QuadrantType.fourth:
        return 3;
    }
  }
}

/// Convert index to QuadrantType
QuadrantType indexToQuadrant(int index) {
  return QuadrantType.values[index];
}

/// Quadrant entity containing tasks
class Quadrant {
  final QuadrantType type;
  final List<String> taskIds;

  const Quadrant({
    required this.type,
    this.taskIds = const [],
  });

  Quadrant copyWith({
    QuadrantType? type,
    List<String>? taskIds,
  }) {
    return Quadrant(
      type: type ?? this.type,
      taskIds: taskIds ?? this.taskIds,
    );
  }

  /// Check if the quadrant is empty
  bool get isEmpty => taskIds.isEmpty;

  /// Get task count
  int get taskCount => taskIds.length;
}
