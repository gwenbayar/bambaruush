import 'dart:convert';

import 'package:flutter/services.dart';

import '../../models/lesson.dart';
import '../../models/letter.dart';
import '../../models/region.dart';
import '../../models/sticker.dart';
import '../../models/word.dart';

class ContentValidationError implements Exception {
  ContentValidationError(this.message);
  final String message;
  @override
  String toString() => 'ContentValidationError: $message';
}

class ContentRepository {
  ContentRepository._({
    required this.regions,
    required this.letters,
    required this.words,
    required this.lessons,
    required this.stickers,
    required Map<String, Lesson> lessonsById,
    required Map<int, Lesson> lessonsByOrder,
    required Map<String, Region> regionsById,
  })  : _lessonsById = lessonsById,
        _lessonsByOrder = lessonsByOrder,
        _regionsById = regionsById;

  final List<Region> regions;
  final Map<String, Letter> letters;
  final Map<String, Word> words;
  final List<Lesson> lessons;
  final Map<String, Sticker> stickers;

  final Map<String, Lesson> _lessonsById;
  final Map<int, Lesson> _lessonsByOrder;
  final Map<String, Region> _regionsById;

  static const _audioPrefix = 'assets/audio/';
  static const _wordImagePrefix = 'assets/images/words/';
  static const _stickerImagePrefix = 'assets/images/stickers/';
  static const _regionImagePrefix = 'assets/images/regions/';
  static const _traceMaskPrefix = 'assets/trace_masks/';

  Letter letterById(String id) =>
      letters[id] ?? (throw ContentValidationError('Unknown letter: $id'));
  Word wordById(String id) =>
      words[id] ?? (throw ContentValidationError('Unknown word: $id'));
  Lesson lessonById(String id) =>
      _lessonsById[id] ??
      (throw ContentValidationError('Unknown lesson: $id'));

  Lesson lessonByOrder(int order) =>
      _lessonsByOrder[order] ??
      (throw ContentValidationError('No lesson with order $order'));

  Sticker stickerById(String id) =>
      stickers[id] ?? (throw ContentValidationError('Unknown sticker: $id'));

  Region regionById(String id) =>
      _regionsById[id] ??
      (throw ContentValidationError('Unknown region: $id'));

  List<Lesson> lessonsInRegion(String regionId) =>
      lessons.where((l) => l.regionId == regionId).toList()
        ..sort((a, b) => a.order.compareTo(b.order));

