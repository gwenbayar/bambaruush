# Slice 5 — Daily Warm-Up — Design Spec

**Date**: 2026-06-05
**Status**: Approved for implementation
**Parent spec**: `docs/superpowers/specs/2026-06-02-modular-games-and-review-design.md` (Slice 5 of its build order, §7)
**Builds on**: Slice 4 (`docs/superpowers/specs/2026-06-03-slice-4-review-session-design.md`) — `ReviewMode`, `reviewRunnerProvider`, `ReviewSession.due/.free`, `reviewQueueProvider`/`freePracticeProvider`, the shared runner/activities and `ReviewCompleteSpec` celebration.
**Branch**: `slice-5-warmup` (off `main`, now that Slices 1–4 are merged)

## 1. Purpose

Add an **optional once-a-day warm-up**: after the splash, if there's something to practice and the child hasn't warmed up today, the mascot offers a quick warm-up — completing it reviews due items (or recently-learned ones) and ends with an encouraging celebration. It's never forced (Skip → straight to the map), and the always-available Practice landmark (Slice 4) is unaffected.

This builds the daily-habit **mechanic** and deliberately leaves the **reward payload light**: warm-up completion currently shows the existing stars celebration only. The motivating collectible reward (house accessories / decorations / upgrades) is the **next design track** (the bear-home subsystem); Slice 5 records `warmupCount` + `lastWarmupAt` and exposes the completion hook as the clean seam that reward will plug into — so we build nothing here that gets thrown away.

The warm-up reuses the entire Slice 4 review flow via a new `ReviewMode.warmup`; the only genuinely new surfaces are the prompt screen and a splash-time routing check.

## 2. Locked decisions

1. **Reward is deferred (temporary resolution).** Warm-up completion grants **no collectible yet** — it reuses Slice 4's `ReviewCompleteSpec` stars celebration. `warmupCount` + the `_persistWarmup` hook are the seam where the future house-accessory reward attaches. (Explicitly *not* building a daily-sticker system that the house reward would replace.)
2. **Once per day.** At most one prompt per calendar day. An explicit **Skip** or a **completion** stamps `lastWarmupAt` and closes the day; merely bailing (closing the app at the prompt) may re-offer next launch.
3. **Appears from day one.** The warm-up reviews **due items if any, else free-practice** of learned items — usable immediately, not only once items come due. (No learned items at all → no prompt.)
4. **Schema change is a clean fresh-start** on version mismatch (no real users) — no migration, same as Slice 3.

## 3. Flow

```
Splash (after load)
  └─ shouldOfferWarmup(lastWarmupAt, now, hasPracticeItems)?
       ├─ no  → /steppe
       └─ yes → /warmup  (WarmupPromptScreen: "Ready for a quick warm-up?")
                  ├─ Skip → stamp lastWarmupAt=now → /steppe
                  └─ Yes  → /review?warmup=1  (ReviewRunnerScreen, warmup mode)
                              → review due-or-free items
                              → ReviewCompleteSpec (stars celebration)
                              → on complete: SRS update + warmupCount++ + lastWarmupAt=now
                              → /steppe
```

- **`hasPracticeItems`** = `reviewQueueProvider` (due) non-empty **OR** `freePracticeProvider` (learned) non-empty.
- Warm-up items = **due if any, else free-practice**, capped at 8 (the existing `ReviewSession.sessionCap`). Both paths already end in `ReviewCompleteSpec` — no new session factory or celebration widget.

## 4. Reward seam (what the house feature will plug into)

Slice 5 intentionally ships the mechanic without a collectible. The seam for the future reward is concrete:

- **`Progress.warmupCount`** — total completed warm-ups (a natural driver for "grant the Nth accessory", milestones, etc.).
- **`_persistWarmup`** (the warm-up completion handler) — the single place where, later, the house feature adds `inventory`/accessory grants alongside the SRS update.
- **`ReviewCompleteSpec`** celebration — later swappable for an accessory-reward view (the same way `RewardSpec`/`RewardActivityView` shows lesson stickers), or the warm-up sequence can append a future `AccessoryRewardSpec`.

No `Sticker`/content/album changes in this slice.

## 5. Progress & persistence

`Progress` gains:
```dart
DateTime? lastWarmupAt;          // once-a-day gate; stamped on Skip or completion
@Default(0) int warmupCount;     // total completed warm-ups (reward seam + telemetry)
```
Bump `schemaVersion` 2 → 3 (`Progress.empty()` + `ProgressRepository._currentSchemaVersion`). On mismatch the repo already returns `Progress.empty()` — existing progress resets cleanly, no migration.

## 6. Warm-up logic (pure, testable)

`lib/features/warmup/warmup_logic.dart`:
```dart
/// Same calendar day in local time (null a → false).
bool isSameDay(DateTime? a, DateTime b) =>
    a != null && a.year == b.year && a.month == b.month && a.day == b.day;

/// Offer the daily warm-up when there's something to practice and we haven't
/// already warmed up (or skipped) today.
bool shouldOfferWarmup({
  required DateTime? lastWarmupAt,
  required DateTime now,
  required bool hasPracticeItems,
}) => hasPracticeItems && !isSameDay(lastWarmupAt, now);
```

