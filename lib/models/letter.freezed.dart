// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'letter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Letter _$LetterFromJson(Map<String, dynamic> json) {
  return _Letter.fromJson(json);
}

/// @nodoc
mixin _$Letter {
  String get id => throw _privateConstructorUsedError;
  String get cyrillic => throw _privateConstructorUsedError;
  String get romanization => throw _privateConstructorUsedError;
  String get audioAssetPath => throw _privateConstructorUsedError;
  String get traceTemplatePath => throw _privateConstructorUsedError;

  /// Serializes this Letter to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Letter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LetterCopyWith<Letter> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LetterCopyWith<$Res> {
  factory $LetterCopyWith(Letter value, $Res Function(Letter) then) =
      _$LetterCopyWithImpl<$Res, Letter>;
  @useResult
  $Res call(
      {String id,
      String cyrillic,
      String romanization,
      String audioAssetPath,
      String traceTemplatePath});
}

/// @nodoc
class _$LetterCopyWithImpl<$Res, $Val extends Letter>
    implements $LetterCopyWith<$Res> {
  _$LetterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Letter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? cyrillic = null,
    Object? romanization = null,
    Object? audioAssetPath = null,
    Object? traceTemplatePath = null,
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
      romanization: null == romanization
          ? _value.romanization
          : romanization // ignore: cast_nullable_to_non_nullable
              as String,
      audioAssetPath: null == audioAssetPath
          ? _value.audioAssetPath
          : audioAssetPath // ignore: cast_nullable_to_non_nullable
              as String,
      traceTemplatePath: null == traceTemplatePath
          ? _value.traceTemplatePath
          : traceTemplatePath // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LetterImplCopyWith<$Res> implements $LetterCopyWith<$Res> {
  factory _$$LetterImplCopyWith(
          _$LetterImpl value, $Res Function(_$LetterImpl) then) =
      __$$LetterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String cyrillic,
      String romanization,
      String audioAssetPath,
      String traceTemplatePath});
}

/// @nodoc
class __$$LetterImplCopyWithImpl<$Res>
    extends _$LetterCopyWithImpl<$Res, _$LetterImpl>
    implements _$$LetterImplCopyWith<$Res> {
  __$$LetterImplCopyWithImpl(
      _$LetterImpl _value, $Res Function(_$LetterImpl) _then)
      : super(_value, _then);

  /// Create a copy of Letter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? cyrillic = null,
    Object? romanization = null,
    Object? audioAssetPath = null,
    Object? traceTemplatePath = null,
  }) {
    return _then(_$LetterImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      cyrillic: null == cyrillic
          ? _value.cyrillic
          : cyrillic // ignore: cast_nullable_to_non_nullable
              as String,
      romanization: null == romanization
          ? _value.romanization
          : romanization // ignore: cast_nullable_to_non_nullable
              as String,
      audioAssetPath: null == audioAssetPath
          ? _value.audioAssetPath
          : audioAssetPath // ignore: cast_nullable_to_non_nullable
              as String,
      traceTemplatePath: null == traceTemplatePath
          ? _value.traceTemplatePath
          : traceTemplatePath // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LetterImpl extends _Letter {
  const _$LetterImpl(
      {required this.id,
      required this.cyrillic,
      required this.romanization,
      required this.audioAssetPath,
      required this.traceTemplatePath})
      : super._();

  factory _$LetterImpl.fromJson(Map<String, dynamic> json) =>
      _$$LetterImplFromJson(json);

  @override
  final String id;
  @override
  final String cyrillic;
  @override
  final String romanization;
  @override
  final String audioAssetPath;
  @override
  final String traceTemplatePath;

  @override
  String toString() {
    return 'Letter(id: $id, cyrillic: $cyrillic, romanization: $romanization, audioAssetPath: $audioAssetPath, traceTemplatePath: $traceTemplatePath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LetterImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.cyrillic, cyrillic) ||
                other.cyrillic == cyrillic) &&
            (identical(other.romanization, romanization) ||
                other.romanization == romanization) &&
            (identical(other.audioAssetPath, audioAssetPath) ||
                other.audioAssetPath == audioAssetPath) &&
            (identical(other.traceTemplatePath, traceTemplatePath) ||
                other.traceTemplatePath == traceTemplatePath));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, cyrillic, romanization,
      audioAssetPath, traceTemplatePath);

  /// Create a copy of Letter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LetterImplCopyWith<_$LetterImpl> get copyWith =>
      __$$LetterImplCopyWithImpl<_$LetterImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LetterImplToJson(
      this,
    );
  }
}

abstract class _Letter extends Letter {
  const factory _Letter(
      {required final String id,
      required final String cyrillic,
      required final String romanization,
      required final String audioAssetPath,
      required final String traceTemplatePath}) = _$LetterImpl;
  const _Letter._() : super._();

  factory _Letter.fromJson(Map<String, dynamic> json) = _$LetterImpl.fromJson;

  @override
  String get id;
  @override
  String get cyrillic;
  @override
  String get romanization;
  @override
  String get audioAssetPath;
  @override
  String get traceTemplatePath;

  /// Create a copy of Letter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LetterImplCopyWith<_$LetterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
