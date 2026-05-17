import 'package:http/http.dart' as http;
import 'dart:convert';

class TranslationApiClient {

  Future<String> translate({
    required String content,
  }) async {

    final url = Uri.parse(
      'https://api.mymemory.translated.net/get?q=$content&langpair=en|pt-PT&de=matheus.maia22@gmail.com',
    );
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Falha ao solicitar tradução");
    }

    final decoded = json.decode(response.body) as Map<String, dynamic>;

    if (decoded['responseStatus'] as int != 200) {
      throw Exception("Falha ao receber tradução");
    }
    return decoded['responseData']['translatedText'] as String;
  }
}


