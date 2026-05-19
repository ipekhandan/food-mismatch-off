import 'dart:io';

import 'package:flutter/material.dart';
import '../models/analysis_result.dart';
import '../services/saved_images_service.dart';
import 'result_screen.dart';
import 'visual_analysis_upload_screen.dart';

class SavedImagesScreen extends StatefulWidget {
  const SavedImagesScreen({super.key});

  @override
  State<SavedImagesScreen> createState() => _SavedImagesScreenState();
}

class _SavedImagesScreenState extends State<SavedImagesScreen> {
  late Future<List<Map<String, dynamic>>> _savedFuture;

  @override
  void initState() {
    super.initState();
    _savedFuture = SavedImagesService.getSavedItems();
  }

  void _refreshSaved() {
    setState(() {
      _savedFuture = SavedImagesService.getSavedItems();
    });
  }

  Future<void> _startFirstAnalysis() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const VisualAnalysisUploadScreen(),
      ),
    );

    if (!mounted) return;
    _refreshSaved();
  }

  String _formatDate(String? iso) {
    if (iso == null) return 'Tarih bilinmiyor';

    final date = DateTime.tryParse(iso);
    if (date == null) return 'Tarih bilinmiyor';

    return '${date.day}.${date.month}.${date.year}';
  }

  String? _asString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  @override
  Widget build(BuildContext context) {
    const darkText = Color(0xFF2B2146);
    const lilac = Color(0xFF8E73D8);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF9FB),
              Color(0xFFF4EDFF),
              Color(0xFFFFEEF7),
            ],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _savedFuture,
            builder: (context, snapshot) {
              final items = snapshot.data ?? [];

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _TopButton(
                          icon: Icons.arrow_back_rounded,
                          onTap: () => Navigator.pop(context),
                        ),
                        _TopButton(
                          icon: Icons.settings_rounded,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(24, 34, 24, 28),
                      children: [
                        const Text(
                          'Kayıtlarım',
                          style: TextStyle(
                            fontSize: 40,
                            height: 1,
                            fontWeight: FontWeight.w900,
                            color: darkText,
                            letterSpacing: -1.5,
                          ),
                        ),
                        const SizedBox(height: 42),
                        if (snapshot.connectionState == ConnectionState.waiting)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 80),
                              child: CircularProgressIndicator(color: lilac),
                            ),
                          )
                        else if (items.isEmpty)
                          _EmptySavedCard(onStartTap: _startFirstAnalysis)
                        else
                          Column(
                            children: items.map((item) {
                              final String? imagePath = _asString(
                                item['frontImagePath'] ??
                                    item['imagePath'] ??
                                    item['path'],
                              );

                              final String? imageUrl = _asString(
                                item['frontImageUrl'] ??
                                    item['imageUrl'] ??
                                    item['productImageUrl'] ??
                                    item['image_url'],
                              );

                              final String title = _asString(
                                    item['productName'] ??
                                        item['product_name'] ??
                                        item['title'],
                                  ) ??
                                  'Analiz Edilen Ürün';

                              AnalysisResult? analysisResult;

                              final dynamic rawAnalysis =
                                  item['analysisResult'] ?? item['analysis_result'];

                              if (rawAnalysis is Map<String, dynamic>) {
                                analysisResult =
                                    AnalysisResult.fromJson(rawAnalysis);
                              } else if (item.containsKey('misleadingScore') ||
                                  item.containsKey('misleading_score') ||
                                  item.containsKey('productName') ||
                                  item.containsKey('product_name')) {
                                analysisResult = AnalysisResult.fromJson(item);
                              }

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _SavedItemCard(
                                  title: title,
                                  date: _formatDate(
                                    _asString(item['createdAt'] ??
                                        item['created_at'] ??
                                        item['date']),
                                  ),
                                  imagePath: imagePath,
                                  imageUrl: imageUrl,
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ResultScreen(
                                          imagePath: imagePath,
                                          analysisResult: analysisResult,
                                        ),
                                      ),
                                    );

                                    if (!mounted) return;
                                    _refreshSaved();
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TopButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TopButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8E73D8).withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(
          icon,
          color: const Color(0xFF6F6287),
          size: 28,
        ),
      ),
    );
  }
}

class _EmptySavedCard extends StatelessWidget {
  final VoidCallback onStartTap;

  const _EmptySavedCard({
    required this.onStartTap,
  });

  @override
  Widget build(BuildContext context) {
    const darkText = Color(0xFF2B2146);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 42),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(38),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8E73D8).withValues(alpha: 0.10),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 160,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(42),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF7EFFF),
                  Color(0xFFE7D8FF),
                ],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 92,
                  height: 66,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCCBFF),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8E73D8)
                            .withValues(alpha: 0.16),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.folder_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                Positioned(
                  top: 26,
                  right: 34,
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white.withValues(alpha: 0.92),
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 34),
          const Text(
            'Henüz kayıt yok',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: darkText,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Yaptığın analizler burada\nlistelenecek.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: darkText.withValues(alpha: 0.52),
              fontSize: 18,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 34),
          GestureDetector(
            onTap: onStartTap,
            child: Container(
              height: 58,
              padding: const EdgeInsets.symmetric(horizontal: 28),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFD7B6FF),
                    Color(0xFF9B7BE8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8E73D8).withValues(alpha: 0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'İlk analizi başlat',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedItemCard extends StatelessWidget {
  final String title;
  final String date;
  final String? imagePath;
  final String? imageUrl;
  final VoidCallback onTap;

  const _SavedItemCard({
    required this.title,
    required this.date,
    required this.imagePath,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final file = imagePath != null ? File(imagePath!) : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8E73D8).withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: _SavedImagePreview(
                file: file,
                imageUrl: imageUrl,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF2B2146),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Analiz tarihi: $date',
                    style: TextStyle(
                      color: const Color(0xFF2B2146).withValues(alpha: 0.52),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF8E73D8),
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedImagePreview extends StatelessWidget {
  final File? file;
  final String? imageUrl;

  const _SavedImagePreview({
    required this.file,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (file != null && file!.existsSync()) {
      return Image.file(
        file!,
        width: 78,
        height: 78,
        fit: BoxFit.cover,
      );
    }

    if (imageUrl != null && imageUrl!.startsWith('http')) {
      return Image.network(
        imageUrl!,
        width: 78,
        height: 78,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _ImagePlaceholder(),
      );
    }

    return const _ImagePlaceholder();
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      height: 78,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFEDE2FF),
            Color(0xFFF7EFFF),
          ],
        ),
      ),
      child: const Icon(
        Icons.image_rounded,
        color: Color(0xFF8E73D8),
        size: 38,
      ),
    );
  }
}