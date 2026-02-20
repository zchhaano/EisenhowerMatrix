import 'package:flutter/foundation.dart';
import '../../domain/entities/inbox_task.dart';
import '../../../quadrant/domain/entities/quadrant.dart';
import 'dart:collection';

/// State for inbox management
class InboxState {
  final List<InboxTask> tasks;
  final InboxFilter filter;
  final InboxSort sort;
  final bool isLoading;
  final String? error;
  final int currentIndex;

  const InboxState({
    this.tasks = const [],
    this.filter = InboxFilter.unprocessed,
    this.sort = InboxSort.createdAt,
    this.isLoading = false,
    this.error,
    this.currentIndex = 0,
  });

  /// Get filtered tasks
  List<InboxTask> get filteredTasks {
    var result = tasks.toList();

    switch (filter) {
      case InboxFilter.unprocessed:
        result = result.where((t) => !t.isProcessed).toList();
        break;
      case InboxFilter.processed:
        result = result.where((t) => t.isProcessed).toList();
        break;
      case InboxFilter.urgent:
        result = result.where((t) => t.tags.contains('urgent')).toList();
        break;
      case InboxFilter.important:
        result = result.where((t) => t.tags.contains('important')).toList();
        break;
      case InboxFilter.all:
        break;
    }

    // Apply sorting
    switch (sort) {
      case InboxSort.createdAt:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case InboxSort.priority:
        result.sort((a, b) => b.priority.compareTo(a.priority));
        break;
      case InboxSort.dueDate:
        result.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;
      case InboxSort.suggestedQuadrant:
        result.sort((a, b) {
          if (a.suggestedQuadrant == null && b.suggestedQuadrant == null) return 0;
          if (a.suggestedQuadrant == null) return 1;
          if (b.suggestedQuadrant == null) return -1;
          return a.suggestedQuadrant!.index.compareTo(b.suggestedQuadrant!.index);
        });
        break;
    }

    return result;
  }

