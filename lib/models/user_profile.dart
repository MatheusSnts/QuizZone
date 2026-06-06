class UserProfile {
  const UserProfile({required this.xp});

  final int xp;

  static const int xpPerLevel = 500;

  int get level => 1 + (xp / xpPerLevel).floor();

  int get xpToLevelUp => xp % xpPerLevel;

  double get levelProgress => xpToLevelUp / xpPerLevel;
}
