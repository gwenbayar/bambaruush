import 'package:flutter/painting.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters/offset_converter.dart';

part 'constellation.freezed.dart';
part 'constellation.g.dart';

@freezed
class Constellation with _$Constellation {
  const factory Constellation({
    required String id,
    required String nameEn, // accurate English astronomical name
    required String nameMn, // faithful Cyrillic; native-speaker check
    required int order,
    @OffsetListConverter() required List<Offset> slots, // normalized star positions
    required String shapeImage, // what it resembles; animates in on completion
    required String trivia, // one warm kid-sentence; cultural pride
  }) = _Constellation;

  factory Constellation.fromJson(Map<String, dynamic> json) =>
      _$ConstellationFromJson(json);
}
