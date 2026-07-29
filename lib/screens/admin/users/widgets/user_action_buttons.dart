import 'package:flutter/material.dart';
import '../dialogs/change_role_dialog.dart';
import '../../../../models/user_model.dart';
import '../../../../services/user_service.dart';
import '../dialogs/deactivate_user_dialog.dart';
import '../dialogs/delete_user_dialog.dart';

class UserActionButtons extends StatelessWidget {
  const UserActionButtons({
    super.key,
    required this.user,
    required this.userService,
  });

  final UserModel user;
  final UserService userService;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Actions",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
                letterSpacing: -0.3,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // PRIMARY ACTION: Change Role (High contrast)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF111827),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.manage_accounts_outlined, size: 20),
                label: const Text(
                  "Change Role",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => ChangeRoleDialog(
                      user: user,
                      userService: userService,
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 12),
            
            // SECONDARY ACTION: Activate / Deactivate (Clean outlined tonal)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF9FAFB),
                  foregroundColor: const Color(0xFF374151),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => DeactivateUserDialog(
                      user: user,
                      userService: userService,
                    ),
                  );
                },
                icon: Icon(
                  user.isActive ? Icons.block_flipped : Icons.check_circle_outline,
                  size: 20,
                  color: user.isActive ? const Color(0xFFD97706) : const Color(0xFF10B981),
                ),
                label: Text(
                  user.isActive ? "Deactivate User" : "Activate User",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // DESTRUCTIVE ACTION: Delete User (Soft red)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFEF2F2),
                  foregroundColor: const Color(0xFFDC2626),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                label: const Text(
                  "Delete User",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => DeleteUserDialog(
                      user: user,
                      userService: userService,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}