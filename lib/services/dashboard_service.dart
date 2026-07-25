import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> getTotalProducts() async {
    final snapshot = await _firestore.collection("products").get();
    return snapshot.docs.length;
  }

  Future<int> getTotalUsers() async {
    final snapshot = await _firestore.collection("users").get();
    return snapshot.docs.length;
  }

  Future<int> getTotalOrders() async {
    final snapshot = await _firestore.collection("orders").get();
    return snapshot.docs.length;
  }

  Future<int> getPendingOrders() async {
    final snapshot = await _firestore
        .collection("orders")
        .where("status", isEqualTo: "Pending")
        .get();

    return snapshot.docs.length;
  }

  Future<double> getTotalRevenue() async {
    final snapshot = await _firestore.collection("orders").get();

    double revenue = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();

      revenue +=
          (data["totalAmount"] ?? 0).toDouble();
    }

    return revenue;
  }
}