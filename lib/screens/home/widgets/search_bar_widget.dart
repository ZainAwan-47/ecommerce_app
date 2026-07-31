import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../search/search_screen.dart';
import 'filter_bottom_sheet.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.black.withOpacity(0.12),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff7F4F4F).withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            /// SEARCH BAR
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SearchScreen(),
                    ),
                  );
                },
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    const Icon(
                      Icons.search_rounded,
                      color: Color(0xff7F4F4F),
                      size: 21,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Search Products",
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          color: const Color(0xff8D7B7B),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            /// FILTER BUTTON
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Material(
                color: const Color(0xff7F4F4F),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      builder: (_) => const FilterBottomSheet(),
                    );
                  },
                  child: const SizedBox(
                    width: 38,
                    height: 38,
                    child: Icon(
                      Icons.tune_rounded,
                      color: Colors.white,
                      size: 18,
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