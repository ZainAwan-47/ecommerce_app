import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../models/order_model.dart';
import '../../../services/order_service.dart';
import '../../../constants/order_constants.dart';
import '../../../utils/app_notifier.dart';
import 'order_details_screen.dart';
import 'widgets/order_card.dart';

enum OrderSortOption {
  newest,
  oldest,
  priceHighToLow,
  priceLowToHigh,
}

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final OrderService _orderService = OrderService();
  final TextEditingController _searchController = TextEditingController();
  late final Stream<List<OrderModel>> _ordersStream;
  String _searchQuery = '';
  String _selectedStatus = "All";
  OrderSortOption _selectedSort = OrderSortOption.newest;
  int _currentPage = 1;
  final int _itemsPerPage = 15;

  @override
  void initState() {
    super.initState();
    _ordersStream = _orderService.getAllOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<String, int> _calculateStatusCounts(List<OrderModel> orders) {
    final Map<String, int> counts = {'All': orders.length};
    for (final status in OrderStatus.values) {
      counts[status] = 0;
    }
    for (final order in orders) {
      if (counts.containsKey(order.orderStatus)) {
        counts[order.orderStatus] = counts[order.orderStatus]! + 1;
      }
    }
    return counts;
  }

  List<OrderModel> _filterAndSortOrders(List<OrderModel> rawOrders) {
    var filtered = List<OrderModel>.from(rawOrders);
    
    // 1. Status Filter
    if (_selectedStatus != "All") {
      filtered = filtered
          .where((order) => order.orderStatus == _selectedStatus)
          .toList();
    }
    
    // 2. Search Query Filter (Aligned with Firestore fields: orderId, name, email, phoneNumber)
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((order) {
        final orderId = (order.orderId ?? '').toLowerCase();
        final userName = (order.userName ?? '').toLowerCase(); // Maps to 'name' in Firestore
        final userEmail = (order.email ?? '').toLowerCase();
        final phone = (order.phone ?? '').toLowerCase(); // Maps to 'phoneNumber' in Firestore

        return orderId.contains(query) ||
            userName.contains(query) ||
            userEmail.contains(query) ||
            phone.contains(query);
      }).toList();
    }
    
    // 3. Sorting
    filtered.sort((a, b) {
      switch (_selectedSort) {
        case OrderSortOption.newest:
          return _getDateTime(b.createdAt).compareTo(_getDateTime(a.createdAt));
        case OrderSortOption.oldest:
          return _getDateTime(a.createdAt).compareTo(_getDateTime(b.createdAt));
        case OrderSortOption.priceHighToLow:
          return b.total.compareTo(a.total);
        case OrderSortOption.priceLowToHigh:
          return a.total.compareTo(b.total);
      }
    });
    
    return filtered;
  }

  DateTime _getDateTime(dynamic rawDate) {
    if (rawDate is Timestamp) return rawDate.toDate();
    if (rawDate is DateTime) return rawDate;
    return DateTime.now();
  }

  /// Delete Confirmation Dialog
  Future<void> _confirmAndDeleteOrder(String orderId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFEE2E2)),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFDC2626),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Delete Order",
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to permanently delete order #$orderId? This action cannot be undone.",
          style: const TextStyle(
            color: Color(0xFF475569),
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF475569),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmed || !mounted) return;

    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).delete();
      if (!mounted) return;
      AppNotifier.success(context, "Order deleted successfully");
    } catch (_) {
      if (!mounted) return;
      AppNotifier.error(context, "Failed to delete order. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusList = ["All", ...OrderStatus.values];
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        title: const Text(
          "Orders",
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<OrderModel>>(
          stream: _ordersStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  "Something went wrong. Please try again.",
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Color(0xFF2563EB),
                ),
              );
            }
            final allOrders = snapshot.data!;
            final statusCounts = _calculateStatusCounts(allOrders);
            final filteredOrders = _filterAndSortOrders(allOrders);
            final totalPages = max(
              1,
              (filteredOrders.length / _itemsPerPage).ceil(),
            );
            if (_currentPage > totalPages) {
              _currentPage = totalPages;
            }
            final start = (_currentPage - 1) * _itemsPerPage;
            final end = min(start + _itemsPerPage, filteredOrders.length);
            final pageItems = filteredOrders.isEmpty
                ? <OrderModel>[]
                : filteredOrders.sublist(start, end);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  /// Search Input & Sort Button Row
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF0F172A),
                          ),
                          decoration: InputDecoration(
                            hintText: "Search Order ID or Phone Number",
                            hintStyle: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Color(0xFF64748B),
                              size: 20,
                            ),
                            suffixIcon: _searchQuery.isEmpty
                                ? null
                                : IconButton(
                                    icon: const Icon(
                                      Icons.clear,
                                      size: 18,
                                      color: Color(0xFF64748B),
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchQuery = '';
                                        _currentPage = 1;
                                      });
                                    },
                                  ),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFF2563EB),
                                width: 1.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value.trim();
                              _currentPage = 1;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      /// Sort By Filter Popup Menu
                      PopupMenuButton<OrderSortOption>(
                        initialValue: _selectedSort,
                        tooltip: "Sort Orders",
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onSelected: (option) {
                          setState(() {
                            _selectedSort = option;
                            _currentPage = 1;
                          });
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: OrderSortOption.newest,
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, size: 16),
                                SizedBox(width: 8),
                                Text("Newest First"),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: OrderSortOption.oldest,
                            child: Row(
                              children: [
                                Icon(Icons.history, size: 16),
                                SizedBox(width: 8),
                                Text("Oldest First"),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: OrderSortOption.priceHighToLow,
                            child: Row(
                              children: [
                                Icon(Icons.arrow_downward, size: 16),
                                SizedBox(width: 8),
                                Text("Price: High to Low"),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: OrderSortOption.priceLowToHigh,
                            child: Row(
                              children: [
                                Icon(Icons.arrow_upward, size: 16),
                                SizedBox(width: 8),
                                Text("Price: Low to High"),
                              ],
                            ),
                          ),
                        ],
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: const Icon(
                            Icons.swap_vert_rounded,
                            color: Color(0xFF0F172A),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  /// Status Filter Chips
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: statusList.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final status = statusList[index];
                        final count = statusCounts[status] ?? 0;
                        final isSelected = _selectedStatus == status;
                        return ChoiceChip(
                          label: Text("$status ($count)"),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF475569),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFF0F172A),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF0F172A)
                                : const Color(0xFFE2E8F0),
                          ),
                          showCheckmark: false,
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
                  const SizedBox(height: 14),
                  /// Header Counter & Active Sort Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${filteredOrders.length} ${filteredOrders.length == 1 ? 'order' : 'orders'} found",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        _getSortLabel(_selectedSort),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  /// Orders List View
                  Expanded(
                    child: filteredOrders.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 12),
                            itemCount: pageItems.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final order = pageItems[index];
                              return OrderCard(
                                order: order,
                                onView: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => OrderDetailsScreen(
                                        order: order,
                                      ),
                                    ),
                                  );
                                },
                                onDelete: () =>
                                    _confirmAndDeleteOrder(order.orderId),
                              );
                            },
                          ),
                  ),
                  /// Pagination Footer Dock
                  if (filteredOrders.isNotEmpty && totalPages > 1) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 8, top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: _currentPage > 1
                                ? () => setState(() => _currentPage--)
                                : null,
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              size: 16,
                            ),
                            color: const Color(0xFF0F172A),
                          ),
                          Text(
                            "Page $_currentPage of $totalPages",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          IconButton(
                            onPressed: _currentPage < totalPages
                                ? () => setState(() => _currentPage++)
                                : null,
                            icon: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                            ),
                            color: const Color(0xFF0F172A),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _getSortLabel(OrderSortOption option) {
    switch (option) {
      case OrderSortOption.newest:
        return "Sorted by: Newest";
      case OrderSortOption.oldest:
        return "Sorted by: Oldest";
      case OrderSortOption.priceHighToLow:
        return "Sorted by: Price: High to Low";
      case OrderSortOption.priceLowToHigh:
        return "Sorted by: Price: Low to High";
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 40,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "No Orders Found",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Try adjusting your active filter or search keywords.",
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}