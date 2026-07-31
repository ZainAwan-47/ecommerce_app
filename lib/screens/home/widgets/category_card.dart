import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../categories/category_products_screen.dart';
import '../../../models/category_model.dart';
import '../../../services/category_service.dart';
import '../../../utils/category_icons.dart';

class CategoryCard extends StatelessWidget {
  CategoryCard({super.key});

  final CategoryService _categoryService = CategoryService();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 115,
      child: StreamBuilder<List<CategoryModel>>(
        stream: _categoryService.getCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xff7F4F4F),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const SizedBox.shrink();
          }

          final categories = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryProductsScreen(
                        category: category.name,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 86,
                  margin: const EdgeInsets.only(right: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xff7F4F4F).withOpacity(0.12),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff7F4F4F).withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xff7F4F4F).withOpacity(0.08),
                                const Color(0xff7F4F4F).withOpacity(0.18),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Builder(
                              builder: (_) {
                                if (category.imageType == "icon") {
                                  return Icon(
                                    CategoryIcons.getIcon(category.image),
                                    size: 21,
                                    color: const Color(0xff7F4F4F),
                                  );
                                }
                                return ClipOval(
                                  child: Image.network(
                                    category.image,
                                    width: 44,
                                    height: 44,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.category_outlined,
                                      size: 20,
                                      color: Color(0xff7F4F4F),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          category.name,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w700,
                            fontSize: 11.5,
                            letterSpacing: -0.3,
                            color: const Color(0xff2D2323),
                          ),
                        ),
                      ],
                    ),
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