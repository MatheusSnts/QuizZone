/// Configuração partilhada do desafio diário.
///
/// O desafio é um jogo normal de 10 perguntas de dificuldade `hard`, que cada
/// utilizador só pode jogar uma vez por dia.
class DailyChallenge {
  const DailyChallenge._();

  /// Número de perguntas do desafio.
  static const int questionAmount = 10;

  /// Dificuldade pedida à Open Trivia API.
  static const String difficulty = 'hard';

  /// "Chave do dia" (yyyy-MM-dd) usada para limitar o desafio a uma vez por dia.
  /// Comparar duas chaves diz se foram geradas no mesmo dia de calendário.
  static String format(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  /// Chave do dia atual (hora local).
  static String today() => format(DateTime.now());
}
