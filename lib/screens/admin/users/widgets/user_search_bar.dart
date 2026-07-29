import 'package:flutter/material.dart';

class UserSearchBar extends StatelessWidget {
  const UserSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Maintained original padding to keep your layout intact
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          return TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            onChanged: onChanged,
            // Premium typography for user input
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF111827),
              letterSpacing: -0.2,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF9FAFB), // Subtle premium gray background
              hintText: "Search users...",
              hintStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Color(0xFF9CA3AF),
              ),
              // Adjusted icon padding to feel more integrated and spacious
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 16, right: 12),
                child: Icon(
                  Icons.search_rounded,
                  color: Color(0xFF9CA3AF),
                  size: 22,
                ),
              ),
              suffixIcon: value.text.isEmpty
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: IconButton(
                        icon: const Icon(
                          Icons.close_rounded, // Rounded icons look more modern
                          color: Color(0xFF9CA3AF),
                          size: 20,
                        ),
                        // Stripping away default Android ripple effects for a cleaner iOS-like feel
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onPressed: () {
                          controller.clear();
                          onChanged("");
                        },
                      ),
                    ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              // Unfocused standard state
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
              // Focused active state (sharp monochrome contrast)
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFF111827), // Deep black border on focus
                  width: 1.5,
                ),
              ),
              // Fallback border
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}