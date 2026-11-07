import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/journal_entry.dart';

class LocalStorageService {
  static const String _entriesKey = 'local_entries';

  // Sauvegarder les entrées localement
  Future<void> saveEntries(List<JournalEntry> entries) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<String> encoded =
          entries.map((e) => jsonEncode(e.toMap())).toList();
      await prefs.setStringList(_entriesKey, encoded);
      print("${entries.length} entrées sauvegardées localement");
    } catch (e) {
      print("Erreur saveEntries local : $e");
    }
  }

  // Lire les entrées locales
  Future<List<JournalEntry>> getLocalEntries() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<String>? encoded = prefs.getStringList(_entriesKey);

      if (encoded == null || encoded.isEmpty) return [];

      return encoded
          .map((e) => JournalEntry.fromMap(jsonDecode(e)))
          .toList();
    } catch (e) {
      print("Erreur getLocalEntries : $e");
      return [];
    }
  }

  // Vider le cache local (utile au logout)
  Future<void> clearEntries() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_entriesKey);
  }
}