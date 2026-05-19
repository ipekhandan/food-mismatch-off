
import 'dart:async';
import 'package:flutter/material.dart';

import '../models/analysis_result.dart';
import '../services/api_service.dart';
import '../services/saved_images_service.dart';
import 'result_screen.dart';

class AnalysisLoadingScreen extends StatefulWidget {
  final String imagePath;
  final String? ingredientsImagePath;

  const AnalysisLoadingScreen({
    super.key,
    required this.imagePath,
    this.ingredientsImagePath,
  });

  @override
  State<AnalysisLoadingScreen> createState() => _AnalysisLoadingScreenState();
}

class _AnalysisLoadingScreenState extends State<AnalysisLoadingScreen> {
  int currentStep = 0;
  String? errorMessage;

  final steps = const [
    'Ön yüz görselleri Grok Vision ile analiz ediliyor...',
    'İçindekiler bölümü OCR ile okunuyor...',
    'Katkı maddeleri taranıyor...',
    'Yanıltıcılık skoru hesaplanıyor...',
  ];

  @override
  void initState() {
    super.initState();
    _runAnalysis();
  }

  Future<void> _runAnalysis() async {
    try {
      final savedItem = await SavedImagesService.getSavedItemByPath(widget.imagePath);
      final ingredientsPath = widget.ingredientsImagePath ??
          savedItem?['ingredientsImagePath']?.toString();

      if (ingredientsPath == null || ingredientsPath.isEmpty) {
        throw Exception('İçindekiler fotoğrafı bulunamadı.');
      }

      for (int i = 0; i < 2; i++) {
        await Future.delayed(const Duration(milliseconds: 450));
        if (!mounted) return;
        setState(() => currentStep = i);
      }

      final AnalysisResult result = await ApiService.analyzeProduct(
        frontImagePath: widget.imagePath,
        ingredientsImagePath: ingredientsPath,
      );

      if (!mounted) return;
      setState(() => currentStep = 3);

      await SavedImagesService.updateAnalysisByPath(widget.imagePath, result);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            imagePath: widget.imagePath,
            analysisResult: result,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryLilac = Color(0xFF8E73D8);
    const darkLilac = Color(0xFF2B2146);
    const mediumLilac = Color(0xFFD7B6FF);

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
          child: Padding(
            padding: const EdgeInsets.all(26),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 148,
                  height: 148,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [mediumLilac, primaryLilac],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryLilac.withValues(alpha: 0.25),
                        blurRadius: 28,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    size: 72,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 34),
                Text(
                  errorMessage == null ? 'Analiz yapılıyor' : 'Analiz tamamlanamadı',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: darkLilac,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  errorMessage ?? steps[currentStep],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.4,
                    color: darkLilac.withValues(alpha: 0.62),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 38),
                if (errorMessage == null)
                  SizedBox(
                    width: 74,
                    height: 74,
                    child: CircularProgressIndicator(
                      color: primaryLilac,
                      backgroundColor: primaryLilac.withValues(alpha: 0.14),
                      strokeWidth: 6,
                      strokeCap: StrokeCap.round,
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Geri dön'),
                  ),
                const SizedBox(height: 34),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: primaryLilac.withValues(alpha: 0.12)),
                  ),
                  child: const Text(
                    'Backend açık değilse veya API_BASE_URL yanlışsa analiz başlatılamaz',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: darkLilac,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
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
}
