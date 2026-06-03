# Bambaruush v1 — Design Spec

**Date**: 2026-05-27
**Status**: Approved for implementation planning
**Scope**: v1 only. v2 (auth, cloud sync, conflict resolution) is explicitly out of scope and will get its own spec.

## 1. Product summary

Bambaruush is a Flutter mobile app that teaches Mongolian (Cyrillic) to English-speaking kids age 7+. v1 is a single themed world — "The Steppe" — that introduces ~35 Cyrillic letters and ~30-40 animal/nature vocabulary words through three mini-games, with a teddy-bear mascot ("Bambaruush") guiding the kid.

The whole experience is **offline**, **single-profile**, **single-device**. No accounts, no network, no analytics in v1.

### Audience cuts and v1 scope decisions

| Decision | Choice | Rationale |
|---|---|---|
| Lesson structure | Letter(s) + 2-3 themed words per lesson, ~12-15 lessons | Tight integration of alphabet and vocab; small dedicated unit per session |
| Mini-games | tap-the-picture (read), listen-and-tap (listen), trace-the-letter (write) | Three distinct skills, fixed pedagogy per lesson |
| Audio | Native speaker recordings, bundled in `assets/audio/` | Quality matters for language acquisition; ~75 clips is manageable |
| Mascot | Persistent guide + reactor on most screens, animated via Rive | One rig, multi-state state machine |
| SRS | Leitner box, 5 levels, fixed intervals | Transparent; easy to debug; appropriate depth for age 7 |
| Stickers | Album collection; one unique sticker per lesson completed | Simple, satisfying, no further interaction needed |
| Profiles | **Single profile in v1** (scope cut from original plan) | Multi-profile deferred to v1.1; reduces v1 data model + UI work |
| Home/map layout | Illustrated Steppe with ~4 named locations clustering lessons | More immersive than a list; matches the "Steppe world" framing |
| Lesson flow | Fixed pedagogy: Intro → Trace → Listen → Read → Reward | Predictable for kids; consistent shape across lessons |
| Trace evaluation | Lenient bitmap coverage; second attempt always passes | Fits fine-motor variability at age 7 |
| Platforms | iOS + Android, portrait only, English UI | Mongolian is the *learning target*, not the UI language |

### Tech stack (locked)

- Flutter 3.x with Dart
- Riverpod 2.x for state management
- go_router for navigation
- flutter_animate for micro-animations
- Rive for the mascot
- just_audio for audio playback
- freezed + json_serializable for immutable models with codegen
- JSON file in app documents dir for progress persistence
- `flutter_test` + `integration_test` for tests

## 2. Architecture

### Module layout

```
lib/
├── main.dart            bootstrap: load content, load progress, runApp
├── app.dart             ProviderScope, MaterialApp.router, theme
├── core/
│   ├── audio/           AudioService (preload, play, stop)
│   ├── content/         ContentRepository (load JSON → typed models)
│   ├── persistence/     ProgressRepository (atomic JSON file I/O)
│   ├── srs/             LeitnerEngine (pure functions over Progress)
│   └── routing/         go_router config
├── features/
│   ├── steppe/          SteppeMapScreen + region/lesson providers
│   ├── lesson/          LessonRunner notifier + stage widgets
│   ├── stickers/        StickerAlbumScreen + provider
│   ├── mascot/          MascotProvider + MascotOverlay (Rive)
│   └── settings/        SettingsScreen + ParentGate
└── models/              Letter, Word, Lesson, Region, Progress,
                         SrsBox, Sticker, MascotMood
```

### Dependency rule

- `features/*` → may depend on `core/*` and `models/*`.
- `core/*` → may depend on `models/*`. `core/*` modules do not depend on each other (LeitnerEngine is pure; ContentRepository is read-only; ProgressRepository persists Progress; AudioService is self-contained).
- `features/*` → never imports another feature directly. State sharing only via Riverpod providers exposed in each feature's folder.

Enforced by import discipline + an optional `custom_lint` rule later (not in v1 scope).

## 3. Data model

### Content (read-only, loaded once from bundled JSON)

