import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/dashboard_stats.dart';
import '../../../services/dashboard_service.dart';
import '../../../utils/app_notifier.dart';
import '../../../widgets/admin/admin_navigation_card.dart';
import '../../../widgets/admin/responsive.dart';
import '../categories/categories_screen.dart';
import '../orders/orders_screen.dart';
import '../products/products_screen.dart';
import '../users/users_screen.dart';
import '../settings/admin_settings_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => AdminDashboardScreenState();
}

class AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final DashboardService _dashboardService = DashboardService.instance;
  late final Stream<DashboardStats> _dashboardStatsStream;

  @override
  void initState() {
    super.initState();
    _dashboardStatsStream = _dashboardService.dashboardStream();
  }

  void _showStatInfoSheet(BuildContext context, String title, String subtitle, IconData icon, Color color) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xffFFF9F7),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xff2D2323))),
                      const SizedBox(height: 2),
                      Text(subtitle, style: GoogleFonts.manrope(fontSize: 13, color: const Color(0xff8D7B7B))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                "This metric updates in real-time based on verified store transactions and database status records.",
                style: GoogleFonts.manrope(fontSize: 14, color: Colors.grey.shade700, height: 1.5),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff7F4F4F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text("Got it", style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showWalletManagerDialog(BuildContext context, {String? docId, Map<String, dynamic>? existingData}) {
    final titleController = TextEditingController(text: existingData?['title'] ?? '');
    final nameController = TextEditingController(text: existingData?['accountName'] ?? '');
    final numberController = TextEditingController(text: existingData?['accountNumber'] ?? '');
    final ibanController = TextEditingController(text: existingData?['iban'] ?? '');
    String selectedType = existingData?['type'] ?? 'easypaisa';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              title: Text(
                docId == null ? "Add Payment Account" : "Edit Payment Account",
                style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Account Type", style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      dropdownColor: Colors.white,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'easypaisa', child: Text("EasyPaisa")),
                        DropdownMenuItem(value: 'jazzcash', child: Text("JazzCash")),
                        DropdownMenuItem(value: 'bank', child: Text("Bank Account")),
                      ],
                      onChanged: (val) {
                        setDialogState(() {
                          selectedType = val!;
                          if (docId == null) {
                            titleController.text = val == 'easypaisa' ? 'EasyPaisa' : (val == 'jazzcash' ? 'JazzCash' : 'Bank Transfer');
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(labelText: "Method Title (e.g., JazzCash)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: "Account Holder Name", border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: numberController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: selectedType == 'bank' ? "Account Number" : "Mobile No (03XXXXXXXXX)",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    if (selectedType == 'bank') ...[
                      const SizedBox(height: 14),
                      TextField(
                        controller: ibanController,
                        decoration: InputDecoration(labelText: "IBAN (Optional)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel", style: GoogleFonts.manrope(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff7F4F4F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    final title = titleController.text.trim();
                    final name = nameController.text.trim();
                    final number = numberController.text.trim();
                    final iban = ibanController.text.trim();

                    if (title.isEmpty || name.isEmpty || number.isEmpty) {
                      AppNotifier.error(context, "Please fill in all required fields.");
                      return;
                    }

                    if (selectedType == 'easypaisa' || selectedType == 'jazzcash') {
                      final phoneRegex = RegExp(r'^03\d{9}$');
                      if (!phoneRegex.hasMatch(number)) {
                        AppNotifier.error(context, "Invalid format! EasyPaisa/JazzCash must start with '03' and be 11 digits.");
                        return;
                      }
                    }

                    final dataMap = {
                      'type': selectedType,
                      'title': title,
                      'accountName': name,
                      'accountNumber': number,
                      'iban': iban,
                      'updatedAt': FieldValue.serverTimestamp(),
                    };

                    if (docId == null) {
                      dataMap['createdAt'] = FieldValue.serverTimestamp();
                      await FirebaseFirestore.instance.collection('payment_accounts').add(dataMap);
                    } else {
                      await FirebaseFirestore.instance.collection('payment_accounts').doc(docId).update(dataMap);
                    }

                    if (!context.mounted) return;
                    Navigator.pop(context);
                    AppNotifier.success(context, "Payment account saved successfully.");
                  },
                  child: Text("Save", style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String docId, String accountTitle) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Text(
            "Delete Account",
            style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xff2D2323)),
          ),
          content: Text(
            "Are you sure you want to delete '$accountTitle'? This action cannot be undone.",
            style: GoogleFonts.manrope(fontSize: 14, color: const Color(0xff8D7B7B)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: GoogleFonts.manrope(color: const Color(0xff8D7B7B), fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                Navigator.pop(context);
                await FirebaseFirestore.instance.collection('payment_accounts').doc(docId).delete();
                if (!context.mounted) return;
                AppNotifier.success(context, "Payment account deleted successfully.");
              },
              child: Text("Delete", style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _manageWalletsScreen(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xffFFF9F7),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          height: MediaQuery.of(context).size.height * 0.72,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Manage Wallets", style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xff2D2323))),
                  Material(
                    color: const Color(0xff7F4F4F),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        _showWalletManagerDialog(context);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.add_rounded, color: Colors.white, size: 24),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('payment_accounts').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xff7F4F4F)));
                    }
                    final docs = snapshot.data!.docs;
                    if (docs.isEmpty) {
                      return Center(
                        child: Text(
                          "No payment accounts configured yet.",
                          style: GoogleFonts.manrope(color: const Color(0xff8D7B7B), fontWeight: FontWeight.w600),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final docData = docs[index].data() as Map<String, dynamic>;
                        final docId = docs[index].id;
                        final isBank = docData['type'] == 'bank';
                        final accountTitle = docData['title'] ?? 'Account';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.black.withOpacity(0.08), width: 0.8),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xffFFF9F7),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  isBank ? Icons.account_balance_rounded : Icons.account_balance_wallet_rounded,
                                  color: const Color(0xff7F4F4F),
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      accountTitle,
                                      style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xff2D2323)),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "${docData['accountName']} • ${docData['accountNumber']}",
                                      style: GoogleFonts.manrope(fontSize: 12.5, color: const Color(0xff8D7B7B)),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_rounded, size: 20, color: Colors.blueGrey),
                                onPressed: () {
                                  _showWalletManagerDialog(context, docId: docId, existingData: docData);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.redAccent),
                                onPressed: () {
                                  _showDeleteConfirmationDialog(context, docId, accountTitle);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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
            onPressed: () {
              AppNotifier.success(context, "No new notifications.");
            },
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.black87,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<DashboardStats>(
          stream: _dashboardStatsStream,
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
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                  ),
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
              // 1. Revenue Card
              InkWell(
                onTap: () => _showStatInfoSheet(
                  context,
                  "Total Revenue",
                  "PKR ${dashboard.revenue.toStringAsFixed(0)}",
                  Icons.payments_outlined,
                  Colors.green,
                ),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.black.withOpacity(0.08), width: 0.8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Revenue", style: GoogleFonts.manrope(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                          const Icon(Icons.payments_outlined, color: Colors.green, size: 20),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "PKR ${dashboard.revenue.toStringAsFixed(0)}",
                        style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xff2D2323)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text("Verified Sales Only", style: GoogleFonts.manrope(fontSize: 11, color: Colors.green.shade700)),
                    ],
                  ),
                ),
              ),

              // 2. Orders Card
              InkWell(
                onTap: () => _showStatInfoSheet(
                  context,
                  "Total Orders",
                  "${dashboard.totalOrders} total recorded orders",
                  Icons.shopping_bag_outlined,
                  Colors.blue,
                ),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.black.withOpacity(0.08), width: 0.8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Orders", style: GoogleFonts.manrope(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                          const Icon(Icons.shopping_bag_outlined, color: Colors.blue, size: 20),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        dashboard.totalOrders.toString(),
                        style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xff2D2323)),
                      ),
                      const SizedBox(height: 2),
                      Text("All Processed Orders", style: GoogleFonts.manrope(fontSize: 11, color: Colors.blue.shade700)),
                    ],
                  ),
                ),
              ),

              // 3. Products Card
              InkWell(
                onTap: () => _showStatInfoSheet(
                  context,
                  "Inventory Products",
                  "${dashboard.totalProducts} active catalog products",
                  Icons.inventory_2_outlined,
                  Colors.orange,
                ),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.black.withOpacity(0.08), width: 0.8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Products", style: GoogleFonts.manrope(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                          const Icon(Icons.inventory_2_outlined, color: Colors.orange, size: 20),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        dashboard.totalProducts.toString(),
                        style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xff2D2323)),
                      ),
                      const SizedBox(height: 2),
                      Text("Available Inventory", style: GoogleFonts.manrope(fontSize: 11, color: Colors.orange.shade700)),
                    ],
                  ),
                ),
              ),

              // 4. Users Card
              InkWell(
                onTap: () => _showStatInfoSheet(
                  context,
                  "Registered Customers",
                  "${dashboard.totalUsers} active customer accounts",
                  Icons.people_outline,
                  Colors.purple,
                ),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.black.withOpacity(0.08), width: 0.8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Users", style: GoogleFonts.manrope(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                          const Icon(Icons.people_outline, color: Colors.purple, size: 20),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        dashboard.totalUsers.toString(),
                        style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xff2D2323)),
                      ),
                      const SizedBox(height: 2),
                      Text("Registered Customers", style: GoogleFonts.manrope(fontSize: 11, color: Colors.purple.shade700)),
                    ],
                  ),
                ),
              ),

              // 5. Pending Orders Card
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OrdersScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.amber.shade300, width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Pending", style: GoogleFonts.manrope(fontSize: 13, color: Colors.amber.shade900, fontWeight: FontWeight.bold)),
                          const Icon(Icons.pending_actions_outlined, color: Colors.amber, size: 20),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        dashboard.pendingOrders.toString(),
                        style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xff2D2323)),
                      ),
                      const SizedBox(height: 2),
                      Text("Action Required (Tap)", style: GoogleFonts.manrope(fontSize: 11, color: Colors.amber.shade800)),
                    ],
                  ),
                ),
              ),
            ];

            final navigationCards = [
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UsersScreen(),
                    ),
                  );
                },
              ),
              AdminNavigationCard(
                title: "Categories",
                icon: Icons.category_outlined,
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CategoriesScreen(),
                    ),
                  );
                },
              ),
              AdminNavigationCard(
                title: "Wallets",
                icon: Icons.account_balance_wallet_outlined,
                color: Colors.teal,
                onTap: () {
                  _manageWalletsScreen(context);
                },
              ),
              AdminNavigationCard(
                title: "Settings",
                icon: Icons.settings_outlined,
                color: Colors.grey,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminSettingsScreen(),
                    ),
                  );
                },
              ),
            ];

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.horizontalPadding(context),
                    vertical: Responsive.verticalPadding(context),
                  ).copyWith(
                    bottom: MediaQuery.of(context).padding.bottom + 24,
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
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          mainAxisExtent: 110,
                        ),
                        itemBuilder: (context, index) => statCards[index],
                      ),
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xffFCF8F6),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xffE7D9D4),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.brown.withOpacity(0.08),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.dashboard_customize_outlined,
                                color: Color(0xff7F4F4F),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Management",
                                style: GoogleFonts.manrope(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xff7F4F4F),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: columns,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.55,
                        children: navigationCards,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}