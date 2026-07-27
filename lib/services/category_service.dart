import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Stream<List<CategoryModel>> getCategories() {
    return _firestore
      .collection('categories')
.orderBy('name')
.snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CategoryModel.fromFirestore(
          doc.id,
          doc.data(),
        );
      }).toList();
    });
  }
  Future<String> generateCategoryId() async {
  return _firestore
      .collection("categories")
      .doc()
      .id;
}

/// ===============================
/// ADD CATEGORY
/// ===============================
Future<void> addCategory(
  CategoryModel category,
) async {
  await _firestore
      .collection("categories")
      .doc(category.id)
      .set(category.toMap());
}

/// ===============================
/// UPDATE CATEGORY
/// ===============================
Future<void> updateCategory(
  CategoryModel category,
) async {
  await _firestore
      .collection("categories")
      .doc(category.id)
      .update(category.toMap());
}

/// ===============================
/// DELETE CATEGORY
/// ===============================
Future<void> deleteCategory(
  String categoryId,
) async {
  await _firestore
      .collection("categories")
      .doc(categoryId)
      .delete();
}

/// ===============================
/// CHECK DUPLICATE CATEGORY
/// ===============================
Future<bool> categoryExists(
  String name,
) async {
  final snapshot = await _firestore
      .collection("categories")
      .get();

  final normalized = name.trim().toLowerCase();

  return snapshot.docs.any(
    (doc) =>
        (doc["name"] as String)
            .trim()
            .toLowerCase() ==
        normalized,
  );
}
}