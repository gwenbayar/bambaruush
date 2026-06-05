import 'package:freezed_annotation/freezed_annotation.dart';

part 'word_localization.freezed.dart';
part 'word_localization.g.dart';

/// One language's rendering of a word: its text and (optionally) an audio clip.
@freezed
class WordLocalization with _$WordLocalization {
  const factory WordLocalization({
    required String text,
    String? audioAssetPath,
  }) = _WordLocalization;

  factory WordLocalization.fromJson(Map<String, dynamic> json) =>
      _$WordLocalizationFromJson(json);
}
