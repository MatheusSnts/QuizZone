import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile.dart';

/// Acesso aos dados de perfil dos jogadores no Firestore.
class ProfileDatabase {
  final CollectionReference<Map<String, dynamic>> _users =
      FirebaseFirestore.instance.collection('users');

  /// Observa alterações de XP em tempo real para atualizar a UI.
  Stream<UserProfile> stream(String uid) {
    return _users.doc(uid).snapshots().map(
          (doc) => UserProfile(xp: (doc.data()?['xp'] as num?)?.toInt() ?? 0),
        );
  }

/// Lê o perfil uma única vez.
  Future<UserProfile> get(String uid) async {
    final doc = await _users.doc(uid).get();
    return UserProfile(xp: (doc.data()?['xp'] as num?)?.toInt() ?? 0);
  }

/// Soma XP ao perfil, criando o documento se ainda não existir.
  Future<void> addXp(String uid, int amount) async {
    await _users.doc(uid).set({
      'xp': FieldValue.increment(amount),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
