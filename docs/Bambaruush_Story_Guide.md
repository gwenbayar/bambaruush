# Bambaruush — Story Guide

> **What this file is.** The single source of truth for the world, characters, narrative, reward system, and game rules of **Bambaruush** (Бамбаруш), a Mongolian language-learning app for young children. Optimized as a reference for an AI coding agent and the dev/content team: canonical names are stable and greppable, facts live in tables, and game logic is stated as invariants. When code or content conflicts with this file, this file wins (or update this file deliberately).

> **Tagline / core message:** *Every light shines its own way.*

> **Localization invariant:** All Mongolian strings (names, words, audio) are working drafts and MUST be verified by a native speaker before shipping. Cyrillic is the canonical script.

---

## 0. Quick reference (read first)

| Key fact | Value |
|---|---|
| App name | Bambaruush (Бамбаруш) — "little bear cub" |
| Species | Mazaalai (Mongolian Gobi bear) |
| Protagonist | **Od** (Од) — "star", youngest cub, ~5, **gender open** |
| Setting | A ger on the Mongolian steppe, across one turning year |
| Core message | "Every light shines its own way" |
| Spendable currency | **Odon** (одон, "medal/order") — single symbol, single wallet |
| Permanent progression | **Sky-stars** — earned by mastering words, never purchasable, never spent |
| Mini-game frames | 7 fixed templates, each owned by a family member (see §6) |
| Reward unlock model | Staged rings: siblings → parents → elders (see §7) |
| Endgame star | **Altan Gadas** (North Star), earned when Od can "guide the family" |

### Canonical names (use these exact spellings in code/content)

| Code key | Cyrillic | Latin | Meaning / role |
|---|---|---|---|
| `od` | Од | Od | "Star" — youngest cub, protagonist, gender open |
| `nar` | Нар | Nar | "Sun" — older **brother** (~10), the gentle artist |
| `sar` | Сар | Sar | "Moon" — older **sister** (~8), the bold athlete |
| `aav` | Аав | Aav | Father — herder & stargazer, often away |
| `eej` | Ээж | Eej | Mother — anchor of the ger |
| `ovoo` | Өвөө | Övöö | Grandfather — storyteller |
| `emee` | Эмээ | Emee | Grandmother — keeper of the hearth |
| `bars` | Барс | Bars | Bankhar guardian dog — non-speaking, celebrates wins |

> **Naming warning for writers/UI:** Nar = SUN but is the *gentle* one; Sar = MOON but is the *bold* one. Each child is the deliberate opposite of what their name implies. Do not "correct" this — it is the theme.

---

## 1. The big idea

The player helps a family of **Mazaalai** bears live out one turning year on the steppe. The player learns Mongolian not through flashcards but by **helping the bears with the real work of their lives**: naming the world for the youngest cub, dressing the family for festivals, walking them to the well and the pasture, reading the night sky with the father.

The youngest cub, **Od** ("star"), is just learning to name everything — exactly like the child playing. Player and Od learn each word together. As words are mastered, Od grows braver and more capable, and a new star is placed in the family's night sky. The faint little star slowly learns to shine.

**One-sentence pitch:** A child raises their voice alongside Od, the smallest star in a bear family lit by the Sun and the Moon — and by learning the names of the world, helps the overlooked little one become the star the whole family finds its way home by.

**Cultural grounding:** The Mazaalai is a real national treasure (Mongolia named its first satellite after it). The family lives in a ger and follows Mongolian custom (door faces south; khoimor / place of honor at the north), keeps the five-snouts herd, and prepares across the year for **Naadam** (summer festival) and **Tsagaan Sar** (lunar new year).

---

## 2. Messages & values

All values are **shown through gameplay and gesture, never stated as lessons.** A child should absorb them without being told.

**Core message:** *Every light shines its own way.* A sun doesn't have to blaze to matter. A moon doesn't have to be soft. And the smallest, faintest star — the one everyone calls too little to help — can become the one the whole family finds its way home by.

| # | Value | How it's felt in-app |
|---|---|---|
| 1 | You are enough as you are | Nobody is asked to change. Praise is for the *specific act*, never a category. |
| 2 | Growth comes from helping, not winning | Every mini-game is framed as helping a bear. No score, no beating anyone. |
| 3 | The small/overlooked can be most important | Od's arc; the faint North Star is the one all navigate by. |
| 4 | Be who you are; you'll be loved for it | Parents delight in children who defied their names. No "but you're a boy / that's for girls" line ever. |
| 5 | Home & family are warmth | The ger is the safe center the year returns to. |

### Tone guardrails (apply everywhere)

