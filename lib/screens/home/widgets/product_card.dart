import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/product_model.dart';
import '../../../services/firestore_service.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key});

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<List<ProductModel>>(
      stream: FirestoreService().getProducts(),

      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }


        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              "No products available",
            ),
          );
        }


        final products = snapshot.data!;


        return SizedBox(
          height: 330,

          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: 22,
            ),

            itemCount: products.length,

            itemBuilder: (context, index) {

              final product = products[index];


              return Container(
                width: 220,

                margin: const EdgeInsets.only(
                  right: 18,
                ),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                      BorderRadius.circular(25),

                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withOpacity(.06),
                      blurRadius: 20,
                      offset:
                          const Offset(0, 10),
                    ),
                  ],
                ),


                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [


                    // Product Image
                    Expanded(
                      child: Stack(
                        children: [


                          ClipRRect(
                            borderRadius:
                                const BorderRadius.vertical(
                              top: Radius.circular(25),
                            ),

                            child: Image.network(
                              product.image,

                              width:
                                  double.infinity,

                              fit:
                                  BoxFit.contain,

                              errorBuilder:
                                  (context, error, stack) {

                                return const Center(
                                  child: Icon(
                                    Icons.image,
                                    size: 60,
                                  ),
                                );

                              },
                            ),
                          ),



                          Positioned(
                            right: 12,
                            top: 12,

                            child: Container(

                              height: 38,
                              width: 38,

                              decoration:
                                  const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),

                              child: const Icon(
                                Icons.favorite_border,
                                color:
                                    Color(0xff7F4F4F),
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),



                    Padding(
                      padding:
                          const EdgeInsets.all(15),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [


                          Text(
                            product.name,

                            maxLines: 1,

                            overflow:
                                TextOverflow.ellipsis,

                            style:
                                GoogleFonts.playfairDisplay(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),


                          const SizedBox(height: 8),



                          Row(
                            children: [

                              const Icon(
                                Icons.star,
                                size: 17,
                                color: Colors.amber,
                              ),


                              const SizedBox(
                                width: 5,
                              ),


                              Text(
                                product.rating.toString(),

                                style:
                                    GoogleFonts.poppins(
                                  fontSize: 13,
                                ),
                              ),

                            ],
                          ),



                          const SizedBox(height: 10),



                          Text(
                            "Rs ${product.price}",

                            style:
                                GoogleFonts.poppins(
                              fontSize: 19,
                              fontWeight:
                                  FontWeight.bold,

                              color:
                                  const Color(
                                      0xff7F4F4F),
                            ),
                          ),

                        ],
                      ),
                    )

                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}