## 7. Reuse: `ReviewMode.warmup`

- **`enum ReviewMode { due, free, warmup }`** (extends the Slice 4 enum).
- **`reviewRunnerProvider(ReviewMode.warmup)`**: items = `reviewQueueProvider` if non-empty else `freePracticeProvider`; build the matching existing session — `ReviewSession.due(items, …)` when due, else `ReviewSession.free(items, …)`. (No new `ReviewSession` factory; the warm-up sequence is an ordinary review ending in `ReviewCompleteSpec`.)
- `ReviewSession` and the activity library are **unchanged**.

## 8. `ReviewRunnerScreen` in warmup mode

`ReviewRunnerScreen` gains an optional `bool warmup` (from the `/review?warmup=1` query param):
- **warmup = true:** no gate — always run, mode `ReviewMode.warmup`. (Guard: if both due and free pools are somehow empty, just `context.go('/steppe')` — normally prevented by the splash check.)
- On `SessionComplete`, persist via **`_persistWarmup`** instead of `_persistReview`:
  ```dart
  await update(progress.copyWith(
    srsByItem: applySessionToSrs(current: progress.srsByItem, itemCorrectness: s.itemCorrectness, now: now),
    warmupCount: progress.warmupCount + 1,
    lastWarmupAt: now,
    lastPlayed: now,
  ));
  ```
  (No reward grant yet — that's the seam §4. SRS still updates exactly as a normal review.)
- **Navigation differs by entry path:** warmup mode is reached via `context.go` (splash → `/warmup` → `/review?warmup=1`), so its exits — completion **and** the quit/close button — use `context.go('/steppe')`, not `context.pop()`. due/free modes (reached via `push` from the map landmark) keep `context.pop()`. So all exit points check `warmup ? context.go('/steppe') : context.pop()`.
- **due/free modes** (Slice 4) are unchanged — still `_persistReview` (SRS only).

## 9. Prompt screen + routing

- **`/warmup` → `WarmupPromptScreen`** (new, `features/warmup/`): mascot + *"Ready for a quick warm-up?"* with **Yes** (`context.go('/review?warmup=1')`) and **Maybe later** (stamp `lastWarmupAt=now` via `progressController.update(progress.copyWith(lastWarmupAt: now))`, then `context.go('/steppe')`). A `PopScope`/system-back behaves as Skip.
- **`/review` route** gains the `warmup` query param: `ReviewRunnerScreen(warmup: state.uri.queryParameters['warmup'] == '1')`.
- **`SplashScreen`**: after the existing delay, read `progressControllerProvider` + `reviewQueueProvider` + `freePracticeProvider`, compute `shouldOfferWarmup(...)`, and `context.go('/warmup')` or `context.go('/steppe')`.

## 10. Module structure

```
NEW  lib/features/warmup/warmup_logic.dart          isSameDay, shouldOfferWarmup (pure)
NEW  lib/features/warmup/warmup_prompt_screen.dart  WarmupPromptScreen (mascot offer)
MOD  lib/models/progress.dart                          + lastWarmupAt, warmupCount; schemaVersion 3
MOD  lib/core/persistence/progress_repository.dart     _currentSchemaVersion = 3
MOD  lib/features/review/review_runner_screen.dart     ReviewMode.warmup, warmup flag, _persistWarmup, go-navigation
MOD  lib/features/steppe/splash_screen.dart            shouldOfferWarmup routing
MOD  lib/core/routing/app_router.dart                  + /warmup, /review?warmup= param
```

(No `Sticker`, `content_repository`, `content.json`, `review_session`, or album changes — the reward is deferred.)

## 11. Testing (logic is pure → cheap)

- **`shouldOfferWarmup`**: same-day `lastWarmupAt` → false; different day → true; null → true; `hasPracticeItems == false` → false regardless.
- **`isSameDay`**: same y/m/d true; different day false; null → false; near-midnight boundary.
- **`Progress`**: round-trips `lastWarmupAt` + `warmupCount`; schema-bump → fresh-start path green.
- **Warm-up persistence** (the `_persistWarmup` computation, extracted as a pure helper returning the next `Progress` if practical): a completion produces the SRS update + `warmupCount+1` + `lastWarmupAt`, and does **not** touch `lessons`/`earnedStickerIds`.
- **Regression**: `reviewRunnerProvider` due/free paths and `ReviewSession.due/.free` ending in `ReviewCompleteSpec` stay green (warm-up reuses them).
- Screen/widget tests omitted (Image.asset + GoRouter hang in `flutter_test`, per prior slices) — verify UI via `flutter analyze` + a `flutter build web --debug` smoke.

## 12. Out of scope (deferred)

- **The warm-up reward** — house accessories / decorations / upgrades. This is the **next design track** (the bear-home subsystem). Slice 5's `warmupCount` + `_persistWarmup` are the seam it attaches to; revisit the celebration (swap `ReviewCompleteSpec` for an accessory reward) then.
- **Streaks** (consecutive-day counter + UI) — `warmupCount`/`lastWarmupAt` leave room; not built now.
- No change to lessons or the manual Practice landmark; warm-up is purely additive.
