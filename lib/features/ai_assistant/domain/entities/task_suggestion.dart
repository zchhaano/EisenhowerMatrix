import '../services/ai_service.dart';

/// Entity representing an AI-generated task suggestion
class TaskSuggestion {
  final String suggestedTitle;
  final EisenhowerQuadrant recommendedQuadrant;
  final String? reasoning;
  final DateTime? suggestedDateTime;
  final Duration? estimatedDuration;
  final double confidence;
  final List<String> alternativeTitles;
  final List<String> tags;

  const TaskSuggestion({
    required this.suggestedTitle,
    required this.recommendedQuadrant,
    this.reasoning,
    this.suggestedDateTime,
    this.estimatedDuration,
    this.confidence = 0.8,
    this.alternativeTitles = const [],
    this.tags = const [],
  });

  TaskSuggestion copyWith({
    String? suggestedTitle,
    EisenhowerQuadrant? recommendedQuadrant,
    String? reasoning,
    DateTime? suggestedDateTime,
    Duration? estimatedDuration,
    double? confidence,
    List<String>? alternativeTitles,
    List<String>? tags,
  }) {
    return TaskSuggestion(
      suggestedTitle: suggestedTitle ?? this.suggestedTitle,
      recommendedQuadrant: recommendedQuadrant ?? this.recommendedQuadrant,
      reasoning: reasoning ?? this.reasoning,
      suggestedDateTime: suggestedDateTime ?? this.suggestedDateTime,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      confidence: confidence ?? this.confidence,
      alternativeTitles: alternativeTitles ?? this.alternativeTitles,
      tags: tags ?? this.tags,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskSuggestion &&
          runtimeType == other.runtimeType &&
          suggestedTitle == other.suggestedTitle &&
          recommendedQuadrant == other.recommendedQuadrant;

  @override
  int get hashCode =>
      suggestedTitle.hashCode ^ recommendedQuadrant.hashCode;
}
