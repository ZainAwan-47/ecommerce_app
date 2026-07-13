import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Stream<List<CategoryModel>> getCategories() {
    return _firestore
        .collection('categories')
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
}