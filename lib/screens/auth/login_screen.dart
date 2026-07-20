import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../main/main_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_notifier.dart';
import '../../services/otp_service.dart';

import 'otp_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool obscurePassword = true;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
bool isGoogleLoading = false;

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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Logo
              Center(
                child: Image.asset(
                  "assets/logo/applogo.png",
                  height: 220,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Welcome Back",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Sign in to continue your beauty journey.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 40),

              // Email
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

              const SizedBox(height: 20),

              // Password
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

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                     Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) =>
        const ForgotPasswordScreen(),
  ),
);
                  },
                  child: const Text("Forgot Password?"),
                ),
              ),

              const SizedBox(height: 20),

              // Sign In Button
              SizedBox(
                height: 55,
                child: ElevatedButton(
           onPressed: () async {
  try {
    final credential =
        await _auth.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    final user = credential.user;

    if (user == null) {
      throw Exception("Login failed.");
    }

    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    final userData = userDoc.data() ?? {};

    final name =
        userData["name"] ?? "Customer";

    final email =
        userData["email"] ?? user.email!;

    final sent =
        await OtpService.createAndSendOtp(
      userName: name,
      email: email,
    );

    if (!mounted) return;

    if (!sent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Failed to send OTP.",
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            OtpVerificationScreen(
          uid: user.uid,
          name: name,
          email: email,
        ),
      ),
    );
  }on FirebaseAuthException catch (e) {
  String message;

  switch (e.code) {
    case "invalid-email":
      message = "Please enter a valid email address.";
      break;

    case "invalid-credential":
      message = "Incorrect email or password.";
      break;

    case "wrong-password":
      message = "Incorrect password.";
      break;

    case "user-not-found":
      message = "No account found with this email.";
      break;

    case "email-already-in-use":
      message = "This email is already registered.";
      break;

    case "user-disabled":
      message = "This account has been disabled.";
      break;

    case "too-many-requests":
      message = "Too many login attempts. Please try again later.";
      break;

    case "network-request-failed":
      message = "No internet connection.";
      break;

    default:
      message = "Login failed. Please try again.";
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
},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff7F4F4F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Sign In",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 35),

              // Divider
              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "OR",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 25),

        SizedBox(
  height: 55,
  child: OutlinedButton.icon(
    onPressed: isGoogleLoading
        ? null
        : () async {
            setState(() {
              isGoogleLoading = true;
            });

            try {
              final user =
                  await AuthService.instance
                      .signInWithGoogle();

              if (!mounted) return;

              if (user != null) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const MainScreen(),
                  ),
                );
              }
            } catch (e) {
              if (!mounted) return;

              ScaffoldMessenger.of(context)
                  .showSnackBar(
                SnackBar(
                  content: Text(
                    e.toString(),
                  ),
                ),
              );
            }

            if (mounted) {
              setState(() {
                isGoogleLoading = false;
              });
            }
          },
    icon: isGoogleLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child:
                CircularProgressIndicator(
              strokeWidth: 2,
            ),
          )
        : Image.asset(
            "assets/icons/google.png",
            height: 22,
          ),
    label: const Text(
      "Continue with Google",
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
    style: OutlinedButton.styleFrom(
      backgroundColor: Colors.white,
      side: const BorderSide(
        color: Color(0xffDDDDDD),
      ),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(15),
      ),
    ),
  ),
),

const SizedBox(height: 25),

SizedBox(
  height: 55,
  child: OutlinedButton(
    onPressed: () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const MainScreen(),
        ),
      );
    },
    style: OutlinedButton.styleFrom(
      side:
          const BorderSide(color: Colors.grey),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(15),
      ),
    ),
    child: const Text(
      "Continue as Guest",
      style: TextStyle(fontSize: 17),
    ),
  ),
),
const SizedBox(height: 25),
              // Create Account Button
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: () { Navigator.push(
                               context,
                              MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                               ),
                             );},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffEEDFD8),
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Create New Account",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 35),

              const Text(
                "By continuing, you agree to\nTerms of Service & Privacy Policy",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}