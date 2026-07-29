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
    // Premium minimal status colors
    final Color statusColor = user.isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // REFINED AVATAR WITH INTEGRATED STATUS DOT
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFFF9FAFB),
                      backgroundImage: user.photo.isNotEmpty ? NetworkImage(user.photo) : null,
                      child: user.photo.isEmpty
                          ? Text(
                              user.name.isNotEmpty ? user.name[0].toUpperCase() : "?",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
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
                
                // USER INFO COLUMN (Fully Responsive)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // NAME
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // EMAIL & DATE MERGED (Clean right edge, no overflows)
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              user.email,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (user.createdAt != null) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6.0),
                              child: Text(
                                "•",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: const Color(0xFF9CA3AF).withOpacity(0.5),
                                ),
                              ),
                            ),
                            Text(
                              _formatDate(user.createdAt!),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // BADGES (Uses Wrap to naturally drop to next line if screen is tiny)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          RoleChip(role: user.role),
                          AccountStatusChip(isActive: user.isActive),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // SUBTLE TRAILING ICON
                const Padding(
                  padding: EdgeInsets.only(left: 12.0),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Color(0xFFD1D5DB),
                    size: 14, 
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return "$day/$month/${date.year}";
  }
}