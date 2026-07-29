import 'package:flutter/material.dart';

class AccountStatusChip extends StatelessWidget {
  const AccountStatusChip({
    super.key,
    required this.isActive,
  });

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        isActive
            ? Icons.check_circle
            : Icons.block,
        size: 18,
        color: isActive
            ? Colors.green
            : Colors.red,
      ),
      label: Text(
        isActive
            ? "Active"
            : "Inactive",
      ),
      labelStyle: TextStyle(
        color: isActive
            ? Colors.green
            : Colors.red,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: isActive
          ? Colors.green.shade50
          : Colors.red.shade50,
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }
}