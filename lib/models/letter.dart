import 'package:freezed_annotation/freezed_annotation.dart';

import 'item.dart';

part 'letter.freezed.dart';
part 'letter.g.dart';

@freezed
class Letter with _$Letter implements Item {
  const Letter._();

  @override
  ItemType get type => ItemType.letter;

  const factory Letter({
    required String id,
    required String cyrillic,
    required String romanization,
    required String audioAssetPath,
    required String traceTemplatePath,
  }) = _Letter;

  factory Letter.fromJson(Map<String, dynamic> json) => _$LetterFromJson(json);
}
