import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/product_model.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Add Product to Cart
 Future<bool> addToCart(
  ProductModel product,
  int quantity,
) async {
  final user = _auth.currentUser;

  if (user == null) {
    return false;
  }

  final cartRef = _firestore
      .collection('users')
      .doc(user.uid)
      .collection('cart')
      .doc(product.id);

  final doc = await cartRef.get();

  if (doc.exists) {
    final currentQuantity =
        (doc['quantity'] as num).toInt();

    await cartRef.update({
      'quantity': currentQuantity + quantity,
    });
  } else {
    await cartRef.set({
      'name': product.name,
      'image': product.image,
      'price': product.price,
      'quantity': quantity,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  return true;
}
 /// Get Cart Items
Stream<QuerySnapshot> getCart() {
  final user = _auth.currentUser;

  if (user == null) {
    return const Stream.empty();
  }

  return _firestore
      .collection('users')
      .doc(user.uid)
      .collection('cart')
      .snapshots();
}

  /// Remove Product
  Future<void> removeFromCart(String productId) async {
    final user = _auth.currentUser;

    await _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('cart')
        .doc(productId)
        .delete();
  }

  /// Increase Quantity
  Future<void> increaseQuantity(String productId) async {
    final user = _auth.currentUser;

    final doc = await _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('cart')
        .doc(productId)
        .get();

    final quantity = doc['quantity'];

    await doc.reference.update({
      'quantity': quantity + 1,
    });
  }

  /// Decrease Quantity
  Future<void> decreaseQuantity(String productId) async {
    final user = _auth.currentUser;

    final doc = await _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('cart')
        .doc(productId)
        .get();

    final quantity = doc['quantity'];

    if (quantity > 1) {
      await doc.reference.update({
        'quantity': quantity - 1,
      });
    } else {
      await doc.reference.delete();
    }
  }

  /// Calculate Total Price
  double calculateTotal(List<QueryDocumentSnapshot> items) {
    double total = 0;

    for (var item in items) {
      total +=
          (item['price'] as num).toDouble() *
          (item['quantity'] as num).toDouble();
    }

    return total;
  }
}