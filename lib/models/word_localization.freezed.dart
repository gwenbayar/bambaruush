// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'word_localization.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WordLocalization _$WordLocalizationFromJson(Map<String, dynamic> json) {
  return _WordLocalization.fromJson(json);
}

/// @nodoc
mixin _$WordLocalization {
  String get text => throw _privateConstructorUsedError;
  String? get audioAssetPath => throw _privateConstructorUsedError;

  /// Serializes this WordLocalization to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WordLocalization
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WordLocalizationCopyWith<WordLocalization> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WordLocalizationCopyWith<$Res> {
  factory $WordLocalizationCopyWith(
          WordLocalization value, $Res Function(WordLocalization) then) =
      _$WordLocalizationCopyWithImpl<$Res, WordLocalization>;
  @useResult
  $Res call({String text, String? audioAssetPath});
}

/// @nodoc
class _$WordLocalizationCopyWithImpl<$Res, $Val extends WordLocalization>
    implements $WordLocalizationCopyWith<$Res> {
  _$WordLocalizationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WordLocalization
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
    Object? audioAssetPath = freezed,
  }) {
    return _then(_value.copyWith(
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      audioAssetPath: freezed == audioAssetPath
          ? _value.audioAssetPath
          : audioAssetPath // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WordLocalizationImplCopyWith<$Res>
    implements $WordLocalizationCopyWith<$Res> {
  factory _$$WordLocalizationImplCopyWith(_$WordLocalizationImpl value,
          $Res Function(_$WordLocalizationImpl) then) =
      __$$WordLocalizationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String text, String? audioAssetPath});
}

/// @nodoc
class __$$WordLocalizationImplCopyWithImpl<$Res>
    extends _$WordLocalizationCopyWithImpl<$Res, _$WordLocalizationImpl>
    implements _$$WordLocalizationImplCopyWith<$Res> {
  __$$WordLocalizationImplCopyWithImpl(_$WordLocalizationImpl _value,
      $Res Function(_$WordLocalizationImpl) _then)
      : super(_value, _then);

  /// Create a copy of WordLocalization
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
    Object? audioAssetPath = freezed,
  }) {
    return _then(_$WordLocalizationImpl(
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      audioAssetPath: freezed == audioAssetPath
          ? _value.audioAssetPath
          : audioAssetPath // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WordLocalizationImpl implements _WordLocalization {
  const _$WordLocalizationImpl({required this.text, this.audioAssetPath});

  factory _$WordLocalizationImpl.fromJson(Map<String, dynamic> json) =>
      _$$WordLocalizationImplFromJson(json);

  @override
  final String text;
  @override
  final String? audioAssetPath;

  @override
  String toString() {
    return 'WordLocalization(text: $text, audioAssetPath: $audioAssetPath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WordLocalizationImpl &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.audioAssetPath, audioAssetPath) ||
                other.audioAssetPath == audioAssetPath));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, text, audioAssetPath);

  /// Create a copy of WordLocalization
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WordLocalizationImplCopyWith<_$WordLocalizationImpl> get copyWith =>
      __$$WordLocalizationImplCopyWithImpl<_$WordLocalizationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WordLocalizationImplToJson(
      this,
    );
  }
}

abstract class _WordLocalization implements WordLocalization {
  const factory _WordLocalization(
      {required final String text,
      final String? audioAssetPath}) = _$WordLocalizationImpl;

  factory _WordLocalization.fromJson(Map<String, dynamic> json) =
      _$WordLocalizationImpl.fromJson;

  @override
  String get text;
  @override
  String? get audioAssetPath;

  /// Create a copy of WordLocalization
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WordLocalizationImplCopyWith<_$WordLocalizationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
