import 'package:flutter/material.dart';
import '../../../models/checkout_item.dart';

class PaymentSummaryCard extends StatelessWidget {
  final List<CheckoutItem> items;
  final double subtotal;
  final double delivery;
  final double total;

  const PaymentSummaryCard({
    super.key,
    required this.items,
    required this.subtotal,
    required this.delivery,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: const [
              Icon(
                Icons.receipt_long_rounded,
                color: Color(0xff7F4F4F),
              ),
              SizedBox(width: 10),
              Text(
                "Payment Summary",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xffFFF9F7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        item.image,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          "Quantity × ${item.quantity}",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Text(
                    "Rs ${(item.price * item.quantity).toStringAsFixed(0)}",
                    style: const TextStyle(
                      color: Color(0xff7F4F4F),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 35),

          _priceRow(
            "Subtotal",
            "Rs ${subtotal.toStringAsFixed(0)}",
          ),

          const SizedBox(height: 10),

          _priceRow(
            "Delivery",
            delivery == 0
                ? "Free"
                : "Rs ${delivery.toStringAsFixed(0)}",
            valueColor:
                delivery == 0 ? Colors.green : null,
          ),

          const Divider(height: 35),

          _priceRow(
            "Grand Total",
            "Rs ${total.toStringAsFixed(0)}",
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _priceRow(
    String title,
    String value, {
    bool bold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight:
                bold ? FontWeight.bold : FontWeight.w500,
            fontSize: bold ? 20 : 16,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? const Color(0xff7F4F4F),
            fontWeight:
                bold ? FontWeight.bold : FontWeight.w600,
            fontSize: bold ? 20 : 16,
          ),
        ),
      ],
    );
  }
}