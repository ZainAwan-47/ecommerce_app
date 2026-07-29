import 'package:flutter/material.dart';

class RoleChip extends StatelessWidget {
  const RoleChip({
    super.key,
    required this.role,
  });

  final String role;

  @override
  Widget build(BuildContext context) {
    final isAdmin =
        role.toLowerCase() == "admin";

    return Chip(
      avatar: Icon(
        isAdmin
            ? Icons.admin_panel_settings
            : Icons.person,
        size: 18,
        color: isAdmin
            ? Colors.deepPurple
            : Colors.blue,
      ),
      label: Text(
        isAdmin ? "Admin" : "Customer",
      ),
      labelStyle: TextStyle(
        color: isAdmin
            ? Colors.deepPurple
            : Colors.blue,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: isAdmin
          ? Colors.deepPurple.shade50
          : Colors.blue.shade50,
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }
}