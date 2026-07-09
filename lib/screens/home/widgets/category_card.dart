import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {"icon": Icons.face_retouching_natural, "name": "Skincare"},
      {"icon": Icons.brush, "name": "Makeup"},
      {"icon": Icons.spa, "name": "Perfume"},
      {"icon": Icons.content_cut, "name": "Hair"},
      {"icon": Icons.favorite_border, "name": "Care"},
    ];

    return SizedBox(
      height: 110,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final item = categories[index];

          final selected = index == 0;

          return Container(
            width: 90,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xff7F4F4F)
                  : Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.05),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                CircleAvatar(
                  radius: 24,
                  backgroundColor: selected
                      ? Colors.white24
                      : const Color(0xffF7ECE8),
                  child: Icon(
                    item["icon"] as IconData,
                    color: selected
                        ? Colors.white
                        : const Color(0xff7F4F4F),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  item["name"] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color:
                        selected ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}