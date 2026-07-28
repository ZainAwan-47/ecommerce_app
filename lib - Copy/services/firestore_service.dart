import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  /// All Products
  Stream<List<ProductModel>> getProducts() {
    return _firestore
        .collection('products')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductModel.fromFirestore(
          doc.id,
          doc.data(),
        );
      }).toList();
    });
  }

  /// Products by Category
  Stream<List<ProductModel>> getProductsByCategory(
    String category,
  ) {
    return _firestore
        .collection('products')
        .where(
          'category',
          isEqualTo: category,
        )
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductModel.fromFirestore(
          doc.id,
          doc.data(),
        );
      }).toList();
    });
  }
}