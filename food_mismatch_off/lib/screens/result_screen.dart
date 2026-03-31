import 'dart:io';

import 'package:flutter/material.dart';
import '../models/analysis_result.dart';
import '../widgets/ingredient_list.dart';
import '../widgets/score_card.dart';

class ResultScreen extends StatelessWidget {
  final String? imagePath;

  const ResultScreen({super.key, this.imagePath});

  @override
  Widget build(BuildContext context) {
    final result = AnalysisResult.mock();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Analiz Sonucu'),
        backgroundColor: Colors.green.shade700,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imagePath != null) ...[
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(imagePath!),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Yanıltıcılık Skoru
            ScoreCard(score: result.misleadingScore),

            const SizedBox(height: 24),

            // Tespit Edilen Görseller
            _buildSection(
              'Ambalajda Tespit Edilen Görseller',
              result.detectedVisuals,
              Colors.blue,
            ),

            const SizedBox(height: 16),

            // Gerçek İçerikler
            IngredientList(ingredients: result.actualIngredients),

            const SizedBox(height: 16),

            // Sağlık Riski
            _buildHealthRisk(result.healthRisk),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> items, Color color) {
    final textColor = Color.alphaBlend(
      Colors.black.withValues(alpha: 0.3),
      color,
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((item) {
                return Chip(
                  label: Text(item),
                  backgroundColor: color.withValues(alpha: 0.2),
                  labelStyle: TextStyle(color: textColor),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthRisk(String risk) {
    Color riskColor;
    IconData riskIcon;

    switch (risk.toLowerCase()) {
      case 'düşük':
        riskColor = Colors.green;
        riskIcon = Icons.check_circle;
        break;
      case 'orta':
        riskColor = Colors.orange;
        riskIcon = Icons.warning;
        break;
      case 'yüksek':
        riskColor = Colors.red;
        riskIcon = Icons.error;
        break;
      default:
        riskColor = Colors.grey;
        riskIcon = Icons.help;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(riskIcon, color: riskColor, size: 32),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sağlık Risk Seviyesi',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  risk.toUpperCase(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: riskColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}