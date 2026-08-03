import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/order_constants.dart';
import '../models/order_model.dart';
import 'payment_service.dart';
import 'receipt_service.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final CollectionReference<Map<String, dynamic>> _ordersRef =
      _firestore.collection("orders");

  String generateOrderId() {
    return _ordersRef.doc().id;
  }

  Future<void> clearCart() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final cartSnapshot = await _firestore
        .collection("users")
        .doc(user.uid)
        .collection("cart")
        .get();
    if (cartSnapshot.docs.isEmpty) return;
    final batch = _firestore.batch();
    for (final item in cartSnapshot.docs) {
      batch.delete(item.reference);
    }
    await batch.commit();
  }

  Future<void> placeManualPaymentOrder({
    required String userName,
    required String email,
    required String address,
    required String phone,
    required List<Map<String, dynamic>> products,
    required double subtotal,
    required double delivery,
    required double total,
    required String paymentMethod,
    required File receipt,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in.");
    }

    try {
      final settingsDoc = await _firestore.collection('settings').doc('general').get();
      final bool allowCheckout = settingsDoc.data()?['allowCheckout'] ?? true;

      if (!allowCheckout) {
        throw Exception("Store is currently closed for checkout. Please check back later.");
      }

      final orderId = generateOrderId();
      final receiptUrl = await ReceiptService.instance.uploadReceipt(
        receipt: receipt,
        orderId: orderId,
      );
      
      await PaymentService.instance.submitPayment(
        orderId: orderId,
        userName: userName,
        email: email,
        phone: phone,
        address: address,
        products: products,
        subtotal: subtotal,
        delivery: delivery,
        total: total,
        paymentMethod: paymentMethod,
        receiptUrl: receiptUrl,
      );
      
      await clearCart();
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<OrderModel>> getUserOrders() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }
    return _ordersRef
        .where("userId", isEqualTo: user.uid)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(OrderModel.fromDocument).toList(),
        );
  }

  Stream<List<OrderModel>> getAllOrders() {
    return _ordersRef
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(OrderModel.fromDocument).toList(),
        );
  }

  Stream<List<OrderModel>> getOrdersByOrderStatus(String orderStatus) {
    return _ordersRef
        .where("orderStatus", isEqualTo: orderStatus)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(OrderModel.fromDocument).toList(),
        );
  }

  Future<OrderModel?> getOrderById(String orderId) async {
    final doc = await _ordersRef.doc(orderId).get();
    if (!doc.exists) return null;
    return OrderModel.fromDocument(doc);
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String orderStatus,
  }) async {
    final Map<String, dynamic> updateData = {
      "orderStatus": orderStatus,
      "updatedAt": FieldValue.serverTimestamp(),
    };

    // If order is cancelled, automatically ensure payment status is marked rejected/cancelled
    if (orderStatus == OrderStatus.cancelled) {
      updateData["paymentStatus"] = PaymentStatus.rejected;
    }

    await _ordersRef.doc(orderId).update(updateData);
  }

  Future<void> updatePaymentStatus({
    required String orderId,
    required String paymentStatus,
  }) async {
    final Map<String, dynamic> updateData = {
      "paymentStatus": paymentStatus,
      "updatedAt": FieldValue.serverTimestamp(),
    };

    // If payment is rejected, automatically force order status to cancelled so it leaves pending
    if (paymentStatus == PaymentStatus.rejected) {
      updateData["orderStatus"] = OrderStatus.cancelled;
    }

    await _ordersRef.doc(orderId).update(updateData);
  }

  Future<void> markAdminSeen(String orderId) async {
    await _ordersRef.doc(orderId).update({
      "adminSeen": true,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> cancelOrder(String orderId) async {
    await _ordersRef.doc(orderId).update({
      "orderStatus": OrderStatus.cancelled,
      "paymentStatus": PaymentStatus.rejected,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteOrder(String orderId) async {
    await _ordersRef.doc(orderId).delete();
  }
}