```dart
class Letter {
  String id;                // "letter_a"
  String cyrillic;          // "А"
  String romanization;      // "A"
  String audioAssetPath;    // resolved: "assets/audio/letter_a.mp3"
  String traceTemplatePath; // resolved: "assets/trace_masks/letter_a.png"
}

class Word {
  String id;                // "word_aav"
  String cyrillic;          // "Аав"
  String english;           // "father"
  String audioAssetPath;
  String imageAssetPath;
  List<String> letterIds;
}

class Lesson {
  String id;                // "lesson_01"
  int order;                // 1
  String regionId;
  List<String> letterIds;   // the letter(s) introduced
  List<String> wordIds;     // 2-3 words
  String stickerId;
}

class Region {
  String id;                // "region_yurt"
  String nameEn;            // "The Yurt"
  String nameMn;            // "Гэр"
  int order;
  String mapImagePath;
  Offset mapPosition;       // normalized 0..1 on the Steppe map
}

class Sticker {
  String id;
  String lessonId;
  String imageAssetPath;
  String nameEn;
}
```

### Runtime / persisted

```dart
class Progress {
  Map<String, LessonProgress> lessons;   // by lesson id
  Map<String, SrsBox> srsByWord;          // by word id
  Set<String> earnedStickerIds;
  int schemaVersion;                      // = 1 in v1
  DateTime lastPlayed;
}

class LessonProgress {
  String lessonId;
  bool unlocked;
  bool completed;
  int completionCount;
  DateTime? completedAt;
}

class SrsBox {
  String wordId;
  int level;                   // 1..5
  DateTime nextReviewAt;
  int correctStreak;
}

enum MascotMood { idle, cheer, sad, point, sleep, wave }
```

## 4. Content authoring schema

Single bundled file: `assets/content/content.json`.

```json
{
  "schemaVersion": 1,
  "regions": [
    { "id": "region_yurt", "nameEn": "The Yurt", "nameMn": "Гэр",
      "order": 1, "mapPosition": [0.18, 0.62] }
  ],
  "letters": [
    { "id": "letter_a", "cyrillic": "А", "romanization": "A",
      "audio": "letter_a.mp3", "traceMask": "letter_a.png" }
  ],
  "words": [
    { "id": "word_aav", "cyrillic": "Аав", "english": "father",
      "audio": "word_aav.mp3", "image": "word_aav.png",
      "letterIds": ["letter_a", "letter_v"] }
  ],
  "lessons": [
    { "id": "lesson_01", "order": 1, "regionId": "region_yurt",
      "letterIds": ["letter_a"], "wordIds": ["word_aav", "word_aaw"],
      "stickerId": "sticker_aav" }
  ],
  "stickers": [
    { "id": "sticker_aav", "lessonId": "lesson_01",
      "image": "sticker_aav.png", "nameEn": "Father Bear" }
  ]
}
```

**Asset path resolution**: JSON stores filenames only. `ContentRepository` prepends conventional prefixes when building model objects:
- `audio` → `assets/audio/<filename>`
- `image` (word) → `assets/images/words/<filename>`
- `image` (sticker) → `assets/images/stickers/<filename>`
- `traceMask` → `assets/trace_masks/<filename>`

**Validation at load time** (fatal startup error if any fail):
- Every `lesson.letterIds`, `wordIds`, `stickerId` resolves.
- Every `word.letterIds` resolves.
- Every `sticker.lessonId` resolves.
- `lessons` and `regions` have unique, contiguous `order` starting from 1.
- All asset paths resolve (rootBundle check at startup).

**Region grouping for v1** (final assignment authored alongside content):
- Yurt — lessons 1-4 (family/home letters)
- River — lessons 5-8 (water/animals)
- Mountain — lessons 9-12 (terrain/sky)
- Eagle's Nest — lessons 13-15 (final letters + mastery)

## 5. Routes and screen flow

`go_router`. Flat routes:

```
/                     SplashScreen
/steppe               SteppeMapScreen
/region/:id           RegionDetailScreen
/lesson/:id           LessonRunnerScreen
/album                StickerAlbumScreen
/settings             SettingsScreen
/settings/gate        ParentGateScreen
```

### Flow

