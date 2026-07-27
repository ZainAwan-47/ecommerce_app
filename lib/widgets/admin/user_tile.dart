import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/user_model.dart';
import 'admin_card.dart';

class UserTile extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;

  final VoidCallback onDelete;

  final ValueChanged<bool> onStatusChanged;

  const UserTile({
    super.key,
    required this.user,
    required this.onTap,
    required this.onDelete,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor:
                const Color(0xff7F4F4F).withOpacity(.12),
            backgroundImage: user.photo.isNotEmpty
                ? NetworkImage(user.photo)
                : null,
            child: user.photo.isEmpty
                ? const Icon(
                    Icons.person,
                    color: Color(0xff7F4F4F),
                  )
                : null,
          ),

          const SizedBox(width: 16),

          Expanded(
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name.isEmpty
                        ? "Unknown User"
                        : user.name,
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    user.email,
                    style: GoogleFonts.manrope(
                      color: Colors.grey.shade700,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: user.isActive
                              ? Colors.green
                                  .withOpacity(.08)
                              : Colors.red
                                  .withOpacity(.08),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: Text(
                          user.isActive
                              ? "Active"
                              : "Disabled",
                          style:
                              GoogleFonts.manrope(
                            color: user.isActive
                                ? Colors.green
                                : Colors.red,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue
                              .withOpacity(.08),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: Text(
                          user.role,
                          style:
                              GoogleFonts.manrope(
                            color: Colors.blue,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Column(
            children: [
              Switch(
                value: user.isActive,
                activeColor:
                    const Color(0xff7F4F4F),
                onChanged: onStatusChanged,
              ),

              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}