import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
class NotificationService {
  final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;
final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();
    Future<void> _initializeLocalNotifications() async {
  const AndroidInitializationSettings android =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings settings =
      InitializationSettings(
    android: android,
  );

  await _localNotifications.initialize(settings);
}
  Future<void> initialize() async {
    NotificationSettings settings =
        await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  await _initializeLocalNotifications();
    debugPrint(
      "Notification Permission: ${settings.authorizationStatus}",
    );

    await _saveToken();

    FirebaseMessaging.instance.onTokenRefresh.listen(
      (token) async {
        await _updateToken(token);
      },
    );

   FirebaseMessaging.onMessage.listen(
  (RemoteMessage message) async {
    if (message.notification == null) return;

    await _localNotifications.show(
      0,
      message.notification!.title,
      message.notification!.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'shop_notifications',
          'Shop Notifications',
          channelDescription:
              'Notifications for Shop by Tehreem',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  },
);

    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        debugPrint("Notification Clicked");
      },
    );
  }

  Future<void> _saveToken() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final token = await _messaging.getToken();

    if (token == null) return;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .set({
      "fcmToken": token,
    }, SetOptions(merge: true));

    debugPrint("FCM Token Saved");
  }

  Future<void> _updateToken(String token) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .update({
      "fcmToken": token,
    });

    debugPrint("FCM Token Updated");
  }
}