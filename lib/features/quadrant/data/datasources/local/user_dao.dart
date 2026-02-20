import 'package:drift/drift.dart';
import 'package:logger/logger.dart';
import '../../../../../core/database/database.dart';
import '../../models/user_model.dart';

/// Data Access Object for Users
/// Handles all database operations related to users
class UserDao {
  final AppDatabase _db;
  final Logger _logger;

  UserDao(this._db, this._logger);

  /// Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final user = await (_db.select(_db.users)
            ..where((tbl) => tbl.id.equals(userId)))
          .getSingleOrNull();

      if (user == null) return null;
      return UserModel.fromDrift(user);
    } catch (e) {
      _logger.e('Error getting user $userId: $e');
      rethrow;
    }
  }

  /// Get user by email
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final user = await (_db.select(_db.users)
            ..where((tbl) => tbl.email.equals(email)))
          .getSingleOrNull();

      if (user == null) return null;
      return UserModel.fromDrift(user);
    } catch (e) {
      _logger.e('Error getting user by email $email: $e');
      rethrow;
    }
  }

  /// Create a new user
  Future<UserModel> createUser(UserModel user) async {
    try {
      final companion = user.toDriftCompanion();
      await _db.into(_db.users).insert(companion);
      _logger.i('Created user ${user.id}');
      return user;
    } catch (e) {
      _logger.e('Error creating user: $e');
      rethrow;
    }
  }

  /// Update an existing user
  Future<UserModel> updateUser(UserModel user) async {
    try {
      final companion = user.toDriftCompanion();
      await (_db.update(_db.users)
            ..where((tbl) => tbl.id.equals(user.id)))
          .write(companion);
      _logger.i('Updated user ${user.id}');
      return user;
    } catch (e) {
      _logger.e('Error updating user ${user.id}: $e');
      rethrow;
    }
  }

  /// Update user profile
  Future<UserModel> updateProfile(
    String userId, {
    String? displayName,
    String? avatarUrl,
  }) async {
    try {
      final current = await getUserById(userId);
      if (current == null) {
        throw Exception('User not found: $userId');
      }

      final updated = current.updateProfile(
        displayName: displayName,
        avatarUrl: avatarUrl,
      );

      return await updateUser(updated);
    } catch (e) {
      _logger.e('Error updating profile for user $userId: $e');
      rethrow;
    }
  }

  /// Update last active timestamp
  Future<void> updateLastActive(String userId) async {
    try {
      await (_db.update(_db.users)
            ..where((tbl) => tbl.id.equals(userId)))
          .write(UsersCompanion(
            lastActiveAt: Value(DateTime.now()),
          ));
    } catch (e) {
      _logger.e('Error updating last active for user $userId: $e');
      rethrow;
    }
  }

  /// Add experience points to user
  Future<UserModel> addExperience(String userId, int points) async {
    try {
      final user = await getUserById(userId);
      if (user == null) {
        throw Exception('User not found: $userId');
      }

      final updated = user.addExperience(points);
      return await updateUser(updated);
    } catch (e) {
      _logger.e('Error adding experience for user $userId: $e');
      rethrow;
    }
  }

  /// Increment user streak
  Future<UserModel> incrementStreak(String userId) async {
    try {
      final user = await getUserById(userId);
      if (user == null) {
        throw Exception('User not found: $userId');
      }

      final updated = user.incrementStreak();
      return await updateUser(updated);
    } catch (e) {
      _logger.e('Error incrementing streak for user $userId: $e');
      rethrow;
    }
  }

  /// Reset user streak
  Future<UserModel> resetStreak(String userId) async {
    try {
      final user = await getUserById(userId);
      if (user == null) {
        throw Exception('User not found: $userId');
      }

      final updated = user.resetStreak();
      return await updateUser(updated);
    } catch (e) {
      _logger.e('Error resetting streak for user $userId: $e');
      rethrow;
    }
  }

  /// Increment completed tasks count
  Future<UserModel> incrementCompletedTasks(String userId) async {
    try {
      final user = await getUserById(userId);
      if (user == null) {
        throw Exception('User not found: $userId');
      }

      final updated = user.incrementCompletedTasks();
      return await updateUser(updated);
    } catch (e) {
      _logger.e('Error incrementing completed tasks for user $userId: $e');
      rethrow;
    }
  }

  /// Get users needing sync
  Future<List<UserModel>> getUsersNeedingSync() async {
    try {
      final users = await (_db.select(_db.users)
            ..where((tbl) => tbl.syncStatus.isNotIn([SyncStatus.synced.name])))
          .get();

      return users.map((user) => UserModel.fromDrift(user)).toList();
    } catch (e) {
      _logger.e('Error getting users needing sync: $e');
      rethrow;
    }
  }

  /// Mark user as synced
  Future<void> markUserSynced(String userId) async {
    try {
      await (_db.update(_db.users)
            ..where((tbl) => tbl.id.equals(userId)))
          .write(UsersCompanion(
            syncStatus: const Value(SyncStatus.synced),
          ));
    } catch (e) {
      _logger.e('Error marking user $userId as synced: $e');
      rethrow;
    }
  }

  /// Delete a user
  Future<void> deleteUser(String userId) async {
    try {
      await (_db.delete(_db.users)
            ..where((tbl) => tbl.id.equals(userId)))
          .go();

      _logger.i('Deleted user $userId');
    } catch (e) {
      _logger.e('Error deleting user $userId: $e');
      rethrow;
    }
  }

  /// Get all users (admin use)
  Future<List<UserModel>> getAllUsers({int? limit, int? offset}) async {
    try {
      final query = _db.select(_db.users)
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);

      if (limit != null) {
        query.limit(limit, offset: offset);
      }

      final users = await query.get();
      return users.map((user) => UserModel.fromDrift(user)).toList();
    } catch (e) {
      _logger.e('Error getting all users: $e');
      rethrow;
    }
  }
}
