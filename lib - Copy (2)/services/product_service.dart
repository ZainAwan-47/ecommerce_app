import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  /// ===============================
  /// GET ALL PRODUCTS
  /// ===============================
  Stream<List<ProductModel>> getProducts() {
    return _firestore
        .collection("products")
        .orderBy("name")
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ProductModel.fromFirestore(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }
Future<String> generateProductId() async {
  return _firestore
      .collection("products")
      .doc()
      .id;
}
  /// ===============================
  /// GET FEATURED PRODUCTS
  /// ===============================
  Stream<List<ProductModel>> getFeaturedProducts() {
    return _firestore
        .collection("products")
        .where("featured", isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ProductModel.fromFirestore(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  /// ===============================
  /// GET PRODUCTS BY CATEGORY
  /// ===============================
  Stream<List<ProductModel>> getProductsByCategory(
    String category,
  ) {
    return _firestore
        .collection("products")
        .where("category", isEqualTo: category)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ProductModel.fromFirestore(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  /// ===============================
  /// GET SINGLE PRODUCT
  /// ===============================
  Future<ProductModel?> getProduct(
    String productId,
  ) async {
    final doc = await _firestore
        .collection("products")
        .doc(productId)
        .get();

    if (!doc.exists) return null;

    return ProductModel.fromFirestore(
      doc.id,
      doc.data()!,
    );
  }

  /// ===============================
  /// ADD PRODUCT
  /// ===============================
  Future<void> addProduct(
    ProductModel product,
  ) async {
    await _firestore
        .collection("products")
        .doc(product.id)
        .set(product.toMap());
  }

  /// ===============================
  /// UPDATE PRODUCT
  /// ===============================
  Future<void> updateProduct(
    ProductModel product,
  ) async {
    await _firestore
        .collection("products")
        .doc(product.id)
        .update(product.toMap());
  }

  /// ===============================
  /// DELETE PRODUCT
  /// ===============================
  Future<void> deleteProduct(
    String productId,
  ) async {
    await _firestore
        .collection("products")
        .doc(productId)
        .delete();
  }
}