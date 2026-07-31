import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class FirestoreService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// All Products[cite: 6]
  Stream<List<ProductModel>> getProducts() {
    return firestore
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

  /// Products by Category[cite: 6]
  Stream<List<ProductModel>> getProductsByCategory(
    String category,
  ) {
    return firestore
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

  /// Unique Categories Stream (Normalized & Case-Insensitive)
  Stream<List<String>> getCategories() {
    return firestore
        .collection('products')
        .snapshots()
        .map((snapshot) {
      final Map<String, String> uniqueCategoriesMap = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        // Fallback check if 'category' exists
        final rawCategory = data['category'] as String?;
        if (rawCategory != null && rawCategory.trim().isNotEmpty) {
          final trimmed = rawCategory.trim();
          // Use lowercase as key to prevent duplicates like "Fiction" and "fiction"
          final lowerKey = trimmed.toLowerCase();
          
          if (!uniqueCategoriesMap.containsKey(lowerKey)) {
            uniqueCategoriesMap[lowerKey] = trimmed;
          }
        }
      }

      final categories = uniqueCategoriesMap.values.toList();
      categories.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      return categories;
    });
  }
}