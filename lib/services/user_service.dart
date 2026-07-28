import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  /// Stream all users
  Stream<List<UserModel>> getUsers() {
    return _firestore
        .collection("users")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => UserModel.fromMap(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  /// Update user active status
  Future<void> toggleUserStatus({
    required String uid,
    required bool isActive,
  }) async {
    await _firestore
        .collection("users")
        .doc(uid)
        .update({
      "isActive": isActive,
    });
  }

  /// Delete user document
  Future<void> deleteUser(
    String uid,
  ) async {
    await _firestore
        .collection("users")
        .doc(uid)
        .delete();
  }

  /// Total orders of a user
  Future<int> getUserOrderCount(
    String uid,
  ) async {
    final snapshot = await _firestore
        .collection("orders")
        .where("userId", isEqualTo: uid)
        .get();

    return snapshot.docs.length;
  }

  /// Total amount spent by a user
  Future<double> getUserTotalSpent(
    String uid,
  ) async {
    final snapshot = await _firestore
        .collection("orders")
        .where("userId", isEqualTo: uid)
        .get();

    double total = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();

      total +=
          (data["total"] ?? 0)
              .toDouble();
    }

    return total;
  }
  Future<void> updateUserRole(String uid, String newRole) async {
  await _firestore.collection('users').doc(uid).update({
    'role': newRole,
  });
}
}