import '../models/category.dart';
import '../models/quiz_question.dart';
import 'open_trivia_api_service.dart';
import '../database/question_database.dart';
import 'translation_api_service.dart';

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


  Future<List<QuizQuestion>> startCategoryQuiz(int categoryId) {
    return startQuiz(amount: questionsPerGame, categoryId: categoryId);
  }

  Future<List<QuizQuestion>> startQuiz({
    required int amount,
    int? categoryId,
  }) async {
    final rawQuestions = await _triviaApi.getRandomQuestions(
      amount: amount,
      category: categoryId,
    );

    final result = <QuizQuestion>[];
    for (final raw in rawQuestions) {
      categoryId = categoryId ?? _categoryIdFromName(raw.category);

      final cached = await _database.findByOriginalQuestion(raw.question);
      if (cached != null) {
        result.add(cached);
        continue;
      }
      result.add(await _translateAndSave(raw, categoryId));
    }
    return result;
  }

  int _categoryIdFromName(String name) {
    return categories
        .firstWhere((c) => c.name == name)
        .id;
  }

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
