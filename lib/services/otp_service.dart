import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class OtpService {
  static const String serviceId = "service_kdxsvhf";
  static const String templateId = "template_2shxshg";
  static const String publicKey = "argzFHSsrQqo5GuJ1";

  static String generateOtp() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  static Future<bool> sendOtp({
    required String userName,
    required String email,
    required String otp,
  }) async {
    final response = await http.post(
      Uri.parse("https://api.emailjs.com/api/v1.0/email/send"),
      headers: {
        "origin": "http://localhost",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "service_id": serviceId,
        "template_id": templateId,
        "user_id": publicKey,
        "template_params": {
          "user_name": userName,
          "email": email,
          "passcode": otp,
        }
      }),
    );

    return response.statusCode == 200;
  }

  static Future<bool> createAndSendOtp({
    required String userName,
    required String email,
  }) async {
    final otp = generateOtp();

    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection("login_otps")
        .doc(uid)
        .set({
      "otp": otp,
      "email": email,
      "createdAt": FieldValue.serverTimestamp(),
      "expiresAt": Timestamp.fromDate(
        DateTime.now().add(
          const Duration(minutes: 5),
        ),
      ),
    });

    return await sendOtp(
      userName: userName,
      email: email,
      otp: otp,
    );
  }
}