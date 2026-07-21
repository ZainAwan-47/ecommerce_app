import 'package:flutter/material.dart';

import '../../core/tab_controller.dart';
import '../../core/page_controller_holder.dart';

import '../home/home_screen.dart';
import '../product/products_screen.dart';
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
  final pages = [
    const HomeScreen(),
    const ProductsScreen(),
    WishlistScreen(),
    const OrdersScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      selectedTab.value = widget.initialIndex;
      appPageController.jumpToPage(widget.initialIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedTab,
      builder: (context, index, _) {
        return Scaffold(
          body: PageView(
            controller: appPageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (value) {
              selectedTab.value = value;
            },
            children: pages,
          ),
          bottomNavigationBar: BottomNav(
            currentIndex: index,
            onTap: (value) {
              if (value != selectedTab.value) {
                goToTab(value);
              }
            },
          ),
        );
      },
    );
  }
}