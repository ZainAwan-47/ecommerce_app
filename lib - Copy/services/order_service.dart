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

  /// GENERATE UNIQUE ORDER ID
  String generateOrderId() {
    return _firestore.collection("orders").doc().id;
  }

  /// CLEAR USER CART AFTER SUCCESSFUL PAYMENT
  Future<void> clearCart() async {
    final user = _auth.currentUser;

    if (user == null) return;

    final cartSnapshot = await _firestore
        .collection("users")
        .doc(user.uid)
        .collection("cart")
        .get();

    for (final item in cartSnapshot.docs) {
      await item.reference.delete();
    }
  }

  /// PLACE MANUAL PAYMENT ORDER
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
  }

  /// USER ORDERS
  Stream<QuerySnapshot<Map<String, dynamic>>> getOrders() {
    final user = _auth.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection("orders")
        .where("userId", isEqualTo: user.uid)
        .orderBy(
          "createdAt",
          descending: true,
        )
        .snapshots();
  }

  /// ===============================
  /// ADMIN - GET ALL ORDERS
  /// ===============================
  Stream<List<OrderModel>> getAllOrders() {
    return _firestore
        .collection("orders")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => OrderModel.fromMap(doc.data()),
              )
              .toList(),
        );
  }

  /// ===============================
  /// ADMIN - FILTER ORDERS BY STATUS
  /// ===============================
  Stream<List<OrderModel>> getOrdersByOrderStatus(
    String orderStatus,
  ) {
    return _firestore
        .collection("orders")
        .where("orderStatus", isEqualTo: orderStatus)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => OrderModel.fromMap(doc.data()),
              )
              .toList(),
        );
  }

  /// ===============================
  /// ADMIN - GET SINGLE ORDER
  /// ===============================
  Future<OrderModel?> getOrderById(
    String orderId,
  ) async {
    final doc = await _firestore.collection("orders").doc(orderId).get();

    if (!doc.exists) return null;

    return OrderModel.fromMap(doc.data()!);
  }

  /// ===============================
  /// ADMIN - UPDATE ORDER STATUS
  /// ===============================
  Future<void> updateOrderStatus({
    required String orderId,
    required String orderStatus,
  }) async {
    await _firestore.collection("orders").doc(orderId).update({
      "orderStatus": orderStatus,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  /// ===============================
  /// ADMIN - UPDATE PAYMENT STATUS
  /// ===============================
  Future<void> updatePaymentStatus({
    required String orderId,
    required String paymentStatus,
  }) async {
    await _firestore.collection("orders").doc(orderId).update({
      "paymentStatus": paymentStatus,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  /// ===============================
  /// ADMIN - MARK ORDER AS SEEN
  /// ===============================
  Future<void> markAdminSeen(
    String orderId,
  ) async {
    await _firestore.collection("orders").doc(orderId).update({
      "adminSeen": true,
    });
  }

  /// ===============================
  /// CANCEL ORDER
  /// ===============================
 /// CANCEL ORDER
  Future<void> cancelOrder(
    String orderId,
  ) async {
    await _firestore.collection("orders").doc(orderId).update({
      "orderStatus": OrderStatus.cancelled,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }
}