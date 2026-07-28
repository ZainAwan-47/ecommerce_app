import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotificationService {
  Future<void> addWelcomeNotification({
    required String userId,
  }) async {
    await FirebaseFirestore.instance
        .collection("notifications")
        .add({
      "userId": userId,
      "title": "Welcome to Shop by Tehreem",
      "body":
          "Thank you for joining us. Discover premium beauty products curated just for you.",
      "type": "welcome",
      "isRead": false,
      "createdAt": Timestamp.now(),
    });
  }
}