```
Splash ──preload──► Steppe ──tap region──► RegionDetail ──tap lesson──► LessonRunner
              ⚙       │                                                    │
              ▼       └── tap album ──► StickerAlbum                       ▼
        ParentGate                                                     Reward
              │                                                            │
              ▼                                                            ▼
        Settings                                                      RegionDetail
                                                                      (sticker added,
                                                                       next lesson unlocked)
```

### Splash behavior

- Loads + validates `content.json`.
- Loads `progress.json` (creates fresh `Progress.empty()` if missing).
- Preloads audio for lesson 1's letter + words (first-launch only; later launches preload around `lastPlayed`).
- Shows mascot idle animation and a quiet loading indicator.
- On fatal content/asset error: single error screen ("Something went wrong — restart the app").

### Lesson navigation contract

- `LessonRunnerScreen` is one route; stages are body swaps, not route changes.
- Hardware back button mid-lesson → "Quit lesson?" confirm. Yes → exit to RegionDetail without saving partial progress for the in-flight stage (already-completed stages of this attempt are not persisted; the lesson restarts next time).
- Reward stage tap-to-continue → pops back to RegionDetail. Sticker appears in album, lesson marked complete, next lesson unlocked.

### Unlock rule

Lesson N+1 unlocks when lesson N is marked complete. First lesson (order=1) always unlocked. Locking is global ordinal, not per-region — the Steppe is one ordered sequence visually grouped into regions.

## 6. LessonRunner and mini-game contracts

### State machine

```dart
sealed class LessonStage {}
class IntroStage    extends LessonStage { String letterId; }
class TraceStage    extends LessonStage { String letterId; }
class ListenStage   extends LessonStage {
  String wordId;
  List<String> distractorWordIds;
  int attempt;
}
class ReadStage     extends LessonStage {
  String wordId;
  List<String> distractorWordIds;
  int attempt;
}
class RewardStage   extends LessonStage { String stickerId; }
class LessonComplete extends LessonStage {}

class LessonRunnerState {
  Lesson lesson;
  LessonStage stage;
  int totalSteps;
  int currentStep;
  Map<String, bool> wordCorrectness; // wordId -> got it right on FIRST attempt of BOTH listen + read
}
```

### Step sequence (computed once at lesson start)

For each letter in `lesson.letterIds`: Intro, Trace.
For each word in `lesson.wordIds`: Listen.
For each word in `lesson.wordIds`: Read.
Then: Reward.

Example for 1 letter + 3 words: Intro, Trace, Listen×3, Read×3, Reward = 9 steps.

### Distractor selection (pure function)

```
pickDistractors(targetWordId, lesson, allWords, n=2) -> List<wordId>
```

1. Candidates = words in the same region as `lesson`, minus `targetWordId`.
2. If fewer than `n`, top up from any other region's words.
3. Shuffle with a seed derived from `(lessonId, targetWordId, stageType)` for deterministic tests; in production seed from `DateTime.now().microsecondsSinceEpoch` for variety.

### Stage widget contract

Each stage widget is a `ConsumerWidget` that:
1. Reads its inputs from `LessonRunnerState.stage` (already cast to its specific subtype by the parent).
2. Calls `runner.advance(correct: bool)` when the kid finishes the stage.
3. Triggers mascot reactions via `ref.read(mascotProvider.notifier)`.

### TraceStage

- `CustomPaint` canvas. Background: faded letter sprite from `traceMask` (alpha multiplied).
- `GestureDetector` accumulates a `List<List<Offset>>` of strokes.
- "Done" tap or 2 s of inactivity triggers evaluation:
  - Rasterize strokes to a 256×256 binary mask.
  - Load the trace template mask (alpha channel as binary).
  - Compute `insideRatio = (strokes ∩ template) / template_pixels`.
  - Compute `outsideRatio = (strokes − template) / strokes_pixels` (0 if no strokes).
  - Pass if `insideRatio ≥ 0.6` AND `outsideRatio ≤ 0.4`.
