import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/journal_entry.dart';
import '../models/sentiment_result.dart';
import '../services/firebase_service.dart';
import '../services/local_storage_service.dart';
import '../services/sentiment_service.dart';
import 'auth_provider.dart';

// Stream des entrées depuis Firestore — se met à jour en temps réel
final entriesStreamProvider = StreamProvider<List<JournalEntry>>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return const Stream.empty();
      return FirebaseService().getEntriesStream(user.uid);
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

class JournalNotifier extends AsyncNotifier<List<JournalEntry>> {
  final FirebaseService _firebaseService = FirebaseService();
  final LocalStorageService _localStorage = LocalStorageService();
  final SentimentService _sentimentService = SentimentService();

  @override
Future<List<JournalEntry>> build() async {
  // Toujours charger depuis le cache local au démarrage
  // Si Firebase répond → le stream prend le relais automatiquement
  final localEntries = await _localStorage.getLocalEntries();
  print("Cache local : ${localEntries.length} entrées");
  return localEntries;
}

Future<SentimentResult> addEntry(String text, String userId) async {
  state = const AsyncLoading();

  // 1. Analyser le sentiment
  final sentiment = await _sentimentService.analyze(text);

  // 2. Créer l'entrée
  final entry = JournalEntry(
    id: const Uuid().v4(),
    userId: userId,
    text: text,
    mood: sentiment.label,
    score: sentiment.score,
    date: DateTime.now(),
  );

  final current = state.value ?? [];
  final updated = [entry, ...current];

  // 3. Sauvegarder localement d'abord (offline-first)
  await _localStorage.saveEntries(updated);
  state = AsyncData(updated);

  // 4. Essayer d'envoyer vers Firebase
  try {
    await _firebaseService.addEntry(entry);
    print("Entrée synchronisée avec Firebase ");
  } catch (e) {
    // Pas de connexion — entrée gardée localement
    print("Pas de connexion — entrée sauvegardée localement ");
  }

  return sentiment;
}

  // Supprimer une entrée
  Future<void> deleteEntry(String entryId) async {
    try {
      await _firebaseService.deleteEntry(entryId);
      final current = state.value ?? [];
      final updated = current.where((e) => e.id != entryId).toList();
      await _localStorage.saveEntries(updated);
      state = AsyncData(updated);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

final journalProvider =
    AsyncNotifierProvider<JournalNotifier, List<JournalEntry>>(
  JournalNotifier.new,
);