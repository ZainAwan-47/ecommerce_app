import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_notifier.dart';
import '../../models/product_model.dart';
import '../../services/cart_service.dart';
import '../../services/wishlist_service.dart';
import '../../core/page_controller_holder.dart';
import '../../core/tab_controller.dart';

class WishlistScreen extends StatelessWidget {
  WishlistScreen({super.key});

  final WishlistService wishlistService = WishlistService();
  final CartService cartService = CartService();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: const Color(0xffFFF9F7),
      appBar: AppBar(
        backgroundColor: const Color(0xffFFF9F7),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xff3A2B2B),
            size: 18,
          ),
          onPressed: () {
            goBackTab();
          },
        ),
        title: Text(
          "My Wishlist",
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xff2D2323),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: wishlistService.getWishlist(),
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
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: Colors.red.shade300,
                  fontSize: 14,
                ),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 72,
                    color: const Color(0xff8D7B7B).withOpacity(0.4),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Your Wishlist is Empty",
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff2D2323),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Save products you love\nand they'll appear here.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      color: const Color(0xff8D7B7B),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          final wishlist = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: wishlist.length,
            itemBuilder: (context, index) {
              final item = wishlist[index];
              final data = item.data() as Map<String, dynamic>? ?? {};
              
              // Safe check for inStock parameter defaulting to true if missing
              final bool inStock = data.containsKey('inStock')
                  ? (data['inStock'] ?? true)
                  : true;

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.black.withOpacity(0.08),
                    width: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff7F4F4F).withOpacity(0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 75,
                        height: 75,
                        color: const Color(0xffFFF9F7),
                        child: Image.network(
                          data['image'] ?? '',
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: Color(0xff7F4F4F),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: Color(0xff8D7B7B),
                                size: 28,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['name'] ?? 'No Name',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xff2D2323),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Rs ${data['price'] ?? 0}",
                            style: GoogleFonts.manrope(
                              color: const Color(0xff7F4F4F),
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 15,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                (data['rating'] ?? 0).toString(),
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xff8D7B7B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: 38,
                            child: ElevatedButton.icon(
                              onPressed: !inStock
                                  ? null
                                  : () async {
                                      final product =
                                          ProductModel.fromFirestore(
                                        item.id,
                                        data,
                                      );

                                      final added = await cartService.addToCart(
                                        product,
                                        1,
                                      );

                                      if (!context.mounted) return;

                                      if (!added) {
                                        AppNotifier.error(
                                          context,
                                          "Please Sign In",
                                        );
                                        return;
                                      }

                                      if (!context.mounted) return;

                                      AppNotifier.cart(
                                        context,
                                        "Added to Cart",
                                      );

                                      await Future.delayed(
                                        const Duration(milliseconds: 200),
                                      );

                                      await wishlistService.removeFromWishlist(
                                        item.id,
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff7F4F4F),
                                disabledBackgroundColor:
                                    Colors.grey.shade200,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: Icon(
                                Icons.shopping_cart_outlined,
                                color: inStock
                                    ? Colors.white
                                    : Colors.grey.shade500,
                                size: 15,
                              ),
                              label: Text(
                                inStock ? "Add to Cart" : "Out of Stock",
                                style: GoogleFonts.manrope(
                                  color: inStock
                                      ? Colors.white
                                      : Colors.grey.shade600,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () async {
                        AppNotifier.remove(
                          context,
                          "Removed from Wishlist",
                        );
                        await Future.delayed(
                          const Duration(milliseconds: 200),
                        );
                        await wishlistService.removeFromWishlist(item.id);
                      },
                      icon: Icon(
                        Icons.favorite_rounded,
                        color: Colors.red.shade400,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}