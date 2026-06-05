// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LessonImpl _$$LessonImplFromJson(Map<String, dynamic> json) => _$LessonImpl(
      id: json['id'] as String,
      order: (json['order'] as num).toInt(),
      title: json['title'] as String?,
      kind: $enumDecodeNullable(_$LessonKindEnumMap, json['kind']) ??
          LessonKind.letter,
      regionId: json['regionId'] as String,
      letterIds:
          (json['letterIds'] as List<dynamic>).map((e) => e as String).toList(),
      wordIds:
          (json['wordIds'] as List<dynamic>).map((e) => e as String).toList(),
      stickerId: json['stickerId'] as String,
    );

Map<String, dynamic> _$$LessonImplToJson(_$LessonImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order': instance.order,
      'title': instance.title,
      'kind': _$LessonKindEnumMap[instance.kind]!,
      'regionId': instance.regionId,
      'letterIds': instance.letterIds,
      'wordIds': instance.wordIds,
      'stickerId': instance.stickerId,
    };

const _$LessonKindEnumMap = {
  LessonKind.vocabulary: 'vocabulary',
  LessonKind.letter: 'letter',
};
