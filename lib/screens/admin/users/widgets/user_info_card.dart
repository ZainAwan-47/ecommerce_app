import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for Clipboard

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
    final Color statusColor = user.isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. COMPACT HEADER: Avatar & Details Side-by-Side
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // AVATAR
              Stack(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: const Color(0xFFF9FAFB),
                    backgroundImage: user.photo.isNotEmpty ? NetworkImage(user.photo) : null,
                    child: user.photo.isEmpty
                        ? Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : "?",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(width: 16),
              
              // DETAILS
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // BADGES
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        RoleChip(role: user.role),
                        AccountStatusChip(isActive: user.isActive),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 2. METRICS ROW: Side-by-side sleek stat cards
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: "Orders",
                  value: orderCount.toString(),
                  icon: Icons.shopping_bag_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: "Total Spent",
                value: "Rs. ${totalSpent.toStringAsFixed(2)}",
                  icon: Icons.payments_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 3. GROUPED METADATA BLOCK
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: Column(
              children: [
                _InlineInfoRow(
                  icon: Icons.tag,
                  title: "User ID",
                  value: user.uid,
                  showCopyButton: true, // Enabled copy button here
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(height: 1, color: Color(0xFFE5E7EB)),
                ),
                _InlineInfoRow(
                  icon: Icons.calendar_today_outlined,
                  title: "Joined",
                  value: _formatDate(user.createdAt),
                  showCopyButton: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "-";
    final date = timestamp.toDate();
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return "$day/$month/${date.year}";
  }
}

// --- PRIVATE COMPACT WIDGETS ---

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: const Color(0xFF9CA3AF)),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
              letterSpacing: -0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _InlineInfoRow extends StatelessWidget {
  const _InlineInfoRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.showCopyButton,
  });

  final IconData icon;
  final String title;
  final String value;
  final bool showCopyButton;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (showCopyButton) ...[
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: value));
                if (context.mounted) {
                  // Premium minimal Snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 16),
                          const SizedBox(width: 8),
                          const Text(
                            "Copied!",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: const Color(0xFF111827),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
                      elevation: 0,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  Icons.copy_rounded,
                  size: 14,
                  color: const Color(0xFF2563EB).withOpacity(0.8), // Subtle blue
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}