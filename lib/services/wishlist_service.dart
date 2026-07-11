import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/product_model.dart';

class WishlistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Add to Wishlist
  Future<bool> addToWishlist(ProductModel product) async {
    final user = _auth.currentUser;

    if (user == null) {
      return false;
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('wishlist')
        .doc(product.id)
       .set({
  'name': product.name,
  'image': product.image,
  'price': product.price,
  'oldPrice': product.oldPrice,
  'rating': product.rating,
  'category': product.category,
  'description': product.description,
  'featured': product.featured,
  'discount': product.discount,
  'inStock': product.inStock,
  'addedAt': FieldValue.serverTimestamp(),
});

    return true;
  }

  /// Remove from Wishlist
  Future<void> removeFromWishlist(String productId) async {
    final user = _auth.currentUser;

    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('wishlist')
        .doc(productId)
        .delete();
  }

  /// Check if Product is Wishlisted
  Stream<bool> isWishlisted(String productId) {
    final user = _auth.currentUser;

    if (user == null) {
      return Stream.value(false);
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('wishlist')
        .doc(productId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  /// Toggle Wishlist
  Future<bool> toggleWishlist(ProductModel product) async {
    final user = _auth.currentUser;

    if (user == null) {
      return false;
    }

    final ref = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('wishlist')
        .doc(product.id);

    final doc = await ref.get();

    if (doc.exists) {
      await ref.delete();
    } else {
     await ref.set({
  'name': product.name,
  'image': product.image,
  'price': product.price,
  'oldPrice': product.oldPrice,
  'rating': product.rating,
  'category': product.category,
  'description': product.description,
  'featured': product.featured,
  'discount': product.discount,
  'inStock': product.inStock,
  'addedAt': FieldValue.serverTimestamp(),
});
    }

    return true;
  }

  /// Wishlist Stream
  Stream<QuerySnapshot> getWishlist() {
    final user = _auth.currentUser;

    return _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('wishlist')
        .orderBy('addedAt', descending: true)
        .snapshots();
  }
}