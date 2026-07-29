import 'package:flutter/material.dart';

class AccountStatusChip extends StatelessWidget {
  const AccountStatusChip({
    super.key,
    required this.isActive,
  });

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    // Premium minimal color palette
    final Color statusColor = isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final Color textColor = isActive ? const Color(0xFF065F46) : const Color(0xFF991B1B);
    final Color bgColor = isActive ? const Color(0xFF10B981).withOpacity(0.08) : const Color(0xFFEF4444).withOpacity(0.08);
    final Color borderColor = isActive ? const Color(0xFF10B981).withOpacity(0.2) : const Color(0xFFEF4444).withOpacity(0.2);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      // MainAxisSize.min guarantees it takes only the space it needs, keeping it responsive
      child: Row(
        mainAxisSize: MainAxisSize.min, 
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // MINIMAL STATUS DOT
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          
          const SizedBox(width: 6),
          
          // CRISP TYPOGRAPHY
          Text(
            isActive ? "Active" : "Inactive",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: 0.3, // Adds a premium feel to the text
            ),
          ),
        ],
      ),
    );
  }
}