- Never preach. Message lands in gestures, not speeches.
- Praise the specific act, never the category ("what a careful stitch," not "good boy for sewing").
- No villains, no failure states, no shaming. A wrong answer is "let's try again," never a loss.
- Warmth over excitement. Cozy, not frantic. Night sky and hearth are the two emotional anchors.
- Elders stay traditional; children are free. The contrast is the point.

---

## 3. Characters

### Od (Од) — "Star" · youngest · the hero
- **Role:** Protagonist and the player's buddy. Age ~5. **Gender deliberately open** — art, clothing, and voice keep Od ambiguous so every child sees themselves.
- **Personality:** Curious, fearless in small ways, a natural peacemaker, idolizes both older siblings. Just learning to name everything.
- **The heart of it:** In a family lit by the Sun and Moon, Od is "just a little star" — often called too little to help. That is how a small child feels among capable big people.
- **Arc:** The overlooked little star learns the names of the world and becomes the guiding star of the family — the one who knows the words, leads the way, helps bring the away-father home. Not the loudest; the truest.

### Nar (Нар) — "Sun" · older brother · the artist
- **Role:** Older brother, ~10. The artist and noticer. Gentle, patient, a little dreamy.
- **Against the stereotype:** Name means the bright blazing sun; he is the calm creative one. Draws, sews patterns, arranges things, spots the detail others miss.
- **Owns:** Colors, shapes, patterns, crafts — and the **dress-up & decorating** mini-games.
- **Loop hook:** Items the child buys for Nar can appear as new decoration options elsewhere (he's the family's maker).

### Sar (Сар) — "Moon" · older sister · the athlete
- **Role:** Older sister, ~8. The athlete. Fast, bold, competitive, never sits still.
- **Against the stereotype:** Name means the cool calm moon; she is the restless racer. Training for her first **Naadam** horse race.
- **Owns:** Motion verbs (run, gallop, jump, stop), sports, the **road-sign / voice-command running** games. Always daring Od to keep up.

### Aav (Аав) — Father · the stargazer & herder *(most story-critical adult)*
- **Role:** A herder who crosses the dark steppe by the stars, so he teaches Od to read them. **Often away with the herds.**
- **Emotional engine:** He and Od **share the same sky.** Every word Od learns becomes a star — Od reaching across the distance to the away-parent. Learning to guide the family is, specifically, learning to find Aav and bring him home.
- **Owns:** Numbers, constellations, **Altan Gadas** (North Star), **Doloon Burhan** (Big Dipper, "the seven gods"), navigation, weather — and the **typing / bubble-pop** game (popping star-letters from the sky).

### Eej (Ээж) — Mother · anchor of the ger
- The parent who *stays* while Aav is away. **Owns:** family words, body parts, clothing, household items, greetings/kindness phrases. Natural home for shared dress-up/decorating too.

### Övöö (Өвөө) — Grandfather · the storyteller
- Gentle wisdom by the fire. **Owns:** proverbs, riddles, old tales.

### Emee (Эмээ) — Grandmother · keeper of the hearth
- **Owns:** food, süütei tsai (milk tea), dairy, hospitality, welcoming guests — and **listen-and-find-the-picture** games around home objects.

### Bars (Барс) — the Bankhar dog · comfort & comic relief
- Big loyal guardian dog. **Does not speak.** Celebrates every win the same way (happy spin + bark). Always present, always glad to see you. His snacks are the reward floor (see §7).

---

## 4. Relationships

- **Sibling balance:** Sar and Nar are opposites of **temperament**, not gender — Sar fast/outward, Nar careful/inward. They squabble, then close ranks to protect Od. No interest is coded "the boy one" or "the girl one."
- **Od & the big kids:** Od adores them and tags along everywhere → this is why the reward shop *starts* with Sar and Nar (§7). A youngest child lives in the orbit of the big kids before being "old enough" to help grown-ups.
- **Od & Aav (the quiet heart):** The smallest star and the parent who reads the sky. Aav's absence makes the shared sky the thread between them. The most emotionally powerful bond in the app and the engine of Od's arc.
- **The hearth:** With Aav often out, the ger is Eej + elders + children + Bars. Warmth, tea, belonging — the safe place the year returns to.

**How acceptance is shown, never told:**
- Aav holds Nar's pattern up to the light and goes quiet with pride.
- Eej is hoarse from cheering Sar across the finish line.
- Nobody ever says "but you're a boy" / "that's for girls."
- Praise names the specific thing, never the category.

---

## 5. Story structure — a year on the steppe

