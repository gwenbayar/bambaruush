// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lesson.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Lesson _$LessonFromJson(Map<String, dynamic> json) {
  return _Lesson.fromJson(json);
}

/// @nodoc
mixin _$Lesson {
  String get id => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  LessonKind get kind => throw _privateConstructorUsedError;
  String get regionId => throw _privateConstructorUsedError;
  List<String> get letterIds => throw _privateConstructorUsedError;
  List<String> get wordIds => throw _privateConstructorUsedError;
  String get stickerId => throw _privateConstructorUsedError;

  /// Serializes this Lesson to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Lesson
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LessonCopyWith<Lesson> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LessonCopyWith<$Res> {
  factory $LessonCopyWith(Lesson value, $Res Function(Lesson) then) =
      _$LessonCopyWithImpl<$Res, Lesson>;
  @useResult
  $Res call(
      {String id,
      int order,
      String? title,
      LessonKind kind,
      String regionId,
      List<String> letterIds,
      List<String> wordIds,
      String stickerId});
}

/// @nodoc
class _$LessonCopyWithImpl<$Res, $Val extends Lesson>
    implements $LessonCopyWith<$Res> {
  _$LessonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Lesson
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? order = null,
    Object? title = freezed,
    Object? kind = null,
    Object? regionId = null,
    Object? letterIds = null,
    Object? wordIds = null,
    Object? stickerId = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      kind: null == kind
          ? _value.kind
          : kind // ignore: cast_nullable_to_non_nullable
              as LessonKind,
      regionId: null == regionId
          ? _value.regionId
          : regionId // ignore: cast_nullable_to_non_nullable
              as String,
      letterIds: null == letterIds
          ? _value.letterIds
          : letterIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      wordIds: null == wordIds
          ? _value.wordIds
          : wordIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      stickerId: null == stickerId
          ? _value.stickerId
          : stickerId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LessonImplCopyWith<$Res> implements $LessonCopyWith<$Res> {
  factory _$$LessonImplCopyWith(
          _$LessonImpl value, $Res Function(_$LessonImpl) then) =
      __$$LessonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      int order,
      String? title,
      LessonKind kind,
      String regionId,
      List<String> letterIds,
      List<String> wordIds,
      String stickerId});
}

/// @nodoc
class __$$LessonImplCopyWithImpl<$Res>
    extends _$LessonCopyWithImpl<$Res, _$LessonImpl>
    implements _$$LessonImplCopyWith<$Res> {
  __$$LessonImplCopyWithImpl(
      _$LessonImpl _value, $Res Function(_$LessonImpl) _then)
      : super(_value, _then);

  /// Create a copy of Lesson
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? order = null,
    Object? title = freezed,
    Object? kind = null,
    Object? regionId = null,
    Object? letterIds = null,
    Object? wordIds = null,
    Object? stickerId = null,
  }) {
    return _then(_$LessonImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      kind: null == kind
          ? _value.kind
          : kind // ignore: cast_nullable_to_non_nullable
              as LessonKind,
      regionId: null == regionId
          ? _value.regionId
          : regionId // ignore: cast_nullable_to_non_nullable
              as String,
      letterIds: null == letterIds
          ? _value._letterIds
          : letterIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      wordIds: null == wordIds
          ? _value._wordIds
          : wordIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      stickerId: null == stickerId
          ? _value.stickerId
          : stickerId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LessonImpl implements _Lesson {
  const _$LessonImpl(
      {required this.id,
      required this.order,
      this.title,
      this.kind = LessonKind.letter,
      required this.regionId,
      required final List<String> letterIds,
      required final List<String> wordIds,
      required this.stickerId})
      : _letterIds = letterIds,
        _wordIds = wordIds;

  factory _$LessonImpl.fromJson(Map<String, dynamic> json) =>
      _$$LessonImplFromJson(json);

  @override
  final String id;
  @override
  final int order;
  @override
  final String? title;
  @override
  @JsonKey()
  final LessonKind kind;
  @override
  final String regionId;
  final List<String> _letterIds;
  @override
  List<String> get letterIds {
    if (_letterIds is EqualUnmodifiableListView) return _letterIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_letterIds);
  }

  final List<String> _wordIds;
  @override
  List<String> get wordIds {
    if (_wordIds is EqualUnmodifiableListView) return _wordIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_wordIds);
  }

  @override
  final String stickerId;

  @override
  String toString() {
    return 'Lesson(id: $id, order: $order, title: $title, kind: $kind, regionId: $regionId, letterIds: $letterIds, wordIds: $wordIds, stickerId: $stickerId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LessonImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.kind, kind) || other.kind == kind) &&
            (identical(other.regionId, regionId) ||
                other.regionId == regionId) &&
            const DeepCollectionEquality()
                .equals(other._letterIds, _letterIds) &&
            const DeepCollectionEquality().equals(other._wordIds, _wordIds) &&
            (identical(other.stickerId, stickerId) ||
                other.stickerId == stickerId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      order,
      title,
      kind,
      regionId,
      const DeepCollectionEquality().hash(_letterIds),
      const DeepCollectionEquality().hash(_wordIds),
      stickerId);

  /// Create a copy of Lesson
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LessonImplCopyWith<_$LessonImpl> get copyWith =>
      __$$LessonImplCopyWithImpl<_$LessonImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LessonImplToJson(
      this,
    );
  }
}

abstract class _Lesson implements Lesson {
  const factory _Lesson(
      {required final String id,
      required final int order,
      final String? title,
      final LessonKind kind,
      required final String regionId,
      required final List<String> letterIds,
      required final List<String> wordIds,
      required final String stickerId}) = _$LessonImpl;

  factory _Lesson.fromJson(Map<String, dynamic> json) = _$LessonImpl.fromJson;

  @override
  String get id;
  @override
  int get order;
  @override
  String? get title;
  @override
  LessonKind get kind;
  @override
  String get regionId;
  @override
  List<String> get letterIds;
  @override
  List<String> get wordIds;
  @override
  String get stickerId;

  /// Create a copy of Lesson
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LessonImplCopyWith<_$LessonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
