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
      appBar: AppBar(
        title: const Text("User Management"),
        centerTitle: true,
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: _userService.getUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

         if (!snapshot.hasData ||
    snapshot.data!.isEmpty) {
  return const EmptyUsersWidget();
}

         final users = _filterUsers(snapshot.data!);

if (users.isEmpty) {
  return const EmptyUsersWidget(
    message: "No matching users found",
  );
}

          return Column(
            children: [
              // MOVED: The stats GridView is now safely inside the Column's children
              Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.1,
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
                      icon: Icons.verified_user,
                      color: Colors.green,
                    ),
                    UserStatsCard(
                      title: "Inactive",
                      value: _inactiveUsers,
                      icon: Icons.block,
                      color: Colors.red,
                    ),
                    UserStatsCard(
                      title: "Admins",
                      value: _admins,
                      icon: Icons.admin_panel_settings,
                      color: Colors.deepPurple,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

UserSearchBar(
  controller: _searchController,
  onChanged: (value) {
    setState(() {
      _searchQuery = value;
    });
  },
),

              const SizedBox(height: 12),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    "All",
                    "Customers",
                    "Admins",
                    "Active",
                    "Inactive",
                  ]
                      // FIXED: Added <Widget> to tell Dart this maps to a List of Widgets
                      .map<Widget>(
                        (filter) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(filter),
                            selected: _selectedFilter == filter,
                            onSelected: (_) {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            },
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];

                    return UserCard(
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
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}