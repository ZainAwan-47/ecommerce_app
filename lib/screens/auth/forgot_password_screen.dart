import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_notifier.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> resetPassword() async {
    if (emailController.text.trim().isEmpty) {
      AppNotifier.error(
        context,
        "Please enter your email address.",
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );

      if (!mounted) return;
      AppNotifier.success(
        context,
        "Password reset email sent.",
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case "invalid-email":
          message = "Please enter a valid email address.";
          break;
        case "user-not-found":
          message = "No account found with this email.";
          break;
        case "network-request-failed":
          message = "No internet connection.";
          break;
        case "too-many-requests":
          message = "Too many requests. Please try again later.";
          break;
        default:
          message = "Failed to send reset email.";
      }
      if (mounted) {
        AppNotifier.error(context, message);
      }
    } catch (e) {
      if (mounted) {
        AppNotifier.error(context, "An unexpected error occurred.");
      }
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
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
            /// Subtle Bottom-Right Ambient Glow Accent
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      "Forgot Password",
                      style: GoogleFonts.manrope(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff2D2323),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Enter your email address and we'll send you a password reset link.",
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        color: const Color(0xff8D7B7B),
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 36),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        color: const Color(0xff2D2323),
                      ),
                      decoration: InputDecoration(
                        labelText: "Email Address",
                        labelStyle: GoogleFonts.manrope(
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
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: loading ? null : resetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff7F4F4F),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                "Send Reset Link",
                                style: GoogleFonts.manrope(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
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