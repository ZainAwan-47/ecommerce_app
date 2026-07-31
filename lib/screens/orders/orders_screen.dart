import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/tab_controller.dart';
import '../auth/login_screen.dart';
import 'order_details_screen.dart';
import '../../core/page_controller_holder.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final width = MediaQuery.sizeOf(context).width;

    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xffFFF9F7),
        appBar: AppBar(
          backgroundColor: const Color(0xffFFF9F7),
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xff3A2B2B),
              size: 18,
            ),
            onPressed: () {
              goBackTab();
            },
          ),
          title: Text(
            "My Orders",
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xff2D2323),
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 72,
                  color: Color(0xff7F4F4F),
                ),
                const SizedBox(height: 20),
                Text(
                  "Login Required",
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff2D2323),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Please sign in to view your orders.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    color: const Color(0xff8D7B7B),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: 220,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff7F4F4F),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Login",
                      style: GoogleFonts.manrope(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffFFF9F7),
      appBar: AppBar(
        backgroundColor: const Color(0xffFFF9F7),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xff3A2B2B),
            size: 18,
          ),
          onPressed: () {
            goBackTab();
          },
        ),
        title: Text(
          "My Orders",
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xff2D2323),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("orders")
            .where("userId", isEqualTo: user.uid)
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: GoogleFonts.manrope(
                  color: Colors.red.shade300,
                  fontSize: 14,
                ),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xff7F4F4F),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 72,
                    color: const Color(0xff8D7B7B).withOpacity(0.4),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "No Orders Yet",
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff2D2323),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Place your first order\nand it will appear here.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      color: const Color(0xff8D7B7B),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: 220,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        goToTab(1);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff7F4F4F),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        "Continue Shopping",
                        style: GoogleFonts.manrope(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final orders = snapshot.data!.docs;
          return RefreshIndicator(
            color: const Color(0xff7F4F4F),
            onRefresh: () async {
              await Future.delayed(
                const Duration(milliseconds: 500),
              );
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final data = order.data() as Map<String, dynamic>? ?? {};
                final products = data['products'] as List<dynamic>? ?? [];
                final itemCount = products.length;
                final Timestamp? timestamp = data['createdAt'] as Timestamp?;
                final DateTime? date = timestamp?.toDate();

                // Extract fields safely
                final String rawStatus = data['status'] ?? 'Pending';
                final String paymentStatus = data['paymentStatus'] ??
                    data['payment_status'] ??
                    'Pending';

                // Dynamically override display status if payment was rejected
                final String displayStatus =
                    (paymentStatus.toLowerCase() == 'rejected')
                        ? 'Rejected'
                        : rawStatus;

                Color statusColor = Colors.orange;
                switch (displayStatus.toLowerCase()) {
                  case "delivered":
                    statusColor = Colors.green;
                    break;
                  case "cancelled":
                  case "rejected":
                    statusColor = Colors.red;
                    break;
                  case "processing":
                  case "shipped":
                  case "dispatched":
                  case "confirmed":
                    statusColor = Colors.blue;
                    break;
                  default:
                    statusColor = Colors.orange;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.black.withOpacity(0.08),
                      width: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff7F4F4F).withOpacity(0.04),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 20,
                            backgroundColor: Color(0xffF5EAEA),
                            child: Icon(
                              Icons.shopping_bag_outlined,
                              size: 20,
                              color: Color(0xff7F4F4F),
                            ),
                          ),
                          SizedBox(width: width * 0.03),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Order #${order.id.length >= 6 ? order.id.substring(0, 6).toUpperCase() : order.id.toUpperCase()}",
                                  style: GoogleFonts.manrope(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xff2D2323),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  date == null
                                      ? "Just now"
                                      : "${date.day}-${date.month}-${date.year}. ${date.hour}:${date.minute.toString().padLeft(2, '0')}",
                                  style: GoogleFonts.manrope(
                                    color: const Color(0xff8D7B7B),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              displayStatus.toUpperCase(),
                              style: GoogleFonts.manrope(
                                color: statusColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$itemCount Item${itemCount > 1 ? "s" : ""}",
                                style: GoogleFonts.manrope(
                                  color: const Color(0xff8D7B7B),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Rs ${((data['total'] ?? 0) as num).toStringAsFixed(0)}",
                                style: GoogleFonts.manrope(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xff7F4F4F),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OrderDetailsScreen(
                                  order: order,
                                ),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xff7F4F4F),
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(
                            Icons.visibility_outlined,
                            size: 18,
                            color: Color(0xff7F4F4F),
                          ),
                          label: Text(
                            "View Details",
                            style: GoogleFonts.manrope(
                              color: const Color(0xff7F4F4F),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}