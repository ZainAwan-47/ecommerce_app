import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../models/product_model.dart';
import '../../product/product_details_screen.dart';

class YouMayLikeSection extends StatelessWidget {
  const YouMayLikeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("products")
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        List<QueryDocumentSnapshot> products =
            List.from(snapshot.data!.docs);

        if (products.isEmpty) {
          return const SizedBox();
        }

        products.shuffle();

        if (products.length > 6) {
  products = products.sublist(0, 6);
}

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: .90,
            ),
            itemBuilder: (context, index) {
              final data =
                  products[index].data() as Map<String, dynamic>;

              return GestureDetector(
           onTap: () {
  final product = ProductModel(
    id: products[index].id,
    name: data["name"] ?? "",
     images: [
    data["image"] ?? "",
  ],
    price: (data["price"] as num?)?.toDouble() ?? 0,
    oldPrice: (data["oldPrice"] as num?)?.toDouble() ??
        (data["price"] as num?)?.toDouble() ??
        0,
    rating: (data["rating"] as num?)?.toDouble() ?? 0,
    category: data["category"] ?? "",
    description: data["description"] ?? "",
    featured: data["featured"] ?? false,
    discount: data["discount"] ?? 0,
    inStock: data["inStock"] ?? true,
  );

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
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.05),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 80,
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Image.network(
                            data["image"],
                            width: double.infinity,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(
                                8, 4, 8, 8),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              data["name"],
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 2),

                            Text(
                              "Rs ${data["price"]}",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight:
                                    FontWeight.bold,
                                color:
                                    Color(0xff7F4F4F),
                              ),
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
        );
      },
    );
  }
}