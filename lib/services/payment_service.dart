import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constants/order_constants.dart';
import '../models/order_model.dart';

class PaymentService {
  PaymentService._();

  static final PaymentService instance = PaymentService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Cached reference to the 'orders' collection
  late final CollectionReference<Map<String, dynamic>> _ordersRef =
      _firestore.collection("orders");

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

    // 5. Defensive validation check
    if (products.isEmpty) {
      throw Exception("Cannot place an order with an empty product list.");
    }

    // Instantiate model using standardized constants
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
      
      // 1 & 2. Fixed order status and string hardcoding bug
      paymentStatus: PaymentStatus.pending,
      orderStatus: OrderStatus.pending,
      adminSeen: false,
      
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );

    // 3. Override local clock timestamps with Firestore server timestamps
    final orderData = order.toMap();
    orderData['createdAt'] = FieldValue.serverTimestamp();
    orderData['updatedAt'] = FieldValue.serverTimestamp();

    // 4. Clean document set via cached collection reference
    await _ordersRef.doc(orderId).set(orderData);
  }
}