import 'package:flutter/material.dart';

import '../../../../models/order_model.dart';

class RecentOrdersCard extends StatelessWidget {
  const RecentOrdersCard({
    super.key,
    required this.orders,
  });

  final List<OrderModel> orders;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(top: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              "Recent Orders",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 16),

            if (orders.isEmpty)
              const Center(
                child: Padding(
                  padding:
                      EdgeInsets.all(24),
                  child: Text(
                    "No orders yet",
                  ),
                ),
              )
            else
              ...orders.map(
                (order) => ListTile(
                  dense: true,
                  contentPadding:
                      EdgeInsets.zero,
                  title: Text(order.orderId),
                  subtitle: Text(
              "${order.itemCount} item(s)"
                  ),
                  trailing: Text(
               "\$${order.total.toStringAsFixed(2)}",
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}