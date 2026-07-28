import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/order_model.dart';
import 'order_status_chip.dart';
import 'payment_status_chip.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onView;

  const OrderCard({
    super.key,
    required this.order,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Order ID + Date
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.orderId,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                 DateFormat('dd MMM yyyy').format(order.createdAt.toDate()),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// Customer
            Text(
              order.userName,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "${order.products.length} Product(s)",
              style: theme.textTheme.bodyMedium,
            ),

            const SizedBox(height: 6),

            Text(
              "PKR ${order.total.toStringAsFixed(0)}",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                PaymentStatusChip(
                  status: order.paymentStatus,
                ),
                OrderStatusChip(
                  status: order.orderStatus,
                ),
              ],
            ),

            const SizedBox(height: 14),

            const Divider(height: 1),

            const SizedBox(height: 8),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onView,
                child: const Text("View Details"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}