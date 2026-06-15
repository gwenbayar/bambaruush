// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'constellation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConstellationImpl _$$ConstellationImplFromJson(Map<String, dynamic> json) =>
    _$ConstellationImpl(
      id: json['id'] as String,
      nameEn: json['nameEn'] as String,
      nameMn: json['nameMn'] as String,
      order: (json['order'] as num).toInt(),
      slots: const OffsetListConverter().fromJson(json['slots'] as List),
      shapeImage: json['shapeImage'] as String,
      trivia: json['trivia'] as String,
    );

Map<String, dynamic> _$$ConstellationImplToJson(_$ConstellationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nameEn': instance.nameEn,
      'nameMn': instance.nameMn,
      'order': instance.order,
      'slots': const OffsetListConverter().toJson(instance.slots),
      'shapeImage': instance.shapeImage,
      'trivia': instance.trivia,
    };
