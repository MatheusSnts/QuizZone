class UserProfile {
  const UserProfile({required this.xp});

 /// Experiência total acumulada pelo jogador.
  final int xp;

  static const int xpPerLevel = 500;

 /// O nível começa em 1 e sobe a cada 500 XP.
  int get level => 1 + (xp / xpPerLevel).floor();

 /// XP acumulado dentro do nível atual.
  int get xpToLevelUp => xp % xpPerLevel;

  /// Valor entre 0 e 1 usado pela barra de progresso.
  double get levelProgress => xpToLevelUp / xpPerLevel;
}
