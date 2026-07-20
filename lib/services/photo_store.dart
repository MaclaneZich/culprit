import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Copies captured meal photos into the app documents directory so the
/// database can reference them by a stable path. Photos never leave the
/// device; the optional vision call sends bytes directly, not files.
class PhotoStore {
  const PhotoStore();

  Future<String> persist(File source) async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'meal_photos'));
    await dir.create(recursive: true);
    final name =
        'meal_${DateTime.now().millisecondsSinceEpoch}${p.extension(source.path)}';
    final saved = await source.copy(p.join(dir.path, name));
    return saved.path;
  }

  Future<void> deleteAll() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'meal_photos'));
    if (await dir.exists()) await dir.delete(recursive: true);
  }
}
