import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ReceiptService {
  ReceiptService._();

  static final ReceiptService instance =
      ReceiptService._();

  final ImagePicker _picker = ImagePicker();

  /// Pick from Gallery
  Future<File?> pickFromGallery() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) return null;

    return File(image.path);
  }

  /// Pick from Camera
  Future<File?> pickFromCamera() async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (image == null) return null;

    return File(image.path);
  }

  /// Upload Receipt
  Future<String> uploadReceipt({
    required File receipt,
    required String orderId,
  }) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child("payment_receipts")
        .child("$orderId.jpg");

    final task = await ref.putFile(receipt);

    return await task.ref.getDownloadURL();
  }

  /// Delete Receipt
  Future<void> deleteReceipt(
    String downloadUrl,
  ) async {
    if (downloadUrl.isEmpty) return;

    try {
      await FirebaseStorage.instance
          .refFromURL(downloadUrl)
          .delete();
    } catch (_) {}
  }
}