import 'package:flutter/material.dart';

import '../../../../models/user_model.dart';
import '../../../../models/order_model.dart';
import '../../../../services/user_service.dart';
import 'widgets/recent_orders_card.dart';
import 'widgets/user_info_card.dart';
import 'widgets/user_action_buttons.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({
    super.key,
    required this.user,
  });

  final UserModel user;

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final UserService _userService = UserService();

  int _orderCount = 0;
  double _totalSpent = 0;
  bool _loadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final orders = await _userService.getUserOrderCount(
      widget.user.uid,
    );

    final spent = await _userService.getUserTotalSpent(
      widget.user.uid,
    );

    if (!mounted) return;

    setState(() {
      _orderCount = orders;
      _totalSpent = spent;
      _loadingStats = false;
    });
  }

  // Pull-to-refresh handler for user stats
  Future<void> _onRefresh() async {
    await _loadStats();
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        title: const Text(
          "User Profile",
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
      // StreamBuilder tracks the user document in real-time for instant status/role updates
      body: StreamBuilder<UserModel?>(
        stream: _userService.getUserStream(widget.user.uid),
        initialData: widget.user,
        builder: (context, userSnapshot) {
          final currentUser = userSnapshot.data ?? widget.user;

          if (_loadingStats) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          }

          return RefreshIndicator(
            color: Colors.black,
            backgroundColor: Colors.white,
            onRefresh: _onRefresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                // 1. LIVE USER INFORMATION CARD
                UserInfoCard(
                  user: currentUser,
                  orderCount: _orderCount,
                  totalSpent: _totalSpent,
                ),

                const SizedBox(height: 16),

                // 2. USER ACTION BUTTONS
                UserActionButtons(
                  user: currentUser,
                  userService: _userService,
                ),

                const SizedBox(height: 16),

                // 3. RECENT ORDERS STREAM
                StreamBuilder<List<OrderModel>>(
                  stream: _userService.getRecentOrders(
                    currentUser.uid,
                  ),
                  builder: (context, orderSnapshot) {
                    if (!orderSnapshot.hasData) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      );
                    }

                    return RecentOrdersCard(
                      orders: orderSnapshot.data!,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}