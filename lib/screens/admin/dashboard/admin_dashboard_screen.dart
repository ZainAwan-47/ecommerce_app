import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/dashboard_service.dart';
import '../../../widgets/admin/admin_stat_card.dart';
import '../../../widgets/admin/responsive.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});
final DashboardService _dashboardService = DashboardService();
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
     body: FutureBuilder(
  future: Future.wait([
    _dashboardService.getTotalRevenue(),
    _dashboardService.getTotalOrders(),
    _dashboardService.getTotalProducts(),
    _dashboardService.getTotalUsers(),
    _dashboardService.getPendingOrders(),
  ]),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xff7F4F4F),
        ),
      );
    }

    if (snapshot.hasError) {
      return const Center(
        child: Text("Something went wrong."),
      );
    }

    final data = snapshot.data!;

    final revenue = data[0] as double;
    final orders = data[1] as int;
    final products = data[2] as int;
    final users = data[3] as int;
    final pending = data[4] as int;

    final columns = Responsive.columns(context);

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

          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 2.2,
            ),
            children: [
              AdminStatCard(
                title: "Revenue",
                value: "PKR ${revenue.toStringAsFixed(0)}",
                subtitle: "Total Sales",
                icon: Icons.payments_outlined,
                color: Colors.green,
              ),
              AdminStatCard(
                title: "Orders",
                value: orders.toString(),
                subtitle: "Total Orders",
                icon: Icons.shopping_bag_outlined,
                color: Colors.blue,
              ),
              AdminStatCard(
                title: "Products",
                value: products.toString(),
                subtitle: "Available",
                icon: Icons.inventory_2_outlined,
                color: Colors.orange,
              ),
              AdminStatCard(
                title: "Users",
                value: users.toString(),
                subtitle: "Customers",
                icon: Icons.people_outline,
                color: Colors.purple,
              ),
              AdminStatCard(
                title: "Pending",
                value: pending.toString(),
                subtitle: "Orders",
                icon: Icons.pending_actions_outlined,
                color: Colors.red,
              ),
            ],
          ),

          const SizedBox(height: 28),

          Text(
            "Recent Orders",
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 12),

          const AdminCard(
            child: Text(
              "Recent orders will appear here.",
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