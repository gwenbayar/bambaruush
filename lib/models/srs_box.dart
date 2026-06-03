import 'package:freezed_annotation/freezed_annotation.dart';

part 'srs_box.freezed.dart';
part 'srs_box.g.dart';

@freezed
class SrsBox with _$SrsBox {
  const factory SrsBox({
    required String wordId,
    required int level,
    required DateTime nextReviewAt,
    required int correctStreak,
  }) = _SrsBox;

  factory SrsBox.fromJson(Map<String, dynamic> json) => _$SrsBoxFromJson(json);
}
