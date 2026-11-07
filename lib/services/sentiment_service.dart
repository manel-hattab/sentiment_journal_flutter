import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sentiment_result.dart';

class SentimentService {
  static const String _apiKey = 'YOUR_API_KEY';

  static const String _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  Future<SentimentResult> analyze(String text) async {
    try {
      print("=== SENTIMENT API CALL ===");
      print("Texte : $text");

      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text':
                      'Return ONLY one word: positif, negatif, or neutre. Text: "$text"'
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.1,
            'maxOutputTokens': 500
          }
        }),
      ).timeout(const Duration(seconds: 15));

      print("Status : ${response.statusCode}");
      print("Body : ${response.body}");

      // HANDLE NON-200 RESPONSES

      if (response.statusCode == 503) {
        print("Server busy → retrying...");
        await Future.delayed(const Duration(seconds: 2));
        return analyze(text);
      }

      if (response.statusCode != 200) {
        print("API error");
        return SentimentResult.neutral();
      }

      final data = jsonDecode(response.body);

final candidates = data['candidates'];

if (candidates == null || candidates.isEmpty) {
  print("No candidates returned");
  return SentimentResult.neutral();
}

final candidate = candidates[0];      final content = candidate?['content'];
      final parts = content?['parts'];

      if (parts == null || parts.isEmpty) {
        print("Empty response from AI");
        return SentimentResult.neutral();
      }

      String resultText = parts[0]['text'] ?? "";
      resultText = resultText.toLowerCase().trim();

      print("AI raw result: $resultText");

      // SAFE CLASSIFICATION
String label;
double score;

if (resultText.contains("positif")) {
  label = "positif";
  score = 0.85;
} else if (resultText.contains("negatif") || resultText.contains("négatif")) {
  label = "negatif";  // avec accent pour correspondre à JournalEntry
  score = -0.85;
} else {
  label = "neutre";
  score = 0.60;
}

return SentimentResult(
  label: label,
  score: score,
  emoji: _getEmoji(label),
);
    } catch (e) {
      print("Exception : $e");
      return SentimentResult.neutral();
    }
  }

  String _getEmoji(String label) {
    switch (label) {
      case 'positif':
        return '😊';
      case 'negatif':
        return '😢';
      default:
        return '😐';
    }
  }
}