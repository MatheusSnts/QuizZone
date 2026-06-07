import 'package:http/http.dart' as http;
import 'dart:convert';

/// Cliente HTTP para obter perguntas da Open Trivia Database.
class OpenTriviaApiClient {
 // A API usa tokens para reduzir repetição de perguntas durante uma sessão.
  String? token;
  DateTime? tokenValidUntil;
  final Duration tokenDuration = Duration(hours: 6);
  final Duration safetyOffsetDuration = Duration(minutes: 5);

 /// Obtém ou reutiliza um token válido para pedidos à Open Trivia.
  Future<String> _getToken() async {
    if (token != null &&
        tokenValidUntil!.isBefore(
          DateTime.now().subtract(safetyOffsetDuration),
        )) {
      return token as String;
    }

    final url = Uri.parse('https://opentdb.com/api_token.php?command=request');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Falha ao solicitar token Open Trivia");
    }

    final decoded = json.decode(response.body) as Map<String, dynamic>;

    if (decoded['response_code'] as int != 0) {
      throw Exception("Falha ao receber token Open Trivia");
    }

    token = decoded['token'] as String;
    tokenValidUntil = DateTime.now().add(tokenDuration);
    return token as String;
  }

/// Pede perguntas aleatórias à API, opcionalmente filtradas por categoria.
  Future<List<OpenTriviaQuestion>> getRandomQuestions({
    required int amount,
    int? category,
    String type = 'multiple',
  }) async {
    if (amount < 1 || amount > 50) {
      throw Exception("Amount deve ser entre 1 e 50");
    }

    final params = <String, String>{
      'amount': amount.toString(),
      'type': type,
      'token': await _getToken(),
      'encode': 'url3986',
    };

    if (category != null) {
      params['category'] = category.toString();
    }

    final url = Uri.https('opentdb.com', '/api.php', params);
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Falha ao solicitar questões Open Trivia");
    }

    final decoded = json.decode(response.body) as Map<String, dynamic>;

    if (decoded['response_code'] as int != 0) {
      throw Exception("Falha ao receber questões Open Trivia");
    }

    return List<Map<String, dynamic>>.from(
      decoded['results'],
    ).map((e) => OpenTriviaQuestion.fromJson(e)).toList();
  }
}
/// Modelo cru devolvido pela Open Trivia API antes da tradução.
class OpenTriviaQuestion {
  final String type;
  final String difficulty;
  final String category;
  final String question;
  final String correctAnswer;
  final List<String> incorrectAnswers;

  OpenTriviaQuestion({
    required this.type,
    required this.difficulty,
    required this.category,
    required this.question,
    required this.correctAnswer,
    required this.incorrectAnswers,
  });

/// A API devolve texto codificado em URL, por isso é descodificado aqui.
  factory OpenTriviaQuestion.fromJson(Map<String, dynamic> json) =>
      OpenTriviaQuestion(
        type: Uri.decodeComponent(json['type'] as String),
        difficulty: Uri.decodeComponent(json['difficulty'] as String),
        category: Uri.decodeComponent(json['category'] as String),
        question: Uri.decodeComponent(json['question'] as String),
        correctAnswer: Uri.decodeComponent(json['correct_answer'] as String),
        incorrectAnswers: (json['incorrect_answers'] as List)
            .map((e) => Uri.decodeComponent(e as String))
            .toList(),
      );

  /// Útil para debug ou persistência temporária do formato original.
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'difficulty': difficulty,
      'category': category,
      'question': question,
      'correctAnswer': correctAnswer,
      'incorrectAnswers': incorrectAnswers,
    };
  }
}
