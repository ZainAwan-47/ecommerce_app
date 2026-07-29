import 'package:flutter/material.dart';

import '../../../../constants/order_constants.dart';

class PaymentStatusChip extends StatelessWidget {
  final String status;

  const PaymentStatusChip({
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
      case PaymentStatus.pending:
        return Colors.orange.shade100;

      case PaymentStatus.verified:
        return Colors.green.shade100;

      case PaymentStatus.rejected:
        return Colors.red.shade100;

      case PaymentStatus.refunded:
        return Colors.purple.shade100;

      default:
        return Colors.grey.shade200;
    }
  }

  Color get _textColor {
    switch (status) {
      case PaymentStatus.pending:
        return Colors.orange.shade800;

      case PaymentStatus.verified:
        return Colors.green.shade800;

      case PaymentStatus.rejected:
        return Colors.red.shade800;

      case PaymentStatus.refunded:
        return Colors.purple.shade800;

      default:
        return Colors.grey.shade800;
    }
  }
}