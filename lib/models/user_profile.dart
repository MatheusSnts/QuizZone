
class UserProfile {
  const UserProfile({
    required this.xp,
    this.username = 'Jogador',
  });

  final int xp;
  final String username;

  static const int xpPerLevel = 500;

  int get level => 1 + (xp / xpPerLevel).floor();

  int get xpToLevelUp => xp % xpPerLevel;

  double get levelProgress => xpToLevelUp / xpPerLevel;

  factory UserProfile.fromMap(Map<String, dynamic>? data) {
    return UserProfile(
      xp: (data?['xp'] as num?)?.toInt() ?? 0,
      username: data?['username'] ?? 'Jogador',
    );
  }
}