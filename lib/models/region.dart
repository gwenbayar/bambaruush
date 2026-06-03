import 'package:flutter/painting.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters/offset_converter.dart';

part 'region.freezed.dart';
part 'region.g.dart';

@freezed
class Region with _$Region {
  const factory Region({
    required String id,
    required String nameEn,
    required String nameMn,
    required int order,
    required String mapImagePath,
    @OffsetConverter() required Offset mapPosition,
  }) = _Region;

  factory Region.fromJson(Map<String, dynamic> json) => _$RegionFromJson(json);
}
