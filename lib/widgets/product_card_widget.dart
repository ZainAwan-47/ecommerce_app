import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';
import '../services/wishlist_service.dart';
import '../utils/app_notifier.dart';
import '../screens/product/product_details_screen.dart';

class ProductCardWidget extends StatelessWidget {
  final ProductModel product;
  const ProductCardWidget({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final cartService = CartService();
    final wishlistService = WishlistService();
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
        width: MediaQuery.sizeOf(context).width * 0.43,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: Stack(
                  children: [
                    // Product Image Base
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Image.network(
                          product.image,
                          width: double.infinity,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) {
                              return child;
                            }
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                size: 70,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Wishlist Button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: StreamBuilder<bool>(
                        stream: wishlistService.isWishlisted(product.id),
                        builder: (context, snapshot) {
                          final wishlisted = snapshot.data ?? false;
                          return CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                wishlisted
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: wishlisted ? Colors.red : Colors.grey,
                                size: 20,
                              ),
                              onPressed: () async {
                                final success = await wishlistService
                                    .toggleWishlist(product);
                                if (!context.mounted) {
                                  return;
                                }
                                if (!success) {
                                  AppNotifier.remove(
                                    context,
                                    "Please sign in first.",
                                  );
                                  return;
                                }
                                if (wishlisted) {
                                  AppNotifier.remove(
                                    context,
                                    "Removed from Wishlist",
                                  );
                                } else {
                                  AppNotifier.wishlist(
                                    context,
                                    "Added to Wishlist",
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),

                    // Fixed Discount Badge (Properly padded & clipped inside the border)
                    if (product.discount > 0)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "${product.discount}% OFF",
                            style: GoogleFonts.manrope(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),

                    // Out of Stock Overlay
                    if (!product.inStock)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(.55),
                          ),
                          child: Center(
                            child: Text(
                              "OUT OF STOCK",
                              style: GoogleFonts.manrope(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
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
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      if (product.discount > 0)
                        Text(
                          "Rs ${product.oldPrice.toStringAsFixed(0)}",
                          style: GoogleFonts.manrope(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Rs ${product.price.toStringAsFixed(0)}",
                        style: GoogleFonts.manrope(
                          color: const Color(0xff7F4F4F),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xffA86A6A),
                        child: IconButton(
                          icon: const Icon(
                            Icons.shopping_cart_outlined,
                            color: Colors.white,
                            size: 14,
                          ),
                          onPressed: product.inStock
                              ? () async {
                                  final added =
                                      await cartService.addToCart(product, 1);
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
                                }
                              : null,
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
  }
}