// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProgressImpl _$$ProgressImplFromJson(Map<String, dynamic> json) =>
    _$ProgressImpl(
      lessons: (json['lessons'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, LessonProgress.fromJson(e as Map<String, dynamic>)),
      ),
      srsByItem: (json['srsByItem'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, SrsBox.fromJson(e as Map<String, dynamic>)),
      ),
      earnedStickerIds: (json['earnedStickerIds'] as List<dynamic>)
          .map((e) => e as String)
          .toSet(),
      schemaVersion: (json['schemaVersion'] as num).toInt(),
      lastPlayed: DateTime.parse(json['lastPlayed'] as String),
      volume: (json['volume'] as num?)?.toDouble() ?? 1.0,
    );

Map<String, dynamic> _$$ProgressImplToJson(_$ProgressImpl instance) =>
    <String, dynamic>{
      'lessons': instance.lessons,
      'srsByItem': instance.srsByItem,
      'earnedStickerIds': instance.earnedStickerIds.toList(),
      'schemaVersion': instance.schemaVersion,
      'lastPlayed': instance.lastPlayed.toIso8601String(),
      'volume': instance.volume,
    };
