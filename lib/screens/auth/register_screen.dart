import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../utils/app_notifier.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool _isLoading = false;

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
      AppNotifier.error(context, "Passwords do not match");
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final emailTrimmed = emailController.text.trim().toLowerCase();
      
      final querySnapshot = await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: emailTrimmed)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        final bool isActive = userDoc.data()["isActive"] ?? true;
        if (!isActive) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          AppNotifier.alert(
            context,
            "This account was previously deactivated. Please contact support to reactivate your account.",
          );
          return;
        }
      }

      UserCredential userCredential =
          await auth.createUserWithEmailAndPassword(
        email: emailTrimmed,
        password: passwordController.text.trim(),
      );

      final String? fcmToken = await FirebaseMessaging.instance.getToken();

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

      if (!mounted) return;
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
      if (!mounted) return;
      AppNotifier.error(context, message);
    } catch (e) {
      if (!mounted) return;
      AppNotifier.error(context, "Something went wrong.");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF9F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xffFFF9F7),
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xff2D2323)),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xffFFF9F7),
              Color(0xffF9EFEB),
              Color(0xffF2E3DE),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: -80,
              right: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xff7F4F4F).withOpacity(0.05),
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
                    
                    // Unboxed Logo & Header Section
                    Center(
                      child: Image.asset(
                        "assets/logo/applogo.png",
                        height: 140,
                        width: 140,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.auto_stories_rounded,
                          size: 70,
                          color: Color(0xff7F4F4F),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Create Account",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff2D2323),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Join Shop by Tehreem today",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        color: const Color(0xff8D7B7B),
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Full Name Field
                    TextField(
                      controller: fullNameController,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        color: const Color(0xff2D2323),
                      ),
                      decoration: InputDecoration(
                        hintText: "Full Name",
                        hintStyle: GoogleFonts.manrope(
                          color: const Color(0xff8D7B7B),
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.person_outline_rounded,
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
                    
                    // Email Address Field
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
                    const SizedBox(height: 12),
                    
                    // Confirm Password Field
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: obscureConfirmPassword,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        color: const Color(0xff2D2323),
                      ),
                      decoration: InputDecoration(
                        hintText: "Confirm Password",
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
                            obscureConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: const Color(0xff8D7B7B),
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              obscureConfirmPassword = !obscureConfirmPassword;
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
                    const SizedBox(height: 20),
                    
                    // Register Button
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : registerUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff7F4F4F),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                "Create Account",
                                style: GoogleFonts.manrope(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Sign In Redirect Option
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?",
                          style: GoogleFonts.manrope(
                            color: const Color(0xff8D7B7B),
                            fontSize: 13.5,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Sign In",
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xff7F4F4F),
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      ],
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