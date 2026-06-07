import 'dart:convert';
import 'package:html_unescape/html_unescape.dart';
import 'package:http/http.dart' as http;

/// Cliente HTTP para traduzir texto inglês para português de Portugal.
class TranslationApiClient {
  /// Traduz conteúdo mantendo texto vazio sem pedido externo.
  Future<String> translate({
    required String content,
  }) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return content;

 // MyMemory exige o par de línguas e um email de contacto.
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

 // Algumas traduções chegam com entidades HTML, por exemplo &quot;.
    final translated = decoded['responseData']['translatedText'] as String;
    return HtmlUnescape().convert(translated);
  }

}
