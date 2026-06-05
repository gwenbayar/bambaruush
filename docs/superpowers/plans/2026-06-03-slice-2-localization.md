# Slice 2 — Localization-Ready Content Model — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make vocabulary language-agnostic — move each `Word`'s per-language `text`/`audio` into a `localizations` map, add a `learningLanguageProvider` seam, with net behavior unchanged (Mongolian learning, English glosses).

**Architecture:** `Word` holds `Map<String, WordLocalization>` keyed by language code; accessors `text(lang)`/`audioPath(lang)`. A `learningLanguageProvider` (default `'mn'`) selects the taught language; `glossLanguage = 'en'` is the fixed meaning/UI language. Task 1 lands the model + content + repo behind temporary back-compat getters so the app stays green; Task 2 migrates the widgets and removes the getters.

**Tech Stack:** Flutter · Dart 3 · freezed/json_serializable · flutter_riverpod

**Spec:** `docs/superpowers/specs/2026-06-03-localized-content-model-design.md`

**Scope guard:** Words only — `Letter` is untouched. No `Concept`/`key`, no SRS/review changes, no language-switcher UI. Content is bundled (not persisted) → no schema-version/migration.

**No git commit steps** — the user manages git. Pause after each task for the user to commit.

---

## File map

```
lib/models/word_localization.dart              CREATE — WordLocalization {text, audioAssetPath?}
lib/models/word.dart                           MODIFY — localizations map + WordText extension + TEMP back-compat getters
lib/core/content/content_repository.dart       MODIFY — _wordFromRawJson builds localizations; validate required langs
lib/core/i18n/language.dart                    CREATE — learningLanguageProvider + glossLanguage (Task 2)
assets/content/content.json                    MODIFY — 7 words → localized shape
test/fixtures/content_valid.json               MODIFY — 4 words → localized shape
test/fixtures/content_dangling_ref.json        MODIFY — words → localized shape
test/fixtures/content_duplicate_id.json        MODIFY — words → localized shape
test/fixtures/content_dangling_word_letter.json MODIFY — words → localized shape (keep its letterIds mutation)
test/fixtures/content_dangling_lesson_region.json MODIFY — words → localized shape
test/fixtures/content_non_contiguous_order.json MODIFY — words → localized shape
test/fixtures/content_word_missing_lang.json   CREATE — a word missing the 'mn' localization
test/models/word_localization_test.dart        CREATE — accessor tests
test/core/content/content_repository_test.dart MODIFY — assertions use text('en')/text('mn'); add missing-lang test
lib/features/lesson/read_activity.dart         MODIFY (Task 2) — use text()/audioPath()
lib/features/lesson/listen_activity.dart       MODIFY (Task 2) — use text()/audioPath()
lib/features/steppe/region_detail_screen.dart  MODIFY (Task 2) — word preview uses text(glossLanguage)
```

---

## Task 1: Localized `Word` model + content/fixtures migration (app stays green via temporary getters)

**Files:**
- Create: `lib/models/word_localization.dart`, `test/models/word_localization_test.dart`, `test/fixtures/content_word_missing_lang.json`
- Modify: `lib/models/word.dart`, `lib/core/content/content_repository.dart`, `assets/content/content.json`, the 6 `test/fixtures/content_*.json`, `test/core/content/content_repository_test.dart`

- [ ] **Step 1: Write the failing accessor test**

Create `test/models/word_localization_test.dart`:

```dart
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
    expect(w.audioPath('en'), isNull); // English gloss has no recording
  });
}
```

- [ ] **Step 2: Run it — confirm failure**

Run: `flutter test test/models/word_localization_test.dart`
Expected: FAIL — `WordLocalization` undefined and `Word` has no `localizations`/`text`.

- [ ] **Step 3: Create `lib/models/word_localization.dart`**

```dart
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
```

