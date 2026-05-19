import 'dart:io';
import 'package:flutter/material.dart';

import '../services/saved_images_service.dart';
import 'result_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadFavorites();
  }

  Future<List<Map<String, dynamic>>> _loadFavorites() async {
    final items = await SavedImagesService.getSavedItems();
    return items.where((item) => item['isFavorite'] == true).toList();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBFC),
        elevation: 0,
        foregroundColor: const Color(0xFF4D7C57),
        title: const Text(
          'Favoriler',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (items.isEmpty) {
            return const Center(
              child: Text(
                'Henüz favori ürün yok',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final imagePath = item['frontImagePath'] ?? item['path'];
                final file = File(imagePath);

                return GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ResultScreen(imagePath: imagePath),
                      ),
                    );
                    _refresh();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: file.existsSync()
                              ? Image.file(
                                  file,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 70,
                                  height: 70,
                                  color: const Color(0xFFFCE7EE),
                                  child: const Icon(Icons.image),
                                ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            item['productName'] ?? 'Analiz Edilen Ürün',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.favorite_rounded,
                          color: Color(0xFFE8578A),
                        ),
                      ],
                    ),
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