import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/order_model.dart';

class PaymentService {
  PaymentService._();

  static final PaymentService instance =
      PaymentService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  Future<void> submitPayment({
    required String orderId,
    required String userName,
    required String email,
    required String phone,
    required String address,

    required List<Map<String, dynamic>> products,

    required double subtotal,
    required double delivery,
    required double total,

    required String paymentMethod,
    required String receiptUrl,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in.");
    }

  final order = OrderModel(
  orderId: orderId,
  userId: user.uid,
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

  // New payment system
 paymentStatus: "Pending Verification",

orderStatus: "Pending Verification",
  adminSeen: false,

  createdAt: Timestamp.now(),
  updatedAt: Timestamp.now(),
);

    await _firestore
        .collection("orders")
        .doc(orderId)
        .set(order.toMap());
  }
}