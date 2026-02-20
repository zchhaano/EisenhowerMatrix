import 'package:flutter/foundation.dart';
import '../../../quadrant/domain/entities/task.dart' as quad;
import '../../../quadrant/domain/entities/quadrant.dart';
import '../../domain/services/nlp_parser.dart';

/// State for quick capture functionality
class QuickCaptureState {
  final bool isLoading;
  final String? error;
  final quad.Task? capturedTask;
  final bool isSuccess;

  const QuickCaptureState({
    this.isLoading = false,
    this.error,
    this.capturedTask,
    this.isSuccess = false,
  });

  QuickCaptureState copyWith({
    bool? isLoading,
    String? error,
    quad.Task? capturedTask,
    bool? isSuccess,
    bool clearError = false,
  }) {
    return QuickCaptureState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      capturedTask: capturedTask ?? this.capturedTask,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

/// Provider for quick capture functionality
///
/// Manages the state of creating tasks quickly from natural language input
class QuickCaptureProvider extends ChangeNotifier {
  QuickCaptureState _state = const QuickCaptureState();

  QuickCaptureState get state => _state;

  /// Parse input and create a task from natural language
  Future<quad.Task?> parseAndCreate(String input) async {
    if (input.trim().isEmpty) {
      _state = _state.copyWith(
        error: '输入不能为空',
      );
      notifyListeners();
      return null;
    }

    try {
      _state = _state.copyWith(isLoading: true, clearError: true);
      notifyListeners();

      // Parse the input
      final result = NLPParser.parse(input);

      // Create the task
      final task = quad.Task(
        id: _generateTaskId(),
        title: result.title,
        description: result.description,
        quadrant: result.suggestedQuadrant ?? QuadrantType.fourth,
        createdAt: DateTime.now(),
        dueDate: result.suggestedDueDate,
        priority: result.suggestedPriority,
        tags: result.detectedTags,
      );

      _state = _state.copyWith(
        isLoading: false,
        capturedTask: task,
        isSuccess: true,
      );
      notifyListeners();

      return task;
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      notifyListeners();
      return null;
    }
  }

  /// Create a task from a pre-parsed NLP result
  quad.Task createFromResult(NLPResult result) {
    return quad.Task(
      id: _generateTaskId(),
      title: result.title,
      description: result.description,
      quadrant: result.suggestedQuadrant ?? QuadrantType.fourth,
      createdAt: DateTime.now(),
      dueDate: result.suggestedDueDate,
      priority: result.suggestedPriority,
      tags: result.detectedTags,
    );
  }

  /// Reset the provider state
  void reset() {
    _state = const QuickCaptureState();
    notifyListeners();
  }

  /// Clear any error state
  void clearError() {
    if (_state.error != null) {
      _state = _state.copyWith(clearError: true);
      notifyListeners();
    }
  }

  /// Generate a unique task ID
  String _generateTaskId() {
    return 'task_${DateTime.now().millisecondsSinceEpoch}_${_state.hashCode}';
  }
}

/// Simple in-memory repository for captured tasks
class QuickCaptureRepository {
  final List<quad.Task> _capturedTasks = [];

  List<quad.Task> get capturedTasks => List.unmodifiable(_capturedTasks);

  void addTask(quad.Task task) {
    _capturedTasks.add(task);
  }

  void removeTask(String taskId) {
    _capturedTasks.removeWhere((t) => t.id == taskId);
  }

  void clear() {
    _capturedTasks.clear();
  }

  int get length => _capturedTasks.length;

  bool get isEmpty => _capturedTasks.isEmpty;
}
