import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/journal_entry.dart';
import '../models/app_user.dart';

class FirebaseService {
  // Instance Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===== GESTION UTILISATEUR =====

  // Sauvegarder l'utilisateur dans Firestore à l'inscription
  Future<void> saveUser(AppUser user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(user.toMap());
      print("Utilisateur sauvegardé : ${user.email}");
    } catch (e) {
      print("Erreur saveUser : $e");
    }
  }

  // ===== GESTION DES ENTRÉES =====

  // Ajouter une entrée
  Future<void> addEntry(JournalEntry entry) async {
    try {
      await _firestore
          .collection('entries')
          .doc(entry.id)
          .set(entry.toMap());
      print("Entrée ajoutée : ${entry.id}");
    } catch (e) {
      print("Erreur addEntry : $e");
      rethrow; // on relance l'erreur pour que le provider puisse la gérer
    }
  }

  // Stream = données en temps réel (se met à jour automatiquement)
Stream<List<JournalEntry>> getEntriesStream(String userId) {
  return _firestore
      .collection('entries')
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((snapshot) {
        final entries = snapshot.docs.map((doc) {
          return JournalEntry.fromMap(doc.data());
        }).toList();

        // Tri côté Flutter — plus besoin d'index Firestore
        entries.sort((a, b) => b.date.compareTo(a.date));
        return entries;
      });
}

  // Supprimer une entrée
  Future<void> deleteEntry(String entryId) async {
    try {
      await _firestore.collection('entries').doc(entryId).delete();
      print("Entrée supprimée : $entryId");
    } catch (e) {
      print("Erreur deleteEntry : $e");
      rethrow;
    }
  }
}