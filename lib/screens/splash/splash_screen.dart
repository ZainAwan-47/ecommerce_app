import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/login_screen.dart';
import '../main/main_screen.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

@override
void initState() {
  super.initState();
  _checkAppState();
}

Future<void> _checkAppState() async {
  await Future.delayed(
    const Duration(seconds: 3),
  );

  final prefs =
      await SharedPreferences.getInstance();

  final seenOnboarding =
      prefs.getBool('onboardingCompleted') ??
          false;

  final user =
      FirebaseAuth.instance.currentUser;

  if (!mounted) return;

  if (!seenOnboarding) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const OnboardingScreen(),
      ),
    );
    return;
  }

  if (user != null) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
    builder: (_) => const MainScreen(),
    ),
  );
}
  else {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xffFFF9F7),
              Color(0xffFCF4F2),
              Color(0xffF6ECE9),
            ],
          ),
        ),

        child: Stack(
          children: [

            /// Top Left Circle
            Positioned(
              top: -120,
              left: -120,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.pink.withOpacity(.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            /// Bottom Right Circle
            Positioned(
              bottom: -150,
              right: -150,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  color: Colors.pink.withOpacity(.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    /// Logo
                    Image.asset(
                      "assets/logo/applogo.png",
                      width: 220,
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      "Shop by Tehreem",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff7F4F4F),
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      "Luxury Beauty, Delivered to Your Door",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 60),

                    const SizedBox(
                      width: 35,
                      height: 35,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Color(0xff7F4F4F),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      "Enhancing your ritual",
                      style: TextStyle(
                        color: Colors.black45,
                        letterSpacing: 2,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}