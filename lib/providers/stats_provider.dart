import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/journal_entry.dart';
import 'journal_provider.dart';

final statsProvider = Provider<Map<String, dynamic>>((ref) {
  // On écoute le stream Firestore
  final entriesAsync = ref.watch(entriesStreamProvider);

  return entriesAsync.when(
    data: (entries) => _calculateStats(entries),
    loading: () => _emptyStats(),
    error: (_, __) => _emptyStats(),
  );
});

Map<String, dynamic> _calculateStats(List<JournalEntry> entries) {
  if (entries.isEmpty) return _emptyStats();

  // Compter les humeurs
  int positif = entries.where((e) => e.mood == 'positif').length;
  int negatif = entries.where((e) => e.mood == 'negatif').length;
  int neutre = entries.where((e) => e.mood == 'neutre').length;

  // Score moyen
  double scoreMoyen = entries.map((e) => e.score).reduce((a, b) => a + b)
      / entries.length;

  // Données pour le graphique (7 derniers jours)
  final now = DateTime.now();
  List<Map<String, dynamic>> chartData = List.generate(7, (i) {
    final day = now.subtract(Duration(days: 6 - i));
    final dayEntries = entries.where((e) =>
      e.date.day == day.day &&
      e.date.month == day.month &&
      e.date.year == day.year
    ).toList();

    double avgScore = dayEntries.isEmpty
        ? 0.0
        : dayEntries.map((e) => e.score).reduce((a, b) => a + b)
            / dayEntries.length;

    return {
      'day': '${day.day}/${day.month}',
      'score': avgScore,
      'count': dayEntries.length,
    };
  });

  return {
    'total': entries.length,
    'positif': positif,
    'negatif': negatif,
    'neutre': neutre,
    'scoreMoyen': scoreMoyen,
    'chartData': chartData,
  };
}

Map<String, dynamic> _emptyStats() {
  return {
    'total': 0,
    'positif': 0,
    'negatif': 0,
    'neutre': 0,
    'scoreMoyen': 0.0,
    'chartData': <Map<String, dynamic>>[],
  };
}