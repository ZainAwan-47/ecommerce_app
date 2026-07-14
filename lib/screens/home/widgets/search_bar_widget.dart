import 'package:flutter/material.dart';

import '../../search/search_screen.dart';
import 'filter_bottom_sheet.dart';
class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SearchScreen(),
            ),
          );
        },
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.05),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: TextField(
            readOnly: true,
            decoration: InputDecoration(
              hintText: "Search luxury beauty products...",
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Color(0xff7F4F4F),
              ),
             suffixIcon: GestureDetector(
  onTap: () {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      builder: (_) => const FilterBottomSheet(),
    );
  },
  child: Container(
    margin: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: const Color(0xff7F4F4F),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Icon(
      Icons.tune,
      color: Colors.white,
      size: 20,
    ),
  ),
),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
            ),
          ),
        ),
      ),
    );
  }
}