- [ ] **Step 4: Rewrite `lib/models/word.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import 'word_localization.dart';

part 'word.freezed.dart';
part 'word.g.dart';

@freezed
class Word with _$Word {
  const factory Word({
    required String id,
    required String imageAssetPath,
    required List<String> letterIds,
    required Map<String, WordLocalization> localizations,
  }) = _Word;

  factory Word.fromJson(Map<String, dynamic> json) => _$WordFromJson(json);
}

extension WordText on Word {
  /// Localized text for [lang]. Content validation guarantees the configured
  /// languages (mn, en) are present, so this is non-null for those.
  String text(String lang) => localizations[lang]!.text;

  /// Resolved audio asset path for [lang], or null when that language has no
  /// recording (e.g. the English gloss).
  String? audioPath(String lang) => localizations[lang]?.audioAssetPath;

  // TEMPORARY back-compat shims — removed in Slice 2 Task 2 once widgets migrate.
  String get cyrillic => text('mn');
  String get english => text('en');
  String get audioAssetPath => audioPath('mn')!;
}
```

- [ ] **Step 5: Regenerate codegen**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: rebuilds `word.freezed.dart`/`word.g.dart` + `word_localization.freezed.dart`/`word_localization.g.dart`. No errors.

- [ ] **Step 6: Run the accessor test — confirm pass**

Run: `flutter test test/models/word_localization_test.dart`
Expected: 2 PASS.

- [ ] **Step 7: Update `ContentRepository._wordFromRawJson` + add language validation**

In `lib/core/content/content_repository.dart`, replace `_wordFromRawJson` with:

```dart
  static const _requiredWordLanguages = ['mn', 'en'];

  static Word _wordFromRawJson(Map<String, dynamic> j) {
    final rawLocs = j['localizations'] as Map<String, dynamic>;
    final localizations = <String, WordLocalization>{};
    rawLocs.forEach((lang, value) {
      final m = value as Map<String, dynamic>;
      final audio = m['audio'] as String?;
      localizations[lang] = WordLocalization(
        text: m['text'] as String,
        audioAssetPath: audio == null ? null : '$_audioPrefix$audio',
      );
    });
    final id = j['id'] as String;
    for (final lang in _requiredWordLanguages) {
      if (!localizations.containsKey(lang)) {
        throw ContentValidationError(
          'word $id is missing required localization "$lang"',
        );
      }
    }
    return Word(
      id: id,
      imageAssetPath: '$_wordImagePrefix${j['image']}',
      letterIds: List<String>.from(j['letterIds'] as List),
      localizations: localizations,
    );
  }
```

Add the import at the top of the file (next to the other model imports):
```dart
import '../../models/word_localization.dart';
```

- [ ] **Step 8: Migrate `assets/content/content.json` words to the localized shape**

Replace the entire `"words"` array with:

```json
  "words": [
    { "id": "word_aav", "image": "word_aav.png", "letterIds": ["letter_a"], "localizations": { "mn": {"text": "Аав", "audio": "word_aav.mp3"}, "en": {"text": "father"} } },
    { "id": "word_eej", "image": "word_eej.png", "letterIds": ["letter_e"], "localizations": { "mn": {"text": "Ээж", "audio": "word_eej.mp3"}, "en": {"text": "mother"} } },
    { "id": "word_akh", "image": "word_akh.png", "letterIds": ["letter_a"], "localizations": { "mn": {"text": "Ах", "audio": "word_akh.mp3"}, "en": {"text": "older brother"} } },
    { "id": "word_egch", "image": "word_egch.png", "letterIds": ["letter_e"], "localizations": { "mn": {"text": "Эгч", "audio": "word_egch.mp3"}, "en": {"text": "older sister"} } },
    { "id": "word_duu", "image": "word_duu.png", "letterIds": ["letter_d"], "localizations": { "mn": {"text": "Дүү", "audio": "word_duu.mp3"}, "en": {"text": "little sibling"} } },
    { "id": "word_bombog", "image": "word_bombog.png", "letterIds": ["letter_b"], "localizations": { "mn": {"text": "Бөмбөг", "audio": "word_bombog.mp3"}, "en": {"text": "ball"} } },
    { "id": "word_bar", "image": "word_bar.png", "letterIds": ["letter_b"], "localizations": { "mn": {"text": "Бар", "audio": "word_bar.mp3"}, "en": {"text": "tiger"} } }
  ],
```
Leave `regions`, `letters`, `lessons`, `stickers` unchanged. Keep valid JSON.

- [ ] **Step 9: Migrate the test fixtures' word arrays**

In `test/fixtures/content_valid.json`, replace its `"words"` array with:

