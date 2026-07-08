import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash/splash_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Firebase Initialization
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("✅ Firebase Initialized Successfully");

    // Firestore Write Test
    await FirebaseFirestore.instance
        .collection("test")
        .doc("connection")
        .set({
      "message": "Firebase & Firestore Connected",
      "time": Timestamp.now(),
    });

    debugPrint("✅ Firestore Write Successful");

    // Firestore Read Test
    final doc = await FirebaseFirestore.instance
        .collection("test")
        .doc("connection")
        .get();

    debugPrint("✅ Firestore Read Successful");
    debugPrint("📄 Firestore Data: ${doc.data()}");

    // Firebase Storage Test
    final storage = FirebaseStorage.instance;

    debugPrint("✅ Firebase Storage Connected");
    debugPrint("📂 Storage Bucket: ${storage.bucket}");
  } catch (e) {
    debugPrint("❌ ERROR OCCURRED");
    debugPrint(e.toString());
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
        home: const SplashScreen(),
    );
  }
}