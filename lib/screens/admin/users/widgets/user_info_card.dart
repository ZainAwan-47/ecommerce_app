import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../models/user_model.dart';
import 'account_status_chip.dart';
import 'role_chip.dart';

class UserInfoCard extends StatelessWidget {
  const UserInfoCard({
    super.key,
    required this.user,
    required this.orderCount,
    required this.totalSpent,
  });

  final UserModel user;
  final int orderCount;
  final double totalSpent;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 42,
              backgroundColor:
                  Theme.of(context)
                      .colorScheme
                      .primaryContainer,
              backgroundImage: user.photo.isNotEmpty
                  ? NetworkImage(user.photo)
                  : null,
              child: user.photo.isEmpty
                  ? Text(
                      user.name.isNotEmpty
                          ? user.name[0].toUpperCase()
                          : "?",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    )
                  : null,
            ),

            const SizedBox(height: 16),

            Text(
              user.name,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                    fontWeight:
                        FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 4),

            Text(
              user.email,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 16),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment:
                  WrapAlignment.center,
              children: [
                RoleChip(
                  role: user.role,
                ),
                AccountStatusChip(
                  isActive:
                      user.isActive,
                ),
              ],
            ),

            const Divider(height: 32),

            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    title: "Orders",
                    value:
                        orderCount.toString(),
                    icon: Icons.shopping_bag,
                  ),
                ),
                Expanded(
                  child: _StatTile(
                    title: "Spent",
                    value:
                        "\$${totalSpent.toStringAsFixed(2)}",
                    icon:
                        Icons.payments,
                  ),
                ),
              ],
            ),

            const Divider(height: 32),

            _InfoRow(
              icon: Icons.badge_outlined,
              title: "User ID",
              value: user.uid,
            ),

            const SizedBox(height: 12),

            _InfoRow(
              icon: Icons.calendar_today,
              title: "Joined",
              value: _formatDate(
                user.createdAt,
              ),
            ),
          ],
        ),
      ),
    );
  }

 static String _formatDate(Timestamp? timestamp) {
  if (timestamp == null) {
    return "-";
  }

  final date = timestamp.toDate();

  return "${date.day}/${date.month}/${date.year}";
}
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon),

        const SizedBox(height: 8),

        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color:
                      Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 2),

              SelectableText(
                value,
                style: const TextStyle(
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}