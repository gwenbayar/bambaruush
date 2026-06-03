// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'word.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Word _$WordFromJson(Map<String, dynamic> json) {
  return _Word.fromJson(json);
}

/// @nodoc
mixin _$Word {
  String get id => throw _privateConstructorUsedError;
  String get cyrillic => throw _privateConstructorUsedError;
  String get english => throw _privateConstructorUsedError;
  String get audioAssetPath => throw _privateConstructorUsedError;
  String get imageAssetPath => throw _privateConstructorUsedError;
  List<String> get letterIds => throw _privateConstructorUsedError;

  /// Serializes this Word to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Word
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WordCopyWith<Word> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WordCopyWith<$Res> {
  factory $WordCopyWith(Word value, $Res Function(Word) then) =
      _$WordCopyWithImpl<$Res, Word>;
  @useResult
  $Res call(
      {String id,
      String cyrillic,
      String english,
      String audioAssetPath,
      String imageAssetPath,
      List<String> letterIds});
}

/// @nodoc
class _$WordCopyWithImpl<$Res, $Val extends Word>
    implements $WordCopyWith<$Res> {
  _$WordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Word
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? cyrillic = null,
    Object? english = null,
    Object? audioAssetPath = null,
    Object? imageAssetPath = null,
    Object? letterIds = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      cyrillic: null == cyrillic
          ? _value.cyrillic
          : cyrillic // ignore: cast_nullable_to_non_nullable
              as String,
      english: null == english
          ? _value.english
          : english // ignore: cast_nullable_to_non_nullable
              as String,
      audioAssetPath: null == audioAssetPath
          ? _value.audioAssetPath
          : audioAssetPath // ignore: cast_nullable_to_non_nullable
              as String,
      imageAssetPath: null == imageAssetPath
          ? _value.imageAssetPath
          : imageAssetPath // ignore: cast_nullable_to_non_nullable
              as String,
      letterIds: null == letterIds
          ? _value.letterIds
          : letterIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WordImplCopyWith<$Res> implements $WordCopyWith<$Res> {
  factory _$$WordImplCopyWith(
          _$WordImpl value, $Res Function(_$WordImpl) then) =
      __$$WordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String cyrillic,
      String english,
      String audioAssetPath,
      String imageAssetPath,
      List<String> letterIds});
}

/// @nodoc
class __$$WordImplCopyWithImpl<$Res>
    extends _$WordCopyWithImpl<$Res, _$WordImpl>
    implements _$$WordImplCopyWith<$Res> {
  __$$WordImplCopyWithImpl(_$WordImpl _value, $Res Function(_$WordImpl) _then)
      : super(_value, _then);

  /// Create a copy of Word
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? cyrillic = null,
    Object? english = null,
    Object? audioAssetPath = null,
    Object? imageAssetPath = null,
    Object? letterIds = null,
  }) {
    return _then(_$WordImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      cyrillic: null == cyrillic
          ? _value.cyrillic
          : cyrillic // ignore: cast_nullable_to_non_nullable
              as String,
      english: null == english
          ? _value.english
          : english // ignore: cast_nullable_to_non_nullable
              as String,
      audioAssetPath: null == audioAssetPath
          ? _value.audioAssetPath
          : audioAssetPath // ignore: cast_nullable_to_non_nullable
              as String,
      imageAssetPath: null == imageAssetPath
          ? _value.imageAssetPath
          : imageAssetPath // ignore: cast_nullable_to_non_nullable
              as String,
      letterIds: null == letterIds
          ? _value._letterIds
          : letterIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WordImpl implements _Word {
  const _$WordImpl(
      {required this.id,
      required this.cyrillic,
      required this.english,
      required this.audioAssetPath,
      required this.imageAssetPath,
      required final List<String> letterIds})
      : _letterIds = letterIds;

  factory _$WordImpl.fromJson(Map<String, dynamic> json) =>
      _$$WordImplFromJson(json);

  @override
  final String id;
  @override
  final String cyrillic;
  @override
  final String english;
  @override
  final String audioAssetPath;
  @override
  final String imageAssetPath;
  final List<String> _letterIds;
  @override
  List<String> get letterIds {
    if (_letterIds is EqualUnmodifiableListView) return _letterIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_letterIds);
  }

  @override
  String toString() {
    return 'Word(id: $id, cyrillic: $cyrillic, english: $english, audioAssetPath: $audioAssetPath, imageAssetPath: $imageAssetPath, letterIds: $letterIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.cyrillic, cyrillic) ||
                other.cyrillic == cyrillic) &&
            (identical(other.english, english) || other.english == english) &&
            (identical(other.audioAssetPath, audioAssetPath) ||
                other.audioAssetPath == audioAssetPath) &&
            (identical(other.imageAssetPath, imageAssetPath) ||
                other.imageAssetPath == imageAssetPath) &&
            const DeepCollectionEquality()
                .equals(other._letterIds, _letterIds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      cyrillic,
      english,
      audioAssetPath,
      imageAssetPath,
      const DeepCollectionEquality().hash(_letterIds));

  /// Create a copy of Word
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WordImplCopyWith<_$WordImpl> get copyWith =>
      __$$WordImplCopyWithImpl<_$WordImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WordImplToJson(
      this,
    );
  }
}

abstract class _Word implements Word {
  const factory _Word(
      {required final String id,
      required final String cyrillic,
      required final String english,
      required final String audioAssetPath,
      required final String imageAssetPath,
      required final List<String> letterIds}) = _$WordImpl;

  factory _Word.fromJson(Map<String, dynamic> json) = _$WordImpl.fromJson;

  @override
  String get id;
  @override
  String get cyrillic;
  @override
  String get english;
  @override
  String get audioAssetPath;
  @override
  String get imageAssetPath;
  @override
  List<String> get letterIds;

  /// Create a copy of Word
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WordImplCopyWith<_$WordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
