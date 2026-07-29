import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/app_notification_service.dart';
import '../../utils/app_notifier.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> registerUser() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match"),
        ),
      );
      return;
    }

    try {
      final emailTrimmed = emailController.text.trim().toLowerCase();

      // 1. Check Firestore first for deactivated / soft-deleted accounts
      final querySnapshot = await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: emailTrimmed)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        final bool isActive = userDoc.data()["isActive"] ?? true;

        if (!isActive) {
          AppNotifier.error(
            context,
            "This account was previously deactivated. Please contact support to reactivate your account.",
          );
          return;
        }
      }

      // 2. Proceed with Firebase Auth registration
      UserCredential userCredential =
          await auth.createUserWithEmailAndPassword(
        email: emailTrimmed,
        password: passwordController.text.trim(),
      );

      final String? fcmToken =
          await FirebaseMessaging.instance.getToken();

      // 3. Create active user profile document in Firestore
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userCredential.user!.uid)
          .set({
        "uid": userCredential.user!.uid,
        "name": fullNameController.text.trim(),
        "email": emailTrimmed,
        "role": "customer",
        "isActive": true,
        "fcmToken": fcmToken ?? "",
        "createdAt": FieldValue.serverTimestamp(),
      });

      await AppNotificationService().addWelcomeNotification(
        userId: userCredential.user!.uid,
      );

      AppNotifier.success(
        context,
        "Account created. Please sign in.",
      );
      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case "email-already-in-use":
          message = "An account with this email already exists.";
          break;
        case "invalid-email":
          message = "Please enter a valid email address.";
          break;
        case "weak-password":
          message = "Password must be at least 6 characters.";
          break;
        case "network-request-failed":
          message = "No internet connection.";
          break;
        case "too-many-requests":
          message = "Too many attempts. Please try again later.";
          break;
        default:
          message = "Registration failed. Please try again.";
      }
      AppNotifier.error(
        context,
        message,
      );
    } catch (e) {
      AppNotifier.error(
        context,
        "Something went wrong.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF9F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Image.asset(
                "assets/logo/applogo.png",
                height: 220,
              ),
              const SizedBox(height: 20),
              const Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Join Shop by Tehreem today",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 35),
              TextField(
                controller: fullNameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                  prefixIcon: const Icon(Icons.person_outline),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email Address",
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: confirmPasswordController,
                obscureText: obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureConfirmPassword = !obscureConfirmPassword;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff7F4F4F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account?",
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Sign In",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xff7F4F4F),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                "By creating an account, you agree to\nTerms of Service & Privacy Policy",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}