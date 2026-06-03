Inspiration:
Language learning made easy for anyone who wants to learn Mongolian.
Initial focus:
Designed for kids aged 7+
Beginners
People who can read and understand English
Future:
Younger children who can learn through pictures or vocal instruction
Adult learners
Intermediate speakers

Tech stack:

Flutter 3.x with Dart
Riverpod 2.x for state management
Go_router for navigation
Flutter_animate for micro-animations
Rive for character animation
JSON for local storage (v1)
Supabase for backup storage (v2)

v1:
Flutter + Dart, Cyrillic only, mascot (bambaruush - a teddy bear)
One world (The Steppe) with Mongolian alphabet + ~30-40 animal/nature vocabulary words
Three mini-games: tap-the-picture, listen-and-tap, trace-the-letter
Local-only – no backend, no accounts, no internet required
Multiple user profiles on one device
Progress tracking, spaced repetition, sticker rewards

v2:
Authentication: parents sign up and log in
User-scoped cloud storage: each parent's data is private to them
Sync engine: local SQLite ↔ cloud Postgres, in both directions
Conflict resolution: what happens if a kid plays offline on a tablet, then on a phone, before they sync
Lesson content delivery: same content for everyone, but updatable without an app release