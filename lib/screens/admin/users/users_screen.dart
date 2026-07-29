import 'package:flutter/material.dart';
import 'widgets/empty_users_widget.dart';
import '../../../models/user_model.dart';
import '../../../services/user_service.dart';
import 'widgets/user_card.dart';
import 'widgets/user_stats_card.dart';
import 'widgets/user_search_bar.dart';
import 'widgets/user_filter_tabs.dart';
import 'user_details_screen.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final UserService _userService = UserService();
  final TextEditingController _searchController = TextEditingController();
  
  String _searchQuery = "";
  String _selectedFilter = "All";
  
  int _totalUsers = 0;
  int _activeUsers = 0;
  int _inactiveUsers = 0;
  int _admins = 0;

  Future<void> _loadStats() async {
    final results = await Future.wait([
      _userService.getTotalUsers(),
      _userService.getActiveUsersCount(),
      _userService.getInactiveUsersCount(),
      _userService.getAdminCount(),
    ]);

    if (!mounted) return;
    setState(() {
      _totalUsers = results[0] as int;
      _activeUsers = results[1] as int;
      _inactiveUsers = results[2] as int;
      _admins = results[3] as int;
    });
  }

  // Pull-to-refresh handler
  Future<void> _onRefresh() async {
    await _loadStats();
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<UserModel> _filterUsers(List<UserModel> users) {
    List<UserModel> filtered = users;
    switch (_selectedFilter) {
      case "Admins":
        filtered = filtered.where((e) => e.role.toLowerCase() == "admin").toList();
        break;
      case "Customers":
        filtered = filtered.where((e) => e.role.toLowerCase() == "customer").toList();
        break;
      case "Active":
        filtered = filtered.where((e) => e.isActive).toList();
        break;
      case "Inactive":
        filtered = filtered.where((e) => !e.isActive).toList();
        break;
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((user) {
        return user.name.toLowerCase().contains(query) ||
            user.email.toLowerCase().contains(query);
      }).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        title: const Text(
          "User Management",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: _userService.getUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          final allUsers = snapshot.data ?? [];
          final users = _filterUsers(allUsers);

          // Calculate counts safely for real-time tabs
          final int customersCount = allUsers.where((e) => e.role.toLowerCase() == "customer").length;
          final int adminsCount = allUsers.where((e) => e.role.toLowerCase() == "admin").length;
          final int activeCount = allUsers.where((e) => e.isActive).length;
          final int inactiveCount = allUsers.where((e) => !e.isActive).length;

          return RefreshIndicator(
            color: Colors.black,
            backgroundColor: Colors.white,
            onRefresh: _onRefresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // STATS GRID
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.2,
                      children: [
                        UserStatsCard(
                          title: "Total Users",
                          value: _totalUsers,
                          icon: Icons.people_alt_rounded,
                          color: Colors.blue,
                        ),
                        UserStatsCard(
                          title: "Active",
                          value: _activeUsers,
                          icon: Icons.verified_user_rounded,
                          color: Colors.green,
                        ),
                        UserStatsCard(
                          title: "Inactive",
                          value: _inactiveUsers,
                          icon: Icons.block_rounded,
                          color: Colors.red,
                        ),
                        UserStatsCard(
                          title: "Admins",
                          value: _admins,
                          icon: Icons.admin_panel_settings_rounded,
                          color: Colors.deepPurple,
                        ),
                      ],
                    ),
                  ),
                ),

                // SEARCH BAR
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: UserSearchBar(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                ),

                // MODERN FILTER TABS WITH REAL-TIME COUNTS
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: UserFilterTabs(
                      selectedFilter: _selectedFilter,
                      onChanged: (value) {
                        setState(() {
                          _selectedFilter = value;
                        });
                      },
                      counts: {
                        "All": allUsers.length,
                        "Customers": customersCount,
                        "Admins": adminsCount,
                        "Active": activeCount,
                        "Inactive": inactiveCount,
                      },
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 8)),

                // USER LIST OR EMPTY STATE (FIXED TO PREVENT KEYBOARD OVERFLOW)
                users.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: EmptyUsersWidget(
                            message: "No matching users found",
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final user = users[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: UserCard(
                                  user: user,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => UserDetailsScreen(
                                          user: user,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                            childCount: users.length,
                          ),
                        ),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}