import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'order_details_screen.dart';
import '../../../models/order_model.dart';
import '../../../services/order_service.dart';
import '../../../widgets/admin/admin_card.dart';
import '../../../widgets/admin/responsive.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final OrderService _orderService = OrderService();

  final TextEditingController _searchController =
      TextEditingController();

  String _selectedStatus = "All";

  final List<String> statuses = [
    "All",
    "Pending",
    "Processing",
    "Shipped",
    "Delivered",
    "Cancelled",
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          "Orders",
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w700,
            fontSize: Responsive.titleSize(context),
            color: Colors.black87,
          ),
        ),
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.horizontalPadding(context),
          vertical: Responsive.verticalPadding(context),
        ),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search customer...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    Responsive.radius,
                  ),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (_) {
                setState(() {});
              },
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      Responsive.radius,
                    ),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: statuses
                    .map(
                      (status) =>
                          DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
              ),
            ),

            const SizedBox(height: 18),

            Expanded(
              child: StreamBuilder<List<OrderModel>>(
                stream: _selectedStatus == "All"
                    ? _orderService.getAllOrders()
                    : _orderService
                        .getOrdersByStatus(
                        _selectedStatus,
                      ),
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

                  if (!snapshot.hasData ||
                      snapshot.data!.isEmpty) {
                    return const Center(
                      child:
                          Text("No orders found."),
                    );
                  }

                  List<OrderModel> orders =
                      snapshot.data!;

                  if (_searchController
                      .text.isNotEmpty) {
                    orders = orders.where((order) {
                      return order.userName
                          .toLowerCase()
                          .contains(
                            _searchController.text
                                .toLowerCase(),
                          );
                    }).toList();
                  }

                  return ListView.separated(
                    itemCount: orders.length,
                    separatorBuilder:
                        (_, __) =>
                            const SizedBox(
                      height: 12,
                    ),
                    itemBuilder:
                        (context, index) {
                      final order =
                          orders[index];

                      return AdminCard(
                       onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => OrderDetailsScreen(
        order: order,
      ),
    ),
  );
},
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor:
                                  const Color(
                                0xff7F4F4F,
                              ),
                              child: Text(
                                order.userName
                                    .isNotEmpty
                                    ? order.userName[
                                        0]
                                    : "?",
                                style:
                                    const TextStyle(
                                  color:
                                      Colors.white,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ),

                            const SizedBox(
                                width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    order.userName,
                                    style:
                                        GoogleFonts
                                            .manrope(
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),

                                  const SizedBox(
                                      height:
                                          4),

                                  Text(
                                    order.orderId,
                                    style:
                                        GoogleFonts
                                            .manrope(
                                      color: Colors
                                          .grey,
                                      fontSize: 12,
                                    ),
                                  ),

                                  const SizedBox(
                                      height:
                                          4),

                                  Text(
                                    "PKR ${order.total.toStringAsFixed(0)}",
                                    style:
                                        GoogleFonts
                                            .manrope(
                                      fontWeight:
                                          FontWeight
                                              .w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration:
                                  BoxDecoration(
                                color:
                                    _statusColor(
                                            order
                                                .status)
                                        .withOpacity(
                                            0.15),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            8),
                              ),
                              child: Text(
                                order.status,
                                style:
                                    GoogleFonts
                                        .manrope(
                                  color:
                                      _statusColor(
                                    order.status,
                                  ),
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),

                            const SizedBox(
                                width: 8),

                            const Icon(
                              Icons
                                  .chevron_right,
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
      ),
    );
  }

  Color _statusColor(
    String status,
  ) {
    switch (status) {
      case "Pending":
        return Colors.orange;

      case "Processing":
        return Colors.blue;

      case "Shipped":
        return Colors.purple;

      case "Delivered":
        return Colors.green;

      case "Cancelled":
        return Colors.red;

      default:
        return Colors.grey;
    }
  }
}