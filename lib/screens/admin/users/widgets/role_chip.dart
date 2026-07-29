import 'package:flutter/material.dart';

class RoleChip extends StatelessWidget {
  const RoleChip({
    super.key,
    required this.role,
  });

  final String role;

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = role.toLowerCase() == "admin";

    // Elite minimal colors: Deep Purple for Admin, Blue for Customer
    final Color textColor = isAdmin ? const Color(0xFF4C1D95) : const Color(0xFF1D4ED8);
    final Color bgColor = isAdmin ? const Color(0xFF6D28D9).withOpacity(0.08) : const Color(0xFF2563EB).withOpacity(0.08);
    final Color borderColor = isAdmin ? const Color(0xFF6D28D9).withOpacity(0.2) : const Color(0xFF2563EB).withOpacity(0.2);
    final IconData icon = isAdmin ? Icons.shield_rounded : Icons.person_rounded;

    return Container(
      // Exactly matches the padding of AccountStatusChip for perfect alignment
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // MINIMAL ICON (Reduced size to prevent container stretching)
          Icon(
            icon,
            size: 10,
            color: textColor,
          ),
          
          const SizedBox(width: 4),
          
          // CRISP TYPOGRAPHY
          Text(
            isAdmin ? "Admin" : "Customer",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: 0.3,
              height: 1.0, // STRIPS invisible vertical padding so it stays tiny
            ),
          ),
        ],
      ),
    );
  }
}