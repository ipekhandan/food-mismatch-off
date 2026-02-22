import 'dart:io';

import 'package:flutter/material.dart';
import '../services/saved_images_service.dart';
import 'result_screen.dart';

class SavedImagesScreen extends StatefulWidget {
  const SavedImagesScreen({super.key});

  @override
  State<SavedImagesScreen> createState() => _SavedImagesScreenState();
}

class _SavedImagesScreenState extends State<SavedImagesScreen> {
  late Future<List<String>> _future;

  @override
  void initState() {
    super.initState();
    _future = SavedImagesService.getSavedPaths();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = SavedImagesService.getSavedPaths();
    });
  }

  Future<void> _delete(BuildContext context, String path) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Silinsin mi?'),
        content: const Text('Bu kaydı silmek istiyor musun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    await SavedImagesService.deleteSavedPath(path);
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıtlarım'),
      ),
      body: FutureBuilder<List<String>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final paths = snapshot.data ?? [];

          if (paths.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Henüz kayıt yok.\nKamera veya galeriden bir fotoğraf seçince burada görünecek.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: paths.length,
             separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final path = paths[i];
                final file = File(path);

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: FutureBuilder<bool>(
                        future: file.exists(),
                        builder: (context, ex) {
                          final exists = ex.data ?? false;
                          if (!exists) {
                            return Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey.shade200,
                              alignment: Alignment.center,
                              child: const Icon(Icons.image_not_supported),
                            );
                          }
                          return Image.file(
                            file,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                    title: Text(
                      'Kayıt #${paths.length - i}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      path.split('/').last,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _delete(context, path),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ResultScreen(imagePath: path),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
