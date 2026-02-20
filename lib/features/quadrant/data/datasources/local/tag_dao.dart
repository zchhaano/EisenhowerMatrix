import 'package:drift/drift.dart';
import 'package:logger/logger.dart';
import '../../../../../core/database/database.dart';
import '../../models/tag_model.dart';

/// Data Access Object for Tags
/// Handles all database operations related to tags
class TagDao {
  final AppDatabase _db;
  final Logger _logger;

  TagDao(this._db, this._logger);

  /// Get all tags for a user
  Future<List<TagModel>> getTagsForUser(String userId) async {
    try {
      final tags = await (_db.select(_db.tags)
            ..where((tbl) => tbl.userId.equals(userId))
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
          .get();

      return tags.map((tag) => TagModel.fromDrift(tag)).toList();
    } catch (e) {
      _logger.e('Error getting tags for user $userId: $e');
      rethrow;
    }
  }

  /// Get tags with task counts
  Future<List<TagWithCount>> getTagsWithCount(String userId) async {
    try {
      final query = _db.select(_db.tags)
        ..where((tbl) => tbl.userId.equals(userId))
        ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]);

      final tags = await query.get();

      final result = <TagWithCount>[];
      for (final tag in tags) {
        final count = await (_db.select(_db.taskTags)
              ..where((tbl) => tbl.tagId.equals(tag.id)))
            .get()
            .then((list) => list.length);

        result.add(TagWithCount(
          tag: TagModel.fromDrift(tag, count),
          taskCount: count,
        ));
      }

      return result;
    } catch (e) {
      _logger.e('Error getting tags with count: $e');
      rethrow;
    }
  }

  /// Get tag by ID
  Future<TagModel?> getTagById(String tagId) async {
    try {
      final tag = await (_db.select(_db.tags)
            ..where((tbl) => tbl.id.equals(tagId)))
          .getSingleOrNull();

      if (tag == null) return null;
      return TagModel.fromDrift(tag);
    } catch (e) {
      _logger.e('Error getting tag $tagId: $e');
      rethrow;
    }
  }

  /// Get tags for a task
  Future<List<TagModel>> getTagsForTask(String taskId) async {
    try {
      final query = _db.select(_db.tags).join([
        innerJoin(
          _db.taskTags,
          _db.taskTags.tagId.equalsExp(_db.tags.id),
        ),
      ])
        ..where(_db.taskTags.taskId.equals(taskId));

      final results = await query.get();
      return results.map((row) {
        final tag = row.readTable(_db.tags);
        return TagModel.fromDrift(tag);
      }).toList();
    } catch (e) {
      _logger.e('Error getting tags for task $taskId: $e');
      return [];
    }
  }

  /// Get tag by name for a user
  Future<TagModel?> getTagByName(String userId, String name) async {
    try {
      final tag = await (_db.select(_db.tags)
            ..where((tbl) => tbl.userId.equals(userId))
            ..where((tbl) => tbl.name.equals(name)))
          .getSingleOrNull();

      if (tag == null) return null;
      return TagModel.fromDrift(tag);
    } catch (e) {
      _logger.e('Error getting tag by name $name: $e');
      rethrow;
    }
  }

  /// Create a new tag
  Future<TagModel> createTag(TagModel tag) async {
    try {
      final companion = tag.toDriftCompanion();
      await _db.into(_db.tags).insert(companion);
      _logger.i('Created tag ${tag.id}');
      return tag;
    } catch (e) {
      _logger.e('Error creating tag: $e');
      rethrow;
    }
  }

  /// Update an existing tag
  Future<TagModel> updateTag(TagModel tag) async {
    try {
      final companion = tag.toDriftCompanion();
      await (_db.update(_db.tags)
            ..where((tbl) => tbl.id.equals(tag.id)))
          .write(companion);
      _logger.i('Updated tag ${tag.id}');
      return tag;
    } catch (e) {
      _logger.e('Error updating tag ${tag.id}: $e');
      rethrow;
    }
  }

  /// Update tag color
  Future<TagModel> updateTagColor(String tagId, String color) async {
    try {
      final tag = await getTagById(tagId);
      if (tag == null) {
        throw Exception('Tag not found: $tagId');
      }
      final updated = tag.updateColor(color);
      return await updateTag(updated);
    } catch (e) {
      _logger.e('Error updating color for tag $tagId: $e');
      rethrow;
    }
  }

  /// Update tag name
  Future<TagModel> updateTagName(String tagId, String name) async {
    try {
      final tag = await getTagById(tagId);
      if (tag == null) {
        throw Exception('Tag not found: $tagId');
      }
      final updated = tag.updateName(name);
      return await updateTag(updated);
    } catch (e) {
      _logger.e('Error updating name for tag $tagId: $e');
      rethrow;
    }
  }

  /// Delete a tag
  Future<void> deleteTag(String tagId) async {
    try {
      await (_db.delete(_db.taskTags)
            ..where((tbl) => tbl.tagId.equals(tagId)))
          .go();

      await (_db.delete(_db.tags)
            ..where((tbl) => tbl.id.equals(tagId)))
          .go();

      _logger.i('Deleted tag $tagId');
    } catch (e) {
      _logger.e('Error deleting tag $tagId: $e');
      rethrow;
    }
  }

  /// Add tag to task
  Future<void> addTagToTask(String taskId, String tagId) async {
    try {
      await _db.into(_db.taskTags).insert(
        TaskTagsCompanion(
          taskId: Value(taskId),
          tagId: Value(tagId),
        ),
        mode: InsertMode.insertOrIgnore,
      );
    } catch (e) {
      _logger.e('Error adding tag $tagId to task $taskId: $e');
      rethrow;
    }
  }

  /// Remove tag from task
  Future<void> removeTagFromTask(String taskId, String tagId) async {
    try {
      await (_db.delete(_db.taskTags)
            ..where((tbl) =>
              tbl.taskId.equals(taskId) &
              tbl.tagId.equals(tagId)
            ))
          .go();
    } catch (e) {
      _logger.e('Error removing tag $tagId from task $taskId: $e');
      rethrow;
    }
  }

  /// Set tags for a task (replace all existing)
  Future<void> setTagsForTask(String taskId, List<String> tagIds) async {
    try {
      await (_db.delete(_db.taskTags)
            ..where((tbl) => tbl.taskId.equals(taskId)))
          .go();

      for (final tagId in tagIds) {
        await addTagToTask(taskId, tagId);
      }
    } catch (e) {
      _logger.e('Error setting tags for task $taskId: $e');
      rethrow;
    }
  }

  /// Get tags needing sync
  Future<List<TagModel>> getTagsNeedingSync(String userId) async {
    try {
      final tags = await (_db.select(_db.tags)
            ..where((tbl) => tbl.userId.equals(userId))
            ..where((tbl) => tbl.syncStatus.isNotIn([SyncStatus.synced.name])))
          .get();

      return tags.map((tag) => TagModel.fromDrift(tag)).toList();
    } catch (e) {
      _logger.e('Error getting tags needing sync: $e');
      rethrow;
    }
  }

  /// Mark tag as synced
  Future<void> markTagSynced(String tagId) async {
    try {
      await (_db.update(_db.tags)
            ..where((tbl) => tbl.id.equals(tagId)))
          .write(TagsCompanion(
            syncStatus: const Value(SyncStatus.synced),
          ));
    } catch (e) {
      _logger.e('Error marking tag $tagId as synced: $e');
      rethrow;
    }
  }

  /// Search tags by name
  Future<List<TagModel>> searchTags(
    String userId,
    String query, {
    int limit = 20,
  }) async {
    try {
      final searchTerm = '%$query%';

      final tags = await (_db.select(_db.tags)
            ..where((tbl) => tbl.userId.equals(userId))
            ..where((tbl) => tbl.name.like(searchTerm))
            ..limit(limit)
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
          .get();

      return tags.map((tag) => TagModel.fromDrift(tag)).toList();
    } catch (e) {
      _logger.e('Error searching tags: $e');
      rethrow;
    }
  }

  /// Get tag count for user
  Future<int> getTagCount(String userId) async {
    try {
      return await (_db.select(_db.tags)
            ..where((tbl) => tbl.userId.equals(userId)))
          .get()
          .then((list) => list.length);
    } catch (e) {
      _logger.e('Error getting tag count: $e');
      rethrow;
    }
  }

  /// Get most used tags for user
  Future<List<TagWithCount>> getMostUsedTags(
    String userId, {
    int limit = 10,
  }) async {
    try {
      final allTagsWithCount = await getTagsWithCount(userId);
      allTagsWithCount.sort((a, b) => b.taskCount.compareTo(a.taskCount));
      return allTagsWithCount.take(limit).toList();
    } catch (e) {
      _logger.e('Error getting most used tags: $e');
      rethrow;
    }
  }
}