  static Future<ContentRepository> loadFromAssets() async {
    final raw = await rootBundle.loadString('assets/content/content.json');
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw ContentValidationError('Root is not a JSON object');
    }
    return fromJson(decoded);
  }

  static ContentRepository fromJson(Map<String, dynamic> json) {
    final regionList = (json['regions'] as List)
        .map((e) => _regionFromRawJson(e as Map<String, dynamic>))
        .toList();
    final letterList = (json['letters'] as List)
        .map((e) => _letterFromRawJson(e as Map<String, dynamic>))
        .toList();
    final wordList = (json['words'] as List)
        .map((e) => _wordFromRawJson(e as Map<String, dynamic>))
        .toList();
    final lessonList = (json['lessons'] as List)
        .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
        .toList();
    final stickerList = (json['stickers'] as List)
        .map((e) => _stickerFromRawJson(e as Map<String, dynamic>))
        .toList();

    _checkUniqueIds(regionList.map((e) => e.id), 'regions');
    _checkUniqueIds(letterList.map((e) => e.id), 'letters');
    _checkUniqueIds(wordList.map((e) => e.id), 'words');
    _checkUniqueIds(lessonList.map((e) => e.id), 'lessons');
    _checkUniqueIds(stickerList.map((e) => e.id), 'stickers');

    final letters = {for (final l in letterList) l.id: l};
    final words = {for (final w in wordList) w.id: w};
    final stickers = {for (final s in stickerList) s.id: s};
    final regionIds = regionList.map((r) => r.id).toSet();

    for (final w in wordList) {
      for (final lid in w.letterIds) {
        if (!letters.containsKey(lid)) {
          throw ContentValidationError(
            'word ${w.id} references unknown letter $lid',
          );
        }
      }
    }

    for (final lesson in lessonList) {
      if (!regionIds.contains(lesson.regionId)) {
        throw ContentValidationError(
          'lesson ${lesson.id} references unknown region ${lesson.regionId}',
        );
      }
      for (final lid in lesson.letterIds) {
        if (!letters.containsKey(lid)) {
          throw ContentValidationError(
            'lesson ${lesson.id} references unknown letter $lid',
          );
        }
      }
      for (final wid in lesson.wordIds) {
        if (!words.containsKey(wid)) {
          throw ContentValidationError(
            'lesson ${lesson.id} references unknown word $wid',
          );
        }
      }
      if (!stickers.containsKey(lesson.stickerId)) {
        throw ContentValidationError(
          'lesson ${lesson.id} references unknown sticker ${lesson.stickerId}',
        );
      }
    }

    for (final s in stickerList) {
      if (!lessonList.any((l) => l.id == s.lessonId)) {
        throw ContentValidationError(
          'sticker ${s.id} references unknown lesson ${s.lessonId}',
        );
      }
    }

    _checkContiguousOrder(lessonList.map((l) => l.order).toList(), 'lessons');
    _checkContiguousOrder(regionList.map((r) => r.order).toList(), 'regions');

    final sortedLessons = lessonList..sort((a, b) => a.order.compareTo(b.order));
    final sortedRegions = regionList..sort((a, b) => a.order.compareTo(b.order));
    return ContentRepository._(
      regions: sortedRegions,
      letters: letters,
      words: words,
      lessons: sortedLessons,
      stickers: stickers,
      lessonsById: {for (final l in sortedLessons) l.id: l},
      lessonsByOrder: {for (final l in sortedLessons) l.order: l},
      regionsById: {for (final r in sortedRegions) r.id: r},
    );
  }

  static Region _regionFromRawJson(Map<String, dynamic> j) => Region.fromJson({
        ...j,
        'mapImagePath': '$_regionImagePrefix${j['mapImagePath']}',
      });

  static Letter _letterFromRawJson(Map<String, dynamic> j) => Letter(
        id: j['id'] as String,
        cyrillic: j['cyrillic'] as String,
        romanization: j['romanization'] as String,
        audioAssetPath: '$_audioPrefix${j['audio']}',
        traceTemplatePath: '$_traceMaskPrefix${j['traceMask']}',
      );

  static Word _wordFromRawJson(Map<String, dynamic> j) => Word(
        id: j['id'] as String,
        cyrillic: j['cyrillic'] as String,
        english: j['english'] as String,
        audioAssetPath: '$_audioPrefix${j['audio']}',
        imageAssetPath: '$_wordImagePrefix${j['image']}',
        letterIds: List<String>.from(j['letterIds'] as List),
      );

  static Sticker _stickerFromRawJson(Map<String, dynamic> j) => Sticker(
        id: j['id'] as String,
        lessonId: j['lessonId'] as String,
        imageAssetPath: '$_stickerImagePrefix${j['image']}',
        nameEn: j['nameEn'] as String,
      );

  static void _checkUniqueIds(Iterable<String> ids, String label) {
    final seen = <String>{};
    for (final id in ids) {
      if (!seen.add(id)) {
        throw ContentValidationError('Duplicate $label id: $id');
      }
    }
  }

  static void _checkContiguousOrder(List<int> orders, String label) {
    final sorted = [...orders]..sort();
    for (var i = 0; i < sorted.length; i++) {
      if (sorted[i] != i + 1) {
        throw ContentValidationError(
          '$label orders are not contiguous from 1: $sorted',
        );
      }
    }
  }
}
