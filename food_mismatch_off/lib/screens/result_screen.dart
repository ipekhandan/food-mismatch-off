import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/analysis_result.dart';
import '../services/saved_images_service.dart';
import 'home_screen.dart';

const _primaryLilac = Color(0xFF8E73D8);
const _darkLilac = Color(0xFF2B2146);
const _softLilac = Color(0xFFF4EDFF);
const _mediumLilac = Color(0xFFD7B6FF);

class ResultScreen extends StatefulWidget {
  final String? imagePath;
  final AnalysisResult? analysisResult;

  const ResultScreen({super.key, this.imagePath, this.analysisResult});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late final AnalysisResult result;

  bool isFavorite = false;

  @override
  void initState() {
    super.initState();

    result = widget.analysisResult ??
        AnalysisResult(
          productName: 'Analiz Edilen Ürün',
          misleadingScore: 0,
          detectedVisuals: const [],
          actualIngredients: const ['İçerik bilgisi bulunamadı'],
          healthRisk: 'bilinmiyor',
          healthScore: 0,
          eCodes: const [],
          mismatches: const [],
          explanation: '',
          ocrSource: '',
          dataSource: '',
        );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.imagePath != null) {
        await SavedImagesService.updateAnalysisByPath(
          widget.imagePath!,
          result,
        );

        final fav = await SavedImagesService.isFavorite(widget.imagePath!);

        if (!mounted) return;

        setState(() {
          isFavorite = fav;
        });
      }
    });
  }

  Future<void> _toggleFavorite() async {
    if (widget.imagePath == null) return;

    await SavedImagesService.toggleFavorite(widget.imagePath!);

    final fav = await SavedImagesService.isFavorite(widget.imagePath!);

    if (!mounted) return;

    setState(() {
      isFavorite = fav;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          fav ? 'Favorilere eklendi' : 'Favorilerden çıkarıldı',
        ),
      ),
    );
  }

  void _goBack() {
    Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (_) => const HomeScreen(),
    ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9FB),
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(),
                Transform.translate(
                  offset: const Offset(0, -22),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 22, 16, 24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.72),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(34),
                        topRight: Radius.circular(34),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _primaryLilac.withValues(alpha: 0.08),
                          blurRadius: 24,
                          offset: const Offset(0, -6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildScoreCard(result.misleadingScore),
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildCard(
                                title: 'Ambalajda Tespit\nEdilen Görseller',
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      spacing: 6,
                                      children: _visualEmojis(
                                        result.detectedVisuals,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    ...result.detectedVisuals.map(
                                      (v) => _checkRow(v),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildCard(
                                title: 'Ürün İçeriği',
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: result.actualIngredients
                                      .map((i) => _checkRow(i))
                                      .toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildRiskCard(result.healthRisk),
                        const SizedBox(height: 14),
                        if (result.eCodes.isNotEmpty)
                          _buildCard(
                            title: 'Tespit Edilen E-Kodları',
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: result.eCodes
                                  .map(
                                    (e) => Chip(
                                      label: Text(e),
                                      backgroundColor: _softLilac,
                                      labelStyle: const TextStyle(
                                        color: _darkLilac,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        if (result.eCodes.isNotEmpty) const SizedBox(height: 14),
                        if (result.mismatches.isNotEmpty)
                          _buildCard(
                            title: 'Uyumsuzluk Açıklamaları',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: result.mismatches.map((m) => _checkRow(m)).toList(),
                            ),
                          ),
                        if (result.mismatches.isNotEmpty) const SizedBox(height: 14),
                        if (result.explanation.isNotEmpty)
                          _buildCard(
                            title: 'Akıllı Analiz Yorumu',
                            child: Text(
                              result.explanation,
                              style: const TextStyle(
                                color: _darkLilac,
                                fontSize: 14,
                                height: 1.45,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        if (result.explanation.isNotEmpty) const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEDE4FF),
            Color(0xFFD9C8FF),
            Color(0xFFFFEEF7),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 12,
            left: 16,
            child: _HeaderCircleButton(
              icon: Icons.arrow_back_rounded,
              onTap: _goBack,
            ),
          ),
          const Positioned(
            top: 25,
            left: 0,
            right: 0,
            child: Text(
              'Analiz Sonucu',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _darkLilac,
                fontWeight: FontWeight.w900,
                fontSize: 22,
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 16,
            child: _FavoriteButton(
              isFavorite: isFavorite,
              onTap: _toggleFavorite,
            ),
          ),
          Positioned(
            left: 22,
            top: 106,
            right: 160,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.productName,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: _darkLilac,
                    height: 1.08,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Analiz tarihi:',
                  style: TextStyle(
                    color: _darkLilac.withValues(alpha: 0.55),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _formattedDate(),
                  style: TextStyle(
                    color: _darkLilac.withValues(alpha: 0.55),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 10,
            bottom: 18,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.42),
                borderRadius: BorderRadius.circular(30),
              ),
              child: widget.imagePath != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.file(
                  File(widget.imagePath!),
                  fit: BoxFit.cover,
                ),
              )
                  : result.imageUrl != null && result.imageUrl!.isNotEmpty
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.network(
                  result.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.image_rounded,
                    color: _primaryLilac,
                    size: 62,
                  ),
                ),
              )
                  : const Icon(
                Icons.image_rounded,
                color: _primaryLilac,
                size: 62,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(int score) {
    final scoreColor = _scoreColor(score);
    final label = _scoreLabel(score);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: _primaryLilac.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Yanıltıcılık Skoru',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: _darkLilac,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: scoreColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      color: scoreColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Yanıltıcılık skoru: $score',
                  style: TextStyle(
                    fontSize: 13,
                    color: _darkLilac.withValues(alpha: 0.45),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 88,
            height: 88,
            child: CustomPaint(
              painter: _CircleScorePainter(
                score: score,
                color: scoreColor,
              ),
              child: Center(
                child: Text(
                  '$score',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: scoreColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _primaryLilac.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _darkLilac,
              fontSize: 16,
              height: 1.35,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _checkRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_rounded,
            size: 18,
            color: _primaryLilac,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: _darkLilac,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _visualEmojis(List<String> visuals) {
    final emojis = ['🥛', '🍓', '🍯', '🌿', '🫐', '🍋'];

    return List.generate(
      visuals.length.clamp(0, emojis.length),
      (i) => Text(
        emojis[i],
        style: const TextStyle(fontSize: 24),
      ),
    );
  }

  Widget _buildRiskCard(String risk) {
    final color = _riskColor(risk);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _primaryLilac.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _riskIcon(risk),
              color: color,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sağlık Riski: ${risk.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _riskDescription(risk),
                  style: TextStyle(
                    fontSize: 14,
                    color: _darkLilac.withValues(alpha: 0.55),
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formattedDate() {
    final now = DateTime.now();
    return '${now.day}.${now.month}.${now.year}';
  }

  Color _riskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'düşük':
        return const Color(0xFF8E73D8);
      case 'orta':
        return const Color(0xFFE2A53B);
      case 'yüksek':
        return const Color(0xFFD95C5C);
      default:
        return Colors.grey;
    }
  }

  IconData _riskIcon(String risk) {
    switch (risk.toLowerCase()) {
      case 'düşük':
        return Icons.check_circle_rounded;
      case 'orta':
        return Icons.warning_amber_rounded;
      case 'yüksek':
        return Icons.error_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  Color _scoreColor(int score) {
    if (score >= 70) {
      return const Color(0xFFE2A53B);
    }

    if (score >= 40) {
      return const Color(0xFF8E73D8);
    }

    return const Color(0xFF7B61D1);
  }

  String _scoreLabel(int score) {
    if (score >= 70) return 'Orta';
    if (score >= 40) return 'Düşük';
    return 'İyi';
  }

  String _riskDescription(String risk) {
    switch (risk.toLowerCase()) {
      case 'düşük':
        return 'İçerik açısından dikkat çekici büyük bir risk görünmüyor.';
      case 'orta':
        return 'Bazı içerikler dikkat gerektirebilir.';
      case 'yüksek':
        return 'Dikkat edilmesi gereken ciddi uyumsuzluk olabilir.';
      default:
        return 'Risk seviyesi değerlendirilemedi.';
    }
  }
}

class _HeaderCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderCircleButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _primaryLilac.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(
          icon,
          color: _darkLilac.withValues(alpha: 0.8),
          size: 28,
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;

  const _FavoriteButton({
    required this.isFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _primaryLilac.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: _primaryLilac,
          size: 28,
        ),
      ),
    );
  }
}

class _CircleScorePainter extends CustomPainter {
  final int score;
  final Color color;

  _CircleScorePainter({
    required this.score,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 7;
    const strokeWidth = 8.0;

    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * (score / 100);

    canvas.drawArc(
      Rect.fromCircle(
        center: center,
        radius: radius,
      ),
      -pi / 2,
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_CircleScorePainter old) {
    return old.score != score || old.color != color;
  }
}
