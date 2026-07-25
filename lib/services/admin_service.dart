import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/admin_model.dart';

class AdminService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  Future<AdminModel?> getCurrentAdmin() async {
    final user = _auth.currentUser;

    if (user == null) return null;

    final doc = await _firestore
        .collection("admins")
        .doc(user.uid)
        .get();

    if (!doc.exists) return null;

    return AdminModel.fromMap(
      doc.id,
      doc.data()!,
    );
  }

  Future<bool> isAdmin() async {
    final admin = await getCurrentAdmin();
    return admin != null && admin.role == "admin";
  }
}