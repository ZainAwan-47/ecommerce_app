import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../constants/order_constants.dart';
import '../../../../models/order_model.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onView;
  final VoidCallback onDelete;

  const OrderCard({
    super.key,
    required this.order,
    required this.onView,
    required this.onDelete,
  });

  Color _getOrderStatusColor(String status) {
    switch (status) {
      case OrderStatus.pending:
        return const Color(0xFFD97706);
      case OrderStatus.confirmed:
        return const Color(0xFF2563EB);
      case OrderStatus.packed:
      case OrderStatus.shipped:
        return const Color(0xFF7C3AED);
      case OrderStatus.delivered:
        return const Color(0xFF059669);
      case OrderStatus.cancelled:
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF4B5563);
    }
  }

  Color _getPaymentStatusColor(String status) {
    switch (status) {
      case PaymentStatus.pending:
        return const Color(0xFFD97706);
      case PaymentStatus.verified:
        return const Color(0xFF0D9488);
      case PaymentStatus.rejected:
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF4B5563);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderColor = _getOrderStatusColor(order.orderStatus);
    final paymentColor = _getPaymentStatusColor(order.paymentStatus);

    // Safely convert Timestamp to DateTime
    final dynamic rawDate = order.createdAt;
    final DateTime date =
        rawDate is Timestamp ? rawDate.toDate() : (rawDate as DateTime);

    final formattedDate =
        "${date.day} ${_getMonthName(date.month)} ${date.year}";

    final shortOrderId = order.orderId.length > 10
        ? "${order.orderId.substring(0, 10)}..."
        : order.orderId;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onView,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Header: Customer Name, Order ID, Date & Options
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.userName.isNotEmpty
                                ? order.userName
                                : "Guest Customer",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "#$shortOrderId",
                              style: const TextStyle(
                                fontFamily: 'Monospace',
                                fontSize: 11,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),

                    /// Options Menu (Delete)
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        size: 18,
                        color: Color(0xFF64748B),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      onSelected: (value) {
                        if (value == 'delete') onDelete();
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline,
                                  size: 18, color: Color(0xFFDC2626)),
                              SizedBox(width: 8),
                              Text(
                                "Delete Order",
                                style: TextStyle(
                                  color: Color(0xFFDC2626),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),

                /// Price & Items Summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${order.products.length} ${order.products.length == 1 ? 'item' : 'items'}",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      "PKR ${order.total.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// Status Badges
                Row(
                  children: [
                    _buildBadge(
                      label: "Order: ${order.orderStatus}",
                      icon: Icons.inventory_2_outlined,
                      color: orderColor,
                    ),
                    const SizedBox(width: 8),
                    _buildBadge(
                      label: "Pay: ${order.paymentStatus}",
                      icon: Icons.payments_outlined,
                      color: paymentColor,
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF94A3B8),
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[month - 1];
  }
}