```json
  "words": [
    { "id": "word_aav", "image": "word_aav.png", "letterIds": ["letter_a"], "localizations": { "mn": {"text": "Аав", "audio": "word_aav.mp3"}, "en": {"text": "father"} } },
    { "id": "word_akh", "image": "word_akh.png", "letterIds": ["letter_a"], "localizations": { "mn": {"text": "Ах", "audio": "word_akh.mp3"}, "en": {"text": "older brother"} } },
    { "id": "word_baavgai", "image": "word_baavgai.png", "letterIds": ["letter_b", "letter_a"], "localizations": { "mn": {"text": "Баавгай", "audio": "word_baavgai.mp3"}, "en": {"text": "bear"} } },
    { "id": "word_bombog", "image": "word_bombog.png", "letterIds": ["letter_b"], "localizations": { "mn": {"text": "Бөмбөг", "audio": "word_bombog.mp3"}, "en": {"text": "ball"} } }
  ],
```

Apply the **same** localized `words` array to these four fixtures (their non-word mutations stay untouched):
- `test/fixtures/content_dangling_ref.json`
- `test/fixtures/content_duplicate_id.json` (note: it also has a duplicated `letter_a` in `letters` — leave that)
- `test/fixtures/content_dangling_lesson_region.json`
- `test/fixtures/content_non_contiguous_order.json`

For `test/fixtures/content_dangling_word_letter.json`, use the same array **except** `word_aav`'s `letterIds` stays its mutated value:
```json
    { "id": "word_aav", "image": "word_aav.png", "letterIds": ["letter_missing"], "localizations": { "mn": {"text": "Аав", "audio": "word_aav.mp3"}, "en": {"text": "father"} } },
```
(the other three words identical to content_valid).

- [ ] **Step 10: Create the missing-language fixture**

Create `test/fixtures/content_word_missing_lang.json` as a copy of `content_valid.json` but with `word_aav` missing its `mn` localization:
```json
    { "id": "word_aav", "image": "word_aav.png", "letterIds": ["letter_a"], "localizations": { "en": {"text": "father"} } },
```
(keep the other three words and all non-word sections identical to content_valid).

- [ ] **Step 11: Update `content_repository_test.dart` assertions + add the missing-lang test**

