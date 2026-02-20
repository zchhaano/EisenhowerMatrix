import '../../domain/entities/task_suggestion.dart';
import '../../domain/services/ai_service.dart';
import '../../domain/services/task_classifier.dart';

/// Implementation of AI service with local classification
class AIRepositoryImpl implements AIService {
  final TaskClassifier _classifier = TaskClassifier();

  @override
  Future<bool> get isAvailable async => true;

  @override
  Future<EisenhowerQuadrant> classifyTask(String taskTitle, String? description) async {
    final classification = _classifier.classify(taskTitle, description);
    return classification.quadrant;
  }

  @override
  Future<TaskSuggestion> generateSuggestion(String taskTitle, String? description) async {
    final classification = _classifier.classify(taskTitle, description);

    // Generate alternative titles based on the original
    final alternatives = _generateAlternativeTitles(taskTitle);

    // Estimate duration based on task complexity
    final duration = _estimateDuration(taskTitle, description);

    return TaskSuggestion(
      suggestedTitle: taskTitle,
      recommendedQuadrant: classification.quadrant,
      reasoning: classification.reasoning,
      estimatedDuration: duration,
      confidence: classification.confidence,
      alternativeTitles: alternatives,
      tags: _generateTags(taskTitle, description),
    );
  }

  @override
  Future<DateTime?> suggestSchedule(String taskTitle, String? description) async {
    final classification = _classifier.classify(taskTitle, description);

    switch (classification.quadrant) {
      case EisenhowerQuadrant.q1:
        // Schedule for today if it's morning, otherwise tomorrow
        final now = DateTime.now();
        if (now.hour < 12) {
          return DateTime(now.year, now.month, now.day, 14, 0); // 2 PM today
        }
        return DateTime(now.year, now.month, now.day + 1, 9, 0); // 9 AM tomorrow

      case EisenhowerQuadrant.q2:
        // Schedule for later this week
        final now = DateTime.now();
        final daysUntilNextBusinessDay = _daysUntilNextBusinessDay(now);
        return DateTime(now.year, now.month, now.day + daysUntilNextBusinessDay, 10, 0);

      case EisenhowerQuadrant.q3:
        // Schedule for delegation review
        final now = DateTime.now();
        return DateTime(now.year, now.month, now.day, 16, 0); // 4 PM for delegation

      case EisenhowerQuadrant.q4:
        // No scheduling - consider deletion
        return null;
    }
  }

  @override
  Future<List<String>> suggestTitles(String partialInput) async {
    final suggestions = <String>[];

    if (partialInput.isEmpty) {
      return suggestions;
    }

    // Generate suggestions based on common task patterns
    final lowerInput = partialInput.toLowerCase();

    if (lowerInput.contains('meet')) {
      suggestions.addAll([
        'Meeting with ${_capitalize(partialInput.replaceAll('meet', '').replaceAll('meeting', '').trim())}',
        'Prepare for ${_capitalize(partialInput)}',
        'Follow up on ${_capitalize(partialInput)}',
      ]);
    }

    if (lowerInput.contains('call')) {
      suggestions.addAll([
        'Call ${_capitalize(partialInput.replaceAll('call', '').trim())}',
        'Schedule call with ${_capitalize(partialInput.replaceAll('call', '').trim())}',
        'Prepare agenda for ${_capitalize(partialInput)}',
      ]);
    }

    if (lowerInput.contains('report') || lowerInput.contains('document')) {
      suggestions.addAll([
        'Complete ${_capitalize(partialInput)}',
        'Review ${_capitalize(partialInput)}',
        'Submit ${_capitalize(partialInput)}',
      ]);
    }

    if (lowerInput.contains('learn') || lowerInput.contains('study')) {
      suggestions.addAll([
        '${_capitalize(partialInput)} - 30 min session',
        '${_capitalize(partialInput)} - Create study plan',
        'Practice ${_capitalize(partialInput.replaceAll('learn', '').replaceAll('study', '').trim())}',
      ]);
    }

    return suggestions;
  }

  @override
  Future<Duration?> estimateTime(String taskTitle, String? description) async {
    return _estimateDuration(taskTitle, description);
  }

  Duration? _estimateDuration(String title, String? description) {
    final combined = '$title ${description ?? ''}'.toLowerCase();

    // Quick tasks (5-15 minutes)
    if (combined.contains(RegExp(r'\b(call|email|message|quick|brief)\b'))) {
      return const Duration(minutes: 15);
    }

    // Medium tasks (30-60 minutes)
    if (combined.contains(RegExp(r'\b(meet|review|discuss|report)\b'))) {
      return const Duration(minutes: 45);
    }

    // Long tasks (2+ hours)
    if (combined.contains(RegExp(r'\b(project|create|build|develop|write|plan)\b'))) {
      return const Duration(hours: 2);
    }

    // Learning tasks
    if (combined.contains(RegExp(r'\b(learn|study|read|course)\b'))) {
      return const Duration(minutes: 60);
    }

    // Default
    return const Duration(minutes: 30);
  }

  List<String> _generateAlternativeTitles(String title) {
    final alternatives = <String>[];
    final lower = title.toLowerCase();

    if (lower.startsWith('review ')) {
      alternatives.add('Audit ${title.substring(7)}');
      alternatives.add('Check ${title.substring(7)}');
    } else if (lower.startsWith('call ')) {
      alternatives.add('Phone ${title.substring(5)}');
      alternatives.add('Reach out to ${title.substring(5)}');
    } else if (lower.startsWith('meeting ')) {
      alternatives.add('Meet with ${title.substring(8)}');
      alternatives.add('Discuss ${title.substring(8)}');
    }

    return alternatives;
  }

  List<String> _generateTags(String title, String? description) {
    final tags = <String>[];
    final combined = '$title ${description ?? ''}'.toLowerCase();

    if (combined.contains('work') || combined.contains('project')) {
      tags.add('Work');
    }
    if (combined.contains('personal')) {
      tags.add('Personal');
    }
    if (combined.contains('health') || combined.contains('exercise')) {
      tags.add('Health');
    }
    if (combined.contains('call') || combined.contains('email')) {
      tags.add('Communication');
    }
    if (combined.contains('learn') || combined.contains('study')) {
      tags.add('Learning');
    }

    return tags;
  }

  int _daysUntilNextBusinessDay(DateTime date) {
    final nextDay = date.add(const Duration(days: 1));
    switch (nextDay.weekday) {
      case 6: // Saturday
        return 2;
      case 7: // Sunday
        return 1;
      default:
        return 1;
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
