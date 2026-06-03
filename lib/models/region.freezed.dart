// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'region.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Region _$RegionFromJson(Map<String, dynamic> json) {
  return _Region.fromJson(json);
}

/// @nodoc
mixin _$Region {
  String get id => throw _privateConstructorUsedError;
  String get nameEn => throw _privateConstructorUsedError;
  String get nameMn => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError;
  String get mapImagePath => throw _privateConstructorUsedError;
  @OffsetConverter()
  Offset get mapPosition => throw _privateConstructorUsedError;

  /// Serializes this Region to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Region
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RegionCopyWith<Region> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RegionCopyWith<$Res> {
  factory $RegionCopyWith(Region value, $Res Function(Region) then) =
      _$RegionCopyWithImpl<$Res, Region>;
  @useResult
  $Res call(
      {String id,
      String nameEn,
      String nameMn,
      int order,
      String mapImagePath,
      @OffsetConverter() Offset mapPosition});
}

/// @nodoc
class _$RegionCopyWithImpl<$Res, $Val extends Region>
    implements $RegionCopyWith<$Res> {
  _$RegionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Region
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nameEn = null,
    Object? nameMn = null,
    Object? order = null,
    Object? mapImagePath = null,
    Object? mapPosition = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nameEn: null == nameEn
          ? _value.nameEn
          : nameEn // ignore: cast_nullable_to_non_nullable
              as String,
      nameMn: null == nameMn
          ? _value.nameMn
          : nameMn // ignore: cast_nullable_to_non_nullable
              as String,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      mapImagePath: null == mapImagePath
          ? _value.mapImagePath
          : mapImagePath // ignore: cast_nullable_to_non_nullable
              as String,
      mapPosition: null == mapPosition
          ? _value.mapPosition
          : mapPosition // ignore: cast_nullable_to_non_nullable
              as Offset,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RegionImplCopyWith<$Res> implements $RegionCopyWith<$Res> {
  factory _$$RegionImplCopyWith(
          _$RegionImpl value, $Res Function(_$RegionImpl) then) =
      __$$RegionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String nameEn,
      String nameMn,
      int order,
      String mapImagePath,
      @OffsetConverter() Offset mapPosition});
}

/// @nodoc
class __$$RegionImplCopyWithImpl<$Res>
    extends _$RegionCopyWithImpl<$Res, _$RegionImpl>
    implements _$$RegionImplCopyWith<$Res> {
  __$$RegionImplCopyWithImpl(
      _$RegionImpl _value, $Res Function(_$RegionImpl) _then)
      : super(_value, _then);

  /// Create a copy of Region
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nameEn = null,
    Object? nameMn = null,
    Object? order = null,
    Object? mapImagePath = null,
    Object? mapPosition = null,
  }) {
    return _then(_$RegionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nameEn: null == nameEn
          ? _value.nameEn
          : nameEn // ignore: cast_nullable_to_non_nullable
              as String,
      nameMn: null == nameMn
          ? _value.nameMn
          : nameMn // ignore: cast_nullable_to_non_nullable
              as String,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      mapImagePath: null == mapImagePath
          ? _value.mapImagePath
          : mapImagePath // ignore: cast_nullable_to_non_nullable
              as String,
      mapPosition: null == mapPosition
          ? _value.mapPosition
          : mapPosition // ignore: cast_nullable_to_non_nullable
              as Offset,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RegionImpl implements _Region {
  const _$RegionImpl(
      {required this.id,
      required this.nameEn,
      required this.nameMn,
      required this.order,
      required this.mapImagePath,
      @OffsetConverter() required this.mapPosition});

  factory _$RegionImpl.fromJson(Map<String, dynamic> json) =>
      _$$RegionImplFromJson(json);

  @override
  final String id;
  @override
  final String nameEn;
  @override
  final String nameMn;
  @override
  final int order;
  @override
  final String mapImagePath;
  @override
  @OffsetConverter()
  final Offset mapPosition;

  @override
  String toString() {
    return 'Region(id: $id, nameEn: $nameEn, nameMn: $nameMn, order: $order, mapImagePath: $mapImagePath, mapPosition: $mapPosition)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nameEn, nameEn) || other.nameEn == nameEn) &&
            (identical(other.nameMn, nameMn) || other.nameMn == nameMn) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.mapImagePath, mapImagePath) ||
                other.mapImagePath == mapImagePath) &&
            (identical(other.mapPosition, mapPosition) ||
                other.mapPosition == mapPosition));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, nameEn, nameMn, order, mapImagePath, mapPosition);

  /// Create a copy of Region
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RegionImplCopyWith<_$RegionImpl> get copyWith =>
      __$$RegionImplCopyWithImpl<_$RegionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RegionImplToJson(
      this,
    );
  }
}

abstract class _Region implements Region {
  const factory _Region(
      {required final String id,
      required final String nameEn,
      required final String nameMn,
      required final int order,
      required final String mapImagePath,
      @OffsetConverter() required final Offset mapPosition}) = _$RegionImpl;

  factory _Region.fromJson(Map<String, dynamic> json) = _$RegionImpl.fromJson;

  @override
  String get id;
  @override
  String get nameEn;
  @override
  String get nameMn;
  @override
  int get order;
  @override
  String get mapImagePath;
  @override
  @OffsetConverter()
  Offset get mapPosition;

  /// Create a copy of Region
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RegionImplCopyWith<_$RegionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
