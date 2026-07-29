import 'package:flutter/material.dart';

import '../../../models/user_model.dart';
import '../../../models/order_model.dart';
import '../../../services/user_service.dart';
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
  State<UserDetailsScreen> createState() =>
      _UserDetailsScreenState();
}

class _UserDetailsScreenState
    extends State<UserDetailsScreen> {
  final UserService _userService =
      UserService();

  int _orderCount = 0;
  double _totalSpent = 0;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final orders =
        await _userService.getUserOrderCount(
      widget.user.uid,
    );

    final spent =
        await _userService.getUserTotalSpent(
      widget.user.uid,
    );

    if (!mounted) return;

    setState(() {
      _orderCount = orders;
      _totalSpent = spent;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("User Details"),
      ),
      body: _loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : ListView(
              padding:
                  const EdgeInsets.all(16),
              children: [

                UserInfoCard(
                  user: widget.user,
                  orderCount: _orderCount,
                  totalSpent: _totalSpent,
                ),

                const SizedBox(height: 20),

                UserActionButtons(
                  user: widget.user,
                  userService: _userService,
                ),
                const SizedBox(height: 16),

StreamBuilder<List<OrderModel>>(
  stream: _userService.getRecentOrders(
    widget.user.uid,
  ),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    return RecentOrdersCard(
      orders: snapshot.data!,
    );
  },
),
              ],
            ),
    );
  }
}