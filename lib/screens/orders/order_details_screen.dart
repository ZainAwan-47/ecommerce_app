import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderDetailsScreen extends StatelessWidget {
  final DocumentSnapshot order;

  const OrderDetailsScreen({
    super.key,
    required this.order,
  });

  // Helper color for order status badges
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return const Color(0xFF16A34A);
      case 'shipped':
      case 'dispatched':
        return const Color(0xFF2563EB);
      case 'processing':
      case 'confirmed':
        return const Color(0xFFD97706);
      case 'cancelled':
      case 'rejected':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFFEA580C); // Pending / Default
    }
  }

  // Helper color for payment status badges
  Color _getPaymentColor(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
      case 'paid':
      case 'completed':
        return const Color(0xFF16A34A);
      case 'rejected':
      case 'failed':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFFD97706); // Pending verification
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: const Color(0xffFFF9F7),
      appBar: AppBar(
        backgroundColor: const Color(0xffFFF9F7),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          "Order Details",
          style: GoogleFonts.manrope(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      // Real-time Firestore Stream listener
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .doc(order.id)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error loading order details: ${snapshot.error}"));
          }

          // Use live snapshot if available, fallback to initial snapshot
          final doc = snapshot.data ?? order;
          final data = doc.data() as Map<String, dynamic>? ?? {};

          final List products = data['products'] ?? order['products'] ?? [];
          final String orderStatus = data['status'] ?? order['status'] ?? 'Pending';
          final String paymentStatus = data['paymentStatus'] ?? data['payment_status'] ?? 'Pending';
          final String? rejectionReason = data['rejectionReason'] ?? data['rejection_reason'];

          final bool isPaymentRejected = paymentStatus.toLowerCase() == 'rejected';
          final bool isOrderCancelled = orderStatus.toLowerCase() == 'cancelled';

          return SingleChildScrollView(
            padding: EdgeInsets.all(width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -------------------------------------------------------------
                // 1. REAL-TIME ALERT BANNER (If Payment Rejected or Cancelled)
                // -------------------------------------------------------------
                if (isPaymentRejected || isOrderCancelled) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: Color(0xFFDC2626),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isPaymentRejected
                                    ? "Payment Verification Rejected"
                                    : "Order Cancelled",
                                style: GoogleFonts.manrope(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF991B1B),
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isPaymentRejected
                                    ? (rejectionReason != null && rejectionReason.isNotEmpty
                                        ? "Reason: $rejectionReason"
                                        : "Your payment proof could not be verified by the admin. Please contact support or upload a valid receipt.")
                                    : "This order has been cancelled by the administration.",
                                style: GoogleFonts.manrope(
                                  color: const Color(0xFF7F1D1D),
                                  fontSize: 13,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // -------------------------------------------------------------
                // 2. PRODUCTS SECTION
                // -------------------------------------------------------------
                Text(
                  "Products",
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            product['image'] ?? '',
                            width: width * 0.12,
                            height: width * 0.12,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: width * 0.12,
                              height: width * 0.12,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.image_not_supported, size: 20),
                            ),
                          ),
                        ),
                        title: Text(
                          product['name'] ?? 'Item',
                          style: GoogleFonts.manrope(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          "Qty : ${product['quantity'] ?? 1}",
                          style: GoogleFonts.manrope(fontSize: 13),
                        ),
                        trailing: Text(
                          "Rs ${product['price']}",
                          style: GoogleFonts.manrope(
                            color: const Color(0xff7F4F4F),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                // -------------------------------------------------------------
                // 3. DELIVERY & STATUS CARD
                // -------------------------------------------------------------
                Text(
                  "Delivery Information",
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.04,
                    vertical: width * 0.04,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Address
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: Color(0xff7F4F4F),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              data['address'] ?? order['address'] ?? 'N/A',
                              style: GoogleFonts.manrope(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Phone
                      Row(
                        children: [
                          const Icon(
                            Icons.phone_outlined,
                            color: Color(0xff7F4F4F),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            data['phone'] ?? order['phone'] ?? 'N/A',
                            style: GoogleFonts.manrope(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Payment Method & Status Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.payments_outlined,
                                color: Color(0xff7F4F4F),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                data['paymentMethod'] ?? order['paymentMethod'] ?? 'N/A',
                                style: GoogleFonts.manrope(),
                              ),
                            ],
                          ),
                          // Live Payment Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getPaymentColor(paymentStatus).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              paymentStatus.toUpperCase(),
                              style: GoogleFonts.manrope(
                                color: _getPaymentColor(paymentStatus),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Order Delivery Status Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.local_shipping_outlined,
                                color: Color(0xff7F4F4F),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Order Status",
                                style: GoogleFonts.manrope(
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          // Live Order Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(orderStatus).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              orderStatus.toUpperCase(),
                              style: GoogleFonts.manrope(
                                color: _getStatusColor(orderStatus),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 24),

                      // Grand Total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Grand Total",
                            style: GoogleFonts.manrope(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Rs ${((data['total'] ?? order['total'] ?? 0) as num).toStringAsFixed(0)}",
                            style: GoogleFonts.manrope(
                              fontSize: 20,
                              color: const Color(0xff7F4F4F),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }
}