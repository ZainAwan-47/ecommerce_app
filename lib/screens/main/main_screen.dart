import 'package:flutter/material.dart';
import '../../core/tab_controller.dart';

import '../home/home_screen.dart';
import '../wishlist/wishlist_screen.dart';
import '../orders/orders_screen.dart';
import '../profile/profile_screen.dart';
import '../home/widgets/bottom_nav.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    selectedTab.value = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeScreen(),
      WishlistScreen(),
      const OrdersScreen(),
      const ProfileScreen(),
    ];

    return ValueListenableBuilder<int>(
      valueListenable: selectedTab,
      builder: (context, index, child) {
        return Scaffold(
          body: IndexedStack(
            index: index,
            children: pages,
          ),
          bottomNavigationBar: BottomNav(
            currentIndex: index,
            onTap: (value) {
              selectedTab.value = value;
            },
          ),
        );
      },
    );
  }
}