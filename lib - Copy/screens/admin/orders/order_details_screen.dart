import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/order_model.dart';
import '../../../services/order_service.dart';
import '../../../widgets/admin/admin_button.dart';
import '../../../widgets/admin/admin_card.dart';
import '../../../widgets/admin/responsive.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel order;

  const OrderDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  State<OrderDetailsScreen> createState() =>
      _OrderDetailsScreenState();
}

class _OrderDetailsScreenState
    extends State<OrderDetailsScreen> {
  final OrderService _orderService =
      OrderService();

  late String selectedStatus;

  bool isLoading = false;

  final List<String> statuses = [
    "Pending",
    "Processing",
    "Shipped",
    "Delivered",
    "Cancelled",
  ];

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.order.orderStatus;
  }

  Future<void> updateStatus() async {
    setState(() {
      isLoading = true;
    });

    await _orderService.updateOrderStatus(
      orderId: widget.order.orderId,
     orderStatus: selectedStatus,
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Order updated successfully."),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return Scaffold(
      backgroundColor: const Color(0xffFFF9F7),

      appBar: AppBar(
        backgroundColor: const Color(0xffFFF9F7),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          "Order Details",
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w700,
            fontSize:
                Responsive.titleSize(context),
            color: Colors.black87,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(
          Responsive.horizontalPadding(context),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _section(
              "Customer",
              [
                _tile("Name", order.userName),
                _tile("Email", order.email),
                _tile("Phone", order.phone),
                _tile("Address", order.address),
              ],
            ),

            const SizedBox(height: 18),

            _section(
              "Order",
              [
                _tile("Order ID", order.orderId),
                _tile(
                  "Payment",
                  order.paymentMethod,
                ),
                _tile(
                  "Subtotal",
                  "PKR ${order.subtotal.toStringAsFixed(0)}",
                ),
                _tile(
                  "Delivery",
                  "PKR ${order.delivery.toStringAsFixed(0)}",
                ),
                _tile(
                  "Total",
                  "PKR ${order.total.toStringAsFixed(0)}",
                ),
              ],
            ),

            const SizedBox(height: 18),

            Text(
              "Products",
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 12),

            ...order.products.map(
              (item) => AdminCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    item["name"] ?? "",
                  ),
                  subtitle: Text(
                    "Qty: ${item["quantity"]}",
                  ),
                  trailing: Text(
                    "PKR ${item["price"]}",
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            DropdownButtonFormField<String>(
              value: selectedStatus,
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
                  selectedStatus = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            AdminButton(
              text: "Update Status",
              isLoading: isLoading,
              onPressed: updateStatus,
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(
    String title,
    List<Widget> children,
  ) {
    return AdminCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _tile(
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: GoogleFonts.manrope(
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: GoogleFonts.manrope(
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}