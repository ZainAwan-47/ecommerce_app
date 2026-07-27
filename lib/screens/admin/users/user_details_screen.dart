import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../models/user_model.dart';
import '../../../services/user_service.dart';
import '../../../widgets/admin/admin_card.dart';
import '../../../widgets/admin/responsive.dart';

class UserDetailsScreen extends StatelessWidget {
  final UserModel user;

  const UserDetailsScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final userService = UserService();

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
              backgroundColor:
                  const Color(0xff7F4F4F).withOpacity(.1),
              backgroundImage: user.photo.isNotEmpty
                  ? NetworkImage(user.photo)
                  : null,
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
              user.name.isEmpty
                  ? "Unknown User"
                  : user.name,
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
                  _infoRow(
                    "UID",
                    user.uid,
                  ),

                  const Divider(),

                  _infoRow(
                    "Role",
                    user.role,
                  ),

                  const Divider(),

                  _infoRow(
                    "Status",
                    user.isActive
                        ? "Active"
                        : "Disabled",
                  ),

                  const Divider(),

                  _infoRow(
                    "Joined",
                    user.createdAt == null
                        ? "-"
                        : DateFormat(
                            "dd MMM yyyy",
                          ).format(
                            user.createdAt!.toDate(),
                          ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            FutureBuilder<int>(
              future:
                  userService.getUserOrderCount(user.uid),
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
              future:
                  userService.getUserTotalSpent(user.uid),
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
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 10),
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