import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/user_model.dart';
import '../../../services/user_service.dart';
import '../../../utils/app_notifier.dart';
import '../../../widgets/admin/admin_card.dart';
import '../../../widgets/admin/responsive.dart';
import '../../../widgets/admin/user_tile.dart';
import 'user_details_screen.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final UserService _userService = UserService();

  final TextEditingController _searchController =
      TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _deleteUser(UserModel user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete User"),
        content: Text(
          "Delete ${user.name.isEmpty ? "this user" : user.name}?",
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _userService.deleteUser(user.uid);

    if (!mounted) return;

    AppNotifier.success(
      context,
      "User deleted successfully.",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF9F7),

      appBar: AppBar(
        backgroundColor: const Color(0xffFFF9F7),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Customers",
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w700,
            fontSize: Responsive.titleSize(context),
          ),
        ),
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal:
              Responsive.horizontalPadding(context),
          vertical:
              Responsive.verticalPadding(context),
        ),

        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search customers...",
                prefixIcon:
                    const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                          Responsive.radius),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (_) {
                setState(() {});
              },
            ),

            const SizedBox(height: 18),

            Expanded(
              child: StreamBuilder<List<UserModel>>(
                stream:
                    _userService.getUsers(),
                builder: (
                  context,
                  snapshot,
                ) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child:
                          CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        snapshot.error.toString(),
                      ),
                    );
                  }

                  if (!snapshot.hasData ||
                      snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        "No users found.",
                      ),
                    );
                  }

                  List<UserModel> users =
                      snapshot.data!;

                  final query =
                      _searchController.text
                          .trim()
                          .toLowerCase();

                  if (query.isNotEmpty) {
                    users = users.where((user) {
                      return user.name
                              .toLowerCase()
                              .contains(query) ||
                          user.email
                              .toLowerCase()
                              .contains(query);
                    }).toList();
                  }

                  if (users.isEmpty) {
                    return const Center(
                      child: Text(
                        "No matching users.",
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {},

                    child: ListView.separated(
                      padding:
                          const EdgeInsets.only(
                              bottom: 24),
                      itemCount:
                          users.length,
                      separatorBuilder:
                          (_, __) =>
                              const SizedBox(
                        height: 12,
                      ),
                      itemBuilder:
                          (context, index) {
                        final user =
                            users[index];

                        return UserTile(
                          user: user,

                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    UserDetailsScreen(
                                  user: user,
                                ),
                              ),
                            );
                          },

                          onDelete: () =>
                              _deleteUser(
                                user,
                              ),

                          onStatusChanged:
                              (value) async {
                            await _userService
                                .toggleUserStatus(
                              uid: user.uid,
                              isActive:
                                  value,
                            );

                            if (!mounted) return;

                            AppNotifier.success(
                              context,
                              value
                                  ? "User enabled."
                                  : "User disabled.",
                            );
                          },
                        );
                      },
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