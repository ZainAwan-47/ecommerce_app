import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dashboard_stats.dart';
import '../constants/order_constants.dart';

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

        double revenue = 0.0;
        int pendingOrders = 0;

        for (final doc in orderSnapshot.docs) {
          final data = doc.data();
          final paymentStatus = (data["paymentStatus"] ?? "").toString().toLowerCase();
          final orderStatus = (data["orderStatus"] ?? data["status"] ?? "").toString().toLowerCase();
          final double total = ((data["total"] ?? data["totalAmount"] ?? 0) as num).toDouble();

          // 1. Revenue: Sum verified payments, subtract if cancelled after verification
          if (paymentStatus == PaymentStatus.verified || paymentStatus == "verified") {
            if (orderStatus == OrderStatus.cancelled || orderStatus == "cancelled") {
              revenue -= total;
            } else {
              revenue += total;
            }
          }

          // 2. Pending Orders: Strictly count active pending orders (exclude cancelled/rejected)
          bool isPending = (orderStatus == OrderStatus.pending || orderStatus == "pending");
          bool isRejected = (paymentStatus == PaymentStatus.rejected || paymentStatus == "rejected");
          bool isCancelled = (orderStatus == OrderStatus.cancelled || orderStatus == "cancelled");

          if (isPending && !isRejected && !isCancelled) {
            pendingOrders++;
          }
        }

        return DashboardStats(
          revenue: revenue < 0 ? 0.0 : revenue,
          totalOrders: orderSnapshot.docs.length,
          totalProducts: productSnapshot.docs.length,
          totalUsers: userSnapshot.docs.length,
          pendingOrders: pendingOrders,
        );
      },
    );
  }
}