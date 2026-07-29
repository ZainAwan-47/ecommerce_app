import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../models/user_model.dart';
import '../../../services/user_service.dart';
import '../../../utils/app_notifier.dart';
import '../../../widgets/admin/admin_card.dart';
import '../../../widgets/admin/responsive.dart';

class UserDetailsScreen extends StatelessWidget {
  final UserModel user;

  const UserDetailsScreen({
    super.key,
    required this.user,
  });

  Future<void> _toggleRole(BuildContext context, UserService userService) async {
    final bool isCurrentlyAdmin = user.role.toLowerCase() == 'admin';
    final String newRole = isCurrentlyAdmin ? 'user' : 'admin';
    final String actionText = isCurrentlyAdmin ? 'Revoke Admin Access' : 'Promote to Admin';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(actionText),
        content: Text(
          isCurrentlyAdmin
              ? "Are you sure you want to revoke admin privileges for ${user.name}?"
              : "Are you sure you want to promote ${user.name} to Admin?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isCurrentlyAdmin ? Colors.red : Colors.green,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text("Confirm"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // Assuming your UserService has an updateUserRole method. 
      // If not, add: Future<void> updateUserRole(String uid, String role) async { ... }
      await userService.updateUserRole(user.uid, newRole);

      if (!context.mounted) return;
      AppNotifier.success(
        context,
        isCurrentlyAdmin ? "Admin access revoked." : "User promoted to Admin successfully.",
      );
      
      // Pop to refresh the previous screen
      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;
      AppNotifier.error(context, "Failed to update role: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final userService = UserService();
    final bool isAdmin = user.role.toLowerCase() == 'admin';

    return Scaffold(
      backgroundColor: const Color(0xffFFF9F7),
      appBar: AppBar(
        backgroundColor: const Color(0xffFFF9F7),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Customer Details",
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w700,
            fontSize: Responsive.titleSize(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(
          Responsive.horizontalPadding(context),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xff7F4F4F).withOpacity(.1),
              backgroundImage: user.photo.isNotEmpty ? NetworkImage(user.photo) : null,
              child: user.photo.isEmpty
                  ? const Icon(
                      Icons.person,
                      size: 50,
                      color: Color(0xff7F4F4F),
                    )
                  : null,
            ),
            const SizedBox(height: 20),
            Text(
              user.name.isEmpty ? "Unknown User" : user.name,
              style: GoogleFonts.manrope(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              user.email,
              style: GoogleFonts.manrope(
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 25),
            AdminCard(
              child: Column(
                children: [
                  _infoRow("UID", user.uid),
                  const Divider(),
                  _infoRow("Role", user.role),
                  const Divider(),
                  _infoRow(
                    "Status",
                    user.isActive ? "Active" : "Disabled",
                  ),
                  const Divider(),
                  _infoRow(
                    "Joined",
                    user.createdAt == null
                        ? "-"
                        : DateFormat("dd MMM yyyy").format(user.createdAt!.toDate()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FutureBuilder<int>(
              future: userService.getUserOrderCount(user.uid),
              builder: (_, snapshot) {
                return AdminCard(
                  child: ListTile(
                    leading: const Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.blue,
                    ),
                    title: const Text("Total Orders"),
                    trailing: Text(
                      "${snapshot.data ?? 0}",
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            FutureBuilder<double>(
              future: userService.getUserTotalSpent(user.uid),
              builder: (_, snapshot) {
                return AdminCard(
                  child: ListTile(
                    leading: const Icon(
                      Icons.payments_outlined,
                      color: Colors.green,
                    ),
                    title: const Text("Total Spending"),
                    trailing: Text(
                      "PKR ${(snapshot.data ?? 0).toStringAsFixed(0)}",
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
            if (user.fcmToken.isNotEmpty) ...[
              const SizedBox(height: 12),
              AdminCard(
                child: ListTile(
                  leading: const Icon(
                    Icons.notifications_active_outlined,
                    color: Colors.orange,
                  ),
                  title: const Text("FCM Token"),
                  subtitle: SelectableText(
                    user.fcmToken,
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            
            // --- NEW: Promote/Demote Admin Button ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAdmin ? Colors.red.shade50 : const Color(0xff7F4F4F).withOpacity(0.1),
                  foregroundColor: isAdmin ? Colors.red.shade700 : const Color(0xff7F4F4F),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isAdmin ? Colors.red.shade200 : const Color(0xff7F4F4F).withOpacity(0.3),
                    ),
                  ),
                ),
                icon: Icon(isAdmin ? Icons.person_remove_rounded : Icons.admin_panel_settings_rounded),
                label: Text(
                  isAdmin ? "Revoke Admin Access" : "Promote to Admin",
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                onPressed: () => _toggleRole(context, userService),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.manrope(),
            ),
          ),
        ],
      ),
    );
  }
}