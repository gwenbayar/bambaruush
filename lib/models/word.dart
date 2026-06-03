import 'package:freezed_annotation/freezed_annotation.dart';

import 'word_localization.dart';

part 'word.freezed.dart';
part 'word.g.dart';

@freezed
class Word with _$Word {
  const Word._();

  const factory Word({
    required String id,
    required String imageAssetPath,
    required List<String> letterIds,
    required Map<String, WordLocalization> localizations,
  }) = _Word;

  factory Word.fromJson(Map<String, dynamic> json) => _$WordFromJson(json);

  /// Localized text for [lang]. Content validation guarantees the configured
  /// languages (mn, en) are present, so this is non-null for those.
  String text(String lang) {
    final loc = localizations[lang];
    if (loc == null) {
      throw StateError('word $id has no localization "$lang"');
    }
    return loc.text;
  }

  /// Resolved audio asset path for [lang], or null when that language has no
  /// recording (e.g. the English gloss).
  String? audioPath(String lang) => localizations[lang]?.audioAssetPath;
}
