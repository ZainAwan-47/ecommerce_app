import 'package:flutter/material.dart';

import '../../../../constants/order_constants.dart';

class OrderStatusChip extends StatelessWidget {
  final String status;

  const OrderStatusChip({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color get _backgroundColor {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange.shade100;

      case OrderStatus.confirmed:
        return Colors.blue.shade100;

      case OrderStatus.packed:
        return Colors.indigo.shade100;

      case OrderStatus.shipped:
        return Colors.purple.shade100;

      case OrderStatus.delivered:
        return Colors.green.shade100;

      case OrderStatus.cancelled:
        return Colors.red.shade100;

      default:
        return Colors.grey.shade200;
    }
  }

  Color get _textColor {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange.shade800;

      case OrderStatus.confirmed:
        return Colors.blue.shade800;

      case OrderStatus.packed:
        return Colors.indigo.shade800;

      case OrderStatus.shipped:
        return Colors.purple.shade800;

      case OrderStatus.delivered:
        return Colors.green.shade800;

      case OrderStatus.cancelled:
        return Colors.red.shade800;

      default:
        return Colors.grey.shade800;
    }
  }
}