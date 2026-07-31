import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_notifier.dart';
import '../../services/otp_service.dart';
import '../admin/dashboard/admin_dashboard_screen.dart';
import '../main/main_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String uid;
  final String name;
  final String email;
  final bool isAdmin;

  const OtpVerificationScreen({
    super.key,
    required this.uid,
    required this.name,
    required this.email,
    required this.isAdmin,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;
  bool sendingOtp = true;
  int seconds = 60;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sendOtp();
    });
  }

  void startTimer() {
    setState(() {
      seconds = 60;
    });
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds == 0) {
        timer.cancel();
      } else {
        setState(() {
          seconds--;
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    otpController.dispose();
    super.dispose();
  }

  Future<void> sendOtp() async {
    setState(() {
      sendingOtp = true;
    });
    final success = await OtpService.createAndSendOtp(
      userName: widget.name,
      email: widget.email,
    );
    if (!mounted) return;
    if (success) {
      AppNotifier.success(
        context,
        "OTP sent successfully.",
      );
      startTimer();
    } else {
      AppNotifier.error(
        context,
        "Failed to send OTP.",
      );
    }
    setState(() {
      sendingOtp = false;
    });
  }

  Future<void> verifyOtp() async {
    setState(() {
      isLoading = true;
    });
    try {
      final doc = await FirebaseFirestore.instance
          .collection("login_otps")
          .doc(widget.uid)
          .get();
      if (!doc.exists) {
        throw "Please request a new OTP.";
      }
      final data = doc.data()!;
      final String savedOtp = data["otp"];
      final Timestamp expiresAt = data["expiresAt"];
      if (DateTime.now().isAfter(expiresAt.toDate())) {
        throw "OTP has expired. Please request a new OTP.";
      }
      if (otpController.text.trim() != savedOtp) {
        throw "Invalid OTP.";
      }
      await FirebaseFirestore.instance
          .collection("login_otps")
          .doc(widget.uid)
          .delete();

      if (!mounted) return;
      if (widget.isAdmin) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const AdminDashboardScreen(),
          ),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const MainScreen(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      AppNotifier.error(
        context,
        e.toString().replaceAll("Exception: ", ""),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> resendOtp() async {
    setState(() {
      sendingOtp = true;
    });
    final success = await OtpService.createAndSendOtp(
      userName: widget.name,
      email: widget.email,
    );
    if (!mounted) return;
    if (success) {
      startTimer();
      AppNotifier.success(
        context,
        "OTP sent successfully.",
      );
    } else {
      AppNotifier.error(
        context,
        "Failed to send OTP.",
      );
    }
    setState(() {
      sendingOtp = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: const IconThemeData(color: Color(0xff2D2323)),
        title: Text(
          "Verify OTP",
          style: GoogleFonts.manrope(
            color: const Color(0xff2D2323),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xffFFF9F7),
              Color(0xffF6ECE6),
              Color(0xffEEDFD8),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xff7F4F4F).withOpacity(0.04),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  24,
                  24,
                  24,
                  MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        kToolbarHeight -
                        MediaQuery.of(context).padding.top,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        const Icon(
                          Icons.mark_email_read_rounded,
                          size: 80,
                          color: Color(0xff7F4F4F),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Email Verification",
                          style: GoogleFonts.manrope(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xff2D2323),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "A 6-digit verification code has been sent to\n${widget.email}",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.manrope(
                            color: const Color(0xff8D7B7B),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 36),
                        TextField(
                          controller: otpController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          onChanged: (value) {
                            if (value.length == 6) {
                              FocusScope.of(context).unfocus();
                            }
                          },
                          textAlign: TextAlign.center,
                          style: GoogleFonts.manrope(
                            fontSize: 26,
                            letterSpacing: 8,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xff2D2323),
                          ),
                          decoration: InputDecoration(
                            hintText: "------",
                            counterText: "",
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 16),
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
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isLoading || sendingOtp ? null : verifyOtp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff7F4F4F),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: (isLoading || sendingOtp)
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    "Verify OTP",
                                    style: GoogleFonts.manrope(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: seconds == 0 ? resendOtp : null,
                          child: Text(
                            seconds == 0
                                ? "Resend OTP"
                                : "Resend in ${seconds}s",
                            style: GoogleFonts.manrope(
                              color: seconds == 0
                                  ? const Color(0xff7F4F4F)
                                  : const Color(0xff8D7B7B),
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
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