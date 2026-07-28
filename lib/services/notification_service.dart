import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  /// Initialize FCM and Local Notifications
  Future<void> initialize() async {
    // 1. Request Push Notification Permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint("Notification Permission: ${settings.authorizationStatus}");

    // 2. Setup Local Notifications Channel for Foreground Messages
    await _initializeLocalNotifications();

    // 3. Save initial FCM Token for current user
    await saveToken();

    // 4. Refresh FCM Token listener
    _messaging.onTokenRefresh.listen((token) async {
      await _updateToken(token);
    });

    // 5. Handle Foreground Messages (App running in foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final notification = message.notification;
      if (notification == null) return;

      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'shop_notifications',
            'Shop Notifications',
            channelDescription: 'Notifications for order updates and store news',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    });

    // 6. Handle Background Notification Click
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("Notification Clicked with payload: ${message.data}");
      // Optional: Add navigation logic here if routing to order details screen
    });
  }

  /// Setup Android Notification Channel
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint("Local notification clicked: ${details.payload}");
      },
    );

    // Create Notification Channel for Android 8.0+
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'shop_notifications',
      'Shop Notifications',
      description: 'Notifications for order updates and store news',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Save FCM Token to user document in Firestore
  Future<void> saveToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final token = await _messaging.getToken();
    if (token == null) return;

    await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
      "fcmToken": token,
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    debugPrint("FCM Token Saved: $token");
  }

  /// Update Token when refreshed
  Future<void> _updateToken(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection("users").doc(user.uid).update({
      "fcmToken": token,
      "updatedAt": FieldValue.serverTimestamp(),
    });

    debugPrint("FCM Token Updated");
  }

  /// Send/Log In-App Notification directly to customer's Firestore document
  /// (Call this from Admin side when status changes or payment is rejected)
  static Future<void> sendOrderNotification({
    required String userId,
    required String orderId,
    required String title,
    required String body,
    String type = 'order_update',
  }) async {
    try {
      if (userId.isEmpty) return;

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("notifications")
          .add({
        "title": title,
        "body": body,
        "orderId": orderId,
        "type": type,
        "isRead": false,
        "createdAt": FieldValue.serverTimestamp(),
      });

      debugPrint("In-App Notification logged for user: $userId");
    } catch (e) {
      debugPrint("Error sending in-app notification: $e");
    }
  }
}