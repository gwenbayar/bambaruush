// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'progress.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Progress _$ProgressFromJson(Map<String, dynamic> json) {
  return _Progress.fromJson(json);
}

/// @nodoc
mixin _$Progress {
  Map<String, LessonProgress> get lessons => throw _privateConstructorUsedError;
  Map<String, SrsBox> get srsByItem => throw _privateConstructorUsedError;
  Set<String> get earnedStickerIds => throw _privateConstructorUsedError;
  int get schemaVersion => throw _privateConstructorUsedError;
  DateTime get lastPlayed => throw _privateConstructorUsedError;
  double get volume => throw _privateConstructorUsedError;
  DateTime? get lastWarmupAt => throw _privateConstructorUsedError;
  int get warmupCount => throw _privateConstructorUsedError;

  /// Serializes this Progress to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Progress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProgressCopyWith<Progress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProgressCopyWith<$Res> {
  factory $ProgressCopyWith(Progress value, $Res Function(Progress) then) =
      _$ProgressCopyWithImpl<$Res, Progress>;
  @useResult
  $Res call(
      {Map<String, LessonProgress> lessons,
      Map<String, SrsBox> srsByItem,
      Set<String> earnedStickerIds,
      int schemaVersion,
      DateTime lastPlayed,
      double volume,
      DateTime? lastWarmupAt,
      int warmupCount});
}

