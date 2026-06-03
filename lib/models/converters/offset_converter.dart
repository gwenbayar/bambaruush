import 'package:flutter/painting.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

class OffsetConverter implements JsonConverter<Offset, List<dynamic>> {
  const OffsetConverter();
  @override
  Offset fromJson(List<dynamic> json) =>
      Offset((json[0] as num).toDouble(), (json[1] as num).toDouble());
  @override
  List<dynamic> toJson(Offset o) => [o.dx, o.dy];
}
