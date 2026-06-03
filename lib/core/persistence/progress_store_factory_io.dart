import 'package:path_provider/path_provider.dart';

import 'progress_repository.dart';
import 'progress_store.dart';

/// Native: persist to a JSON file in the app documents directory.
Future<ProgressStore> createProgressStore() async {
  final dir = await getApplicationDocumentsDirectory();
  return ProgressRepository(documentsDir: dir);
}
