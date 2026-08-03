import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../constants/order_constants.dart';
import '../../../models/order_model.dart';
import '../../../services/order_service.dart';
import '../../../services/notification_service.dart';
import '../../../utils/app_notifier.dart';
import 'widgets/customer_info_card.dart';
import 'widgets/order_summary_card.dart';
import 'widgets/order_timeline_card.dart';
import 'widgets/ordered_products_card.dart';
import 'widgets/payment_info_card.dart';
import 'widgets/shipping_address_card.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel order;
  const OrderDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final OrderService _orderService = OrderService();
  bool _isUpdating = false;

  Color _getStatusColor(String status) {
    switch (status) {
      case OrderStatus.pending:
      case PaymentStatus.pending:
        return const Color(0xFFD97706);
      case OrderStatus.confirmed:
      case PaymentStatus.verified:
        return const Color(0xFF2563EB);
      case OrderStatus.packed:
      case OrderStatus.shipped:
        return const Color(0xFF7C3AED);
      case OrderStatus.delivered:
        return const Color(0xFF059669);
      case OrderStatus.cancelled:
      case PaymentStatus.rejected:
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF475569);
    }
  }

  Future<bool> _showConfirmationDialog({
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
    required IconData icon,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: confirmColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: confirmColor.withOpacity(0.2)),
                  ),
                  child: Icon(
                    icon,
                    color: confirmColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            content: Text(
              message,
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
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: confirmColor,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: Text(confirmText),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _updateOrderStatus(String orderId, String status, String userId) async {
    if (_isUpdating) return;
    if (status == OrderStatus.confirmed) {
      final confirmed = await _showConfirmationDialog(
        title: 'Confirm Order',
        message: 'Are you sure you want to approve and confirm this order?',
        confirmText: 'Confirm Order',
        confirmColor: const Color(0xFF2563EB),
        icon: Icons.thumb_up_alt_outlined,
      );
      if (!confirmed) return;
    }
    if (status == OrderStatus.cancelled) {
      final confirmed = await _showConfirmationDialog(
        title: 'Cancel Order',
        message: 'Are you sure you want to cancel this order? This action cannot be undone.',
        confirmText: 'Cancel Order',
        confirmColor: const Color(0xFFDC2626),
        icon: Icons.warning_amber_rounded,
      );
      if (!confirmed) return;
    }

    setState(() => _isUpdating = true);
    try {
      await _orderService.updateOrderStatus(
        orderId: orderId,
        orderStatus: status,
      );

      // If order is cancelled, automatically reject payment status to exit pending state
      if (status == OrderStatus.cancelled) {
        await _orderService.updatePaymentStatus(
          orderId: orderId,
          paymentStatus: PaymentStatus.rejected,
        );
      }

      if (userId.isNotEmpty) {
        final shortId = orderId.length >= 6 ? orderId.substring(0, 6) : orderId;
        await NotificationService.sendOrderNotification(
          userId: userId,
          orderId: orderId,
          title: "Order Status Updated",
          body: "Your order #$shortId status has been updated to ${status.toUpperCase()}.",
          type: "status_update",
        );
      }

      if (!mounted) return;
      AppNotifier.success(context, 'Order status updated to $status');
    } catch (_) {
      if (!mounted) return;
      AppNotifier.error(context, 'Failed to update order status.');
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _updatePaymentStatus(String orderId, String status, String userId) async {
    if (_isUpdating) return;
    if (status == PaymentStatus.rejected) {
      final confirmed = await _showConfirmationDialog(
        title: 'Reject Payment',
        message: 'Are you sure you want to reject this payment? This will also automatically cancel the order.',
        confirmText: 'Reject & Cancel',
        confirmColor: const Color(0xFFDC2626),
        icon: Icons.warning_amber_rounded,
      );
      if (!confirmed) return;
    }
    if (status == PaymentStatus.verified) {
      final confirmed = await _showConfirmationDialog(
        title: 'Verify Payment',
        message: 'Are you sure you want to verify and approve this payment receipt?',
        confirmText: 'Verify Payment',
        confirmColor: const Color(0xFF059669),
        icon: Icons.check_circle_outline,
      );
      if (!confirmed) return;
    }

    setState(() => _isUpdating = true);
    try {
      final bool isRejected = status == PaymentStatus.rejected;
      await _orderService.updatePaymentStatus(
        orderId: orderId,
        paymentStatus: status,
      );

      if (isRejected) {
        await _orderService.updateOrderStatus(
          orderId: orderId,
          orderStatus: OrderStatus.cancelled,
        );
      }

      if (userId.isNotEmpty) {
        final shortId = orderId.length >= 6 ? orderId.substring(0, 6) : orderId;
        final isVerified = status == PaymentStatus.verified;
        await NotificationService.sendOrderNotification(
          userId: userId,
          orderId: orderId,
          title: isVerified ? "Payment Verified!" : "Payment Rejected & Order Cancelled",
          body: isVerified
              ? "Your payment for Order #$shortId has been approved."
              : "Your payment for Order #$shortId was rejected, so the order has been cancelled.",
          type: isVerified ? "payment_approved" : "payment_rejected",
        );
      }

      if (!mounted) return;
      AppNotifier.success(context, 'Payment status updated to $status');
    } catch (_) {
      if (!mounted) return;
      AppNotifier.error(context, 'Failed to update payment status.');
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.order.orderId)
          .snapshots(),
      builder: (context, snapshot) {
        OrderModel order = widget.order;
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.exists &&
            snapshot.data!.data() != null) {
          final data = snapshot.data!.data()!;
          data['orderId'] = snapshot.data!.id;
          order = OrderModel.fromMap(data);
        }

        final width = MediaQuery.of(context).size.width;
        final isDesktop = width >= 900;
        final statusColor = _getStatusColor(order.orderStatus);

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0.5,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Order Details",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: order.orderId));
                    AppNotifier.info(context, "Order ID copied to clipboard");
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "#${order.orderId}",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                          fontFamily: 'Monospace',
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.copy, size: 12, color: Color(0xFF64748B)),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      order.orderStatus.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 65,
                          child: Column(
                            children: [
                              CustomerInfoCard(order: order),
                              const SizedBox(height: 16),
                              ShippingAddressCard(address: order.address),
                              const SizedBox(height: 16),
                              OrderedProductsCard(products: order.products),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 35,
                          child: Column(
                            children: [
                              OrderTimelineCard(currentStatus: order.orderStatus),
                              const SizedBox(height: 16),
                              PaymentInfoCard(
                                order: order,
                                onViewReceipt: () {},
                              ),
                              const SizedBox(height: 16),
                              OrderSummaryCard(
                                subtotal: order.subtotal,
                                delivery: order.delivery,
                                total: order.total,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        CustomerInfoCard(order: order),
                        const SizedBox(height: 16),
                        ShippingAddressCard(address: order.address),
                        const SizedBox(height: 16),
                        OrderedProductsCard(products: order.products),
                        const SizedBox(height: 16),
                        OrderTimelineCard(currentStatus: order.orderStatus),
                        const SizedBox(height: 16),
                        PaymentInfoCard(
                          order: order,
                          onViewReceipt: () {},
                        ),
                        const SizedBox(height: 16),
                        OrderSummaryCard(
                          subtotal: order.subtotal,
                          delivery: order.delivery,
                          total: order.total,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
            ),
          ),
          bottomNavigationBar: _buildBottomActionDock(order),
        );
      },
    );
  }

  Widget? _buildBottomActionDock(OrderModel order) {
    final bool isTerminal = order.orderStatus == OrderStatus.delivered ||
        order.orderStatus == OrderStatus.cancelled ||
        order.paymentStatus == PaymentStatus.rejected;
    if (isTerminal) {
      return null;
    }

    final String userId = order.userId;
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isUpdating)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: LinearProgressIndicator(
                minHeight: 2,
                color: Color(0xFF2563EB),
              ),
            ),
          if (order.paymentStatus == PaymentStatus.pending) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(color: Color(0xFFFCA5A5)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _isUpdating
                        ? null
                        : () => _updatePaymentStatus(
                              order.orderId,
                              PaymentStatus.rejected,
                              userId,
                            ),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text("Reject Payment"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _isUpdating
                        ? null
                        : () => _updatePaymentStatus(
                              order.orderId,
                              PaymentStatus.verified,
                              userId,
                            ),
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text("Verify Payment"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                    side: const BorderSide(color: Color(0xFFFCA5A5)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isUpdating
                      ? null
                      : () => _updateOrderStatus(
                            order.orderId,
                            OrderStatus.cancelled,
                            userId,
                          ),
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: const Text("Cancel Order"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildNextWorkflowButton(order, userId),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNextWorkflowButton(OrderModel order, String userId) {
    String label = "";
    IconData icon = Icons.arrow_forward;
    Color color = const Color(0xFF2563EB);
    String nextStatus = "";

    if (order.orderStatus == OrderStatus.pending) {
      label = "Confirm Order";
      icon = Icons.thumb_up_alt_outlined;
      color = const Color(0xFF2563EB);
      nextStatus = OrderStatus.confirmed;
    } else if (order.orderStatus == OrderStatus.confirmed) {
      label = "Pack Order";
      icon = Icons.inventory_2_outlined;
      color = const Color(0xFF7C3AED);
      nextStatus = OrderStatus.packed;
    } else if (order.orderStatus == OrderStatus.packed) {
      label = "Ship Order";
      icon = Icons.local_shipping_outlined;
      color = const Color(0xFF0284C7);
      nextStatus = OrderStatus.shipped;
    } else if (order.orderStatus == OrderStatus.shipped) {
      label = "Mark Delivered";
      icon = Icons.done_all_rounded;
      color = const Color(0xFF059669);
      nextStatus = OrderStatus.delivered;
    }

    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: _isUpdating
          ? null
          : () => _updateOrderStatus(order.orderId, nextStatus, userId),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}