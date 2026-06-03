// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WordImpl _$$WordImplFromJson(Map<String, dynamic> json) => _$WordImpl(
      id: json['id'] as String,
      imageAssetPath: json['imageAssetPath'] as String,
      letterIds:
          (json['letterIds'] as List<dynamic>).map((e) => e as String).toList(),
      localizations: (json['localizations'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, WordLocalization.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$$WordImplToJson(_$WordImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'imageAssetPath': instance.imageAssetPath,
      'letterIds': instance.letterIds,
      'localizations': instance.localizations,
    };
