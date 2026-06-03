import 'package:freezed_annotation/freezed_annotation.dart';

part 'letter.freezed.dart';
part 'letter.g.dart';

@freezed
class Letter with _$Letter {
  const factory Letter({
    required String id,
    required String cyrillic,
    required String romanization,
    required String audioAssetPath,
    required String traceTemplatePath,
  }) = _Letter;

  factory Letter.fromJson(Map<String, dynamic> json) => _$LetterFromJson(json);
}
