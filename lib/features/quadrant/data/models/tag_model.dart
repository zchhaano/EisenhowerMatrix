import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:drift/drift.dart' hide JsonKey;
import '../../../../core/database/database.dart';

part 'tag_model.freezed.dart';

/// Tag entity model for categorizing tasks
@freezed
class TagModel with _$TagModel {
  const factory TagModel({
    required String id,
    required String name,
    required String color,
    required String userId,
    required DateTime createdAt,
    required SyncStatus syncStatus,
    int? taskCount,
  }) = _TagModel;

  const TagModel._();

  /// Create from Drift Tag
  factory TagModel.fromDrift(Tag tag, [int? taskCount]) {
    return TagModel(
      id: tag.id,
      name: tag.name,
      color: tag.color,
      userId: tag.userId,
      createdAt: tag.createdAt,
      syncStatus: tag.syncStatus,
      taskCount: taskCount ?? 0,
    );
  }

  /// Convert to Drift TagsCompanion
  TagsCompanion toDriftCompanion() {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
      color: Value(color),
      userId: Value(userId),
      createdAt: Value(createdAt),
      syncStatus: Value(syncStatus),
    );
  }

  /// Check if needs sync
  bool get needsSync => syncStatus != SyncStatus.synced;

  /// Get hex color with hash
  String get colorWithHash => color.startsWith('#') ? color : '#$color';

  /// Check if color is light (for text contrast)
  bool get isLightColor {
    final hex = color.replaceAll('#', '');
    if (hex.length != 6) return false;

    final r = int.parse(hex.substring(0, 2), radix: 16);
    final g = int.parse(hex.substring(2, 4), radix: 16);
    final b = int.parse(hex.substring(4, 6), radix: 16);

    // Calculate luminance
    final luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255;
    return luminance > 0.5;
  }

  /// Validate tag name
  static bool isValidName(String name) {
    return name.trim().length >= 1 && name.trim().length <= 50;
  }

  /// Validate color hex
  static bool isValidColor(String color) {
    final hex = color.replaceAll('#', '');
    return hex.length == 6 && RegExp(r'^[0-9a-fA-F]+$').hasMatch(hex);
  }

  /// Common predefined colors
  static const List<String> predefinedColors = [
    '#e74c3c', // Red
    '#e67e22', // Orange
    '#f1c40f', // Yellow
    '#2ecc71', // Green
    '#1abc9c', // Teal
    '#3498db', // Blue
    '#9b59b6', // Purple
    '#e91e63', // Pink
    '#607d8b', // Blue Grey
    '#795548', // Brown
  ];

  /// Get color name from hex (for display)
  String get colorName {
    final normalized = color.toLowerCase();
    final colorMap = {
      '#e74c3c': 'Red',
      '#e67e22': 'Orange',
      '#f1c40f': 'Yellow',
      '#2ecc71': 'Green',
      '#1abc9c': 'Teal',
      '#3498db': 'Blue',
      '#9b59b6': 'Purple',
      '#e91e63': 'Pink',
      '#607d8b': 'Blue Grey',
      '#795548': 'Brown',
    };
    return colorMap[normalized] ?? 'Custom';
  }

  /// Mark for sync
  TagModel markForSync() {
    return copyWith(syncStatus: SyncStatus.pending);
  }

  /// Mark as synced
  TagModel markAsSynced() {
    return copyWith(syncStatus: SyncStatus.synced);
  }

  /// Update color
  TagModel updateColor(String newColor) {
    return copyWith(
      color: newColor,
      syncStatus: SyncStatus.pending,
    );
  }

  /// Update name
  TagModel updateName(String newName) {
    return copyWith(
      name: newName,
      syncStatus: SyncStatus.pending,
    );
  }

  /// Increment task count (for in-memory tracking)
  TagModel incrementTaskCount() {
    return copyWith(taskCount: (taskCount ?? 0) + 1);
  }

  /// Decrement task count (for in-memory tracking)
  TagModel decrementTaskCount() {
    return copyWith(taskCount: ((taskCount ?? 1) - 1).clamp(0, 999999));
  }
}

/// Tag filter for queries
class TagFilter {
  final String? userId;
  final String? searchTerm;
  final List<String>? tagIds;
  final String? color;

  const TagFilter({
    this.userId,
    this.searchTerm,
    this.tagIds,
    this.color,
  });

  /// Check if filter has any active constraints
  bool get hasFilters =>
      userId != null ||
      searchTerm != null ||
      (tagIds != null && tagIds!.isNotEmpty) ||
      color != null;

  /// Empty filter
  static const empty = TagFilter();
}

/// Tag with tasks count result
class TagWithCount {
  final TagModel tag;
  final int taskCount;

  const TagWithCount({
    required this.tag,
    required this.taskCount,
  });
}
