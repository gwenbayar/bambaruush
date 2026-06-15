import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../models/progress.dart';
import 'progress_store.dart';

class ProgressRepository implements ProgressStore {
  ProgressRepository({required Directory documentsDir})
      : _file = File('${documentsDir.path}/progress.json');

  final File _file;

  static const _currentSchemaVersion = 4;

  @override
  Future<Progress> load() async {
    if (!_file.existsSync()) return Progress.empty();
    final String raw;
    try {
      raw = await _file.readAsString();
    } on FileSystemException {
      return Progress.empty();
    }
    final dynamic decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return Progress.empty();
    }
    if (decoded is! Map<String, dynamic>) return Progress.empty();
    if (decoded['schemaVersion'] != _currentSchemaVersion) {
      return Progress.empty();
    }
    return Progress.fromJson(decoded);
  }

  @override
  Future<void> save(Progress p) async {
    final tmp = File('${_file.path}.tmp');
    await tmp.writeAsString(jsonEncode(p.toJson()), flush: true);
    await tmp.rename(_file.path);
  }

  @override
  Future<void> reset() async {
    if (_file.existsSync()) await _file.delete();
  }
}
