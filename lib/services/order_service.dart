import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/product_model.dart';

class OrderService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  /// CART ORDER
  Future<void> placeOrder({
    required String address,
    required String phone,
  }) async {
    final user = _auth.currentUser;

    if (user == null) return;

    final cartSnapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .get();

    if (cartSnapshot.docs.isEmpty) {
      return;
    }

    double total = 0;

    List<Map<String, dynamic>> products = [];

    for (var cartItem in cartSnapshot.docs) {
      final data = cartItem.data();

      final price =
          (data['price'] as num).toDouble();

      final quantity =
          (data['quantity'] as num).toInt();

      total += price * quantity;

      products.add({
        'productId': cartItem.id,
        'name': data['name'],
        'image': data['image'],
        'price': price,
        'quantity': quantity,
      });
    }

    await _firestore.collection('orders').add({
      'userId': user.uid,
      'address': address,
      'phone': phone,
      'paymentMethod': 'Cash on Delivery',
      'status': 'Pending',
      'total': total,
      'products': products,
      'createdAt': FieldValue.serverTimestamp(),
    });

    for (var cartItem in cartSnapshot.docs) {
      await cartItem.reference.delete();
    }
  }

  /// BUY NOW ORDER
  Future<void> placeBuyNowOrder({
    required ProductModel product,
    required String address,
    required String phone,
  }) async {
    final user = _auth.currentUser;

    if (user == null) return;

    await _firestore.collection('orders').add({
      'userId': user.uid,
      'address': address,
      'phone': phone,
      'paymentMethod': 'Cash on Delivery',
      'status': 'Pending',
      'total': product.price,
      'products': [
        {
          'productId': product.id,
          'name': product.name,
          'image': product.image,
          'price': product.price,
          'quantity': 1,
        }
      ],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
  /// GET USER ORDERS (Newest First)
Stream<QuerySnapshot> getOrders() {
  final user = _auth.currentUser;

  return _firestore
      .collection('orders')
      .where('userId', isEqualTo: user!.uid)
      .orderBy('createdAt', descending: true)
      .snapshots();
}
}