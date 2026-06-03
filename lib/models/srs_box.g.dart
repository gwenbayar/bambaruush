// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'srs_box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SrsBoxImpl _$$SrsBoxImplFromJson(Map<String, dynamic> json) => _$SrsBoxImpl(
      wordId: json['wordId'] as String,
      level: (json['level'] as num).toInt(),
      nextReviewAt: DateTime.parse(json['nextReviewAt'] as String),
      correctStreak: (json['correctStreak'] as num).toInt(),
    );

Map<String, dynamic> _$$SrsBoxImplToJson(_$SrsBoxImpl instance) =>
    <String, dynamic>{
      'wordId': instance.wordId,
      'level': instance.level,
      'nextReviewAt': instance.nextReviewAt.toIso8601String(),
      'correctStreak': instance.correctStreak,
    };
