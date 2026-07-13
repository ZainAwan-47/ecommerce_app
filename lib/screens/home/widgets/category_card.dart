import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../categories/category_products_screen.dart';
import '../../../models/category_model.dart';
import '../../../services/category_service.dart';

class CategoryCard extends StatelessWidget {
  CategoryCard({super.key});

  final CategoryService _categoryService = CategoryService();

  IconData _getIcon(String name) {
    switch (name) {
      case "Skin Care":
        return Icons.spa_rounded;

      case "Makeup":
        return Icons.face_retouching_natural_rounded;

      case "Perfume":
        return Icons.local_florist_rounded;

      case "Hair Care":
        return Icons.content_cut_rounded;

      case "Hand Care":
        return Icons.back_hand_rounded;

      default:
        return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 118,
      child: StreamBuilder<List<CategoryModel>>(
        stream: _categoryService.getCategories(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final categories = snapshot.data!;

          return ListView.builder(
            padding:
                const EdgeInsets.symmetric(horizontal: 22),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];

              final selected = index == 0;

              return GestureDetector(
               onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => CategoryProductsScreen(
        category: category.name,
      ),
    ),
  );
},
                child: Container(
                  width: 105,
                  margin:
                      const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xff7F4F4F)
                        : Colors.white,
                    borderRadius:
                        BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(.05),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: selected
                            ? Colors.white24
                            : const Color(
                                0xffF8EEEB,
                              ),
                        child: Icon(
                          _getIcon(category.name),
                          size: 26,
                          color: selected
                              ? Colors.white
                              : const Color(
                                  0xff7F4F4F,
                                ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        category.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight:
                              FontWeight.w600,
                          color: selected
                              ? Colors.white
                              : const Color(
                                  0xff2F2F2F,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}