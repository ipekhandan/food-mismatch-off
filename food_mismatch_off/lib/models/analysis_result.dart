class AnalysisResult {
  final int misleadingScore;
  final List<String> detectedVisuals;
  final List<String> actualIngredients;
  final String healthRisk;

  AnalysisResult({
    required this.misleadingScore,
    required this.detectedVisuals,
    required this.actualIngredients,
    required this.healthRisk,
  });

  // Mock data için factory
  factory AnalysisResult.mock() {
    return AnalysisResult(
      misleadingScore: 75,
      detectedVisuals: ['çilek', 'süt', 'bal'],
      actualIngredients: ['su', 'şeker', 'çilek aroması', 'E211', 'E110'],
      healthRisk: 'orta',
    );
  }
}
