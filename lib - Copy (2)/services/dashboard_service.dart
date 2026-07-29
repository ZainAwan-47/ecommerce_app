import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Required for DateFormat

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

  Future<List<Map<String, dynamic>>> getWeeklyRevenue() async {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 6));
    
    // Initialize the last 7 days with 0 revenue
    Map<String, double> dailyRevenue = {};
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final dateString = DateFormat('EEE').format(date);
      dailyRevenue[dateString] = 0.0;
    }

    try {
      final querySnapshot = await _firestore
          .collection('orders')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo))
          .get();

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        
        // Ensure only successful/delivered orders are counted in the chart
        if (data['status'] == 'Delivered' || 
            data['paymentStatus'] == 'paid' || 
            data['orderStatus'] == 'delivered') {
              
          final createdAt = (data['createdAt'] as Timestamp).toDate();
          final dateString = DateFormat('EEE').format(createdAt);
          final totalAmount = ((data['totalAmount'] ?? 0) as num).toDouble();
          
          if (dailyRevenue.containsKey(dateString)) {
            dailyRevenue[dateString] = dailyRevenue[dateString]! + totalAmount;
          }
        }
      }

      // Convert map to a chronological list for the bar chart
      return dailyRevenue.entries
          .map((e) => {'day': e.key, 'revenue': e.value})
          .toList()
          .reversed
          .toList();
    } catch (e) {
      return [];
    }
  }
}