import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_notifier.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool hideCurrent = true;
  bool hideNew = true;
  bool hideConfirm = true;
  bool loading = false;

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final currentPassword = currentPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      AppNotifier.error(context, "Please fill all fields.");
      return;
    }

    if (newPassword.length < 6) {
      AppNotifier.error(context, "Password must be at least 6 characters.");
      return;
    }

    if (newPassword != confirmPassword) {
      AppNotifier.error(context, "Passwords do not match.");
      return;
    }

    if (currentPassword == newPassword) {
      AppNotifier.error(context, "New password must be different.");
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      if (!mounted) return;
      AppNotifier.success(context, "Password changed successfully.");
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case "wrong-password":
        case "invalid-credential":
          message = "Current password is incorrect.";
          break;
        case "weak-password":
          message = "Password must be at least 6 characters.";
          break;
        case "network-request-failed":
          message = "No internet connection.";
          break;
        case "too-many-requests":
          message = "Too many attempts. Try again later.";
          break;
        default:
          message = "Failed to change password.";
      }
      if (!mounted) return;
      AppNotifier.error(context, message);
    } catch (e) {
      if (!mounted) return;
      AppNotifier.error(context, "Something went wrong.");
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
        backgroundColor: const Color(0xffFFF9F7),
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xff2D2323)),
        title: Text(
          "Change Password",
          style: GoogleFonts.manrope(
            color: const Color(0xff2D2323),
            fontSize: 24,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const CircleAvatar(
              radius: 42,
              backgroundColor: Color(0xff7F4F4F),
              child: Icon(
                Icons.lock_outline_rounded,
                size: 42,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              "Change Your Password",
              style: GoogleFonts.manrope(
                fontSize: 26,
                color: const Color(0xff2D2323),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Enter your current password\nand choose a new one.",
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                color: const Color(0xff8D7B7B),
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 35),
            
            // Current Password Field
            TextField(
              controller: currentPasswordController,
              obscureText: hideCurrent,
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: const Color(0xff2D2323),
              ),
              decoration: InputDecoration(
                labelText: "Current Password",
                labelStyle: GoogleFonts.manrope(
                  color: const Color(0xff8D7B7B),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: Color(0xff7F4F4F),
                  size: 20,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    hideCurrent ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xff8D7B7B),
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      hideCurrent = !hideCurrent;
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
            const SizedBox(height: 18),
            
            // New Password Field
            TextField(
              controller: newPasswordController,
              obscureText: hideNew,
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: const Color(0xff2D2323),
              ),
              decoration: InputDecoration(
                labelText: "New Password",
                labelStyle: GoogleFonts.manrope(
                  color: const Color(0xff8D7B7B),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.lock_reset,
                  color: Color(0xff7F4F4F),
                  size: 20,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    hideNew ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xff8D7B7B),
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      hideNew = !hideNew;
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
            const SizedBox(height: 18),
            
            // Confirm Password Field
            TextField(
              controller: confirmPasswordController,
              obscureText: hideConfirm,
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: const Color(0xff2D2323),
              ),
              decoration: InputDecoration(
                labelText: "Confirm Password",
                labelStyle: GoogleFonts.manrope(
                  color: const Color(0xff8D7B7B),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.lock_person_outlined,
                  color: Color(0xff7F4F4F),
                  size: 20,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    hideConfirm ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xff8D7B7B),
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      hideConfirm = !hideConfirm;
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
            const SizedBox(height: 35),
            
            // Change Password Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff7F4F4F),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: loading ? null : _changePassword,
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
                        "Change Password",
                        style: GoogleFonts.manrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}