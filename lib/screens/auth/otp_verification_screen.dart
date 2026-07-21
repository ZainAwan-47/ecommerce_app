import 'dart:async';
import '../../utils/app_notifier.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../main/main_screen.dart';
import '../../services/otp_service.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String uid;
  final String name;
  final String email;

  const OtpVerificationScreen({
    super.key,
    required this.uid,
    required this.name,
    required this.email,
  });

  @override
  State<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState
    extends State<OtpVerificationScreen> {
  final TextEditingController otpController =
      TextEditingController();

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
    seconds = 60;

    timer?.cancel();

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (seconds == 0) {
          timer.cancel();
        } else {
          setState(() {
            seconds--;
          });
        }
      },
    );
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

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const MainScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

     AppNotifier.error(
  context,
  e.toString(),
);
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> resendOtp() async {
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
  }
    @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF9F7),

      appBar: AppBar(
        backgroundColor: const Color(0xffFFF9F7),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Verify OTP",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

   body: SafeArea(
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
        minHeight:
            MediaQuery.of(context).size.height -
            kToolbarHeight -
            MediaQuery.of(context).padding.top,
      ),
      child: IntrinsicHeight(
        child: Column(
          children: [

            const SizedBox(height: 30),

            const Icon(
              Icons.mark_email_read_rounded,
              size: 90,
              color: Color(0xff7F4F4F),
            ),

            const SizedBox(height: 25),

            const Text(
              "Email Verification",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "A 6-digit verification code has been sent to\n${widget.email}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 40),

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
              style: const TextStyle(
                fontSize: 28,
                letterSpacing: 10,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: "------",
                counterText: "",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
              onPressed:
    isLoading || sendingOtp
        ? null
        : verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xff7F4F4F),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                ),
             child: (isLoading || sendingOtp)
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        "Verify OTP",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            TextButton(
              onPressed:
                  seconds == 0 ? resendOtp : null,
              child: Text(
                seconds == 0
                    ? "Resend OTP"
                    : "Resend in ${seconds}s",
              ),
            ),
                  ],
        ),
      ),
    ),
  ),
),
    );
  }
}