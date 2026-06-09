import '../models/category.dart';
import '../models/quiz_question.dart';
import 'open_trivia_api_service.dart';
import '../database/question_database.dart';
import 'translation_api_service.dart';

/// Orquestra a criação de partidas: API externa, tradução e cache local.
class QuizService {
  QuizService({
    OpenTriviaApiClient? triviaApi,
    TranslationApiClient? translationApi,
    QuestionDatabase? database,
  })  : _triviaApi = triviaApi ?? OpenTriviaApiClient(),
        _translationApi = translationApi ?? TranslationApiClient(),
        _database = database ?? QuestionDatabase();

  final OpenTriviaApiClient _triviaApi;
  final TranslationApiClient _translationApi;
  final QuestionDatabase _database;

  static const int questionsPerGame = 10;

  /// Atalho para começar um jogo normal por categoria.
  Future<List<QuizQuestion>> startCategoryQuiz(int categoryId) {
    return startQuiz(amount: questionsPerGame, categoryId: categoryId);
  }

 /// Busca perguntas, reutiliza cache quando possível e traduz as novas.
 ///
 /// `difficulty` ('easy'/'medium'/'hard') filtra a dificuldade; quando nulo a
 /// API devolve perguntas de dificuldades mistas.
  Future<List<QuizQuestion>> startQuiz({
    required int amount,
    int? categoryId,
    String? difficulty,
  }) async {
    final rawQuestions = await _triviaApi.getRandomQuestions(
      amount: amount,
      category: categoryId,
      difficulty: difficulty,
    );

    final result = <QuizQuestion>[];
    for (final raw in rawQuestions) {
      // Cada pergunta usa a sua própria categoria; num jogo multi-categoria
      // (categoryId nulo) o id é deduzido do nome devolvido pela API.
      final questionCategoryId = categoryId ?? _categoryIdFromName(raw.category);

 // Se a pergunta já existe traduzida no Firestore, evita nova tradução.
      final cached = await _database.findByOriginalQuestion(raw.question);
      if (cached != null) {
        result.add(cached);
        continue;
      }
      result.add(await _translateAndSave(raw, questionCategoryId));
    }
    return result;
  }

/// Liga o nome textual da API ao id usado pela lista de categorias da app.
///
/// Recorre a Conhecimento Geral (id 9) se o nome não constar da lista local.
  int _categoryIdFromName(String name) {
    return categories
        .firstWhere((c) => c.name == name, orElse: () => categories.first)
        .id;
  }

 /// Traduz pergunta e respostas em paralelo, guarda e devolve a pergunta final.
  Future<QuizQuestion> _translateAndSave(
    OpenTriviaQuestion raw,
    int categoryId,
  ) async {
    final translations = await Future.wait([
      _translationApi.translate(content: raw.question),
      _translationApi.translate(content: raw.correctAnswer),
      ...raw.incorrectAnswers.map(
        (answer) => _translationApi.translate(content: answer),
      ),
    ]);

    final question = QuizQuestion(
      originalQuestion: raw.question,
      question: translations[0],
      originalCorrectAnswer: raw.correctAnswer,
      correctAnswer: translations[1],
      originalIncorrectAnswers: raw.incorrectAnswers,
      incorrectAnswers: translations.sublist(2),
      category: raw.category,
      categoryId: categoryId,
      difficulty: raw.difficulty,
      type: raw.type,
    );

    return _database.save(question);
  }
}
