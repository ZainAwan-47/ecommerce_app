import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/app_notifier.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends State<ChangePasswordScreen> {
  final currentPasswordController =
      TextEditingController();

  final newPasswordController =
      TextEditingController();

  final confirmPasswordController =
      TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF9F7),

      appBar: AppBar(
        backgroundColor: const Color(0xffFFF9F7),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Change Password",
          style: GoogleFonts.dmSerifDisplay(
            color: Colors.black,
            fontSize: 30,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [

            const SizedBox(height: 10),

            CircleAvatar(
              radius: 42,
              backgroundColor:
                  const Color(0xff7F4F4F),
              child: const Icon(
                Icons.lock_outline_rounded,
                size: 42,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 22),

            Text(
              "Change Your Password",
              style:
                  GoogleFonts.dmSerifDisplay(
                fontSize: 28,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Enter your current password\nand choose a new one.",
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 35),

            TextField(
              controller:
                  currentPasswordController,
              obscureText: hideCurrent,
              decoration: InputDecoration(
                labelText: "Current Password",
                prefixIcon: const Icon(
                  Icons.lock_outline,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    hideCurrent
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      hideCurrent =
                          !hideCurrent;
                    });
                  },
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            TextField(
              controller:
                  newPasswordController,
              obscureText: hideNew,
              decoration: InputDecoration(
                labelText: "New Password",
                prefixIcon: const Icon(
                  Icons.lock_reset,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    hideNew
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      hideNew = !hideNew;
                    });
                  },
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            TextField(
              controller:
                  confirmPasswordController,
              obscureText: hideConfirm,
              decoration: InputDecoration(
                labelText:
                    "Confirm Password",
                prefixIcon: const Icon(
                  Icons.lock_person_outlined,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    hideConfirm
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      hideConfirm =
                          !hideConfirm;
                    });
                  },
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 35),
            SizedBox(
  width: double.infinity,
  height: 56,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xff7F4F4F),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    ),
    onPressed: loading
        ? null
        : () async {
            final currentPassword =
                currentPasswordController.text.trim();

            final newPassword =
                newPasswordController.text.trim();

            final confirmPassword =
                confirmPasswordController.text.trim();

            if (currentPassword.isEmpty ||
                newPassword.isEmpty ||
                confirmPassword.isEmpty) {
              AppNotifier.error(
                context,
                "Please fill all fields.",
              );
              return;
            }

            if (newPassword.length < 6) {
              AppNotifier.error(
                context,
                "Password must be at least 6 characters.",
              );
              return;
            }

            if (newPassword != confirmPassword) {
              AppNotifier.error(
                context,
                "Passwords do not match.",
              );
              return;
            }

            if (currentPassword == newPassword) {
              AppNotifier.error(
                context,
                "New password must be different.",
              );
              return;
            }

            setState(() {
              loading = true;
            });

            try {
              final user =
                  FirebaseAuth.instance.currentUser!;

              final credential =
                  EmailAuthProvider.credential(
                email: user.email!,
                password: currentPassword,
              );

              await user.reauthenticateWithCredential(
                credential,
              );

              await user.updatePassword(
                newPassword,
              );

              if (!mounted) return;

              AppNotifier.success(
                context,
                "Password changed successfully.",
              );

              Navigator.pop(context);
            } on FirebaseAuthException catch (e) {
              String message;

              switch (e.code) {
                case "wrong-password":
                case "invalid-credential":
                  message =
                      "Current password is incorrect.";
                  break;

                case "weak-password":
                  message =
                      "Password must be at least 6 characters.";
                  break;

                case "network-request-failed":
                  message =
                      "No internet connection.";
                  break;

                case "too-many-requests":
                  message =
                      "Too many attempts. Try again later.";
                  break;

                default:
                  message =
                      "Failed to change password.";
              }

              AppNotifier.error(
                context,
                message,
              );
            } finally {
              if (mounted) {
                setState(() {
                  loading = false;
                });
              }
            }
          },
    child: loading
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.8,
              color: Colors.white,
            ),
          )
        : Text(
            "Change Password",
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.bold,
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