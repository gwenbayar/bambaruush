// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'letter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LetterImpl _$$LetterImplFromJson(Map<String, dynamic> json) => _$LetterImpl(
      id: json['id'] as String,
      cyrillic: json['cyrillic'] as String,
      romanization: json['romanization'] as String,
      audioAssetPath: json['audioAssetPath'] as String,
      traceTemplatePath: json['traceTemplatePath'] as String,
    );

Map<String, dynamic> _$$LetterImplToJson(_$LetterImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'cyrillic': instance.cyrillic,
      'romanization': instance.romanization,
      'audioAssetPath': instance.audioAssetPath,
      'traceTemplatePath': instance.traceTemplatePath,
    };
