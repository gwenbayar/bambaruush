import 'package:bambaruush/models/item.dart';
import 'package:bambaruush/models/letter.dart';
import 'package:bambaruush/models/word.dart';
import 'package:bambaruush/models/word_localization.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Word is an Item of type word with the right key', () {
    const w = Word(
      id: 'word_aav',
      imageAssetPath: 'assets/images/words/word_aav.png',
      letterIds: ['letter_a'],
      localizations: {'mn': WordLocalization(text: 'Аав'), 'en': WordLocalization(text: 'father')},
    );
    expect(w, isA<Item>());
    expect(w.type, ItemType.word);
    expect(w.key, 'word:word_aav');
  });

  test('Letter is an Item of type letter with the right key', () {
    const l = Letter(
      id: 'letter_a',
      cyrillic: 'А',
      romanization: 'A',
      audioAssetPath: 'assets/audio/letter_a.mp3',
      traceTemplatePath: 'assets/trace_masks/letter_a.png',
    );
    expect(l, isA<Item>());
    expect(l.type, ItemType.letter);
    expect(l.key, 'letter:letter_a');
  });

  test('itemKeyOf builds "type:id"', () {
    expect(itemKeyOf(ItemType.word, 'x'), 'word:x');
    expect(itemKeyOf(ItemType.letter, 'y'), 'letter:y');
  });
}
