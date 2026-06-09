import '../utils/daily_challenge.dart';

class UserProfile {
  const UserProfile({
    required this.xp,
    this.username = 'Jogador',
    this.lastDailyChallenge,
  });

  /// Experiência total acumulada pelo jogador.
  final int xp;

  /// Nome de exibição do jogador (usado, por exemplo, no ranking).
  final String username;

  /// Chave (yyyy-MM-dd) do último dia em que o desafio diário foi concluído.
  ///
  /// É `null` quando o jogador ainda nunca jogou o desafio.
  final String? lastDailyChallenge;

  static const int xpPerLevel = 500;

  /// O nível começa em 1 e sobe a cada 500 XP.
  int get level => 1 + (xp / xpPerLevel).floor();

  /// XP acumulado dentro do nível atual.
  int get xpToLevelUp => xp % xpPerLevel;

  /// Valor entre 0 e 1 usado pela barra de progresso.
  double get levelProgress => xpToLevelUp / xpPerLevel;

  /// Indica se o desafio diário ainda pode ser jogado hoje.
  bool get dailyChallengeAvailable =>
      lastDailyChallenge != DailyChallenge.today();

  /// Constrói um perfil a partir dos dados de um documento Firestore.
  factory UserProfile.fromMap(Map<String, dynamic>? data) {
    final rawName = (data?['username'] as String?)?.trim();
    return UserProfile(
      xp: (data?['xp'] as num?)?.toInt() ?? 0,
      username: (rawName == null || rawName.isEmpty) ? 'Jogador' : rawName,
      lastDailyChallenge: data?['lastDailyChallenge'] as String?,
    );
  }
}
