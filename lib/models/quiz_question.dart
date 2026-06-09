import 'package:cloud_firestore/cloud_firestore.dart';

/// Pergunta já normalizada para ser usada no jogo e guardada no Firestore.
class QuizQuestion {
  const QuizQuestion({
    this.id,
    required this.originalQuestion,
    required this.question,
    required this.originalCorrectAnswer,
    required this.correctAnswer,
    required this.originalIncorrectAnswers,
    required this.incorrectAnswers,
    required this.category,
    required this.categoryId,
    required this.difficulty,
    required this.type,
  });

  final String? id;

  final String originalQuestion;
  final String question;
  final String originalCorrectAnswer;
  final String correctAnswer;
  final List<String> originalIncorrectAnswers;
  final List<String> incorrectAnswers;
  final String category;
  final int categoryId;
  final String difficulty;
  final String type;

  /// Define a recompensa de XP com base na dificuldade original da pergunta.
  int get xpReward {
    switch (difficulty) {
      case 'hard':
        return 30;
      case 'medium':
        return 20;
      default:
        return 10;
    }
  }

  QuizQuestion copyWith({String? id}) => QuizQuestion(
        id: id ?? this.id,
        originalQuestion: originalQuestion,
        question: question,
        originalCorrectAnswer: originalCorrectAnswer,
        correctAnswer: correctAnswer,
        originalIncorrectAnswers: originalIncorrectAnswers,
        incorrectAnswers: incorrectAnswers,
        category: category,
        categoryId: categoryId,
        difficulty: difficulty,
        type: type,
      );

 /// Constrói uma pergunta a partir de um documento guardado no Firestore.
  factory QuizQuestion.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return QuizQuestion(
      id: doc.id,
      originalQuestion: data['originalQuestion'] as String,
      question: data['question'] as String,
      originalCorrectAnswer: data['originalCorrectAnswer'] as String,
      correctAnswer: data['correctAnswer'] as String,
      originalIncorrectAnswers:
          List<String>.from(data['originalIncorrectAnswers'] as List),
      incorrectAnswers: List<String>.from(data['incorrectAnswers'] as List),
      category: data['category'] as String,
      categoryId: (data['categoryId'] as num).toInt(),
      difficulty: data['difficulty'] as String,
      type: data['type'] as String,
    );
  }

 /// Converte a pergunta para o formato persistido na coleção `questions`.
  Map<String, dynamic> toFirestore() => {
        'originalQuestion': originalQuestion,
        'question': question,
        'originalCorrectAnswer': originalCorrectAnswer,
        'correctAnswer': correctAnswer,
        'originalIncorrectAnswers': originalIncorrectAnswers,
        'incorrectAnswers': incorrectAnswers,
        'category': category,
        'categoryId': categoryId,
        'difficulty': difficulty,
        'type': type,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
