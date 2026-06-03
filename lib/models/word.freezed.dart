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
  String get imageAssetPath => throw _privateConstructorUsedError;
  List<String> get letterIds => throw _privateConstructorUsedError;
  Map<String, WordLocalization> get localizations =>
      throw _privateConstructorUsedError;

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
      String imageAssetPath,
      List<String> letterIds,
      Map<String, WordLocalization> localizations});
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
    Object? imageAssetPath = null,
    Object? letterIds = null,
    Object? localizations = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      imageAssetPath: null == imageAssetPath
          ? _value.imageAssetPath
          : imageAssetPath // ignore: cast_nullable_to_non_nullable
              as String,
      letterIds: null == letterIds
          ? _value.letterIds
          : letterIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      localizations: null == localizations
          ? _value.localizations
          : localizations // ignore: cast_nullable_to_non_nullable
              as Map<String, WordLocalization>,
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
      String imageAssetPath,
      List<String> letterIds,
      Map<String, WordLocalization> localizations});
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
    Object? imageAssetPath = null,
    Object? letterIds = null,
    Object? localizations = null,
  }) {
    return _then(_$WordImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      imageAssetPath: null == imageAssetPath
          ? _value.imageAssetPath
          : imageAssetPath // ignore: cast_nullable_to_non_nullable
              as String,
      letterIds: null == letterIds
          ? _value._letterIds
          : letterIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      localizations: null == localizations
          ? _value._localizations
          : localizations // ignore: cast_nullable_to_non_nullable
              as Map<String, WordLocalization>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WordImpl extends _Word {
  const _$WordImpl(
      {required this.id,
      required this.imageAssetPath,
      required final List<String> letterIds,
      required final Map<String, WordLocalization> localizations})
      : _letterIds = letterIds,
        _localizations = localizations,
        super._();

  factory _$WordImpl.fromJson(Map<String, dynamic> json) =>
      _$$WordImplFromJson(json);

  @override
  final String id;
  @override
  final String imageAssetPath;
  final List<String> _letterIds;
  @override
  List<String> get letterIds {
    if (_letterIds is EqualUnmodifiableListView) return _letterIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_letterIds);
  }

  final Map<String, WordLocalization> _localizations;
  @override
  Map<String, WordLocalization> get localizations {
    if (_localizations is EqualUnmodifiableMapView) return _localizations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_localizations);
  }

  @override
  String toString() {
    return 'Word(id: $id, imageAssetPath: $imageAssetPath, letterIds: $letterIds, localizations: $localizations)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.imageAssetPath, imageAssetPath) ||
                other.imageAssetPath == imageAssetPath) &&
            const DeepCollectionEquality()
                .equals(other._letterIds, _letterIds) &&
            const DeepCollectionEquality()
                .equals(other._localizations, _localizations));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      imageAssetPath,
      const DeepCollectionEquality().hash(_letterIds),
      const DeepCollectionEquality().hash(_localizations));

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

abstract class _Word extends Word {
  const factory _Word(
      {required final String id,
      required final String imageAssetPath,
      required final List<String> letterIds,
      required final Map<String, WordLocalization> localizations}) = _$WordImpl;
  const _Word._() : super._();

  factory _Word.fromJson(Map<String, dynamic> json) = _$WordImpl.fromJson;

  @override
  String get id;
  @override
  String get imageAssetPath;
  @override
  List<String> get letterIds;
  @override
  Map<String, WordLocalization> get localizations;

  /// Create a copy of Word
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WordImplCopyWith<_$WordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
