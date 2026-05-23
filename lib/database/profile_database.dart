import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile.dart';

class ProfileDatabase {
  final CollectionReference<Map<String, dynamic>> _users =
      FirebaseFirestore.instance.collection('users');


  Stream<UserProfile> stream(String uid) {
    return _users.doc(uid).snapshots().map(
          (doc) => UserProfile(xp: (doc.data()?['xp'] as num?)?.toInt() ?? 0),
        );
  }

  Future<UserProfile> get(String uid) async {
    final doc = await _users.doc(uid).get();
    return UserProfile(xp: (doc.data()?['xp'] as num?)?.toInt() ?? 0);
  }

  Future<void> addXp(String uid, int amount) async {
    await _users.doc(uid).set({
      'xp': FieldValue.increment(amount),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
