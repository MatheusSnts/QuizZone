import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/quiz_question.dart';

/// Cache de perguntas traduzidas no Firestore.
class QuestionDatabase {
  final CollectionReference<Map<String, dynamic>> _questions =
      FirebaseFirestore.instance.collection('questions');


/// Procura uma pergunta pela versão original para evitar traduções repetidas.
  Future<QuizQuestion?> findByOriginalQuestion(String originalQuestion) async {
    final snapshot = await _questions
        .where('originalQuestion', isEqualTo: originalQuestion)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return QuizQuestion.fromFirestore(snapshot.docs.first);
  }

 /// Guarda uma pergunta traduzida e devolve o modelo com o id do documento.
  Future<QuizQuestion> save(QuizQuestion question) async {
    final ref = await _questions.add(question.toFirestore());
    return question.copyWith(id: ref.id);
  }
}
