import 'dart:convert';
import 'dart:io';

import 'package:bambaruush/core/content/content_repository.dart';
import 'package:bambaruush/features/lesson/activity_spec.dart';
import 'package:bambaruush/features/lesson/lesson_session.dart';
import 'package:bambaruush/models/lesson.dart';
import 'package:flutter_test/flutter_test.dart';

ContentRepository _content() {
  final json = jsonDecode(
    File('test/fixtures/content_valid.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  return ContentRepository.fromJson(json);
}

void main() {
  final content = _content();

  test('letter lesson: Intro + Trace per letter, then Listen×N, Read×N, Reward', () {
    final lesson = content.lessonById('lesson_01'); // letter kind, 1 letter, 2 words
    final seq = LessonSession(lesson: lesson, content: content, seed: 1).buildSequence();
    expect(seq.map((s) => s.runtimeType).toList(), [
      IntroSpec, TraceSpec, ListenSpec, ListenSpec, ReadSpec, ReadSpec, RewardSpec,
    ]);
  });

  test('vocabulary lesson: NO Intro/Trace — just Listen×N, Read×N, Reward', () {
    final base = content.lessonById('lesson_01');
    final vocab = Lesson(
      id: 'lesson_vocab',
      order: 1,
      kind: LessonKind.vocabulary,
      regionId: base.regionId,
      letterIds: const [],
      wordIds: base.wordIds,
      stickerId: base.stickerId,
    );
    final seq = LessonSession(lesson: vocab, content: content, seed: 1).buildSequence();
    expect(seq.map((s) => s.runtimeType).toList(), [
      ListenSpec, ListenSpec, ReadSpec, ReadSpec, RewardSpec,
    ]);
    expect(seq.whereType<IntroSpec>(), isEmpty);
    expect(seq.whereType<TraceSpec>(), isEmpty);
  });

  test('Listen/Read specs carry 2 distractor ids that are not the target', () {
    final lesson = content.lessonById('lesson_01');
    final seq = LessonSession(lesson: lesson, content: content, seed: 1).buildSequence();
    final listen = seq.whereType<ListenSpec>().first;
    expect(listen.distractorIds, hasLength(2));
    expect(listen.distractorIds.contains(listen.wordId), isFalse);
  });

  test('same seed yields identical distractor ids (deterministic)', () {
    final lesson = content.lessonById('lesson_01');
    final a = LessonSession(lesson: lesson, content: content, seed: 7).buildSequence();
    final b = LessonSession(lesson: lesson, content: content, seed: 7).buildSequence();
    final aListen = a.whereType<ListenSpec>().map((s) => s.distractorIds).toList();
    final bListen = b.whereType<ListenSpec>().map((s) => s.distractorIds).toList();
    expect(aListen, bListen);
  });
}
