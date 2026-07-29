import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  /// Stream a single user by their UID for live updates
  Stream<UserModel?> getUserStream(String uid) {
    return _firestore
        .collection("users")
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromMap(
        doc.id,
        doc.data()!,
      );
    });
  }

  Future<int> getTotalUsers() async {
    final snapshot = await _firestore.collection("users").get();
    return snapshot.docs.length;
  }

  Future<int> getActiveUsersCount() async {
    final snapshot = await _firestore
        .collection("users")
        .where("isActive", isEqualTo: true)
        .get();
    return snapshot.docs.length;
  }

  Future<int> getInactiveUsersCount() async {
    final snapshot = await _firestore
        .collection("users")
        .where("isActive", isEqualTo: false)
        .get();
    return snapshot.docs.length;
  }

  Future<int> getAdminCount() async {
    final snapshot = await _firestore
        .collection("users")
        .where("role", isEqualTo: "admin")
        .get();
    return snapshot.docs.length;
  }

  Future<int> getCustomerCount() async {
    final snapshot = await _firestore
        .collection("users")
        .where("role", isEqualTo: "customer")
        .get();
    return snapshot.docs.length;
  }

  /// Update user active status
  Future<void> toggleUserStatus({
    required String uid,
    required bool isActive,
  }) async {
    await _firestore.collection("users").doc(uid).update({
      "isActive": isActive,
    });
  }

  /// Delete user document
  Future<void> deleteUser(String uid) async {
    await _firestore.collection("users").doc(uid).delete();
  }

  /// Active Users
  Stream<List<UserModel>> getActiveUsers() {
    return _firestore
        .collection("users")
        .where("isActive", isEqualTo: true)
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

  /// Inactive Users
  Stream<List<UserModel>> getInactiveUsers() {
    return _firestore
        .collection("users")
        .where("isActive", isEqualTo: false)
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

  /// Admins
  Stream<List<UserModel>> getAdmins() {
    return _firestore
        .collection("users")
        .where("role", isEqualTo: "admin")
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

  /// Customers
  Stream<List<UserModel>> getCustomers() {
    return _firestore
        .collection("users")
        .where("role", isEqualTo: "customer")
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

  /// Total orders of a user
  Future<int> getUserOrderCount(String uid) async {
    final snapshot = await _firestore
        .collection("orders")
        .where("userId", isEqualTo: uid)
        .get();
    return snapshot.docs.length;
  }

  /// Total amount spent by a user
  Future<double> getUserTotalSpent(String uid) async {
    final snapshot = await _firestore
        .collection("orders")
        .where("userId", isEqualTo: uid)
        .get();
    double total = 0;
    for (final doc in snapshot.docs) {
      final data = doc.data();
      total += (data["total"] ?? 0).toDouble();
    }
    return total;
  }

  /// Update user role & sync with admins collection
  Future<void> updateUserRole(String uid, String newRole) async {
    final normalizedRole = newRole.toLowerCase();

    // 1. Update the 'users' collection
    await _firestore.collection('users').doc(uid).update({
      'role': normalizedRole,
    });

    // 2. Synchronize with the 'admins' collection checked by AdminService[cite: 4]
    if (normalizedRole == 'admin') {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final userData = userDoc.data() ?? {};

      await _firestore.collection('admins').doc(uid).set({
        'name': userData['name'] ?? 'Admin',
        'email': userData['email'] ?? '',
        'role': 'admin',
        'createdAt': userData['createdAt'] ?? FieldValue.serverTimestamp(),
      });
    } else {
      // If changed back to customer, remove them from the 'admins' collection
      await _firestore.collection('admins').doc(uid).delete();
    }
  }

  Stream<List<OrderModel>> getRecentOrders(
    String userId, {
    int limit = 5,
  }) {
    return _firestore
        .collection("orders")
        .where("userId", isEqualTo: userId)
        .orderBy("createdAt", descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(OrderModel.fromDocument)
              .toList(),
        );
  }
}