import 'package:bambaruush/models/word.dart';
import 'package:bambaruush/models/word_localization.dart';
import 'package:flutter_test/flutter_test.dart';

Word _word() => const Word(
      id: 'word_aav',
      imageAssetPath: 'assets/images/words/word_aav.png',
      letterIds: ['letter_a'],
      localizations: {
        'mn': WordLocalization(text: 'Аав', audioAssetPath: 'assets/audio/word_aav.mp3'),
        'en': WordLocalization(text: 'father'),
      },
    );

void main() {
  test('text(lang) returns the localized text', () {
    final w = _word();
    expect(w.text('mn'), 'Аав');
    expect(w.text('en'), 'father');
  });

  test('audioPath(lang) returns the resolved path or null', () {
    final w = _word();
    expect(w.audioPath('mn'), 'assets/audio/word_aav.mp3');
    expect(w.audioPath('en'), isNull);
  });
}