The whole app = **one turning year**, structured on the real rhythm of Mongolian nomadic life. The family prepares for two great events: **Naadam** (summer, Sar's first race) and **Tsagaan Sar** (winter lunar new year, the home must be perfect). Each season is a "world" of lessons. Emotional engine throughout: **the bears need you**; every lesson is a small act of help, and the bears respond with warmth.

| Season | Setting | Teaches & unlocks |
|---|---|---|
| Spring | Green steppe, newborn animals | First words: home, family, Bars. Aav first shows Od the sky. Reward loop opens with **Sar & Nar**. |
| Summer | Golden journey, Naadam | Sar's race chapter: motion verbs, sport, directions. Mid-year celebration → Od "grown enough" to help parents. |
| Autumn | Mountains, harvest, herding | Aav's world deepens: numbers, weather, navigation, constellations. Parents' tracks active. |
| Winter | Deep snow, Tsagaan Sar | Decorate ger, prepare feast, dress family in festival deel. Elders' tracks open. **Altan Gadas** within reach. |

Each season ends in a gathering in the ger the player has helped furnish — the recurring payoff tying learning, story, and reward together.

---

## 6. Lesson-to-character map (the modular engine)

Bambaruush runs on a **modular lesson engine**: each mini-game is a reusable template filled with any letter/word set. The **7 frames are fixed**; new lessons are authored by dropping new content into a frame (a content task, not an engineering task). Each frame is "owned" by a family member so every lesson arrives wrapped in a character's world.

| `frame_id` | Mini-game | Owner | What it does / teaches |
|---|---|---|---|
| `listen_find` | Listen & find the picture | Emee, Aav | Hear a word, tap matching picture. Home objects; animals & nature. |
| `match_to_char` | Match pictures to characters | Sar | Characters walk/run to the matched picture. Links word ↔ motion. |
| `match_verb` | Match actions to verbs | Sar, Aav | Pair a character's action with the verb. Herding, racing, playing. |
| `dressup` | Dress-up: colors & clothing | Nar | Put colors / deel / clothes on characters. Colors, clothing, patterns. |
| `walk_to_place` | Walk to the right place | Aav, Sar | Guide a character home/school/well/pasture. Places & directions. |
| `bubble_pop` | Typing — bubble pop | Aav | Pop star-letters from the night sky. Letters, spelling, alphabet. |
| `run_walk` | Run & walk — signs / voice | Sar | Respond to road signs or voice commands. Commands, motion, listening. |

**Engine invariant:** the 7 frames never change shape. Adding a lesson = new word/letter set + assets, mapped to an existing frame. Build the content pipeline around this.

---

## 7. Reward system

**Two parallel tracks, kept strictly separate:**
- **Track A — Odon:** spent to widen Od's world outward through the family.
- **Track B — Sky-stars:** earned by mastering words to deepen Od. **Never purchasable, never spent.**

> **Currency invariant:** Reserve the word/asset "star" exclusively for Track B (Od + the sky). **Odon** (одон — Mongolian for "medal/order") is the spendable currency for everything bought — single symbol, single wallet, earned from any mini-game. The name shares its root with **Od** (од, star) and echoes Mongolia's real highest honor, the **Order of the Polar Star** (Алтан гадас одон / *Altan Gadas Odon*) — so collecting odon on the way to lighting Altan Gadas is, fittingly, earning the Order of the Polar Star. Keep odon (spendable) and stars (permanent, earned by mastery) visually and behaviorally distinct.

### Track A — Odon: per-character upgrade tracks
Not loot — *helping each family member grow into who they are.* Each track is that character's dream getting closer.

| Track | What it buys | Why it matters |
|---|---|---|
| Sar | Riding/racing gear → her own fast horse for Naadam | The road to her first race. |
| Nar | Art & craft supplies → a studio corner of his own | Purchases unlock new decoration looks (he's the maker). |
| Aav | Spyglass, star map, cozy hilltop lookout | Deepens the sky he & Od share. |
| Eej | Cooking gear, tea setup, ger comfort | Makes home nicer for everyone. |
| Övöö & Emee | Chair by the fire, snuff bottle, dairy tools | Small, cozy, slower — the "you've made it" tier. |
| Bars | Snacks (always) + toys, collar, bed | See special rule below. |

### Track B — Sky-stars: Od's sky (un-buyable)
Every word **mastered** (not merely attempted) earns a permanent star Aav places in the sky. Stars connect into real Mongolian constellations — chiefly **Doloon Burhan** (Big Dipper). Each completed constellation = a chapter milestone (celebration + special ger decoration). The final, hardest-won star is **Altan Gadas** (North Star), earned when Od has learned enough to truly guide the family — the "you finished the journey" moment.

**Why separate:** Spend builds the family's world; you cannot pay for Od's growth — you earn it. The sky is an honest permanent record of what the child has truly learned.

### Staged progression — the world widens outward
The shop opens in **rings** that mirror how a child's world grows. Never show all characters at once (overwhelming + spreads a 5-year-old too thin).

| Stage | Who unlocks | Notes |
|---|---|---|
| 1 | **Sar & Nar** (big siblings) | Where everyone starts. Two clear stories: the race, the studio. |
| 2 | **Aav & Eej** (parents) | Unlocks after Od has "grown." Aav's sky track meets earned stars — spend & mastery converge. |
| 3 | **Övöö & Emee** (elders) | Widest, gentlest ring. Cozy keepsakes; most aspirational big-ticket items. |

**Unlock invariant (critical):** Stage 2 does **NOT** open at a coin total. It opens when **both sibling story threads hit a milestone** (Sar races; Nar finishes his first real piece), triggering a family gathering where Od is recognized as no longer "just the little one." The unlock = "you grew up a little" = Od's arc. Structure and arc are the same thing.

**Pacing target:** a regular young player should reach the Stage-1 celebration in **days, not weeks**. Prototype where this lands (too fast loses focus; too slow walls off the family).

### Bars's snacks — the always-available floor
Bars is **not** a gated track; he is a **constant**. Snacks are always available, trivially cheap, always rewarding (buy → Bars delighted, every time).
- Guaranteed win for the youngest/least-skilled players — a reliable "I did good" with zero barrier. The floor under the whole economy.
- The gentlest tutorial for the reward loop: earn → spend → make someone happy.
- Comfort, not progress. The gated tracks pull forward; Bars is the warm constant.

**Satiation invariant:** after a snack or two, Bars is happily full, naps, and is ready again later. Never "you're blocked" — "Bars is full and happy now." Caps the spam loop without saying no; the napping dog is itself a small reward. Backup lever: keep snack cost trivial so it never competes with real upgrade tracks.

---

## 8. Rules of the game (invariants)

### Core loop
1. A family member needs help with the season's work (narrative frame for the lesson).
2. Player completes a mini-game to help — learning/practicing words.
3. Success earns Odon; **mastering** a word also earns a permanent sky-star.
4. Odon is spent on family upgrade tracks (and Bars's snacks); stars fill Od's sky.
5. Milestones trigger celebrations that advance the story and open new content.

### Learning & mastery
- Word states: **seen** (first appearance) → **practiced** (answered correctly) → **mastered** (correct recall across several sessions / game types). **Only mastery earns a star.**
- Spaced repetition: mastered words resurface in new lessons. A word can drop **mastered → practiced** for *review-scheduling* if repeatedly missed — **but its earned sky-star is permanent** (once lit, never removed; the kindness invariant forbids taking a star back). This permanence is realized in Slice 6.
- New words ALWAYS introduced with **audio + picture together** before being tested. Never test a word the child hasn't first heard and seen.
- Every word has clear, child-voiced Mongolian audio. **Listening before reading**; reading (bubble-pop) comes later in a child's journey.

### Kindness (non-negotiable)
- **No failure states.** Wrong answer = gentle "let's try again": soft audio, the right answer gently shown. No buzzer, no red X, no lost life.
- **No punishing timers.** Motion/paced games never shame slowness; the bears wait.
- **No villains, no scary content, no competition against the bears.** The player always helps, never beats.
- **No shaming for who a character is.** Praise is specific and warm; never references gender or category.
- Bars always celebrates a win the same way — reliability is the reward.

### Economy
- **One** spendable currency (Odon), one wallet, earned from any mini-game.
- **Earn currency for *trying*, not for *succeeding*.** A child receives Odon for *participating in* a round (engaging, attempting), not as a prize gated on correct answers. This protects healthy **intrinsic motivation** — the desire to learn for its own sake — and reinforces the no-failure-states rule: no child is left empty-handed for getting something wrong. (See §11 References.)
- **Keep intrinsic motivation in mind everywhere.** Rewards should support the joy of learning, never replace it. Favor effort/process praise ("you worked that out") over trait praise ("you're so smart"); let the sky-star — Od's *own* visible growth — be the accomplishment, not a treat handed over for approval. (See §11 References.)
- **Stars** are never purchasable and never spent — accumulate only. A record of learning, not a resource.
- Most upgrade items low-cost & frequent (a little reward almost every session); a few aspirational big-ticket items to save toward (Sar's horse, Aav's spyglass).
- Upgrade tracks gated to story/season — content unfolds across the year, not all at once.
- Bars's snacks always available & trivially cheap; satiation nap prevents a spam loop.
- **No real-money pressure in the child-facing experience.** Any monetization lives behind a parent gate, never in Od's world.

### Cultural & safety
- Honor Mongolian custom in every depiction: ger door faces **south**, khoimor (place of honor) at the **north**, elders greeted with respect, guests offered tea.
- All Mongolian text & audio verified by a native speaker before shipping.
- Conservation theme (rare Mazaalai) stays quiet and positive — pride, never a lecture.
- Age-appropriate throughout: simple language, warm pacing, nothing frightening, a parent gate for settings/purchases.

---

## 9. Glossary (verify all with a native speaker)

| Term | Cyrillic | Meaning / note |
|---|---|---|
| Bambaruush | Бамбаруш | "Little bear cub" — app name |
| Mazaalai | Мазаалай | Mongolian Gobi bear (the family's species) |
| od | од | Star — Od's name; the first word taught; the permanent-progression unit |
| odon | одон | "Medal / order" — the spendable currency; shares a root with *od* (star); echoes the Order of the Polar Star (*Altan Gadas Odon*) |
| nar | нар | Sun — Nar's name |
| sar | сар | Moon — Sar's name |
| ger | гэр | The traditional dwelling; door faces south |
| khoimor | хоймор | Place of honor inside the ger, at the north |
| deel | дээл | The national robe (festival & seasonal versions) |
| Altan Gadas | Алтан гадас | "Golden stake" — the North Star; the endgame star |
| Doloon Burhan | Долоон бурхан | "The seven gods" — the Big Dipper |
| Naadam | Наадам | Summer festival (Sar's first horse race) |
| Tsagaan Sar | Цагаан сар | "White Moon" — lunar new year (winter chapter) |
| süütei tsai | сүүтэй цай | Milk tea (Emee's hospitality) |
| Bankhar | банхар | The Mongolian guardian dog breed (Bars) |
| five snouts | таван хошуу мал | The herd: horses, cattle/yak, camels, sheep, goats |

---

## 10. Related files
- `Bambaruush_Opening_Scene.md` — "The First Star": the canonical opening scene (prose tone reference) + the first playable lesson script (`listen_find` frame teaching `од`). Use as the voice/pacing benchmark for all lessons.

---

## 11. References — reward design & intrinsic motivation

These studies inform the rules above (especially the Economy and Kindness sections): reward *effort/participation* rather than success, prefer process/effort praise over trait praise, and let the child's own visible growth (the sky) be the accomplishment rather than a tangible prize handed over for approval. Tangible, *expected*, success-contingent rewards are the kind most likely to erode a young child's intrinsic motivation; praise and feedback do not carry the same risk.

- **Lepper, M. R., Greene, D., & Nisbett, R. E. (1973).** Undermining children's intrinsic interest with extrinsic reward: A test of the "overjustification" hypothesis. *Journal of Personality and Social Psychology, 28*(1), 129–137. — The foundational nursery-school (ages 3–5) study: children who *expected* a reward for an enjoyable activity later showed less interest in it.
- **Deci, E. L., Koestner, R., & Ryan, R. M. (1999).** A meta-analytic review of experiments examining the effects of extrinsic rewards on intrinsic motivation. *Psychological Bulletin, 125*(6), 627–668. — Large meta-analysis: tangible rewards have a substantial undermining effect, and the effect is stronger for children than adults; expected, task-contingent rewards are the most damaging.
- **Deci, E. L., Koestner, R., & Ryan, R. M. (2001).** Extrinsic rewards and intrinsic motivation in education: Reconsidered once again. *Review of Educational Research, 71*(1), 1–27. — Re-affirms the undermining effect for educational practice and distinguishes controlling rewards from informational feedback.
- **Mueller, C. M., & Dweck, C. S. (1998).** Praise for intelligence can undermine children's motivation and performance. *Journal of Personality and Social Psychology, 75*(1), 33–52. — Praising ability/intelligence harms later motivation and persistence relative to praising effort.
- **Kamins, M. L., & Dweck, C. S. (1999).** Person versus process praise and criticism: Implications for contingent self-worth and coping. *Developmental Psychology, 35*(3), 835–847. — Person/trait praise (and criticism) can signal contingent worth and undermine coping after setbacks; process praise supports resilience.

> Note: a body of work (e.g., Cameron & Pierce) has debated the size of these effects, and very young children may be somewhat less sensitive to *trait* praise than older children. The design above takes the cautious, well-supported path regardless — reward effort, praise process, let growth be its own reward.

---

*End of Story Guide · working draft for team review. Update this file deliberately when decisions change; it is the source of truth.*
