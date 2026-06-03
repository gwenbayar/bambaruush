// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'region.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RegionImpl _$$RegionImplFromJson(Map<String, dynamic> json) => _$RegionImpl(
      id: json['id'] as String,
      nameEn: json['nameEn'] as String,
      nameMn: json['nameMn'] as String,
      order: (json['order'] as num).toInt(),
      mapImagePath: json['mapImagePath'] as String,
      mapPosition:
          const OffsetConverter().fromJson(json['mapPosition'] as List),
    );

Map<String, dynamic> _$$RegionImplToJson(_$RegionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nameEn': instance.nameEn,
      'nameMn': instance.nameMn,
      'order': instance.order,
      'mapImagePath': instance.mapImagePath,
      'mapPosition': const OffsetConverter().toJson(instance.mapPosition),
    };
