// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$UserModel {
  String get id => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  int get level => throw _privateConstructorUsedError;
  int get experiencePoints => throw _privateConstructorUsedError;
  int get pointsToNextLevel => throw _privateConstructorUsedError;
  int get streak => throw _privateConstructorUsedError;
  int get longestStreak => throw _privateConstructorUsedError;
  int get totalTasksCompleted => throw _privateConstructorUsedError;
  int get totalPointsEarned => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get lastActiveAt => throw _privateConstructorUsedError;
  SyncStatus get syncStatus => throw _privateConstructorUsedError;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserModelCopyWith<UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) then) =
      _$UserModelCopyWithImpl<$Res, UserModel>;
  @useResult
  $Res call(
      {String id,
      String displayName,
      String email,
      String? avatarUrl,
      int level,
      int experiencePoints,
      int pointsToNextLevel,
      int streak,
      int longestStreak,
      int totalTasksCompleted,
      int totalPointsEarned,
      DateTime createdAt,
      DateTime lastActiveAt,
      SyncStatus syncStatus});
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res, $Val extends UserModel>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? displayName = null,
    Object? email = null,
    Object? avatarUrl = freezed,
    Object? level = null,
    Object? experiencePoints = null,
    Object? pointsToNextLevel = null,
    Object? streak = null,
    Object? longestStreak = null,
    Object? totalTasksCompleted = null,
    Object? totalPointsEarned = null,
    Object? createdAt = null,
    Object? lastActiveAt = null,
    Object? syncStatus = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
      experiencePoints: null == experiencePoints
          ? _value.experiencePoints
          : experiencePoints // ignore: cast_nullable_to_non_nullable
              as int,
      pointsToNextLevel: null == pointsToNextLevel
          ? _value.pointsToNextLevel
          : pointsToNextLevel // ignore: cast_nullable_to_non_nullable
              as int,
      streak: null == streak
          ? _value.streak
          : streak // ignore: cast_nullable_to_non_nullable
              as int,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      totalTasksCompleted: null == totalTasksCompleted
          ? _value.totalTasksCompleted
          : totalTasksCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      totalPointsEarned: null == totalPointsEarned
          ? _value.totalPointsEarned
          : totalPointsEarned // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastActiveAt: null == lastActiveAt
          ? _value.lastActiveAt
          : lastActiveAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      syncStatus: null == syncStatus
          ? _value.syncStatus
          : syncStatus // ignore: cast_nullable_to_non_nullable
              as SyncStatus,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserModelImplCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$$UserModelImplCopyWith(
          _$UserModelImpl value, $Res Function(_$UserModelImpl) then) =
      __$$UserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String displayName,
      String email,
      String? avatarUrl,
      int level,
      int experiencePoints,
      int pointsToNextLevel,
      int streak,
      int longestStreak,
      int totalTasksCompleted,
      int totalPointsEarned,
      DateTime createdAt,
      DateTime lastActiveAt,
      SyncStatus syncStatus});
}

/// @nodoc
class __$$UserModelImplCopyWithImpl<$Res>
    extends _$UserModelCopyWithImpl<$Res, _$UserModelImpl>
    implements _$$UserModelImplCopyWith<$Res> {
  __$$UserModelImplCopyWithImpl(
      _$UserModelImpl _value, $Res Function(_$UserModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? displayName = null,
    Object? email = null,
    Object? avatarUrl = freezed,
    Object? level = null,
    Object? experiencePoints = null,
    Object? pointsToNextLevel = null,
    Object? streak = null,
    Object? longestStreak = null,
    Object? totalTasksCompleted = null,
    Object? totalPointsEarned = null,
    Object? createdAt = null,
    Object? lastActiveAt = null,
    Object? syncStatus = null,
  }) {
    return _then(_$UserModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
      experiencePoints: null == experiencePoints
          ? _value.experiencePoints
          : experiencePoints // ignore: cast_nullable_to_non_nullable
              as int,
      pointsToNextLevel: null == pointsToNextLevel
          ? _value.pointsToNextLevel
          : pointsToNextLevel // ignore: cast_nullable_to_non_nullable
              as int,
      streak: null == streak
          ? _value.streak
          : streak // ignore: cast_nullable_to_non_nullable
              as int,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      totalTasksCompleted: null == totalTasksCompleted
          ? _value.totalTasksCompleted
          : totalTasksCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      totalPointsEarned: null == totalPointsEarned
          ? _value.totalPointsEarned
          : totalPointsEarned // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastActiveAt: null == lastActiveAt
          ? _value.lastActiveAt
          : lastActiveAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      syncStatus: null == syncStatus
          ? _value.syncStatus
          : syncStatus // ignore: cast_nullable_to_non_nullable
              as SyncStatus,
    ));
  }
}

