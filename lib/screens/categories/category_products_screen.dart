import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/product_model.dart';
import '../../services/firestore_service.dart';
import '../product/product_details_screen.dart';

class CategoryProductsScreen extends StatelessWidget {
  final String category;

  const CategoryProductsScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF9F7),

      appBar: AppBar(
        backgroundColor: const Color(0xffFFF9F7),
        elevation: 0,

        iconTheme: const IconThemeData(
          color: Colors.black,
        ),

        centerTitle: true,

        title: Text(
          category,
          style: GoogleFonts.playfairDisplay(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),

      body: StreamBuilder<List<ProductModel>>(
        stream: FirestoreService()
            .getProductsByCategory(category),

        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "No products found",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                ),
              ),
            );
          }

          final products = snapshot.data!;
                    return GridView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: products.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 18,
              childAspectRatio: .62,
            ),
            itemBuilder: (context, index) {
              final product = products[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ProductDetailsScreen(
                        product: product,
                      ),
                    ),
                  );
                },

                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.06),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Expanded(
                        child: Hero(
                          tag: product.id,
                          child: ClipRRect(
                            borderRadius:
                                const BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                            child: Image.network(
                              product.image,
                              width: double.infinity,
                              fit: BoxFit.contain,

                              loadingBuilder:
                                  (context, child, progress) {
                                if (progress == null) {
                                  return child;
                                }

                                return const Center(
                                  child:
                                      CircularProgressIndicator(),
                                );
                              },

                              errorBuilder:
                                  (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons
                                        .image_not_supported_outlined,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding:
                            const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [

                            Text(
                              product.name,
                              maxLines: 2,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: GoogleFonts
                                  .playfairDisplay(
                                fontSize: 17,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Row(
                              children: [

                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 17,
                                ),

                                const SizedBox(width: 5),

                                Text(
                                  product.rating
                                      .toString(),
                                  style:
                                      GoogleFonts.poppins(),
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
                                  style: GoogleFonts
                                      .poppins(
                                    color: const Color(
                                        0xff7F4F4F),
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                                               CircleAvatar(
                                  radius: 18,
                                  backgroundColor:
                                      const Color(0xff7F4F4F),
                                  child: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Colors.white,
                                    size: 16,
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
      ),
    );
  }
}
                            