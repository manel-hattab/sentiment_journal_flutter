class SentimentResult {
  final String label;     
  final double score;     
  final String emoji;     

  SentimentResult({
    required this.label,
    required this.score,
    required this.emoji,
  });

  // Construire depuis la réponse JSON de l'API
  factory SentimentResult.fromJson(Map<String, dynamic> json) {
    // On va adapter ça selon l'API choisie (Claude ou HuggingFace)
    String rawLabel = json['label'] ?? 'NEUTRAL';
    double rawScore = (json['score'] ?? 0.0).toDouble();

    String label;
    String emoji;

    // Normaliser les labels selon ce que l'API retourne
    if (rawLabel.toUpperCase().contains('POS')) {
      label = 'positif';
      emoji = '😊';
    } else if (rawLabel.toUpperCase().contains('NEG')) {
      label = 'négatif';
      emoji = '😢';
    } else {
      label = 'neutre';
      emoji = '😐';
    }

    return SentimentResult(
      label: label,
      score: rawScore,
      emoji: emoji,
    );
  }

  // Fallback si l'API ne répond pas
  factory SentimentResult.neutral() {
    return SentimentResult(
      label: 'neutre',
      score: 0.0,
      emoji: '😐',
    );
  }
}