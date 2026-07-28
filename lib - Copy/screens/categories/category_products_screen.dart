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
     final width = MediaQuery.sizeOf(context).width;
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
          style: GoogleFonts.manrope(
        fontSize:28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),

      body: StreamBuilder<List<ProductModel>>(
        stream: FirestoreService().getProductsByCategory(category),
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
                style: GoogleFonts.manrope(
                  fontSize: 16,
                ),
              ),
            );
          }

          final products = snapshot.data!;

          return GridView.builder(
           padding: EdgeInsets.all(width * 0.03),
            itemCount: products.length,
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
           crossAxisSpacing: width * 0.015,
mainAxisSpacing: width * 0.015,
              childAspectRatio: .87,
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
                        BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.06),
                        blurRadius: 5,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),

                  child: Column(
                    children: [

                      /// IMAGE + BADGE
                      SizedBox(
                    height: width * 0.31,
                        child: Stack(
                          children: [

                            Center(
                              child: Hero(
                                tag: product.id,
                                child: Image.network(
                                  product.image,
                             height: width * 0.25,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),

                            if (product.discount > 0)
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius:
                                        BorderRadius.circular(18),
                                  ),
                                  child: Text(
                                    "${product.discount}% OFF",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(
                            8,
                            8,
                            9,
                            10,
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
                            children: [

                              SizedBox(
                                height: 37,
                                child: Text(
                                  product.name,
                                  maxLines: 2,
                                  overflow:
                                      TextOverflow.ellipsis,
                                  style: GoogleFonts
                                      .manrope(
                                    fontSize: 15,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                children: [

                                  Text(
                                    "Rs ${product.price.toStringAsFixed(0)}",
                                    style:
                                        GoogleFonts.manrope(
                                      color:
                                          const Color(0xff7F4F4F),
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),

                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star_rounded,
                                        color: Colors.amber,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        product.rating
                                            .toStringAsFixed(1),
                                        style:
                                            GoogleFonts.manrope(
                                          fontSize: 13,
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
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