import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class AppNotifier {
  static void cart(BuildContext context, String message) {
    _show(
      context,
      message,
 const Color(0xff2E7D32),
    );
  }

  static void wishlist(BuildContext context, String message) {
    _show(
      context,
      message,
      const Color(0xffD98A9D),
    );
  }

  static void remove(BuildContext context, String message) {
    _show(
      context,
      message,
      Colors.grey.shade700,
    );
  }
static void success(BuildContext context, String message) {
  _show(
    context,
    message,
    const Color(0xff2E7D32),
  );
}
static void error(BuildContext context, String message) {
  _show(
    context,
    message,
    const Color(0xffD32F2F), // Material Red 700
  );
}
  static void _show(
    BuildContext context,
    String message,
    Color color,
  ) {
    showTopSnackBar(
      Overlay.of(context),
      Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Center(
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
                 decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
      ),
      displayDuration: const Duration(
        milliseconds: 1000,
      ),
    );
  }
}