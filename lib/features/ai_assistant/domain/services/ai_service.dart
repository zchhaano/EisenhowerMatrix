import '../entities/task_suggestion.dart';

/// Abstract AI service for task-related AI operations
abstract class AIService {
  /// Generate intelligent suggestions for a task
  Future<TaskSuggestion> generateSuggestion(String taskTitle, String? description);

  /// Classify a task into an Eisenhower quadrant
  Future<EisenhowerQuadrant> classifyTask(String taskTitle, String? description);

  /// Suggest optimal scheduling for a task
  Future<DateTime?> suggestSchedule(String taskTitle, String? description);

  /// Generate task title suggestions based on user input
  Future<List<String>> suggestTitles(String partialInput);

  /// Analyze task complexity and estimate completion time
  Future<Duration?> estimateTime(String taskTitle, String? description);

  /// Check if AI service is available
  Future<bool> get isAvailable;
}

/// Eisenhower quadrants for task classification
enum EisenhowerQuadrant {
  q1,
  q2,
  q3,
  q4,
}

extension EisenhowerQuadrantExtension on EisenhowerQuadrant {
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

  String get description {
    switch (this) {
      case EisenhowerQuadrant.q1:
        return 'Urgent & Important';
      case EisenhowerQuadrant.q2:
        return 'Not Urgent & Important';
      case EisenhowerQuadrant.q3:
        return 'Urgent & Not Important';
      case EisenhowerQuadrant.q4:
        return 'Not Urgent & Not Important';
    }
  }
}
