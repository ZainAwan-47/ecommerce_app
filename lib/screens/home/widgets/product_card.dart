import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/filter_controller.dart';
import '../../../models/product_model.dart';
import '../../../services/cart_service.dart';
import '../../../services/firestore_service.dart';
import '../../../utils/app_notifier.dart';
import '../../product/product_details_screen.dart';

class ProductCard extends StatelessWidget {
  ProductCard({super.key});

  final CartService cartService = CartService();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 265,
      child: StreamBuilder<List<ProductModel>>(
        stream: FirestoreService().getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xff7F4F4F),
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: GoogleFonts.manrope(color: Colors.red.shade300),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "No Products Found",
                style: GoogleFonts.manrope(
                  color: const Color(0xff8D7B7B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          return ValueListenableBuilder(
            valueListenable: selectedCategory,
            builder: (context, _, __) {
              return ValueListenableBuilder(
                valueListenable: maxPrice,
                builder: (context, _, __) {
                  return ValueListenableBuilder(
                    valueListenable: sortBy,
                    builder: (context, _, __) {
                      List<ProductModel> products = List.from(snapshot.data!);

                      if (selectedCategory.value != null) {
                        products = products
                            .where((product) =>
                                product.category == selectedCategory.value)
                            .toList();
                      }
                      products = products
                          .where((product) => product.price <= maxPrice.value)
                          .toList();

                      final bestSellers = products.where((p) => p.isBestSeller).toList();
                      final bool hasBestSellers = bestSellers.isNotEmpty;

                      // If best sellers exist, show all. If not, show up to 4 trending products.
                      final displayProducts = hasBestSellers 
                          ? bestSellers 
                          : products.take(4).toList();
                      
                      final String sectionTitle = hasBestSellers ? "Best Sellers" : "Trending Now";

                      if (displayProducts.isEmpty) {
                        return SizedBox(
                          height: 265,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 48,
                                  color: const Color(0xff8D7B7B).withOpacity(0.5),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "No products found",
                                  style: GoogleFonts.dmSerifDisplay(
                                    fontSize: 20,
                                    color: const Color(0xff2D2323),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Try changing your filters.",
                                  style: GoogleFonts.manrope(
                                    color: const Color(0xff8D7B7B),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Text(
                                  sectionTitle,
                                  style: GoogleFonts.manrope(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xff2D2323),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  hasBestSellers 
                                      ? Icons.local_fire_department_rounded 
                                      : Icons.trending_up_rounded,
                                  color: hasBestSellers ? Colors.orange : const Color(0xff7F4F4F),
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: displayProducts.length,
                              itemBuilder: (context, index) {
                                final product = displayProducts[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ProductDetailsScreen(
                                          product: product,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width * 0.46,
                                    margin: const EdgeInsets.only(right: 14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(22),
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
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Stack(
                                            children: [
                                              Container(
                                                width: double.infinity,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xffFFF9F7),
                                                  borderRadius: BorderRadius.vertical(
                                                    top: Radius.circular(22),
                                                  ),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius: const BorderRadius.vertical(
                                                    top: Radius.circular(22),
                                                  ),
                                                  child: Image.network(
                                                    product.image,
                                                    fit: BoxFit.contain,
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return const Center(
                                                        child: Icon(
                                                          Icons.image_not_supported_outlined,
                                                          size: 36,
                                                          color: Color(0xff8D7B7B),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: 8,
                                                left: 8,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 6, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: hasBestSellers 
                                                        ? Colors.orange.shade800 
                                                        : const Color(0xff7F4F4F),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        hasBestSellers 
                                                            ? Icons.local_fire_department 
                                                            : Icons.trending_up,
                                                        size: 12, 
                                                        color: Colors.white,
                                                      ),
                                                      const SizedBox(width: 2),
                                                      Text(
                                                        hasBestSellers ? "Best" : "Trending",
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.manrope(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 13.5,
                                                  color: const Color(0xff2D2323),
                                                  letterSpacing: -0.2,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.star_rounded,
                                                    color: Colors.amber,
                                                    size: 14,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    product.rating.toString(),
                                                    style: GoogleFonts.manrope(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                      color: const Color(0xff8D7B7B),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    "Rs ${product.price.toStringAsFixed(0)}",
                                                    style: GoogleFonts.manrope(
                                                      color: const Color(0xff7F4F4F),
                                                      fontWeight: FontWeight.w800,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  Material(
                                                    color: const Color(0xff7F4F4F),
                                                    shape: const CircleBorder(),
                                                    child: InkWell(
                                                      customBorder: const CircleBorder(),
                                                      onTap: () async {
                                                        final added = await cartService
                                                            .addToCart(product, 1);
                                                        if (!context.mounted) return;
                                                        if (!added) {
                                                          AppNotifier.remove(
                                                            context,
                                                            "Please sign in to use the cart.",
                                                          );
                                                          return;
                                                        }
                                                        AppNotifier.cart(
                                                          context,
                                                          "Added to Cart",
                                                        );
                                                      },
                                                      child: const Padding(
                                                        padding: EdgeInsets.all(6),
                                                        child: Icon(
                                                          Icons.shopping_cart_outlined,
                                                          color: Colors.white,
                                                          size: 15,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}