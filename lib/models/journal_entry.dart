class JournalEntry {
  final String id;
  final String userId;    // pour lier l'entrée à l'utilisateur connecté
  final String text;      // le texte écrit par l'utilisateur
  final String mood;      // résultat IA : "positif", "negatif", "neutre"
  final double score;     // score entre -1.0 et 1.0
  final DateTime date;

  JournalEntry({
    required this.id,
    required this.userId,
    required this.text,
    required this.mood,
    required this.score,
    required this.date,
  });

  // Comme dans class_produit.dart — pour envoyer vers Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'text': text,
      'mood': mood,
      'score': score,
      'date': date.toIso8601String(),
    };
  }

  // Comme fromMap() — pour lire depuis Firestore
  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      text: map['text'] ?? '',
      mood: map['mood'] ?? 'neutre',
      score: (map['score'] ?? 0.0).toDouble(),
      date: DateTime.parse(map['date']),
    );
  }
}