  /// Get unprocessed tasks for review
  List<InboxTask> get unprocessedTasks {
    return filteredTasks.where((t) => !t.isProcessed).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get count of unprocessed tasks
  int get unprocessedCount {
    return tasks.where((t) => !t.isProcessed).length;
  }

  /// Get count of processed tasks
  int get processedCount {
    return tasks.where((t) => t.isProcessed).length;
  }

  InboxState copyWith({
    List<InboxTask>? tasks,
    InboxFilter? filter,
    InboxSort? sort,
    bool? isLoading,
    String? error,
    int? currentIndex,
    bool clearError = false,
  }) {
    return InboxState(
      tasks: tasks ?? this.tasks,
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

/// Provider for inbox task management
///
/// Manages state for inbox review flow
class InboxProvider extends ChangeNotifier {
  InboxState _state = const InboxState();
  final List<InboxTask> _allTasks = [];

  InboxState get state => _state;

  List<InboxTask> get unprocessedTasks => _state.unprocessedTasks;
  int get unprocessedCount => _state.unprocessedCount;
  int get processedCount => _state.processedCount;

  /// Get the current task to review
  InboxTask? get currentTask {
    final tasks = unprocessedTasks;
    if (tasks.isEmpty) return null;
    final index = _state.currentIndex.clamp(0, tasks.length - 1);
    return tasks[index];
  }

  /// Add a new task to the inbox
  void addTask(InboxTask task) {
    _allTasks.add(task);
    _state = _state.copyWith(tasks: List.unmodifiable(_allTasks));
    notifyListeners();
  }

  /// Add multiple tasks
  void addTasks(List<InboxTask> tasks) {
    _allTasks.addAll(tasks);
    _state = _state.copyWith(tasks: List.unmodifiable(_allTasks));
    notifyListeners();
  }

  /// Update an existing task
  void updateTask(InboxTask updatedTask) {
    final index = _allTasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      _allTasks[index] = updatedTask;
      _state = _state.copyWith(tasks: List.unmodifiable(_allTasks));
      notifyListeners();
    }
  }

  /// Delete a task from the inbox
  void deleteTask(String taskId) {
    _allTasks.removeWhere((t) => t.id == taskId);
    _state = _state.copyWith(tasks: List.unmodifiable(_allTasks));
    notifyListeners();
  }

  /// Mark current task as processed (skip it)
  void skipCurrentTask() {
    final current = currentTask;
    if (current == null) return;

    // Move to next without processing - just mark as viewed
    _state = _state.copyWith(currentIndex: _state.currentIndex + 1);
    notifyListeners();
  }

  /// Set filter for tasks
  void setFilter(InboxFilter filter) {
    _state = _state.copyWith(filter: filter, currentIndex: 0);
    notifyListeners();
  }

  /// Set sort order for tasks
  void setSort(InboxSort sort) {
    _state = _state.copyWith(sort: sort);
    notifyListeners();
  }

  /// Process a task by assigning to a quadrant
  void processTask(String taskId, QuadrantType quadrant) {
    final task = _allTasks.firstWhere(
      (t) => t.id == taskId,
      orElse: () => throw ArgumentError('Task not found'),
    );
    updateTask(task.markProcessed(quadrant));
  }

  /// Reset all processed tasks to unprocessed
  void resetProcessed() {
    for (var i = 0; i < _allTasks.length; i++) {
      if (_allTasks[i].isProcessed) {
        _allTasks[i] = _allTasks[i].resetProcessed();
      }
    }
    _state = _state.copyWith(
      tasks: List.unmodifiable(_allTasks),
      currentIndex: 0,
    );
    notifyListeners();
  }

  /// Clear all tasks
  void clearAll() {
    _allTasks.clear();
    _state = const InboxState();
    notifyListeners();
  }

  /// Clear only processed tasks
  void clearProcessed() {
    _allTasks.removeWhere((t) => t.isProcessed);
    _state = _state.copyWith(
      tasks: List.unmodifiable(_allTasks),
      currentIndex: 0,
    );
    notifyListeners();
  }

  /// Load sample data for testing
  void loadSampleData() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    addTasks([
      InboxTask(
        id: 'inbox_1',
        title: '完成项目报告',
        description: '整理本周的项目进展报告，包括数据分析和下周计划',
        createdAt: today.subtract(const Duration(hours: 2)),
        dueDate: today.add(const Duration(days: 1)),
        tags: ['urgent', 'important'],
        priority: 3,
        suggestedQuadrant: QuadrantType.first,
      ),
      InboxTask(
        id: 'inbox_2',
        title: '学习新技术',
        description: '学习 Flutter 3.0 的新特性',
        createdAt: today.subtract(const Duration(hours: 5)),
        dueDate: today.add(const Duration(days: 7)),
        tags: ['important'],
        priority: 2,
        suggestedQuadrant: QuadrantType.second,
      ),
      InboxTask(
        id: 'inbox_3',
        title: '回复客户邮件',
        description: '处理待回复的客户咨询邮件',
        createdAt: today.subtract(const Duration(hours: 8)),
        dueDate: today,
        tags: ['urgent'],
        priority: 2,
        suggestedQuadrant: QuadrantType.third,
      ),
      InboxTask(
        id: 'inbox_4',
        title: '浏览社交媒体',
        description: '休息时刷刷朋友圈',
        createdAt: today.subtract(const Duration(days: 1)),
        tags: [],
        priority: 0,
        suggestedQuadrant: QuadrantType.fourth,
      ),
      InboxTask(
        id: 'inbox_5',
        title: '准备会议材料',
        description: '为周五的团队例会准备PPT',
        createdAt: today.subtract(const Duration(minutes: 30)),
        dueDate: today.add(const Duration(days: 2)),
        tags: ['important'],
        priority: 2,
        suggestedQuadrant: QuadrantType.second,
      ),
    ]);
  }

  /// Import from NLP result
  InboxTask fromNLP({
    required String title,
    String? description,
    DateTime? dueDate,
    List<String> tags = const [],
    int priority = 0,
    QuadrantType? suggestedQuadrant,
  }) {
    final task = InboxTask(
      id: 'inbox_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      createdAt: DateTime.now(),
      dueDate: dueDate,
      tags: tags,
      priority: priority,
      suggestedQuadrant: suggestedQuadrant,
    );
    addTask(task);
    return task;
  }

  /// Get statistics
  Map<String, int> get statistics {
    return {
      'total': _allTasks.length,
      'unprocessed': unprocessedCount,
      'processed': processedCount,
      'urgent': _allTasks.where((t) => t.tags.contains('urgent')).length,
      'important': _allTasks.where((t) => t.tags.contains('important')).length,
    };
  }

  @override
  void dispose() {
    _allTasks.clear();
    super.dispose();
  }
}
