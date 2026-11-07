import 'package:flutter/material.dart';
import 'package:sentiment_journal/widgets/mood_badge.dart';
import '../models/journal_entry.dart';

class EntryCard extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback onDelete;

  const EntryCard({
    super.key,
    required this.entry,
    required this.onDelete,
  });

  // Couleur selon l'humeur
  Color get _moodColor {
    switch (entry.mood) {
      case 'positif':
        return Colors.green;
      case 'negatif':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  // Emoji selon l'humeur
  String get _moodEmoji {
    switch (entry.mood) {
      case 'positif':
        return '😊';
      case 'negatif':
        return '😢';
      default:
        return '😐';
    }
  }

  // Formater la date
  String get _formattedDate {
    final d = entry.date;
    return '${d.day}/${d.month}/${d.year} à ${d.hour}h${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        border: Border(
          left: BorderSide(color: _moodColor, width: 4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header : emoji + date + supprimer
            Row(
              children: [
                Text(_moodEmoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _formattedDate,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Texte de l'entrée (max 3 lignes)
            Text(
              entry.text,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 10),

            // Badge humeur + score
            Row(
              children: [
                MoodBadge(mood: entry.mood),
              ],
            ),
          ],
        ),
      ),
    );
  }
}