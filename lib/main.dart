import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'firebase_options.dart';
import 'screens/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Firebase Initialization
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("✅ Firebase Initialized Successfully");

    // Firestore Test
    await FirebaseFirestore.instance
        .collection("test")
        .doc("connection")
        .set({
      "message": "Firebase & Firestore Connected",
      "time": Timestamp.now(),
    });

    final doc = await FirebaseFirestore.instance
        .collection("test")
        .doc("connection")
        .get();

    debugPrint("✅ Firestore Connected");
    debugPrint("📄 ${doc.data()}");

    // Firebase Storage Test
    final storage = FirebaseStorage.instance;
    debugPrint("✅ Storage Connected");
    debugPrint("📂 Bucket: ${storage.bucket}");
  } catch (e) {
    debugPrint("❌ Firebase Error");
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