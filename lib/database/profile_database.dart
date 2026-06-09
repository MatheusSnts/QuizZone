import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile.dart';

class ProfileDatabase {
  final CollectionReference<Map<String, dynamic>> _users =
      FirebaseFirestore.instance.collection('users');

  Stream<UserProfile> stream(String uid) {
    return _users.doc(uid).snapshots().map(
          (doc) => UserProfile.fromMap(doc.data()),
        );
  }

  Future<UserProfile> get(String uid) async {
    final doc = await _users.doc(uid).get();
    return UserProfile.fromMap(doc.data());
  }

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

  Future<void> addXp(String uid, int amount) async {
    await _users.doc(uid).set({
      'xp': FieldValue.increment(amount),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

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
