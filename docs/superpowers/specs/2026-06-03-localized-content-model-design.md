# Slice 2 — Localization-Ready Content Model — Design Spec

**Date**: 2026-06-03
**Status**: Approved for implementation
**Parent spec**: `docs/superpowers/specs/2026-06-02-modular-games-and-review-design.md` (this is Slice 2 of its build order; see §5 there)
**Branch**: `slice-2-localization` (stacked on `slice-1-activity-session` until Slice 1 merges)

## 1. Purpose

Make **vocabulary** language-agnostic so adding a new learning language later is "supply that language's `text` + `audio` per word" — no code changes. Do it now, while content is ~3 lessons and cheap to migrate. **Net behavior is unchanged** (still Mongolian learning target, English glosses); this is a structural refactor that installs the language seam.

Per the parent spec's honest-costs note: this makes **vocabulary** plug-and-play. The two real costs of multi-language (per-language **audio recordings**, and the per-script **alphabet/tracing track**) are *not* in scope and are unaffected by this refactor.

## 2. Locked decisions

1. **Words only.** `Word` gets a localized model. **`Letter` is untouched** — the alphabet is the script itself (a per-language track), not translatable vocabulary.
2. **English is just the `en` localization entry.** The neutral anchor is the existing `Word.id`; every language (including English) lives in one `localizations` map.
3. **One language seam now:** a `learningLanguageProvider` (default `'mn'`) selects the taught language; English is the fixed gloss/UI language via `const glossLanguage = 'en'`. A separate user-facing UI-language axis is deferred (documented, not built).
4. **No neutral `key` field yet** — `id` is the anchor. The full `Concept` taxonomy (`key`, `category`) is the later Slice 5.
5. **No persistence/migration concern.** Content is bundled (loaded from `assets/content/content.json`), not stored in `Progress`. We rewrite the file + test fixtures; no schema-version bump.

## 3. Model (`lib/models/`)

```dart
@freezed
class WordLocalization with _$WordLocalization {
  const factory WordLocalization({
    required String text,            // e.g. "Аав" (mn) / "father" (en)
    String? audioAssetPath,          // resolved "assets/audio/…"; null when no recording (e.g. en gloss)
  }) = _WordLocalization;
  factory WordLocalization.fromJson(...) => ...;
}

@freezed
class Word with _$Word {
  const factory Word({
    required String id,                                   // stable anchor (e.g. "word_aav")
    required String imageAssetPath,                       // language-neutral
    required List<String> letterIds,
    required Map<String, WordLocalization> localizations, // { "mn": {...}, "en": {...} }
  }) = _Word;
  factory Word.fromJson(...) => ...;
}

extension WordText on Word {
  String text(String lang) => localizations[lang]!.text;          // validated present (see §4)
  String? audioPath(String lang) => localizations[lang]?.audioAssetPath;
}
```

**Removed** from `Word`: `cyrillic`, `english`, `audioAssetPath`. Callers move to `text(lang)` / `audioPath(lang)`. `image`/`letterIds` stay.

## 4. Content schema + `ContentRepository`

Each word in `assets/content/content.json` becomes:

```json
{
  "id": "word_aav",
  "image": "word_aav.png",
  "letterIds": ["letter_a"],
  "localizations": {
    "mn": { "text": "Аав", "audio": "word_aav.mp3" },
    "en": { "text": "father" }
  }
}
```

`ContentRepository._wordFromRawJson` builds the `localizations` map, resolving each entry's `audio` filename to `assets/audio/<file>` (omit `audioAssetPath` when `audio` is absent). `imageAssetPath` resolution unchanged. **Letter parsing unchanged.**

**New validation** (consistent with existing fatal-at-load checks): every word must contain the required language keys — at minimum `'mn'` (learning) and `'en'` (gloss). Missing → `ContentValidationError`. This lets `text(lang)` safely return non-null for those languages.

## 5. Language seam

```dart
// lib/core/i18n/language.dart  (or core/providers.dart)
const String glossLanguage = 'en';                 // fixed UI/meaning language for now
final learningLanguageProvider = StateProvider<String>((_) => 'mn');
```

Consumers read `ref.watch(learningLanguageProvider)` for the taught text/audio and use `glossLanguage` for labels. (Provider, not const, so a future settings screen can switch it — that's the seam.)

## 6. Code touch points (small, mechanical)

| File | Change |
|---|---|
| `lib/features/lesson/read_activity.dart` | target cyrillic → `word.text(learningLang)`; audio → `word.audioPath(learningLang)`; tile labels → `word.text(glossLanguage)` |
| `lib/features/lesson/listen_activity.dart` | auto-play + replay → `word.audioPath(learningLang)`; tile labels + image fallback → `word.text(glossLanguage)` |
| `lib/features/steppe/region_detail_screen.dart` | word-preview `word.english` → `word.text(glossLanguage)` |
| `lib/features/lesson/lesson_session.dart`, `distractors.dart`, SRS, stickers/reward/album | **unaffected** (operate on ids / stickers, not word text) |
| `lib/features/lesson/intro_activity.dart`, `trace_activity.dart` | **unaffected** (Letter not touched) |

The widgets are `ConsumerStatefulWidget`s already, so reading `learningLanguageProvider` via `ref` is available. Audio is null-safe: if `audioPath` returns null, skip playback (AudioService already swallows failures; guard the call).

## 7. Testing

- **New** `test/models/word_localization_test.dart`: `text('mn')`/`text('en')` return the right strings; `audioPath('mn')` resolves the prefixed path; `audioPath('en')` is null.
- **Update** `ContentRepository` tests + the `test/fixtures/content_*.json` word entries to the localized shape; add a fixture/test for the new "word missing required language" validation error.
- `learningLanguageProvider` default is `'mn'` (a trivial provider test or covered via widget behavior).
- All existing tests stay green; `flutter analyze` clean; `flutter build web --debug` succeeds.

## 8. Out of scope (explicit)

- Letters / alphabet / tracing (per-script track).
- Per-language audio recordings (content production).
- A user-facing language switcher UI / UI-language axis.
- The full `Concept` taxonomy (`key`, `category`, verbs/colors/places) — Slice 5.
- SRS generalization, review, warm-up — Slices 3-5.
