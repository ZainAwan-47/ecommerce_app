import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'otp_verification_screen.dart';
import '../../services/auth_service.dart';
import '../../utils/app_notifier.dart';
import '../main/main_screen.dart';
import '../admin/dashboard/admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool obscurePassword = true;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  
  bool isGoogleLoading = false;
  bool isLoginLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF9F7),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xffFFF9F7),
              Color(0xffF4E8E2),
              Color(0xffEEDFD8),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -60,
              left: -60,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xff7F4F4F).withOpacity(0.04),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    // Logo & Header Section
                    Center(
                      child: Image.asset(
                        "assets/logo/applogo.png",
                        height: 200,
                        width: 200,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.auto_stories_rounded,
                          size: 70,
                          color: Color(0xff7F4F4F),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Welcome Back",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff2D2323),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Sign in to start shopping",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 13.5,
                        color: const Color(0xff8D7B7B),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Email Field
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        color: const Color(0xff2D2323),
                      ),
                      decoration: InputDecoration(
                        hintText: "Email Address",
                        hintStyle: GoogleFonts.manrope(
                          color: const Color(0xff8D7B7B),
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: Color(0xff7F4F4F),
                          size: 20,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.black.withOpacity(0.08),
                            width: 0.8,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xff7F4F4F),
                            width: 1,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.black.withOpacity(0.08),
                            width: 0.8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Password Field
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        color: const Color(0xff2D2323),
                      ),
                      decoration: InputDecoration(
                        hintText: "Password",
                        hintStyle: GoogleFonts.manrope(
                          color: const Color(0xff8D7B7B),
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: Color(0xff7F4F4F),
                          size: 20,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: const Color(0xff8D7B7B),
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.black.withOpacity(0.08),
                            width: 0.8,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xff7F4F4F),
                            width: 1,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.black.withOpacity(0.08),
                            width: 0.8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Forgot Password?",
                          style: GoogleFonts.manrope(
                            color: const Color(0xff7F4F4F),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Sign In Button
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoginLoading
                            ? null
                            : () async {
                                setState(() {
                                  isLoginLoading = true;
                                });
                                try {
                                  final credential = await auth
                                      .signInWithEmailAndPassword(
                                    email: emailController.text.trim(),
                                    password: passwordController.text.trim(),
                                  );
                                  final user = credential.user;
                                  if (user == null) {
                                    throw Exception("Login failed.");
                                  }

                                  final userDocCheck = await FirebaseFirestore
                                      .instance
                                      .collection("users")
                                      .doc(user.uid)
                                      .get();

                                  if (userDocCheck.exists) {
                                    final userData = userDocCheck.data()!;
                                    final bool isActive =
                                        userData["isActive"] ?? true;
                                    if (!isActive) {
                                      await auth.signOut();
                                      if (!mounted) return;
                                      setState(() {
                                        isLoginLoading = false;
                                      });
                                      AppNotifier.error(
                                        context,
                                        "This account has been deactivated.",
                                      );
                                      return;
                                    }
                                  }

                                  final adminDoc = await FirebaseFirestore.instance
                                      .collection("admins")
                                      .doc(user.uid)
                                      .get();

                                  if (adminDoc.exists) {
                                    final adminData = adminDoc.data()!;
                                    final name = adminData["name"] ?? "Admin";
                                    final email = adminData["email"] ?? user.email!;

                                    AppNotifier.alert(
                                      context,
                                      "Sending OTP to mail...",
                                    );

                                    if (!mounted) return;
                                    setState(() {
                                      isLoginLoading = false;
                                    });

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => OtpVerificationScreen(
                                          uid: user.uid,
                                          name: name,
                                          email: email,
                                          isAdmin: true,
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  if (userDocCheck.exists) {
                                    final userData = userDocCheck.data()!;
                                    final name = userData["name"] ?? "Customer";
                                    final email = userData["email"] ?? user.email!;

                                    AppNotifier.success(
                                      context,
                                      "Sending OTP to mail...",
                                    );

                                    if (!mounted) return;
                                    setState(() {
                                      isLoginLoading = false;
                                    });

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => OtpVerificationScreen(
                                          uid: user.uid,
                                          name: name,
                                          email: email,
                                          isAdmin: false,
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  await auth.signOut();
                                  if (!mounted) return;
                                  setState(() {
                                    isLoginLoading = false;
                                  });
                                  AppNotifier.error(
                                    context,
                                    "Account not found.",
                                  );
                                } on FirebaseAuthException catch (e) {
                                  String message;
                                  switch (e.code) {
                                    case "invalid-email":
                                      message = "Please enter a valid email address.";
                                      break;
                                    case "invalid-credential":
                                    case "wrong-password":
                                      message = "Incorrect email or password.";
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
                                      message = "Too many attempts. Try again later.";
                                      break;
                                    case "network-request-failed":
                                      message = "No internet connection.";
                                      break;
                                    default:
                                      message = "Login failed. Please try again.";
                                  }
                                  if (mounted) {
                                    setState(() {
                                      isLoginLoading = false;
                                    });
                                  }
                                  AppNotifier.error(context, message);
                                } catch (e) {
                                  if (mounted) {
                                    setState(() {
                                      isLoginLoading = false;
                                    });
                                  }
                                  AppNotifier.error(
                                    context,
                                    e.toString().replaceAll("Exception: ", ""),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff7F4F4F),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: isLoginLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                "Sign In",
                                style: GoogleFonts.manrope(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Divider
                    Row(
                      children: [
                        const Expanded(child: Divider(height: 1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            "OR",
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xff8D7B7B),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider(height: 1)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Google Sign-In Button
                    SizedBox(
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: isGoogleLoading
                            ? null
                            : () async {
                                setState(() {
                                  isGoogleLoading = true;
                                });
                                try {
                                  final user =
                                      await AuthService.instance.signInWithGoogle();
                                  if (!mounted) return;
                                  if (user != null) {
                                    final adminDoc = await FirebaseFirestore.instance
                                        .collection("admins")
                                        .doc(user.uid)
                                        .get();

                                    if (adminDoc.exists) {
                                      if (!mounted) return;
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const AdminDashboardScreen(),
                                        ),
                                      );
                                      return;
                                    }

                                    final userDoc = await FirebaseFirestore.instance
                                        .collection("users")
                                        .doc(user.uid)
                                        .get();

                                    if (userDoc.exists) {
                                      final userData = userDoc.data()!;
                                      final role = (userData["role"] ?? "customer")
                                          .toString()
                                          .toLowerCase();
                                      if (role == "admin") {
                                        await FirebaseFirestore.instance
                                            .collection("admins")
                                            .doc(user.uid)
                                            .set({
                                          'name': userData['name'] ??
                                              user.displayName ??
                                              'Admin',
                                          'email':
                                              userData['email'] ?? user.email ?? '',
                                          'role': 'admin',
                                          'createdAt': userData['createdAt'] ??
                                              FieldValue.serverTimestamp(),
                                        });
                                        if (!mounted) return;
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const AdminDashboardScreen(),
                                          ),
                                        );
                                        return;
                                      }
                                    }

                                    if (!mounted) return;
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const MainScreen(),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        e.toString().replaceAll("Exception: ", ""),
                                      ),
                                    ),
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      isGoogleLoading = false;
                                    });
                                  }
                                }
                              },
                        icon: isGoogleLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xff7F4F4F),
                                ),
                              )
                            : Image.asset(
                                "assets/icons/google.png",
                                height: 20,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.g_mobiledata_rounded,
                                  size: 24,
                                  color: Color(0xff7F4F4F),
                                ),
                              ),
                        label: Text(
                          "Continue with Google",
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xff2D2323),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.black.withOpacity(0.08),
                            width: 0.8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Guest Button
                    SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MainScreen(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.black.withOpacity(0.08),
                            width: 0.8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          "Continue as Guest",
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xff8D7B7B),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Create Account Button
                   SizedBox(
  width: double.infinity,
  height: 50,
  child: ElevatedButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
        ),
      );
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xffF3ECE9),
      elevation: 0,
      side: BorderSide(
        color: Colors.black.withOpacity(0.12),
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    child: Text(
      "Create New Account",
      style: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: const Color(0xff1B4D3E),
      ),
    ),
  ),
),
                    const SizedBox(height: 20),
                    
                    // Terms & Privacy footer
                    Text(
                      "By continuing, you agree to our\nTerms of Service & Privacy Policy",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        color: const Color(0xff8D7B7B),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),
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