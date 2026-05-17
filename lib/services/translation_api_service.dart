import 'dart:convert';
import 'package:html_unescape/html_unescape.dart';
import 'package:http/http.dart' as http;

class TranslationApiClient {
  Future<String> translate({
    required String content,
  }) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return content;


    final url = Uri.https('api.mymemory.translated.net', '/get', {
      'q': trimmed,
      'langpair': 'en|pt-PT',
      'de': 'matheus.maia22@gmail.com',
    });

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Falha ao solicitar tradução");
    }

    final decoded = json.decode(response.body) as Map<String, dynamic>;

    if (decoded['responseStatus'] != 200) {
      throw Exception("Falha ao receber tradução");
    }

    final translated = decoded['responseData']['translatedText'] as String;
    return HtmlUnescape().convert(translated);
  }

}
