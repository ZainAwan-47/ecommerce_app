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
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xff3A2B2B)),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xff3A2B2B),
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Order Details",
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xff2D2323),
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
            return Center(
              child: Text(
                "Error loading order details: ${snapshot.error}",
                style: GoogleFonts.manrope(color: Colors.red.shade300),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xff7F4F4F),
              ),
            );
          }

          // Use live snapshot if available, fallback to initial snapshot
          final doc = snapshot.data ?? order;
          final data = doc.data() as Map<String, dynamic>? ?? {};
          final List products =
              data['products'] ?? (order.data() as Map<String, dynamic>?)?['products'] ?? [];
          final String orderStatus =
              data['status'] ?? (order.data() as Map<String, dynamic>?)?['status'] ?? 'Pending';
          final String paymentStatus = data['paymentStatus'] ??
              data['payment_status'] ??
              'Pending';
          final String? rejectionReason =
              data['rejectionReason'] ?? data['rejection_reason'];

          // Dynamically override display status if payment proof was rejected
          final String displayOrderStatus =
              (paymentStatus.toLowerCase() == 'rejected')
                  ? 'Rejected'
                  : orderStatus;

          final bool isPaymentRejected =
              paymentStatus.toLowerCase() == 'rejected';
          final bool isOrderCancelled =
              orderStatus.toLowerCase() == 'cancelled';

          return SingleChildScrollView(
            padding: EdgeInsets.all(width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. REAL-TIME ALERT BANNER (If Payment Rejected or Cancelled)
                if (isPaymentRejected || isOrderCancelled) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(18),
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
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isPaymentRejected
                                    ? (rejectionReason != null &&
                                            rejectionReason.isNotEmpty
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

                // 2. PRODUCTS SECTION
                Text(
                  "Products",
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff2D2323),
                  ),
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index] as Map<String, dynamic>;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.08),
                          width: 0.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xff7F4F4F).withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 50,
                            height: 50,
                            color: const Color(0xffFFF9F7),
                            child: Image.network(
                              product['image'] ?? '',
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 24,
                                  color: Color(0xff8D7B7B),
                                ),
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          product['name'] ?? 'Item',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xff2D2323),
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            "Qty : ${product['quantity'] ?? 1}",
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              color: const Color(0xff8D7B7B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        trailing: Text(
                          "Rs ${product['price']}",
                          style: GoogleFonts.manrope(
                            color: const Color(0xff7F4F4F),
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // 3. DELIVERY & STATUS CARD
                Text(
                  "Delivery Information",
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff2D2323),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(width * 0.045),
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
                      // Address
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: Color(0xff7F4F4F),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              data['address'] ??
                                  (order.data() as Map<String, dynamic>?)?['address'] ??
                                  'N/A',
                              style: GoogleFonts.manrope(
                                fontSize: 13.5,
                                color: const Color(0xff2D2323),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Phone
                      Row(
                        children: [
                          const Icon(
                            Icons.phone_outlined,
                            color: Color(0xff7F4F4F),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            data['phone'] ??
                                (order.data() as Map<String, dynamic>?)?['phone'] ??
                                'N/A',
                            style: GoogleFonts.manrope(
                              fontSize: 13.5,
                              color: const Color(0xff2D2323),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Payment Method & Status Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.payments_outlined,
                                color: Color(0xff7F4F4F),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                data['paymentMethod'] ??
                                    (order.data() as Map<String, dynamic>?)?['paymentMethod'] ??
                                    'N/A',
                                style: GoogleFonts.manrope(
                                  fontSize: 13.5,
                                  color: const Color(0xff2D2323),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getPaymentColor(paymentStatus)
                                  .withOpacity(0.12),
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
                      const SizedBox(height: 12),
                      // Order Delivery Status Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.local_shipping_outlined,
                                color: Color(0xff7F4F4F),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "Order Status",
                                style: GoogleFonts.manrope(
                                  fontSize: 13.5,
                                  color: const Color(0xff8D7B7B),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(displayOrderStatus)
                                  .withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              displayOrderStatus.toUpperCase(),
                              style: GoogleFonts.manrope(
                                color: _getStatusColor(displayOrderStatus),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(height: 1),
                      ),
                      // Grand Total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Grand Total",
                            style: GoogleFonts.manrope(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xff2D2323),
                            ),
                          ),
                          Text(
                            "Rs ${(((data['total'] ?? (order.data() as Map<String, dynamic>?)?['total']) ?? 0) as num).toStringAsFixed(0)}",
                            style: GoogleFonts.manrope(
                              fontSize: 18,
                              color: const Color(0xff7F4F4F),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}