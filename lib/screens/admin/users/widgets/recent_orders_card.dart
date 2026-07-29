import 'package:flutter/material.dart';
import '../../../../models/order_model.dart';
import '../../../../screens/admin/orders/order_details_screen.dart';

class RecentOrdersCard extends StatelessWidget {
  const RecentOrdersCard({
    super.key,
    required this.orders,
  });

  final List<OrderModel> orders;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // HEADER
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              "Recent Orders",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
                letterSpacing: -0.3,
              ),
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF3F4F6)),

          // EMPTY STATE OR LIST
          if (orders.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF9FAFB),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.receipt_long_outlined,
                      color: Color(0xFF9CA3AF),
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "No orders found",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            )
          else
            // MAPPING ORDERS WITH DIVIDERS
            ...orders.asMap().entries.map((entry) {
              final int index = entry.key;
              final OrderModel order = entry.value;

              return Column(
                children: [
                  if (index > 0)
                    const Divider(height: 1, color: Color(0xFFF3F4F6)),
                  
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      // Handles navigation to order details
                     onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => OrderDetailsScreen(order: order),
    ),
  );
},
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // ORDER ICON
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFF3F4F6)),
                              ),
                              child: const Icon(
                                Icons.shopping_bag_outlined,
                                size: 18,
                                color: Color(0xFF4B5563),
                              ),
                            ),
                            
                            const SizedBox(width: 14),
                            
                            // ORDER DETAILS
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order.orderId,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF111827),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${order.itemCount} item(s)",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(width: 12),
                            
                            // TOTAL & CHEVRON
                            Row(
                              children: [
                                Text(
"Rs. ${order.total.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 14,
                                  color: Color(0xFFD1D5DB),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
            
            // BOTTOM SPACING
            if (orders.isNotEmpty) const SizedBox(height: 4),
        ],
      ),
    );
  }
}