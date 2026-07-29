import 'package:flutter/material.dart';

class EmptyUsersWidget extends StatelessWidget {
  const EmptyUsersWidget({
    super.key,
    this.message = "No users found",
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // PREMIUM SUBTLE ICON CONTAINER
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
              ),
              child: const Icon(
                Icons.people_outline_rounded,
                size: 36,
                color: Color(0xFF9CA3AF),
              ),
            ),

            const SizedBox(height: 20),

            // MAIN MESSAGE
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
                letterSpacing: -0.3,
              ),
            ),

            const SizedBox(height: 6),

            // SUBTITLE / HELPER TEXT
            const Text(
              "Try changing your search query or filter options.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}