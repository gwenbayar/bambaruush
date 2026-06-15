// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'constellation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Constellation _$ConstellationFromJson(Map<String, dynamic> json) {
  return _Constellation.fromJson(json);
}

/// @nodoc
mixin _$Constellation {
  String get id => throw _privateConstructorUsedError;
  String get nameEn =>
      throw _privateConstructorUsedError; // accurate English astronomical name
  String get nameMn =>
      throw _privateConstructorUsedError; // faithful Cyrillic; native-speaker check
  int get order => throw _privateConstructorUsedError;
  @OffsetListConverter()
  List<Offset> get slots =>
      throw _privateConstructorUsedError; // normalized star positions
  String get shapeImage =>
      throw _privateConstructorUsedError; // what it resembles; animates in on completion
  String get trivia => throw _privateConstructorUsedError;

  /// Serializes this Constellation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Constellation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConstellationCopyWith<Constellation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConstellationCopyWith<$Res> {
  factory $ConstellationCopyWith(
          Constellation value, $Res Function(Constellation) then) =
      _$ConstellationCopyWithImpl<$Res, Constellation>;
  @useResult
  $Res call(
      {String id,
      String nameEn,
      String nameMn,
      int order,
      @OffsetListConverter() List<Offset> slots,
      String shapeImage,
      String trivia});
}

/// @nodoc
class _$ConstellationCopyWithImpl<$Res, $Val extends Constellation>
    implements $ConstellationCopyWith<$Res> {
  _$ConstellationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Constellation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nameEn = null,
    Object? nameMn = null,
    Object? order = null,
    Object? slots = null,
    Object? shapeImage = null,
    Object? trivia = null,
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
      slots: null == slots
          ? _value.slots
          : slots // ignore: cast_nullable_to_non_nullable
              as List<Offset>,
      shapeImage: null == shapeImage
          ? _value.shapeImage
          : shapeImage // ignore: cast_nullable_to_non_nullable
              as String,
      trivia: null == trivia
          ? _value.trivia
          : trivia // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ConstellationImplCopyWith<$Res>
    implements $ConstellationCopyWith<$Res> {
  factory _$$ConstellationImplCopyWith(
          _$ConstellationImpl value, $Res Function(_$ConstellationImpl) then) =
      __$$ConstellationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String nameEn,
      String nameMn,
      int order,
      @OffsetListConverter() List<Offset> slots,
      String shapeImage,
      String trivia});
}

/// @nodoc
class __$$ConstellationImplCopyWithImpl<$Res>
    extends _$ConstellationCopyWithImpl<$Res, _$ConstellationImpl>
    implements _$$ConstellationImplCopyWith<$Res> {
  __$$ConstellationImplCopyWithImpl(
      _$ConstellationImpl _value, $Res Function(_$ConstellationImpl) _then)
      : super(_value, _then);

  /// Create a copy of Constellation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nameEn = null,
    Object? nameMn = null,
    Object? order = null,
    Object? slots = null,
    Object? shapeImage = null,
    Object? trivia = null,
  }) {
    return _then(_$ConstellationImpl(
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
      slots: null == slots
          ? _value._slots
          : slots // ignore: cast_nullable_to_non_nullable
              as List<Offset>,
      shapeImage: null == shapeImage
          ? _value.shapeImage
          : shapeImage // ignore: cast_nullable_to_non_nullable
              as String,
      trivia: null == trivia
          ? _value.trivia
          : trivia // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ConstellationImpl implements _Constellation {
  const _$ConstellationImpl(
      {required this.id,
      required this.nameEn,
      required this.nameMn,
      required this.order,
      @OffsetListConverter() required final List<Offset> slots,
      required this.shapeImage,
      required this.trivia})
      : _slots = slots;

  factory _$ConstellationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConstellationImplFromJson(json);

  @override
  final String id;
  @override
  final String nameEn;
// accurate English astronomical name
  @override
  final String nameMn;
// faithful Cyrillic; native-speaker check
  @override
  final int order;
  final List<Offset> _slots;
  @override
  @OffsetListConverter()
  List<Offset> get slots {
    if (_slots is EqualUnmodifiableListView) return _slots;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_slots);
  }

// normalized star positions
  @override
  final String shapeImage;
// what it resembles; animates in on completion
  @override
  final String trivia;

  @override
  String toString() {
    return 'Constellation(id: $id, nameEn: $nameEn, nameMn: $nameMn, order: $order, slots: $slots, shapeImage: $shapeImage, trivia: $trivia)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConstellationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nameEn, nameEn) || other.nameEn == nameEn) &&
            (identical(other.nameMn, nameMn) || other.nameMn == nameMn) &&
            (identical(other.order, order) || other.order == order) &&
            const DeepCollectionEquality().equals(other._slots, _slots) &&
            (identical(other.shapeImage, shapeImage) ||
                other.shapeImage == shapeImage) &&
            (identical(other.trivia, trivia) || other.trivia == trivia));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, nameEn, nameMn, order,
      const DeepCollectionEquality().hash(_slots), shapeImage, trivia);

  /// Create a copy of Constellation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConstellationImplCopyWith<_$ConstellationImpl> get copyWith =>
      __$$ConstellationImplCopyWithImpl<_$ConstellationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConstellationImplToJson(
      this,
    );
  }
}

abstract class _Constellation implements Constellation {
  const factory _Constellation(
      {required final String id,
      required final String nameEn,
      required final String nameMn,
      required final int order,
      @OffsetListConverter() required final List<Offset> slots,
      required final String shapeImage,
      required final String trivia}) = _$ConstellationImpl;

  factory _Constellation.fromJson(Map<String, dynamic> json) =
      _$ConstellationImpl.fromJson;

  @override
  String get id;
  @override
  String get nameEn; // accurate English astronomical name
  @override
  String get nameMn; // faithful Cyrillic; native-speaker check
  @override
  int get order;
  @override
  @OffsetListConverter()
  List<Offset> get slots; // normalized star positions
  @override
  String get shapeImage; // what it resembles; animates in on completion
  @override
  String get trivia;

  /// Create a copy of Constellation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConstellationImplCopyWith<_$ConstellationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
