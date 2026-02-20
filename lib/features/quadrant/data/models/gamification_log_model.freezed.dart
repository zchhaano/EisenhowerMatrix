// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gamification_log_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$GamificationLogModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  GamificationLogType get type => throw _privateConstructorUsedError;
  int get points => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String? get taskId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  SyncStatus get syncStatus => throw _privateConstructorUsedError;

  /// Create a copy of GamificationLogModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GamificationLogModelCopyWith<GamificationLogModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GamificationLogModelCopyWith<$Res> {
  factory $GamificationLogModelCopyWith(GamificationLogModel value,
          $Res Function(GamificationLogModel) then) =
      _$GamificationLogModelCopyWithImpl<$Res, GamificationLogModel>;
  @useResult
  $Res call(
      {String id,
      String userId,
      GamificationLogType type,
      int points,
      String description,
      String? taskId,
      DateTime createdAt,
      SyncStatus syncStatus});
}

/// @nodoc
class _$GamificationLogModelCopyWithImpl<$Res,
        $Val extends GamificationLogModel>
    implements $GamificationLogModelCopyWith<$Res> {
  _$GamificationLogModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GamificationLogModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? type = null,
    Object? points = null,
    Object? description = null,
    Object? taskId = freezed,
    Object? createdAt = null,
    Object? syncStatus = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as GamificationLogType,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      taskId: freezed == taskId
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      syncStatus: null == syncStatus
          ? _value.syncStatus
          : syncStatus // ignore: cast_nullable_to_non_nullable
              as SyncStatus,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GamificationLogModelImplCopyWith<$Res>
    implements $GamificationLogModelCopyWith<$Res> {
  factory _$$GamificationLogModelImplCopyWith(_$GamificationLogModelImpl value,
          $Res Function(_$GamificationLogModelImpl) then) =
      __$$GamificationLogModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      GamificationLogType type,
      int points,
      String description,
      String? taskId,
      DateTime createdAt,
      SyncStatus syncStatus});
}

/// @nodoc
class __$$GamificationLogModelImplCopyWithImpl<$Res>
    extends _$GamificationLogModelCopyWithImpl<$Res, _$GamificationLogModelImpl>
    implements _$$GamificationLogModelImplCopyWith<$Res> {
  __$$GamificationLogModelImplCopyWithImpl(_$GamificationLogModelImpl _value,
      $Res Function(_$GamificationLogModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of GamificationLogModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? type = null,
    Object? points = null,
    Object? description = null,
    Object? taskId = freezed,
    Object? createdAt = null,
    Object? syncStatus = null,
  }) {
    return _then(_$GamificationLogModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as GamificationLogType,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      taskId: freezed == taskId
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      syncStatus: null == syncStatus
          ? _value.syncStatus
          : syncStatus // ignore: cast_nullable_to_non_nullable
              as SyncStatus,
    ));
  }
}

/// @nodoc

class _$GamificationLogModelImpl extends _GamificationLogModel {
  const _$GamificationLogModelImpl(
      {required this.id,
      required this.userId,
      required this.type,
      required this.points,
      required this.description,
      this.taskId,
      required this.createdAt,
      required this.syncStatus})
      : super._();

  @override
  final String id;
  @override
  final String userId;
  @override
  final GamificationLogType type;
  @override
  final int points;
  @override
  final String description;
  @override
  final String? taskId;
  @override
  final DateTime createdAt;
  @override
  final SyncStatus syncStatus;

  @override
  String toString() {
    return 'GamificationLogModel(id: $id, userId: $userId, type: $type, points: $points, description: $description, taskId: $taskId, createdAt: $createdAt, syncStatus: $syncStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GamificationLogModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.points, points) || other.points == points) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.taskId, taskId) || other.taskId == taskId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.syncStatus, syncStatus) ||
                other.syncStatus == syncStatus));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, userId, type, points,
      description, taskId, createdAt, syncStatus);

  /// Create a copy of GamificationLogModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GamificationLogModelImplCopyWith<_$GamificationLogModelImpl>
      get copyWith =>
          __$$GamificationLogModelImplCopyWithImpl<_$GamificationLogModelImpl>(
              this, _$identity);
}

abstract class _GamificationLogModel extends GamificationLogModel {
  const factory _GamificationLogModel(
      {required final String id,
      required final String userId,
      required final GamificationLogType type,
      required final int points,
      required final String description,
      final String? taskId,
      required final DateTime createdAt,
      required final SyncStatus syncStatus}) = _$GamificationLogModelImpl;
  const _GamificationLogModel._() : super._();

  @override
  String get id;
  @override
  String get userId;
  @override
  GamificationLogType get type;
  @override
  int get points;
  @override
  String get description;
  @override
  String? get taskId;
  @override
  DateTime get createdAt;
  @override
  SyncStatus get syncStatus;

  /// Create a copy of GamificationLogModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GamificationLogModelImplCopyWith<_$GamificationLogModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
