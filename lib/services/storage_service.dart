import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  StorageService._();

  static final StorageService instance =
      StorageService._();

  final FirebaseStorage _storage =
      FirebaseStorage.instance;

  final Uuid _uuid = const Uuid();

  Future<List<String>> uploadProductImages({
    required List<File> images,
  }) async {
    List<String> imageUrls = [];

    for (final image in images) {
      final imageId = _uuid.v4();

      final ref = _storage
          .ref()
          .child("products")
          .child("$imageId.jpg");

      await ref.putFile(image);

      final url = await ref.getDownloadURL();

      imageUrls.add(url);
    }

    return imageUrls;
  }

  Future<String> uploadCategoryImage({
    required File image,
  }) async {
    final imageId = _uuid.v4();

    final ref = _storage
        .ref()
        .child("categories")
        .child("$imageId.jpg");

    await ref.putFile(image);

    return await ref.getDownloadURL();
  }

  Future<void> deleteImage(
    String imageUrl,
  ) async {
    await _storage.refFromURL(imageUrl).delete();
  }
}