// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WordImpl _$$WordImplFromJson(Map<String, dynamic> json) => _$WordImpl(
      id: json['id'] as String,
      cyrillic: json['cyrillic'] as String,
      english: json['english'] as String,
      audioAssetPath: json['audioAssetPath'] as String,
      imageAssetPath: json['imageAssetPath'] as String,
      letterIds:
          (json['letterIds'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$WordImplToJson(_$WordImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'cyrillic': instance.cyrillic,
      'english': instance.english,
      'audioAssetPath': instance.audioAssetPath,
      'imageAssetPath': instance.imageAssetPath,
      'letterIds': instance.letterIds,
    };
