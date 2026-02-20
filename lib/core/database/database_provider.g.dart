// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$loggerHash() => r'579f9acf067a31494289131bec8228f197d68431';

/// See also [logger].
@ProviderFor(logger)
final loggerProvider = AutoDisposeProvider<Logger>.internal(
  logger,
  name: r'loggerProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$loggerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LoggerRef = AutoDisposeProviderRef<Logger>;
String _$databaseHash() => r'0d7d35e8e08da9bbc24d1c3ba795f4e5a43d0f2c';

/// See also [database].
@ProviderFor(database)
final databaseProvider = AutoDisposeProvider<AppDatabase>.internal(
  database,
  name: r'databaseProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$databaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DatabaseRef = AutoDisposeProviderRef<AppDatabase>;
String _$taskDaoHash() => r'812854ae38a9bcc392ae296f476d7960b2b44858';

/// See also [taskDao].
@ProviderFor(taskDao)
final taskDaoProvider = AutoDisposeProvider<TaskDao>.internal(
  taskDao,
  name: r'taskDaoProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$taskDaoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TaskDaoRef = AutoDisposeProviderRef<TaskDao>;
String _$userDaoHash() => r'ef11cb7d20353b8cb4c74d803b4daf91af9418d4';

/// See also [userDao].
@ProviderFor(userDao)
final userDaoProvider = AutoDisposeProvider<UserDao>.internal(
  userDao,
  name: r'userDaoProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$userDaoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserDaoRef = AutoDisposeProviderRef<UserDao>;
String _$tagDaoHash() => r'21ee59d197c91c7470073858f104a41f3a651aa7';

/// See also [tagDao].
@ProviderFor(tagDao)
final tagDaoProvider = AutoDisposeProvider<TagDao>.internal(
  tagDao,
  name: r'tagDaoProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$tagDaoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TagDaoRef = AutoDisposeProviderRef<TagDao>;
String _$gamificationLogDaoHash() =>
    r'6a48303c04fbf9c6298440f666ac382750d63532';

/// See also [gamificationLogDao].
@ProviderFor(gamificationLogDao)
final gamificationLogDaoProvider =
    AutoDisposeProvider<GamificationLogDao>.internal(
  gamificationLogDao,
  name: r'gamificationLogDaoProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$gamificationLogDaoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GamificationLogDaoRef = AutoDisposeProviderRef<GamificationLogDao>;
String _$syncQueueDaoHash() => r'6e151bde22235f13dfe3ff8c73dd917167684975';

/// See also [syncQueueDao].
@ProviderFor(syncQueueDao)
final syncQueueDaoProvider = AutoDisposeProvider<SyncQueueDao>.internal(
  syncQueueDao,
  name: r'syncQueueDaoProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$syncQueueDaoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SyncQueueDaoRef = AutoDisposeProviderRef<SyncQueueDao>;
String _$databaseInfoHash() => r'521eac72e7abbe33e51eeab4ff9ad5ab58de58dc';

/// See also [databaseInfo].
@ProviderFor(databaseInfo)
final databaseInfoProvider = AutoDisposeProvider<DatabaseInfo>.internal(
  databaseInfo,
  name: r'databaseInfoProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$databaseInfoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DatabaseInfoRef = AutoDisposeProviderRef<DatabaseInfo>;
String _$isDatabaseReadyHash() => r'972abda5b9de90881c212ac65bbbb883682e3e68';

/// See also [isDatabaseReady].
@ProviderFor(isDatabaseReady)
final isDatabaseReadyProvider = AutoDisposeProvider<bool>.internal(
  isDatabaseReady,
  name: r'isDatabaseReadyProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isDatabaseReadyHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsDatabaseReadyRef = AutoDisposeProviderRef<bool>;
String _$checkDatabaseConnectivityHash() =>
    r'ab465eaa49be87df5030cc61a8db7ecb1290bb54';

/// See also [checkDatabaseConnectivity].
@ProviderFor(checkDatabaseConnectivity)
final checkDatabaseConnectivityProvider =
    AutoDisposeFutureProvider<bool>.internal(
  checkDatabaseConnectivity,
  name: r'checkDatabaseConnectivityProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$checkDatabaseConnectivityHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CheckDatabaseConnectivityRef = AutoDisposeFutureProviderRef<bool>;
String _$getDatabaseStatsHash() => r'bfa0e2dcb3d5ad9268a87040ac1e6c825435260a';

/// See also [getDatabaseStats].
@ProviderFor(getDatabaseStats)
final getDatabaseStatsProvider =
    AutoDisposeFutureProvider<DatabaseStats>.internal(
  getDatabaseStats,
  name: r'getDatabaseStatsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getDatabaseStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetDatabaseStatsRef = AutoDisposeFutureProviderRef<DatabaseStats>;
String _$testDatabaseHash() => r'2ff0342476589adc47fdb4f8679fd0140fcc914b';

/// Provider for creating in-memory database for testing
///
/// Copied from [testDatabase].
@ProviderFor(testDatabase)
final testDatabaseProvider = AutoDisposeProvider<AppDatabase>.internal(
  testDatabase,
  name: r'testDatabaseProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$testDatabaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TestDatabaseRef = AutoDisposeProviderRef<AppDatabase>;
String _$databaseInitHash() => r'229fe270db92bd4282fdc4c102b5bed7dbaafe2c';

/// See also [DatabaseInit].
@ProviderFor(DatabaseInit)
final databaseInitProvider =
    AutoDisposeNotifierProvider<DatabaseInit, DatabaseInitState>.internal(
  DatabaseInit.new,
  name: r'databaseInitProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$databaseInitHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DatabaseInit = AutoDisposeNotifier<DatabaseInitState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