/// @nodoc

class _$UserModelImpl extends _UserModel {
  const _$UserModelImpl(
      {required this.id,
      required this.displayName,
      required this.email,
      this.avatarUrl,
      required this.level,
      required this.experiencePoints,
      required this.pointsToNextLevel,
      required this.streak,
      required this.longestStreak,
      required this.totalTasksCompleted,
      required this.totalPointsEarned,
      required this.createdAt,
      required this.lastActiveAt,
      required this.syncStatus})
      : super._();

  @override
  final String id;
  @override
  final String displayName;
  @override
  final String email;
  @override
  final String? avatarUrl;
  @override
  final int level;
  @override
  final int experiencePoints;
  @override
  final int pointsToNextLevel;
  @override
  final int streak;
  @override
  final int longestStreak;
  @override
  final int totalTasksCompleted;
  @override
  final int totalPointsEarned;
  @override
  final DateTime createdAt;
  @override
  final DateTime lastActiveAt;
  @override
  final SyncStatus syncStatus;

  @override
  String toString() {
    return 'UserModel(id: $id, displayName: $displayName, email: $email, avatarUrl: $avatarUrl, level: $level, experiencePoints: $experiencePoints, pointsToNextLevel: $pointsToNextLevel, streak: $streak, longestStreak: $longestStreak, totalTasksCompleted: $totalTasksCompleted, totalPointsEarned: $totalPointsEarned, createdAt: $createdAt, lastActiveAt: $lastActiveAt, syncStatus: $syncStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.experiencePoints, experiencePoints) ||
                other.experiencePoints == experiencePoints) &&
            (identical(other.pointsToNextLevel, pointsToNextLevel) ||
                other.pointsToNextLevel == pointsToNextLevel) &&
            (identical(other.streak, streak) || other.streak == streak) &&
            (identical(other.longestStreak, longestStreak) ||
                other.longestStreak == longestStreak) &&
            (identical(other.totalTasksCompleted, totalTasksCompleted) ||
                other.totalTasksCompleted == totalTasksCompleted) &&
            (identical(other.totalPointsEarned, totalPointsEarned) ||
                other.totalPointsEarned == totalPointsEarned) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.lastActiveAt, lastActiveAt) ||
                other.lastActiveAt == lastActiveAt) &&
            (identical(other.syncStatus, syncStatus) ||
                other.syncStatus == syncStatus));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      displayName,
      email,
      avatarUrl,
      level,
      experiencePoints,
      pointsToNextLevel,
      streak,
      longestStreak,
      totalTasksCompleted,
      totalPointsEarned,
      createdAt,
      lastActiveAt,
      syncStatus);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      __$$UserModelImplCopyWithImpl<_$UserModelImpl>(this, _$identity);
}

abstract class _UserModel extends UserModel {
  const factory _UserModel(
      {required final String id,
      required final String displayName,
      required final String email,
      final String? avatarUrl,
      required final int level,
      required final int experiencePoints,
      required final int pointsToNextLevel,
      required final int streak,
      required final int longestStreak,
      required final int totalTasksCompleted,
      required final int totalPointsEarned,
      required final DateTime createdAt,
      required final DateTime lastActiveAt,
      required final SyncStatus syncStatus}) = _$UserModelImpl;
  const _UserModel._() : super._();

  @override
  String get id;
  @override
  String get displayName;
  @override
  String get email;
  @override
  String? get avatarUrl;
  @override
  int get level;
  @override
  int get experiencePoints;
  @override
  int get pointsToNextLevel;
  @override
  int get streak;
  @override
  int get longestStreak;
  @override
  int get totalTasksCompleted;
  @override
  int get totalPointsEarned;
  @override
  DateTime get createdAt;
  @override
  DateTime get lastActiveAt;
  @override
  SyncStatus get syncStatus;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
