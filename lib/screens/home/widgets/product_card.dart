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
            builder: (context, _, _) {
              return ValueListenableBuilder(
                valueListenable: maxPrice,
                builder: (context, _, _) {
                  return ValueListenableBuilder(
                    valueListenable: sortBy,
                    builder: (context, _, _) {
                      List<ProductModel> products = List.from(snapshot.data!);
                      
                      // Deterministic sort to synchronize with YouMayLikeSection
                      products.sort((a, b) => a.id.compareTo(b.id));

                      if (selectedCategory.value != null) {
                        products = products
                            .where((product) =>
                                product.category == selectedCategory.value)
                            .toList();
                      }

                      products = products
                          .where((product) => product.price <= maxPrice.value)
                          .toList();

                      switch (sortBy.value) {
                        case "low":
                          products.sort((a, b) => a.price.compareTo(b.price));
                          break;
                        case "high":
                          products.sort((a, b) => b.price.compareTo(a.price));
                          break;
                        case "rating":
                          products.sort((a, b) => b.rating.compareTo(a.rating));
                          break;
                      }

                      if (products.length > 5) {
                        products = products.sublist(0, 5);
                      }

                      if (products.isEmpty) {
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

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
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
                                    child: Container(
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
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return const Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Color(0xff7F4F4F),
                                              ),
                                            );
                                          },
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