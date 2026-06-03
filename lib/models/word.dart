import 'package:freezed_annotation/freezed_annotation.dart';

part 'word.freezed.dart';
part 'word.g.dart';

@freezed
class Word with _$Word {
  const factory Word({
    required String id,
    required String cyrillic,
    required String english,
    required String audioAssetPath,
    required String imageAssetPath,
    required List<String> letterIds,
  }) = _Word;

  factory Word.fromJson(Map<String, dynamic> json) => _$WordFromJson(json);
}
