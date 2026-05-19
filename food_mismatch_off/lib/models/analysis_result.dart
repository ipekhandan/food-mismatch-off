class AnalysisResult {
  final String productName;
  final int misleadingScore;
  final List<String> detectedVisuals;
  final List<String> actualIngredients;
  final String healthRisk;
  final int healthScore;
  final List<String> eCodes;
  final List<String> mismatches;
  final String explanation;
  final String ocrSource;
  final String dataSource;
  final String? imageUrl;

  AnalysisResult({
    required this.productName,
    required this.misleadingScore,
    required this.detectedVisuals,
    required this.actualIngredients,
    required this.healthRisk,
    this.healthScore = 0,
    this.eCodes = const [],
    this.mismatches = const [],
    this.explanation = '',
    this.ocrSource = 'mock',
    this.dataSource = 'mock',
    this.imageUrl,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    List<String> asStringList(dynamic value) {
      if (value is List) {
        return value
            .map((e) => e.toString())
            .where((e) => e.trim().isNotEmpty)
            .toList();
      }

      if (value is String && value.trim().isNotEmpty) {
        return [value.trim()];
      }

      return const [];
    }

    int asInt(dynamic value) {
      if (value is num) {
        return value.round();
      }

      return int.tryParse((value ?? '0').toString()) ?? 0;
    }

    final healthRiskLevel =
        json['health_risk_level'] ??
        json['healthRisk'] ??
        json['health_risk'] ??
        'düşük';

    final image =
        json['image_url'] ??
        json['imageUrl'] ??
        json['front_image_url'] ??
        json['frontImageUrl'];

    return AnalysisResult(
      productName:
          (json['product_name'] ??
                  json['productName'] ??
                  'Analiz Edilen Ürün')
              .toString(),
      misleadingScore: asInt(
        json['misleading_score'] ?? json['misleadingScore'] ?? 0,
      ),
      detectedVisuals: asStringList(
        json['visual_claims'] ?? json['detectedVisuals'],
      ),
      actualIngredients: asStringList(
        json['ingredients'] ?? json['actualIngredients'],
      ),
      healthRisk: healthRiskLevel.toString(),
      healthScore: asInt(
        json['health_score'] ?? json['healthScore'] ?? 0,
      ),
      eCodes: asStringList(json['e_codes'] ?? json['eCodes']),
      mismatches: asStringList(json['mismatches']),
      explanation: (json['explanation'] ?? '').toString(),
      ocrSource: (json['ocr_source'] ?? json['ocrSource'] ?? '').toString(),
      dataSource: (json['data_source'] ?? json['dataSource'] ?? '').toString(),
      imageUrl: image?.toString(),
    );
  }

  factory AnalysisResult.mock() {
    return AnalysisResult(
      productName: 'Çilekli Süt',
      misleadingScore: 75,
      detectedVisuals: ['çilek', 'süt', 'bal'],
      actualIngredients: ['su', 'şeker', 'çilek aroması', 'E211', 'E110'],
      healthRisk: 'orta',
      healthScore: 45,
      eCodes: ['E211', 'E110'],
      mismatches: [
        'Çilek görseli var ancak gerçek çilek yerine aroma ifadesi bulunuyor.',
      ],
      explanation:
          'Ambalajda doğal çilek algısı oluşuyor; içerikte ise gerçek çilek yerine aroma kullanımı görülüyor.',
      ocrSource: 'mock',
      dataSource: 'demo',
      imageUrl: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'product_name': productName,
      'misleadingScore': misleadingScore,
      'misleading_score': misleadingScore,
      'detectedVisuals': detectedVisuals,
      'visual_claims': detectedVisuals,
      'actualIngredients': actualIngredients,
      'ingredients': actualIngredients,
      'healthRisk': healthRisk,
      'health_risk_level': healthRisk,
      'healthScore': healthScore,
      'health_score': healthScore,
      'eCodes': eCodes,
      'e_codes': eCodes,
      'mismatches': mismatches,
      'explanation': explanation,
      'ocrSource': ocrSource,
      'ocr_source': ocrSource,
      'dataSource': dataSource,
      'data_source': dataSource,
      'imageUrl': imageUrl,
      'image_url': imageUrl,
    };
  }
}