In `test/core/content/content_repository_test.dart`, the valid-fixture test currently asserts `repo.wordById('word_aav').english`. Change word assertions to the new accessors:
- `expect(repo.wordById('word_aav').english, 'father');` → `expect(repo.wordById('word_aav').text('en'), 'father');`
- If a `.cyrillic` assertion on a word exists, change to `.text('mn')`.
(Leave `letterById('letter_a').cyrillic` — that's a Letter, unchanged.)

Add a new test in the same group:
```dart
    test('throws when a word is missing a required localization', () {
      expect(
        () => ContentRepository.fromJson(_loadFixture('content_word_missing_lang.json')),
        throwsA(isA<ContentValidationError>()),
      );
    });
```

- [ ] **Step 12: Verify**

Run: `flutter analyze`
Expected: No issues found. (Widgets still compile — they use the temporary `cyrillic`/`english`/`audioAssetPath` getters.)

Run: `flutter test`
Expected: all pass — the 2 new accessor tests, the new missing-lang test, the updated content tests, and everything else green.

**Checkpoint:** Localized model + content live; app behaves identically via the temp getters. Pause to commit.

---

## Task 2: Language seam + migrate widgets + remove the temporary getters

**Files:**
- Create: `lib/core/i18n/language.dart`
- Modify: `lib/features/lesson/read_activity.dart`, `lib/features/lesson/listen_activity.dart`, `lib/features/steppe/region_detail_screen.dart`, `lib/models/word.dart`

- [ ] **Step 1: Create the language seam `lib/core/i18n/language.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The fixed meaning/UI ("gloss") language for now. A user-facing UI-language
/// axis is intentionally deferred.
const String glossLanguage = 'en';

/// The language currently being taught. A future settings screen can change it;
/// this provider is the seam that makes vocabulary language-agnostic.
final learningLanguageProvider = StateProvider<String>((ref) => 'mn');
```

- [ ] **Step 2: Migrate `listen_activity.dart`**

Add import: `import '../../core/i18n/language.dart';`

In `_ListenActivityViewState`, read the learning language where needed and use the accessors. Replace `_playTarget` with a null-safe version:

```dart
  Future<void> _playTarget() async {
    final content = ref.read(contentRepositoryProvider);
    final lang = ref.read(learningLanguageProvider);
    final path = content.wordById(widget.spec.wordId).audioPath(lang);
    if (path != null) {
      await ref.read(audioServiceProvider).play(path);
    }
  }
```

In the tile, the label and image-fallback use the gloss language. In `_Tile` / wherever `word.english` is read, change to `word.text(glossLanguage)`. Concretely, the tile's label `Text(word.english, ...)` → `Text(word.text(glossLanguage), ...)`, and the `_imageFallback(word.english)` call → `_imageFallback(word.text(glossLanguage))`.

- [ ] **Step 3: Migrate `read_activity.dart`**

Add import: `import '../../core/i18n/language.dart';`

- The big target word display currently uses `target.cyrillic`. In `build`, read `final lang = ref.watch(learningLanguageProvider);` and use `target.text(lang)` for the displayed word.
- The replay/audio button uses `target.audioPath(lang)` with a null guard:
```dart
            onPressed: () {
              final path = target.audioPath(lang);
              if (path != null) ref.read(audioServiceProvider).play(path);
            },
```
- The tiles' label + image fallback use `word.text(glossLanguage)` (same change as listen).

- [ ] **Step 4: Migrate `region_detail_screen.dart` word preview**

Add import: `import '../../core/i18n/language.dart';`

The preview builds `lesson.wordIds.map((w) => content.wordById(w).english).join(' · ')`. Change `.english` → `.text(glossLanguage)`:
```dart
              final wordsPreview = lesson.wordIds
                  .map((w) => content.wordById(w).text(glossLanguage))
                  .join(' · ');
```

- [ ] **Step 5: Remove the temporary getters from `lib/models/word.dart`**

Delete the three back-compat shim getters from the `WordText` extension, leaving only `text` and `audioPath`:

```dart
extension WordText on Word {
  String text(String lang) => localizations[lang]!.text;
  String? audioPath(String lang) => localizations[lang]?.audioAssetPath;
}
```

- [ ] **Step 6: Verify (the analyzer is the safety net)**

Run: `flutter analyze`
Expected: No issues found. If it reports any remaining use of `.cyrillic` / `.english` / `.audioAssetPath` on a `Word`, that's an un-migrated caller — fix it to the matching accessor (`text('mn')` / `text(glossLanguage)` / `audioPath('mn')`). Confirm via grep that no `.english`/`.cyrillic`/`.audioAssetPath` remains on a Word anywhere in `lib/` (note: `Letter.cyrillic` and `Sticker`/`Letter` paths are fine — only `Word` lost those members).

Run: `flutter test`
Expected: all pass.

- [ ] **Step 7: Build the web bundle + manual walk**

Run: `flutter build web --debug`
Expected: builds. Serve it on a fresh port and confirm in the browser, unchanged from before:
- **Letter А** lesson: the Read activity shows "Аав"/"Ах" (the mn text) as the big word; Listen/Read tiles show English glosses ("father", "older brother"); audio buttons work (silent stubs, no crash).
- **My Family**: Listen/Read tiles show the English glosses; bears render.
- Region screen word previews read in English (e.g. "father · mother · …").

**Checkpoint:** Vocabulary is now language-agnostic behind `learningLanguageProvider`; behavior unchanged. Pause to commit.

---

## Self-review (done at write time)

- **Spec coverage:** WordLocalization + Word.localizations + accessors (T1 S3-4); ContentRepository build + required-language validation (T1 S7,10-11); content.json + fixtures migration (T1 S8-10); language seam `learningLanguageProvider`+`glossLanguage` (T2 S1); widget migration read/listen/region (T2 S2-4); removed `cyrillic`/`english`/`audioAssetPath` (T2 S5); tests (T1 S1,11). Letters untouched; no schema-version. All spec sections map to a step.
- **Placeholders:** none — every step has concrete code/JSON.
- **Type consistency:** `WordLocalization{text, audioAssetPath?}`, `Word{id, imageAssetPath, letterIds, localizations}`, accessors `text(String)`/`audioPath(String)`, `glossLanguage`/`learningLanguageProvider` used identically across model, repo, and widgets. Temp getters exist only in T1 and are removed in T2 S5. Required-language constant `_requiredWordLanguages = ['mn','en']` matches the `glossLanguage='en'` + learning-default `'mn'`.
