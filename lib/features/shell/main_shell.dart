import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../journal/home_screen.dart';
import '../journal/new_entry_screen.dart';
import '../stats/stats_screen.dart';
import '../profile/profile_screen.dart';

// Provider pour garder l'index de la page sélectionnée
final shellIndexProvider = StateProvider<int>((ref) => 0);

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(shellIndexProvider);

    // Les 4 pages
    final pages = [
      const HomeScreen(),
      const NewEntryScreen(),
      const StatsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      // La page courante
      body: pages[currentIndex],

      // Bouton central flottant pour nouvelle entrée
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(shellIndexProvider.notifier).state = 1;
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Barre de navigation 
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Home
            IconButton(
              onPressed: () =>
                  ref.read(shellIndexProvider.notifier).state = 0,
              icon: Icon(
                Icons.home_outlined,
                color: currentIndex == 0
                    ? Colors.deepPurple
                    : Colors.grey,
              ),
              tooltip: 'Accueil',
            ),

            // Espace pour le FAB
            const SizedBox(width: 48),

            // Stats
            IconButton(
              onPressed: () =>
                  ref.read(shellIndexProvider.notifier).state = 2,
              icon: Icon(
                Icons.bar_chart_outlined,
                color: currentIndex == 2
                    ? Colors.deepPurple
                    : Colors.grey,
              ),
              tooltip: 'Statistiques',
            ),

            // Profile
            IconButton(
              onPressed: () =>
                  ref.read(shellIndexProvider.notifier).state = 3,
              icon: Icon(
                Icons.person_outlined,
                color: currentIndex == 3
                    ? Colors.deepPurple
                    : Colors.grey,
              ),
              tooltip: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}