- Attempt 1 pass: advance, `correct: true`.
- Attempt 1 fail: bear says "try again"; canvas clears; attempt 2 begins.
- Attempt 2: always advances. `correct: false` regardless of whether attempt 2 passed the metric. (First-attempt correctness is what SRS sees; second-attempt success keeps the lesson moving but doesn't reward.)

### ListenStage

- Auto-plays target word audio on enter.
- Three image tiles in a row: target + 2 distractors (shuffled).
- Replay-audio button always visible.
- Tap correct on attempt 1 → mascot cheer, advance `correct: true`.
- Tap wrong on attempt 1 → mascot sad, replay target audio, tiles stay, attempt 2 begins.
- Attempt 2 (any tap) → highlight correct tile for 1 s, advance `correct: false`.

### ReadStage

- Same as ListenStage except:
  - Top of screen shows the target word in Cyrillic.
  - Audio does *not* auto-play (this is a reading game). Replay button still present.
  - Otherwise identical behavior.

### Scoring + SRS hand-off at lesson end

For each word in `lesson.wordIds`:
- `wordCorrectness[wordId]` = true iff Listen first-attempt correct AND Read first-attempt correct.
- Apply `LeitnerEngine.onCorrect` (true) or `onWrong` (false) to the word's `SrsBox`, creating it if not present.
- Single SRS update per word per lesson — no mid-lesson bouncing.

After SRS updates: mark `LessonProgress.completed = true`, set `completedAt`, add `stickerId` to `earnedStickerIds`, set `lessons[orderN+1].unlocked = true` if present. Persist via `ProgressRepository.save`.

## 7. SRS — Leitner engine

```dart
class LeitnerEngine {
  static const intervals = {
    1: Duration(days: 1),
    2: Duration(days: 3),
    3: Duration(days: 7),
    4: Duration(days: 14),
    5: Duration(days: 30),
  };

  static SrsBox initial(String wordId) => SrsBox(
    wordId: wordId, level: 1,
    nextReviewAt: DateTime.now(),
    correctStreak: 0,
  );

  static SrsBox onCorrect(SrsBox box, DateTime now) {
    final newLevel = (box.level + 1).clamp(1, 5);
    return box.copyWith(
      level: newLevel,
      nextReviewAt: now.add(intervals[newLevel]!),
      correctStreak: box.correctStreak + 1,
    );
  }

  static SrsBox onWrong(SrsBox box, DateTime now) => box.copyWith(
    level: 1,
    nextReviewAt: now.add(intervals[1]!),
    correctStreak: 0,
  );

  static bool isDue(SrsBox box, DateTime now) => !now.isBefore(box.nextReviewAt);
}
```

**v1 surface**: boxes are recorded silently. A "Review" entry point on the Steppe map that pulls `isDue` words is **out of scope for v1**, but the data model and engine support it without any change for v1.1.

## 8. Mascot system

```dart
class MascotController extends StateNotifier<MascotMood> {
  MascotController() : super(MascotMood.idle);
  void cheer() => _set(MascotMood.cheer, autoReset: true);
  void sad()   => _set(MascotMood.sad,   autoReset: true);
  void point() => _set(MascotMood.point, autoReset: true);
  void wave()  => _set(MascotMood.wave,  autoReset: true);
  void sleep() => _set(MascotMood.sleep, autoReset: false);
  void idle()  => _set(MascotMood.idle,  autoReset: false);
  // 2s auto-reset for transient moods
}

final mascotProvider = StateNotifierProvider<MascotController, MascotMood>((_) => MascotController());
```

- One Rive file: `assets/rive/bambaruush.riv`.
- One state machine with an integer input `mood` mapped from `MascotMood.index`.
- `MascotOverlay` widget wraps the app shell (in `app.dart`) and renders the bear in a corner. Listens to `mascotProvider`.
- Any screen can `ref.read(mascotProvider.notifier).cheer()` etc.

## 9. Audio

`AudioService` wraps `just_audio`. Single shared `AudioPlayer` instance.

```dart
class AudioService {
  Future<void> preload(List<String> assetPaths);
  Future<void> play(String assetPath);
  Future<void> stop();
  void setVolume(double v);  // 0..1
}
```

- Per-lesson preload at lesson start (~4-6 clips for 1 letter + 3 words).
- Playing a new clip stops the previous (no overlap when kid taps replay).
- Volume sourced from `SettingsProvider`. Default 1.0. Persisted alongside Progress (in the same JSON file under a `settings` key).
- iOS audio session category: ambient (does not interrupt music from other apps).

## 10. Assets

```
assets/
  content/
    content.json
  audio/
    letter_*.mp3
    word_*.mp3
  images/
    words/             word_*.png
    stickers/          sticker_*.png
    regions/           region_*.png
    steppe_map.png     home-screen background
  trace_masks/
    letter_*.png       alpha-channel template
  rive/
    bambaruush.riv
```

Declared in `pubspec.yaml` under `flutter.assets`. All bundled — zero network in v1.

## 11. Persistence

`ProgressRepository` reads/writes a single file: `<getApplicationDocumentsDirectory()>/progress.json`.

```dart
class ProgressRepository {
  Future<Progress> load();        // returns Progress.empty() if file missing
  Future<void> save(Progress p);   // atomic via .tmp + rename
  Future<void> reset();            // deletes the file
}
```

- **Atomic write**: write to `progress.json.tmp`, then rename to `progress.json`. POSIX rename is atomic; safe across crash.
- **Schema version**: `Progress.schemaVersion = 1`. On mismatch at load → log and treat as fresh start.
- **Write cadence**: after each stage completion in `LessonRunner` and after every sticker earn (~2 kB writes; cheap).
- **Settings** (volume) persisted in the same file under a `settings` key for v1 simplicity.

## 12. Error handling

| Source | Class of error | Response |
|---|---|---|
| Splash | `content.json` validation failure | Fatal "Restart the app" screen with sad mascot. CI-tested away. |
| Splash | Asset file missing (audio/image referenced by content not present) | Same as above. CI-tested. |
| Runtime | `progress.json` parse fails | Log; treat as fresh start; show first-launch flow. |
| Runtime | Audio playback failure | Skip silently; lesson advances without audio. Logged for diagnostics. |
| Runtime | Any other uncaught | Flutter default error reporter (red screen in dev; logged + swallowed in release). |

No try/catch sprinkled in feature code. Errors are caught at the source (repository / service layer); above that, exceptions propagate to Flutter.

## 13. Testing strategy

| Layer | Tests | Tool |
|---|---|---|
| `LeitnerEngine` | Pure-function: promote, demote, due-date math, clamp at 5 | `flutter test` |
| `ContentRepository` | Loads valid fixture JSON; rejects each invalid fixture (missing refs, dup ids, non-contiguous order) | `flutter test` |
| `ProgressRepository` | Round-trip, atomic write, corrupted-file recovery, fresh-start path | `flutter test` (tmp dir) |
| `LessonRunner` | Drive fake lessons; assert stage sequence; correct/wrong paths; final score and SRS updates | `flutter test` |
| `pickDistractors` | Determinism with seed; falls back across regions when needed | `flutter test` |
| Stage widgets | Smoke tests for tap → callback wiring | `flutter test` |
| End-to-end | First launch → finish lesson 1 → sticker earned → lesson 2 unlocked | `integration_test` |

**Coverage target**: 100% on `core/` (pure logic). Best-effort on `features/` — widget tests focus on wiring, not pixel layout.

## 14. Out of scope for v1 (explicitly)

- Multiple user profiles on one device → v1.1
- "Review" screen pulling SRS-due words → v1.1
- Settings analytics / event logging → v2
- Authentication, accounts, parental dashboard → v2
- Cloud sync, conflict resolution, content hot-updates → v2
- Localization of UI strings (UI stays English in v1) → future
- Tablet-specific layouts (portrait phone layouts also work on tablets in v1) → future
- Younger-kid mode (picture/audio-only, no English) → future
- Adult/intermediate content → future

## 15. Open production questions (not blocking design)

These don't affect code structure but will need answers before the app can ship:

- Native speaker recording producer + schedule.
- Illustrator/animator for the Steppe map, region backgrounds, word images, stickers, and Rive bear rig.
- Final region → lesson assignment + final word list per lesson.
- App store metadata, age rating submissions (COPPA-relevant; v1 has no data collection, which simplifies this).

These will be tracked alongside but separately from the implementation plan.
