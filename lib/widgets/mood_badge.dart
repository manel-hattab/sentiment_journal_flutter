import 'package:flutter/material.dart';

class MoodBadge extends StatelessWidget {
  final String mood;
  final bool showEmoji;

  const MoodBadge({
    super.key,
    required this.mood,
    this.showEmoji = true,
  });

  Color get _color {
    switch (mood) {
      case 'positif': return Colors.green;
      case 'negatif': return Colors.red;
      default: return Colors.orange;
    }
  }

  String get _emoji {
    switch (mood) {
      case 'positif': return '😊';
      case 'negatif': return '😢';
      default: return '😐';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showEmoji) ...[
            Text(_emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
          ],
          Text(
            mood.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}