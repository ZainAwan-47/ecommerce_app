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
      height: 340,
      child: StreamBuilder<List<ProductModel>>(
        stream: FirestoreService().getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No Products Found",
              ),
            );
          }

          return ValueListenableBuilder(
            valueListenable: selectedCategory,
            builder: (context, _, __) {
              return ValueListenableBuilder(
                valueListenable: maxPrice,
                builder: (context, __, ___) {
                  return ValueListenableBuilder(
                    valueListenable: sortBy,
                    builder: (
                      context,
                      ___,
                      ____,
                    ) {
                      List<ProductModel> products =
                          List.from(snapshot.data!);
                      products.shuffle();
                      if (selectedCategory.value !=
                          null) {
                        products = products.where(
                          (product) {
                            return product.category ==
                                selectedCategory
                                    .value;
                          },
                        ).toList();
                      }

                      products = products.where(
                        (product) {
                          return product.price <=
                              maxPrice.value;
                        },
                      ).toList();

                      switch (sortBy.value) {
                        case "low":
                          products.sort(
                            (a, b) => a.price
                                .compareTo(
                                  b.price,
                                ),
                          );
                          break;

                        case "high":
                          products.sort(
                            (a, b) => b.price
                                .compareTo(
                                  a.price,
                                ),
                          );
                          break;

                        case "rating":
                          products.sort(
                            (a, b) => b.rating
                                .compareTo(
                                  a.rating,
                                ),
                          );
                          break;
                      }
  if (products.length > 5) {
  products = products.sublist(0, 5);
}
if (products.isEmpty) {
  return SizedBox(
    height: 340,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 70,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            "No products found",
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 26,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Try changing your filters.",
            style: GoogleFonts.manrope(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    ),
  );
}
                      return ListView.builder(
                        scrollDirection:
                            Axis.horizontal,
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 22,
                        ),
                        itemCount: products.length,
                        itemBuilder:
                            (context, index) {
                          final product =
                              products[index];
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
    width: 220,
    margin: const EdgeInsets.only(right: 18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.08),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            child: Image.network(
              product.image,
              width: double.infinity,
              fit: BoxFit.contain,
              loadingBuilder: (
                context,
                child,
                loadingProgress,
              ) {
                if (loadingProgress == null) {
                  return child;
                }

                return const Center(
                  child:
                      CircularProgressIndicator(),
                );
              },
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return const Center(
                  child: Icon(
                    Icons
                        .image_not_supported_outlined,
                    size: 70,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                maxLines: 2,
                overflow:
                    TextOverflow.ellipsis,
                style:
                    GoogleFonts.dmSerifDisplay(
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 18,
                  ),

                  const SizedBox(width: 4),

                  Text(
                    product.rating.toString(),
                    style:
                        GoogleFonts.manrope(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                children: [
                  Text(
                    "Rs ${product.price.toStringAsFixed(0)}",
                    style:
                        GoogleFonts.manrope(
                      color: const Color(
                          0xff7F4F4F),
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  CircleAvatar(
                    radius: 20,
                    backgroundColor:
                        const Color(
                            0xff7F4F4F),
                    child: IconButton(
                      onPressed: () async {
                        final added =
                            await cartService
                                .addToCart(
                          product,
                          1,
                        );

                        if (!context.mounted) {
                          return;
                        }

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
                      icon: const Icon(
                        Icons
                            .shopping_cart_outlined,
                        color: Colors.white,
                        size: 20,
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