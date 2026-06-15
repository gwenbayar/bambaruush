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

class OffsetListConverter implements JsonConverter<List<Offset>, List<dynamic>> {
  const OffsetListConverter();
  @override
  List<Offset> fromJson(List<dynamic> json) => [
        for (final e in json)
          Offset(
            ((e as List<dynamic>)[0] as num).toDouble(),
            (e[1] as num).toDouble(),
          ),
      ];
  @override
  List<dynamic> toJson(List<Offset> list) => [
        for (final o in list) [o.dx, o.dy],
      ];
}
