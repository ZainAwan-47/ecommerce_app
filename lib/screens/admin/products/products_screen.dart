import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/product_model.dart';
import '../../../services/product_service.dart';
import '../../../widgets/admin/admin_card.dart';
import '../../../widgets/admin/responsive.dart';
import 'add_product_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() =>
      _ProductsScreenState();
}

class _ProductsScreenState
    extends State<ProductsScreen> {
  final ProductService _productService =
      ProductService();

  final TextEditingController _searchController =
      TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF9F7),

      appBar: AppBar(
        backgroundColor: const Color(0xffFFF9F7),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Products",
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w700,
            fontSize:
                Responsive.titleSize(context),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xff7F4F4F),
         foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const AddProductScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
     label: const Text(
  "Add Product",
  style: TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w600,
  ),
),
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal:
              Responsive.horizontalPadding(context),
          vertical:
              Responsive.verticalPadding(context),
        ),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon:
                    const Icon(Icons.search),
                hintText:
                    "Search products...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    Responsive.radius,
                  ),
                  borderSide:
                      BorderSide.none,
                ),
              ),
              onChanged: (_) {
                setState(() {});
              },
            ),

            const SizedBox(height: 18),

            Expanded(
              child: StreamBuilder<
                  List<ProductModel>>(
                stream:
                    _productService.getProducts(),
                builder: (
                  context,
                  snapshot,
                ) {
                  if (snapshot
                          .connectionState ==
                      ConnectionState
                          .waiting) {
                    return const Center(
                      child:
                          CircularProgressIndicator(),
                    );
                  }

                  if (!snapshot.hasData ||
                      snapshot.data!
                          .isEmpty) {
                    return const Center(
                      child: Text(
                        "No products found.",
                      ),
                    );
                  }

                  List<ProductModel>
                      products =
                      snapshot.data!;

                  if (_searchController
                      .text.isNotEmpty) {
                    products = products
                        .where(
                          (product) =>
                              product.name
                                  .toLowerCase()
                                  .contains(
                                    _searchController
                                        .text
                                        .toLowerCase(),
                                  ),
                        )
                        .toList();
                  }

                  return ListView.separated(
                      padding: const EdgeInsets.only(bottom: 100),
                    itemCount:
                        products.length,
                    separatorBuilder:
                        (_, __) =>
                            const SizedBox(
                      height: 12,
                    ),
                    itemBuilder:
                        (context, index) {
                      final product =
                          products[index];

                      return AdminCard(
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(
                                      10),
                              child: Image.network(
                                product.image,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (
                                  context,
                                  error,
                                  stackTrace,
                                ) {
                                  return Container(
                                    width: 70,
                                    height: 70,
                                    color: Colors
                                        .grey
                                        .shade300,
                                    child: const Icon(
                                      Icons
                                          .image_not_supported,
                                    ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(
                                width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    product.name,
                                    style:
                                        GoogleFonts
                                            .manrope(
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),

                                  const SizedBox(
                                      height:
                                          4),

                                  Text(
                                    product
                                        .category,
                                    style:
                                        GoogleFonts
                                            .manrope(
                                      color: Colors
                                          .grey,
                                    ),
                                  ),

                                  const SizedBox(
                                      height:
                                          4),

                                  Text(
                                    "PKR ${product.price.toStringAsFixed(0)}",
                                    style:
                                        GoogleFonts
                                            .manrope(
                                      fontWeight:
                                          FontWeight
                                              .w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),

Wrap(
  spacing: 8,
  runSpacing: 8,
  children: [
    if (product.featured)
      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 4,
        ),
       decoration: BoxDecoration(
  color: Colors.grey[60],
  borderRadius: BorderRadius.circular(20),
  border: Border.all(
    color:Colors.amber.withOpacity(0.50),
    width: 1.2,
  ),
),
        child: const Text(
          "Featured",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

    Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
     decoration: BoxDecoration(
  color: Colors.grey[60],
  borderRadius: BorderRadius.circular(20),
  border: Border.all(
    color: const Color(0xff7F4F4F).withOpacity(0.25),
    width: 1.2,
  ),
),
      child: Text(
        product.inStock
            ? " In Stock"
            : " Out of Stock",
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: product.inStock
              ? Colors.green.shade800
              : Colors.red.shade800,
        ),
      ),
    ),
  ],
),
                                ],
                              ),
                            ),

                        Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    InkWell(
      borderRadius: BorderRadius.circular(12),
    onTap: () async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => AddProductScreen(
        product: product,
      ),
    ),
  );
},
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xff7F4F4F).withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.edit_outlined,
          color: Color(0xff7F4F4F),
          size: 20,
        ),
      ),
    ),

    const SizedBox(height: 10),

    InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        _showDeleteDialog(product);
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.red,
          size: 20,
        ),
      ),
    ),
  ],
),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(
    ProductModel product,
  ) async {
    final confirm =
        await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title:
            const Text("Delete Product"),
        content: Text(
          "Delete ${product.name}?",
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(
                    context, false),
            child: const Text(
                "Cancel"),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(
                    context, true),
            child:
                const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _productService
          .deleteProduct(product.id);
    }
  }
}