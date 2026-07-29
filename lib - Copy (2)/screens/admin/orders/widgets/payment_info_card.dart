import 'package:flutter/material.dart';
import '../../../../constants/order_constants.dart';
import '../../../../models/order_model.dart';

class PaymentInfoCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onViewReceipt;

  const PaymentInfoCard({
    super.key,
    required this.order,
    required this.onViewReceipt,
  });

  Color _getPaymentStatusColor(String status) {
    switch (status) {
      case PaymentStatus.pending:
        return const Color(0xFFD97706);
      case PaymentStatus.verified:
        return const Color(0xFF059669);
      case PaymentStatus.rejected:
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF475569);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getPaymentStatusColor(order.paymentStatus);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Payment Information",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Payment Method",
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              Text(
                order.paymentMethod.isNotEmpty
                    ? order.paymentMethod
                    : "Cash on Delivery",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Payment Status",
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusColor.withOpacity(0.2)),
                ),
                child: Text(
                  order.paymentStatus.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}