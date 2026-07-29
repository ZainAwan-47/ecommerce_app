import 'package:flutter/material.dart';
import '../../../../constants/order_constants.dart';

class OrderTimelineCard extends StatelessWidget {
  final String currentStatus;

  const OrderTimelineCard({
    super.key,
    required this.currentStatus,
  });

  static const List<String> _stages = [
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.packed,
    OrderStatus.shipped,
    OrderStatus.delivered,
  ];

  int get _currentStageIndex {
    if (currentStatus == OrderStatus.cancelled) return -1;
    return _stages.indexOf(currentStatus);
  }

  @override
  Widget build(BuildContext context) {
    final isCancelled = currentStatus == OrderStatus.cancelled;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Order Status Timeline",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              if (isCancelled)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "CANCELLED",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(_stages.length, (index) {
            final stage = _stages[index];
            final isPassed = _currentStageIndex >= index && !isCancelled;
            final isCurrent = _currentStageIndex == index && !isCancelled;
            final isLast = index == _stages.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCurrent
                            ? const Color(0xFF2563EB)
                            : (isPassed
                                ? const Color(0xFF059669)
                                : const Color(0xFFF1F5F9)),
                        border: Border.all(
                          color: isCurrent
                              ? const Color(0xFF2563EB)
                              : (isPassed
                                  ? const Color(0xFF059669)
                                  : const Color(0xFFCBD5E1)),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          isPassed ? Icons.check : Icons.circle,
                          size: isPassed ? 14 : 8,
                          color: (isPassed || isCurrent)
                              ? Colors.white
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 28,
                        color: isPassed && _currentStageIndex > index
                            ? const Color(0xFF059669)
                            : const Color(0xFFE2E8F0),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    _getStageLabel(stage),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isCurrent ? FontWeight.bold : FontWeight.w500,
                      color: isCurrent
                          ? const Color(0xFF2563EB)
                          : (isPassed
                              ? const Color(0xFF0F172A)
                              : const Color(0xFF94A3B8)),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  String _getStageLabel(String stage) {
    switch (stage) {
      case OrderStatus.pending:
        return "Order Placed";
      case OrderStatus.confirmed:
        return "Confirmed";
      case OrderStatus.packed:
        return "Packed";
      case OrderStatus.shipped:
        return "Shipped";
      case OrderStatus.delivered:
        return "Delivered";
      default:
        return stage;
    }
  }
}