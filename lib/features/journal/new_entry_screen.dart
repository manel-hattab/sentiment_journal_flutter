import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/journal_provider.dart';
import '../../models/sentiment_result.dart';
import '../shell/main_shell.dart';

class NewEntryScreen extends ConsumerStatefulWidget {
  const NewEntryScreen({super.key});

  @override
  ConsumerState<NewEntryScreen> createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends ConsumerState<NewEntryScreen> {
  final _textController = TextEditingController();
  bool _isAnalyzing = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _analyzeAndSave() async {
    // Vérifier que le texte n'est pas vide
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Écris quelque chose avant d\'analyser 😊'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Vérifier qu'il y a au moins 10 caractères
    if (_textController.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Écris au moins quelques mots...'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final userId = ref.read(authProvider).value?.uid ?? '';

      // Appel au provider — analyse + sauvegarde
      final result = await ref.read(journalProvider.notifier).addEntry(
            _textController.text.trim(),
            userId,
          );

      setState(() {
        _isAnalyzing = false;
      });

      // Afficher le résultat avec une bottomSheet
      if (mounted) {
        _showResultSheet(result);
      }
    } catch (e) {
      setState(() => _isAnalyzing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Sheet de résultat après analyse
  void _showResultSheet(SentimentResult result) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(result.emoji, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              'Humeur détectée : ${result.label.toUpperCase()}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Score : ${result.score.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Retourner à l'accueil et vider le champ
                  _textController.clear();
                  ref.read(shellIndexProvider.notifier).state = 0;
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Voir mes entrées'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final charCount = _textController.text.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        title: const Text('✍️ Nouvelle entrée'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Indication date du jour
            Text(
              _getTodayDate(),
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
            const SizedBox(height: 16),

            // Zone de texte principale
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _textController,
                maxLines: 12,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText:
                      'Comment tu te sens aujourd\'hui ?\n\nÉcris librement, l\'IA analysera ton humeur...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(20),
                ),
                style: const TextStyle(fontSize: 16, height: 1.6),
              ),
            ),
            const SizedBox(height: 8),

            // Compteur de caractères
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$charCount caractères',
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              ),
            ),
            const SizedBox(height: 24),

            // Bouton analyser
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _analyzeAndSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: _isAnalyzing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.psychology),
                label: Text(
                  _isAnalyzing ? 'Analyse en cours...' : 'Analyser mon humeur',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),

            // Message pendant l'analyse
            if (_isAnalyzing) ...[
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  '🤖 L\'IA analyse ton texte...',
                  style: TextStyle(color: Colors.deepPurple),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getTodayDate() {
    final now = DateTime.now();
    final days = [
      'Lundi', 'Mardi', 'Mercredi',
      'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'
    ];
    final months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${days[now.weekday - 1]} ${now.day} ${months[now.month - 1]} ${now.year}';
  }
}