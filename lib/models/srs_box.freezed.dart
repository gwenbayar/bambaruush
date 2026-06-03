// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'srs_box.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SrsBox _$SrsBoxFromJson(Map<String, dynamic> json) {
  return _SrsBox.fromJson(json);
}

/// @nodoc
mixin _$SrsBox {
  String get wordId => throw _privateConstructorUsedError;
  int get level => throw _privateConstructorUsedError;
  DateTime get nextReviewAt => throw _privateConstructorUsedError;
  int get correctStreak => throw _privateConstructorUsedError;

  /// Serializes this SrsBox to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SrsBox
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SrsBoxCopyWith<SrsBox> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SrsBoxCopyWith<$Res> {
  factory $SrsBoxCopyWith(SrsBox value, $Res Function(SrsBox) then) =
      _$SrsBoxCopyWithImpl<$Res, SrsBox>;
  @useResult
  $Res call(
      {String wordId, int level, DateTime nextReviewAt, int correctStreak});
}

/// @nodoc
class _$SrsBoxCopyWithImpl<$Res, $Val extends SrsBox>
    implements $SrsBoxCopyWith<$Res> {
  _$SrsBoxCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SrsBox
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? wordId = null,
    Object? level = null,
    Object? nextReviewAt = null,
    Object? correctStreak = null,
  }) {
    return _then(_value.copyWith(
      wordId: null == wordId
          ? _value.wordId
          : wordId // ignore: cast_nullable_to_non_nullable
              as String,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
      nextReviewAt: null == nextReviewAt
          ? _value.nextReviewAt
          : nextReviewAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      correctStreak: null == correctStreak
          ? _value.correctStreak
          : correctStreak // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SrsBoxImplCopyWith<$Res> implements $SrsBoxCopyWith<$Res> {
  factory _$$SrsBoxImplCopyWith(
          _$SrsBoxImpl value, $Res Function(_$SrsBoxImpl) then) =
      __$$SrsBoxImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String wordId, int level, DateTime nextReviewAt, int correctStreak});
}

/// @nodoc
class __$$SrsBoxImplCopyWithImpl<$Res>
    extends _$SrsBoxCopyWithImpl<$Res, _$SrsBoxImpl>
    implements _$$SrsBoxImplCopyWith<$Res> {
  __$$SrsBoxImplCopyWithImpl(
      _$SrsBoxImpl _value, $Res Function(_$SrsBoxImpl) _then)
      : super(_value, _then);

  /// Create a copy of SrsBox
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? wordId = null,
    Object? level = null,
    Object? nextReviewAt = null,
    Object? correctStreak = null,
  }) {
    return _then(_$SrsBoxImpl(
      wordId: null == wordId
          ? _value.wordId
          : wordId // ignore: cast_nullable_to_non_nullable
              as String,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
      nextReviewAt: null == nextReviewAt
          ? _value.nextReviewAt
          : nextReviewAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      correctStreak: null == correctStreak
          ? _value.correctStreak
          : correctStreak // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SrsBoxImpl implements _SrsBox {
  const _$SrsBoxImpl(
      {required this.wordId,
      required this.level,
      required this.nextReviewAt,
      required this.correctStreak});

  factory _$SrsBoxImpl.fromJson(Map<String, dynamic> json) =>
      _$$SrsBoxImplFromJson(json);

  @override
  final String wordId;
  @override
  final int level;
  @override
  final DateTime nextReviewAt;
  @override
  final int correctStreak;

  @override
  String toString() {
    return 'SrsBox(wordId: $wordId, level: $level, nextReviewAt: $nextReviewAt, correctStreak: $correctStreak)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SrsBoxImpl &&
            (identical(other.wordId, wordId) || other.wordId == wordId) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.nextReviewAt, nextReviewAt) ||
                other.nextReviewAt == nextReviewAt) &&
            (identical(other.correctStreak, correctStreak) ||
                other.correctStreak == correctStreak));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, wordId, level, nextReviewAt, correctStreak);

  /// Create a copy of SrsBox
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SrsBoxImplCopyWith<_$SrsBoxImpl> get copyWith =>
      __$$SrsBoxImplCopyWithImpl<_$SrsBoxImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SrsBoxImplToJson(
      this,
    );
  }
}

abstract class _SrsBox implements SrsBox {
  const factory _SrsBox(
      {required final String wordId,
      required final int level,
      required final DateTime nextReviewAt,
      required final int correctStreak}) = _$SrsBoxImpl;

  factory _SrsBox.fromJson(Map<String, dynamic> json) = _$SrsBoxImpl.fromJson;

  @override
  String get wordId;
  @override
  int get level;
  @override
  DateTime get nextReviewAt;
  @override
  int get correctStreak;

  /// Create a copy of SrsBox
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SrsBoxImplCopyWith<_$SrsBoxImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
