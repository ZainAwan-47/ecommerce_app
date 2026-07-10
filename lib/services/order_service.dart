import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

      final price = (data['price'] as num).toDouble();
      final quantity = (data['quantity'] as num).toInt();

      print("========");
      print("Product: ${data['name']}");
      print("Price: $price");
      print("Quantity: $quantity");
      print("Subtotal: ${price * quantity}");

      total += price * quantity;

      products.add({
        'productId': cartItem.id,
        'name': data['name'],
        'image': data['image'],
        'price': price,
        'quantity': quantity,
      });
    }

    print("FINAL TOTAL = $total");

    final orderDoc = await _firestore.collection('orders').add({
      'userId': user.uid,
      'address': address,
      'phone': phone,
      'paymentMethod': 'Cash on Delivery',
      'status': 'Pending',
      'total': total,
      'products': products,
      'createdAt': FieldValue.serverTimestamp(),
    });

    print("ORDER CREATED: ${orderDoc.id}");

    for (var cartItem in cartSnapshot.docs) {
      await cartItem.reference.delete();
    }
  }
}