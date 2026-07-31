import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/product_model.dart';
import '../../product/product_details_screen.dart';

class YouMayLikeSection extends StatelessWidget {
  const YouMayLikeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("products").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 160,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xff7F4F4F),
              ),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        List<QueryDocumentSnapshot> products = List.from(snapshot.data!.docs);
        
        // Deterministic sort matching ProductCard
        products.sort((a, b) => a.id.compareTo(b.id));

        // If total products > 8, offset starting index to 5 to avoid overlap with ProductCard (0-4)
        if (products.length > 8) {
          if (products.length > 11) {
            products = products.sublist(5, 11);
          } else {
            products = products.sublist(5, products.length);
          }
        } else {
          if (products.length > 6) {
            products = products.sublist(0, 6);
          }
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 7,
              childAspectRatio: 0.76,
            ),
            itemBuilder: (context, index) {
              final data = products[index].data() as Map<String, dynamic>;
              final imageUrl = data["images"] != null &&
                      (data["images"] as List).isNotEmpty
                  ? data["images"][0]
                  : (data["image"] ?? "");
              final productName = data["name"] ?? "";
              final productPrice = (data["price"] as num?)?.toDouble() ?? 0.0;

              return GestureDetector(
                onTap: () {
                  final product = ProductModel.fromFirestore(
                    products[index].id,
                    data,
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
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 16,
                        color: const Color(0xff7F4F4F).withOpacity(0.05),
                        offset: const Offset(0, 6),
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
                              top: Radius.circular(20),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    color: Color(0xff7F4F4F),
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 28,
                                  color: Color(0xff8D7B7B),
                                ),
                              ),
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
                              productName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.manrope(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xff2D2323),
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Rs ${productPrice.toStringAsFixed(0)}",
                              style: GoogleFonts.manrope(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xff7F4F4F),
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