/// @nodoc
class _$ProgressCopyWithImpl<$Res, $Val extends Progress>
    implements $ProgressCopyWith<$Res> {
  _$ProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Progress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lessons = null,
    Object? srsByItem = null,
    Object? earnedStickerIds = null,
    Object? schemaVersion = null,
    Object? lastPlayed = null,
    Object? volume = null,
    Object? lastWarmupAt = freezed,
    Object? warmupCount = null,
  }) {
    return _then(_value.copyWith(
      lessons: null == lessons
          ? _value.lessons
          : lessons // ignore: cast_nullable_to_non_nullable
              as Map<String, LessonProgress>,
      srsByItem: null == srsByItem
          ? _value.srsByItem
          : srsByItem // ignore: cast_nullable_to_non_nullable
              as Map<String, SrsBox>,
      earnedStickerIds: null == earnedStickerIds
          ? _value.earnedStickerIds
          : earnedStickerIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      schemaVersion: null == schemaVersion
          ? _value.schemaVersion
          : schemaVersion // ignore: cast_nullable_to_non_nullable
              as int,
      lastPlayed: null == lastPlayed
          ? _value.lastPlayed
          : lastPlayed // ignore: cast_nullable_to_non_nullable
              as DateTime,
      volume: null == volume
          ? _value.volume
          : volume // ignore: cast_nullable_to_non_nullable
              as double,
      lastWarmupAt: freezed == lastWarmupAt
          ? _value.lastWarmupAt
          : lastWarmupAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      warmupCount: null == warmupCount
          ? _value.warmupCount
          : warmupCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProgressImplCopyWith<$Res>
    implements $ProgressCopyWith<$Res> {
  factory _$$ProgressImplCopyWith(
          _$ProgressImpl value, $Res Function(_$ProgressImpl) then) =
      __$$ProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Map<String, LessonProgress> lessons,
      Map<String, SrsBox> srsByItem,
      Set<String> earnedStickerIds,
      int schemaVersion,
      DateTime lastPlayed,
      double volume,
      DateTime? lastWarmupAt,
      int warmupCount});
}

/// @nodoc
class __$$ProgressImplCopyWithImpl<$Res>
    extends _$ProgressCopyWithImpl<$Res, _$ProgressImpl>
    implements _$$ProgressImplCopyWith<$Res> {
  __$$ProgressImplCopyWithImpl(
      _$ProgressImpl _value, $Res Function(_$ProgressImpl) _then)
      : super(_value, _then);

  /// Create a copy of Progress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lessons = null,
    Object? srsByItem = null,
    Object? earnedStickerIds = null,
    Object? schemaVersion = null,
    Object? lastPlayed = null,
    Object? volume = null,
    Object? lastWarmupAt = freezed,
    Object? warmupCount = null,
  }) {
    return _then(_$ProgressImpl(
      lessons: null == lessons
          ? _value._lessons
          : lessons // ignore: cast_nullable_to_non_nullable
              as Map<String, LessonProgress>,
      srsByItem: null == srsByItem
          ? _value._srsByItem
          : srsByItem // ignore: cast_nullable_to_non_nullable
              as Map<String, SrsBox>,
      earnedStickerIds: null == earnedStickerIds
          ? _value._earnedStickerIds
          : earnedStickerIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      schemaVersion: null == schemaVersion
          ? _value.schemaVersion
          : schemaVersion // ignore: cast_nullable_to_non_nullable
              as int,
      lastPlayed: null == lastPlayed
          ? _value.lastPlayed
          : lastPlayed // ignore: cast_nullable_to_non_nullable
              as DateTime,
      volume: null == volume
          ? _value.volume
          : volume // ignore: cast_nullable_to_non_nullable
              as double,
      lastWarmupAt: freezed == lastWarmupAt
          ? _value.lastWarmupAt
          : lastWarmupAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      warmupCount: null == warmupCount
          ? _value.warmupCount
          : warmupCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProgressImpl implements _Progress {
  const _$ProgressImpl(
      {required final Map<String, LessonProgress> lessons,
      required final Map<String, SrsBox> srsByItem,
      required final Set<String> earnedStickerIds,
      required this.schemaVersion,
      required this.lastPlayed,
      this.volume = 1.0,
      this.lastWarmupAt,
      this.warmupCount = 0})
      : _lessons = lessons,
        _srsByItem = srsByItem,
        _earnedStickerIds = earnedStickerIds;

  factory _$ProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProgressImplFromJson(json);

  final Map<String, LessonProgress> _lessons;
  @override
  Map<String, LessonProgress> get lessons {
    if (_lessons is EqualUnmodifiableMapView) return _lessons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_lessons);
  }

  final Map<String, SrsBox> _srsByItem;
  @override
  Map<String, SrsBox> get srsByItem {
    if (_srsByItem is EqualUnmodifiableMapView) return _srsByItem;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_srsByItem);
  }

  final Set<String> _earnedStickerIds;
  @override
  Set<String> get earnedStickerIds {
    if (_earnedStickerIds is EqualUnmodifiableSetView) return _earnedStickerIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_earnedStickerIds);
  }

  @override
  final int schemaVersion;
  @override
  final DateTime lastPlayed;
  @override
  @JsonKey()
  final double volume;
  @override
  final DateTime? lastWarmupAt;
  @override
  @JsonKey()
  final int warmupCount;

  @override
  String toString() {
    return 'Progress(lessons: $lessons, srsByItem: $srsByItem, earnedStickerIds: $earnedStickerIds, schemaVersion: $schemaVersion, lastPlayed: $lastPlayed, volume: $volume, lastWarmupAt: $lastWarmupAt, warmupCount: $warmupCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProgressImpl &&
            const DeepCollectionEquality().equals(other._lessons, _lessons) &&
            const DeepCollectionEquality()
                .equals(other._srsByItem, _srsByItem) &&
            const DeepCollectionEquality()
                .equals(other._earnedStickerIds, _earnedStickerIds) &&
            (identical(other.schemaVersion, schemaVersion) ||
                other.schemaVersion == schemaVersion) &&
            (identical(other.lastPlayed, lastPlayed) ||
                other.lastPlayed == lastPlayed) &&
            (identical(other.volume, volume) || other.volume == volume) &&
            (identical(other.lastWarmupAt, lastWarmupAt) ||
                other.lastWarmupAt == lastWarmupAt) &&
            (identical(other.warmupCount, warmupCount) ||
                other.warmupCount == warmupCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_lessons),
      const DeepCollectionEquality().hash(_srsByItem),
      const DeepCollectionEquality().hash(_earnedStickerIds),
      schemaVersion,
      lastPlayed,
      volume,
      lastWarmupAt,
      warmupCount);

  /// Create a copy of Progress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProgressImplCopyWith<_$ProgressImpl> get copyWith =>
      __$$ProgressImplCopyWithImpl<_$ProgressImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProgressImplToJson(
      this,
    );
  }
}

abstract class _Progress implements Progress {
  const factory _Progress(
      {required final Map<String, LessonProgress> lessons,
      required final Map<String, SrsBox> srsByItem,
      required final Set<String> earnedStickerIds,
      required final int schemaVersion,
      required final DateTime lastPlayed,
      final double volume,
      final DateTime? lastWarmupAt,
      final int warmupCount}) = _$ProgressImpl;

  factory _Progress.fromJson(Map<String, dynamic> json) =
      _$ProgressImpl.fromJson;

  @override
  Map<String, LessonProgress> get lessons;
  @override
  Map<String, SrsBox> get srsByItem;
  @override
  Set<String> get earnedStickerIds;
  @override
  int get schemaVersion;
  @override
  DateTime get lastPlayed;
  @override
  double get volume;
  @override
  DateTime? get lastWarmupAt;
  @override
  int get warmupCount;

  /// Create a copy of Progress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProgressImplCopyWith<_$ProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
