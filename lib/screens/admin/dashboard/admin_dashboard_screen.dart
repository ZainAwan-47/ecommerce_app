import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../widgets/admin/admin_navigation_card.dart';
import '../../../models/dashboard_stats.dart';
import '../../../services/dashboard_service.dart';
import '../../../widgets/admin/admin_card.dart';
import '../../../widgets/admin/admin_stat_card.dart';
import '../../../widgets/admin/responsive.dart';
import '../products/products_screen.dart';
import '../orders/orders_screen.dart';
import '../../../widgets/admin/image_source_bottom_sheet.dart';
class AdminDashboardScreen extends StatelessWidget {
  AdminDashboardScreen({super.key});

  final DashboardService _dashboardService = DashboardService.instance;

  @override
  Widget build(BuildContext context) {
    final columns = Responsive.columns(context);

    return Scaffold(
      backgroundColor: const Color(0xffFFF9F7),
      appBar: AppBar(
        backgroundColor: const Color(0xffFFF9F7),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          "Dashboard",
          style: GoogleFonts.manrope(
            fontSize: Responsive.titleSize(context),
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: StreamBuilder<DashboardStats>(
        stream: _dashboardService.dashboardStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xff7F4F4F),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text("No dashboard data found."),
            );
          }

          final dashboard = snapshot.data!;

          final statCards = [
            AdminStatCard(
              title: "Revenue",
              value: "PKR ${dashboard.revenue.toStringAsFixed(0)}",
              subtitle: "Total Sales",
              icon: Icons.payments_outlined,
              color: Colors.green,
            ),
            AdminStatCard(
              title: "Orders",
              value: dashboard.totalOrders.toString(),
              subtitle: "Total Orders",
              icon: Icons.shopping_bag_outlined,
              color: Colors.blue,
            ),
            AdminStatCard(
              title: "Products",
              value: dashboard.totalProducts.toString(),
              subtitle: "Available",
              icon: Icons.inventory_2_outlined,
              color: Colors.orange,
            ),
            AdminStatCard(
              title: "Users",
              value: dashboard.totalUsers.toString(),
              subtitle: "Customers",
              icon: Icons.people_outline,
              color: Colors.purple,
            ),
            AdminStatCard(
              title: "Pending",
              value: dashboard.pendingOrders.toString(),
              subtitle: "Orders",
              icon: Icons.pending_actions_outlined,
              color: Colors.red,
            ),
          ];

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.horizontalPadding(context),
              vertical: Responsive.verticalPadding(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome back, Admin",
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),

                const SizedBox(height: 20),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: statCards.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    mainAxisExtent: 120,
                  ),
                  itemBuilder: (context, index) => statCards[index],
                ),

                const SizedBox(height: 28),

               Text(
  "Management",
  style: GoogleFonts.manrope(
    fontSize: 18,
    fontWeight: FontWeight.w700,
  ),
),

const SizedBox(height: 16),

GridView.count(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  crossAxisCount: columns,
  crossAxisSpacing: 16,
  mainAxisSpacing: 16,
  childAspectRatio: 1.15,
  children: [

    AdminNavigationCard(
      title: "Products",
      icon: Icons.inventory_2_outlined,
      color: Colors.orange,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ProductsScreen(),
          ),
        );
      },
    ),

    AdminNavigationCard(
      title: "Orders",
      icon: Icons.shopping_bag_outlined,
      color: Colors.blue,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const OrdersScreen(),
          ),
        );
      },
    ),

    AdminNavigationCard(
      title: "Customers",
      icon: Icons.people_outline,
      color: Colors.purple,
      onTap: () {},
    ),

    AdminNavigationCard(
      title: "Categories",
      icon: Icons.category_outlined,
      color: Colors.green,
      onTap: () {},
    ),

    AdminNavigationCard(
      title: "Coupons",
      icon: Icons.discount_outlined,
      color: Colors.red,
      onTap: () {},
    ),

    AdminNavigationCard(
      title: "Settings",
      icon: Icons.settings_outlined,
      color: Colors.grey,
      onTap: () {},
    ),
  ],
),
              ],
            ),
          );
        },
      ),
    );
  }
}