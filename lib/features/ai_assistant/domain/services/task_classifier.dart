import 'ai_service.dart';

/// Service for classifying tasks into Eisenhower quadrants
class TaskClassifier {
  /// Keywords that suggest urgency
  static const Map<String, double> _urgencyKeywords = {
    'urgent': 1.0,
    'asap': 0.9,
    'immediately': 0.95,
    'today': 0.8,
    'deadline': 0.85,
    'due': 0.75,
    'emergency': 1.0,
    'critical': 0.9,
    'now': 0.85,
    'priority': 0.7,
    'important': 0.5,
    'meeting': 0.7,
    'call': 0.6,
    'appointment': 0.7,
    'review': 0.5,
  };

  /// Keywords that suggest importance
  static const Map<String, double> _importanceKeywords = {
    'important': 1.0,
    'critical': 0.95,
    'strategic': 0.85,
    'goal': 0.7,
    'health': 0.9,
    'family': 0.85,
    'career': 0.8,
    'project': 0.6,
    'plan': 0.65,
    'learn': 0.6,
    'exercise': 0.8,
    'study': 0.75,
    'growth': 0.7,
    'deadline': 0.8,
    'client': 0.7,
    'contract': 0.75,
  };

  /// Keywords that suggest delegation
  static const Map<String, double> _delegateKeywords = {
    'delegate': 1.0,
    'assign': 0.8,
    'someone': 0.6,
    'team': 0.5,
    'assistant': 0.9,
    'help': 0.5,
    'outsource': 0.95,
  };

  /// Keywords that suggest deletion
  static const Map<String, double> _deleteKeywords = {
    'maybe': 0.6,
    'someday': 0.7,
    'consider': 0.5,
    'think about': 0.5,
    'social media': 0.8,
    'browse': 0.6,
    'watch': 0.4,
    'game': 0.7,
    'waste': 0.9,
  };

  /// Classify a task based on its title and description
  TaskClassification classify(String title, String? description) {
    final combinedText = '$title ${description ?? ''}'.toLowerCase();

    double urgencyScore = _calculateScore(combinedText, _urgencyKeywords);
    double importanceScore = _calculateScore(combinedText, _importanceKeywords);
    double delegateScore = _calculateScore(combinedText, _delegateKeywords);
    double deleteScore = _calculateScore(combinedText, _deleteKeywords);

    // Apply heuristic rules
    EisenhowerQuadrant quadrant;
    String? reasoning;

    if (deleteScore > 0.6) {
      quadrant = EisenhowerQuadrant.q4;
      reasoning = 'Task appears to be low priority or a time-waster';
    } else if (delegateScore > 0.7) {
      quadrant = EisenhowerQuadrant.q3;
      reasoning = 'Task can likely be delegated to others';
    } else if (urgencyScore > 0.6 && importanceScore > 0.5) {
      quadrant = EisenhowerQuadrant.q1;
      reasoning = 'Task is both urgent and important';
    } else if (importanceScore > 0.6) {
      quadrant = EisenhowerQuadrant.q2;
      reasoning = 'Task is important but not urgent';
    } else if (urgencyScore > 0.7) {
      quadrant = EisenhowerQuadrant.q3;
      reasoning = 'Task is urgent but may not be personally important';
    } else {
      // Default classification based on scores
      if (importanceScore >= urgencyScore) {
        quadrant = EisenhowerQuadrant.q2;
        reasoning = 'Task appears to be strategically important';
      } else {
        quadrant = EisenhowerQuadrant.q3;
        reasoning = 'Task requires attention but may be delegatable';
      }
    }

    // Check for deadlines to boost urgency
    if (_hasDeadline(combinedText) && quadrant == EisenhowerQuadrant.q2) {
      quadrant = EisenhowerQuadrant.q1;
      reasoning = 'Deadline makes this task urgent';
    }

    return TaskClassification(
      quadrant: quadrant,
      urgencyScore: urgencyScore,
      importanceScore: importanceScore,
      confidence: _calculateConfidence(urgencyScore, importanceScore, delegateScore, deleteScore),
      reasoning: reasoning,
    );
  }

  double _calculateScore(String text, Map<String, double> keywords) {
    double score = 0;
    for (final entry in keywords.entries) {
      if (text.contains(entry.key)) {
        score += entry.value;
      }
    }
    return score;
  }

  bool _hasDeadline(String text) {
    final deadlinePatterns = [
      RegExp(r'\b\d{1,2}[/-]\d{1,2}[/-]\d{2,4}\b'), // Date formats
      RegExp(r'\bmonday|tuesday|wednesday|thursday|friday|saturday|sunday\b'),
      RegExp(r'\btomorrow|tmrw\b'),
      RegExp(r'\bby\s+\w+\b'),
    ];

    return deadlinePatterns.any((pattern) => pattern.hasMatch(text));
  }

  double _calculateConfidence(double u, double i, double d, double del) {
    final maxScore = [u, i, d, del].reduce((a, b) => a > b ? a : b);
    if (maxScore > 0.8) return 0.9;
    if (maxScore > 0.6) return 0.75;
    if (maxScore > 0.4) return 0.6;
    return 0.4;
  }
}

/// Result of task classification
class TaskClassification {
  final EisenhowerQuadrant quadrant;
  final double urgencyScore;
  final double importanceScore;
  final double confidence;
  final String? reasoning;

  const TaskClassification({
    required this.quadrant,
    required this.urgencyScore,
    required this.importanceScore,
    required this.confidence,
    this.reasoning,
  });
}
