import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile.dart';

/// Acesso aos dados de perfil dos jogadores no Firestore.
class ProfileDatabase {
  final CollectionReference<Map<String, dynamic>> _users =
      FirebaseFirestore.instance.collection('users');

  /// Observa alterações de XP em tempo real para atualizar a UI.
  Stream<UserProfile> stream(String uid) {
    return _users.doc(uid).snapshots().map(
          (doc) => UserProfile.fromMap(doc.data()),
        );
  }

  /// Lê o perfil uma única vez.
  Future<UserProfile> get(String uid) async {
    final doc = await _users.doc(uid).get();
    return UserProfile.fromMap(doc.data());
  }

  /// Cria o documento inicial do utilizador no Firestore.
  Future<void> createUser({
    required String uid,
    required String username,
  }) async {
    await _users.doc(uid).set({
      'username': username,
      'xp': 0,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Regista que o desafio diário foi concluído no dia indicado (`dayKey`).
  Future<void> markDailyChallengeDone(String uid, String dayKey) async {
    await _users.doc(uid).set({
      'lastDailyChallenge': dayKey,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Soma XP ao perfil, criando o documento se ainda não existir.
  Future<void> addXp(String uid, int amount) async {
    await _users.doc(uid).set({
      'xp': FieldValue.increment(amount),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Top 50 jogadores ordenados por XP, para o ranking global.
  Stream<List<UserProfile>> leaderboard() {
    return _users
        .orderBy('xp', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserProfile.fromMap(doc.data()))
              .toList(),
        );
  }
}
