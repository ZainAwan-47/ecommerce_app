import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/dashboard_stats.dart';

class DashboardService {
  DashboardService._();

  static final DashboardService instance = DashboardService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<DashboardStats> dashboardStream() {
    return _firestore.collection("orders").snapshots().asyncMap(
      (orderSnapshot) async {
        final productsFuture = _firestore.collection("products").get();
        final usersFuture = _firestore.collection("users").get();

        final productSnapshot = await productsFuture;
        final userSnapshot = await usersFuture;

        double revenue = 0;
        int pendingOrders = 0;

        for (final doc in orderSnapshot.docs) {
          final data = doc.data();

          revenue +=
              ((data["totalAmount"] ?? 0) as num).toDouble();

          if ((data["status"] ?? "") == "Pending") {
            pendingOrders++;
          }
        }

        return DashboardStats(
          revenue: revenue,
          totalOrders: orderSnapshot.docs.length,
          totalProducts: productSnapshot.docs.length,
          totalUsers: userSnapshot.docs.length,
          pendingOrders: pendingOrders,
        );
      },
    );
  }
}