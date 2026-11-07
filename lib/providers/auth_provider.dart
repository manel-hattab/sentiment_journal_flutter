import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_user.dart';
import '../services/firebase_service.dart';

// Expose l'utilisateur Firebase en temps réel
// Stream = se met à jour automatiquement quand l'user se connecte/déconnecte
// authStateProvider — écoute le token JWT automatiquement
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Notifier qui gère les actions : login, register, logout
class AuthNotifier extends AsyncNotifier<AppUser?> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Future<AppUser?> build() async {
    // Au démarrage, retourner l'user courant s'il existe
    final user = _auth.currentUser;
    if (user == null) return null;
    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? 'Utilisateur',
    );
  }

  // Inscription
  Future<void> register(String email, String password, String name) async {
    state = const AsyncLoading(); // afficher le loading spinner
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(name);

      final appUser = AppUser(
        uid: credential.user!.uid,
        email: email,
        displayName: name,
      );

      // Sauvegarder dans Firestore
      await _firebaseService.saveUser(appUser);

      state = AsyncData(appUser);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  // Connexion
  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final appUser = AppUser(
        uid: credential.user!.uid,
        email: email,
        displayName: credential.user?.displayName ?? 'Utilisateur',
      );
      state = AsyncData(appUser);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  // Déconnexion
  Future<void> logout() async {
    await _auth.signOut();
    state = const AsyncData(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AppUser?>(
  AuthNotifier.new,
);