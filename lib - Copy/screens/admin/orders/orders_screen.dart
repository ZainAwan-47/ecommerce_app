import 'package:flutter/material.dart';

import '../../../models/order_model.dart';
import '../../../services/order_service.dart';
import '../../../constants/order_constants.dart';

import 'order_details_screen.dart';
import 'widgets/order_card.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final OrderService _orderService = OrderService();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = "";
  String _selectedStatus = "All";

  int _currentPage = 1;
  final int _itemsPerPage = 15;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<OrderModel> _filterOrders(List<OrderModel> orders) {
    var filtered = orders;

    if (_selectedStatus != "All") {
      filtered = filtered
          .where((order) => order.orderStatus == _selectedStatus)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();

      filtered = filtered.where((order) {
        return order.orderId.toLowerCase().contains(query) ||
            order.userName.toLowerCase().contains(query) ||
            order.email.toLowerCase().contains(query) ||
            order.phone.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final statusList = [
      "All",
      ...OrderStatus.values,
    ];

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Orders"),
          centerTitle: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// Search
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search orders...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim();
                    _currentPage = 1;
                  });
                },
              ),

              const SizedBox(height: 16),

              /// Status Filter
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: statusList.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final status = statusList[index];

                    return ChoiceChip(
                      label: Text(status),
                      selected: _selectedStatus == status,
                      onSelected: (_) {
                        setState(() {
                          _selectedStatus = status;
                          _currentPage = 1;
                        });
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              /// Orders
              Expanded(
                child: StreamBuilder<List<OrderModel>>(
                  stream: _orderService.getAllOrders(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text("Something went wrong."),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final filtered =
                        _filterOrders(snapshot.data!);

                    if (filtered.isEmpty) {
                      return const Center(
                        child: Text("No orders found."),
                      );
                    }

                    final totalPages =
                        (filtered.length / _itemsPerPage)
                            .ceil();

                    if (_currentPage > totalPages) {
                      _currentPage = totalPages;
                    }

                    final start =
                        (_currentPage - 1) * _itemsPerPage;

                    final end =
                        (start + _itemsPerPage > filtered.length)
                            ? filtered.length
                            : start + _itemsPerPage;

                    final pageItems =
                        filtered.sublist(start, end);

                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: pageItems.length,
                            itemBuilder: (context, index) {
                              final order = pageItems[index];

                              return OrderCard(
                                order: order,
                                onView: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          OrderDetailsScreen(
                                        order: order,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: _currentPage > 1
                                  ? () {
                                      setState(() {
                                        _currentPage--;
                                      });
                                    }
                                  : null,
                              icon: const Icon(
                                  Icons.chevron_left),
                            ),
                            Text(
                              "Page $_currentPage of $totalPages",
                            ),
                            IconButton(
                              onPressed:
                                  _currentPage < totalPages
                                      ? () {
                                          setState(() {
                                            _currentPage++;
                                          });
                                        }
                                      : null,
                              icon: const Icon(
                                  Icons.chevron_right),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}