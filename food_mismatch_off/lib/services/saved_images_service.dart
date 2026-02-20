import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedImagesService {
  static const _key = 'saved_images';

  static Future<String> saveToAppFolder(String sourcePath) async {
    final docs = await getApplicationDocumentsDirectory();
    final savedDir = Directory('${docs.path}/saved_images');

    if (!await savedDir.exists()) {
      await savedDir.create(recursive: true);
    }

    final ext = _safeExt(sourcePath);
    final fileName = 'scan_${DateTime.now().millisecondsSinceEpoch}.$ext';
    final newPath = '${savedDir.path}/$fileName';

    await File(sourcePath).copy(newPath);

    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];

    list.insert(
      0,
      jsonEncode({
        'path': newPath,
        'createdAt': DateTime.now().toIso8601String(),
      }),
    );

    await prefs.setStringList(_key, list);

    return newPath;
  }

  static Future<List<String>> getSavedPaths() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];

    return list
        .map((e) => jsonDecode(e) as Map<String, dynamic>)
        .map((m) => m['path'] as String)
        .toList();
  }

  static Future<void> deleteSavedPath(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }

    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];

    list.removeWhere((e) {
      final m = jsonDecode(e) as Map<String, dynamic>;
      return m['path'] == path;
    });

    await prefs.setStringList(_key, list);
  }

  static String _safeExt(String path) {
    final parts = path.split('.');
    if (parts.length < 2) return 'jpg';

    final ext = parts.last.toLowerCase();
    return ext.isEmpty ? 'jpg' : ext;
  }
}