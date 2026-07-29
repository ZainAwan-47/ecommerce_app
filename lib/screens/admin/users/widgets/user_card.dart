import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'role_chip.dart';
import 'account_status_chip.dart';
import '../../../../models/user_model.dart';

class UserCard extends StatelessWidget {
  const UserCard({
    super.key,
    required this.user,
    required this.onTap,
  });

  final UserModel user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: ListTile(
        onTap: onTap,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),

        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.brown.shade100,
          backgroundImage: user.photo.isNotEmpty
              ? NetworkImage(user.photo)
              : null,
          child: user.photo.isEmpty
              ? Text(
                  user.name.isNotEmpty
                      ? user.name[0].toUpperCase()
                      : "?",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),

        title: Text(
          user.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),

        subtitle: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),

            Text(user.email),

            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
            RoleChip(
  role: user.role,
),
AccountStatusChip(
  isActive: user.isActive,
),
              ],
            ),

            if (user.createdAt != null)
              Padding(
                padding:
                    const EdgeInsets.only(
                  top: 8,
                ),
                child: Text(
                  "Joined ${_formatDate(user.createdAt!)}",
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        Colors.grey.shade600,
                  ),
                ),
              ),
          ],
        ),

      trailing: Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Icon(
      Icons.chevron_right_rounded,
      color: Colors.grey.shade600,
    ),
  ],
),
      ),
    );
  }

  String _formatDate(
    Timestamp timestamp,
  ) {
    final date = timestamp.toDate();

    return "${date.day}/${date.month}/${date.year}";
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.role,
  });

  final String role;

  @override
  Widget build(BuildContext context) {
    final admin =
        role.toLowerCase() == "admin";

    return Chip(
      visualDensity:
          VisualDensity.compact,
      backgroundColor: admin
          ? Colors.deepPurple.shade50
          : Colors.blue.shade50,
      label: Text(
        admin ? "Admin" : "Customer",
        style: TextStyle(
          color: admin
              ? Colors.deepPurple
              : Colors.blue,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.isActive,
  });

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Chip(
      visualDensity:
          VisualDensity.compact,
      backgroundColor: isActive
          ? Colors.green.shade50
          : Colors.red.shade50,
      label: Text(
        isActive
            ? "Active"
            : "Inactive",
        style: TextStyle(
          color: isActive
              ? Colors.green
              : Colors.red,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}