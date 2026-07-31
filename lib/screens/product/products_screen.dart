import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/tab_controller.dart';
import '../../models/product_model.dart';
import 'product_details_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/page_controller_holder.dart';
class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  bool isGrid = true;
  String sort = "Random";
  final ValueNotifier<String> search = ValueNotifier("");
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocus = FocusNode();

  @override
  void dispose() {
    searchController.dispose();
    search.dispose();
    searchFocus.dispose();
    super.dispose();
  }

  void sortProducts(List<QueryDocumentSnapshot> products) {
    switch (sort) {
      case "Random":
        products.shuffle();
        break;
      case "A-Z":
        products.sort(
          (a, b) => (a.data() as Map<String, dynamic>)["name"]
              .toString()
              .toLowerCase()
              .compareTo(
                (b.data() as Map<String, dynamic>)["name"]
                    .toString()
                    .toLowerCase(),
              ),
        );
        break;
      case "Z-A":
        products.sort(
          (a, b) => (b.data() as Map<String, dynamic>)["name"]
              .toString()
              .toLowerCase()
              .compareTo(
                (a.data() as Map<String, dynamic>)["name"]
                    .toString()
                    .toLowerCase(),
              ),
        );
        break;
      case "Price Low-High":
        products.sort(
          (a, b) => ((a.data() as Map<String, dynamic>)["price"] as num)
              .compareTo(
                (b.data() as Map<String, dynamic>)["price"] as num,
              ),
        );
        break;
      case "Price High-Low":
        products.sort(
          (a, b) => ((b.data() as Map<String, dynamic>)["price"] as num)
              .compareTo(
                (a.data() as Map<String, dynamic>)["price"] as num,
              ),
        );
        break;
      case "Newest":
        products.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aTime = aData["createdAt"] as Timestamp?;
          final bTime = bData["createdAt"] as Timestamp?;
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          return bTime.compareTo(aTime);
        });
        break;
      case "Oldest":
        products.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aTime = aData["createdAt"] as Timestamp?;
          final bTime = bData["createdAt"] as Timestamp?;
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          return aTime.compareTo(bTime);
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final width = size.width;

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
            size: 20,
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              goToTab(0); //[cite: 5, 6]
            }
          },
        ),
        title: Text(
          "Products",
          style: GoogleFonts.manrope(
            color: const Color(0xff3A2B2B),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("products").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xff7F4F4F),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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

          List<QueryDocumentSnapshot> allProducts =
              List.from(snapshot.data!.docs);

          return ValueListenableBuilder<String>(
            valueListenable: search,
            builder: (context, searchText, _) {
              List<QueryDocumentSnapshot> products = List.from(allProducts);
              sortProducts(products);

              if (searchText.trim().isNotEmpty) {
                products = products.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data["name"] ?? "")
                      .toString()
                      .trim()
                      .toLowerCase();
                  return name.contains(searchText.trim().toLowerCase());
                }).toList();
              }

              return Padding(
                padding: EdgeInsets.fromLTRB(
                  width * 0.04,
                  8,
                  width * 0.04,
                  12,
                ),
                child: Column(
                  children: [
                    /// SEARCH BAR
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.12),
                          width: 0.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xff7F4F4F).withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: searchController,
                        focusNode: searchFocus,
                        textInputAction: TextInputAction.search,
                        onChanged: (value) {
                          search.value = value;
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Color(0xff7F4F4F),
                            size: 21,
                          ),
                          hintText: "Search Product",
                          hintStyle: GoogleFonts.manrope(
                            color: const Color(0xff8D7B7B),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    /// GRID/LIST + FILTER
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 46,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.black.withOpacity(0.12),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    onTap: () {
                                      setState(() {
                                        isGrid = true;
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isGrid
                                            ? const Color(0xff7F4F4F)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(13),
                                      ),
                                      child: Icon(
                                        Icons.grid_view_rounded,
                                        color: isGrid
                                            ? Colors.white
                                            : const Color(0xff8D7B7B),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    onTap: () {
                                      setState(() {
                                        isGrid = false;
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: !isGrid
                                            ? const Color(0xff7F4F4F)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(13),
                                      ),
                                      child: Icon(
                                        Icons.view_list_rounded,
                                        color: !isGrid
                                            ? Colors.white
                                            : const Color(0xff8D7B7B),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Material(
                          color: const Color(0xff7F4F4F),
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.white,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(24),
                                  ),
                                ),
                                builder: (context) {
                                  return SafeArea(
                                    child: Wrap(
                                      children: [
                                        const SizedBox(height: 12),
                                        Center(
                                          child: Container(
                                            width: 40,
                                            height: 4,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade300,
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 8,
                                          ),
                                          child: Text(
                                            "Sort Products",
                                            style: GoogleFonts.manrope(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xff2D2323),
                                            ),
                                          ),
                                        ),
                                        _buildSortTile("Random", Icons.shuffle),
                                        _buildSortTile("A-Z", Icons.sort_by_alpha),
                                        _buildSortTile("Z-A", Icons.sort_by_alpha),
                                        _buildSortTile("Price Low-High",
                                            Icons.arrow_upward),
                                        _buildSortTile("Price High-Low",
                                            Icons.arrow_downward),
                                        _buildSortTile("Newest", Icons.fiber_new),
                                        _buildSortTile("Oldest", Icons.history),
                                        const Divider(height: 1),
                                        ListTile(
                                          leading: const Icon(
                                            Icons.refresh,
                                            color: Color(0xff7F4F4F),
                                          ),
                                          title: Text(
                                            "Reset",
                                            style: GoogleFonts.manrope(
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xff2D2323),
                                            ),
                                          ),
                                          onTap: () {
                                            setState(() {
                                              sort = "Random";
                                              search.value = "";
                                              searchController.clear();
                                            });
                                            Navigator.pop(context);
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: const SizedBox(
                              width: 46,
                              height: 46,
                              child: Icon(
                                Icons.tune_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    /// PRODUCTS DISPLAY
                    Expanded(
                      child: AnimatedCrossFade(
                        duration: const Duration(milliseconds: 280),
                        crossFadeState: isGrid
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        firstChild: GridView.builder(
                          itemCount: products.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.78,
                          ),
                          itemBuilder: (context, index) {
                            final data = products[index].data()
                                as Map<String, dynamic>;
                            final product = ProductModel.fromFirestore(
                              products[index].id,
                              data,
                            );

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
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: Colors.black.withOpacity(0.12),
                                    width: 0.8,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xff7F4F4F)
                                          .withOpacity(0.04),
                                      blurRadius: 16,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            decoration: const BoxDecoration(
                                              color: Color(0xffFFF9F7),
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                top: Radius.circular(22),
                                              ),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                top: Radius.circular(22),
                                              ),
                                              child: Image.network(
                                                product.image,
                                                fit: BoxFit.contain,
                                                errorBuilder:
                                                    (_, __, ___) =>
                                                        const Center(
                                                  child: Icon(
                                                    Icons
                                                        .image_not_supported_outlined,
                                                    size: 36,
                                                    color: Color(0xff8D7B7B),
                                                  ),
                                                ),
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
                                                      BorderRadius.circular(
                                                          16),
                                                ),
                                                child: Text(
                                                  "${product.discount}% OFF",
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.manrope(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                              color: const Color(0xff2D2323),
                                              letterSpacing: -0.2,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                            children: [
                                              Text(
                                                "Rs ${product.price.toStringAsFixed(0)}",
                                                style: GoogleFonts.manrope(
                                                  color: const Color(
                                                      0xff7F4F4F),
                                                  fontWeight:
                                                      FontWeight.w800,
                                                  fontSize: 14,
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
                                                    style: GoogleFonts
                                                        .manrope(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: const Color(
                                                          0xff8D7B7B),
                                                    ),
                                                  ),
                                                ],
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
                        ),
                        secondChild: ListView.builder(
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final data = products[index].data()
                                as Map<String, dynamic>;
                            final product = ProductModel.fromFirestore(
                              products[index].id,
                              data,
                            );

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: Colors.black.withOpacity(0.12),
                                  width: 0.8,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xff7F4F4F)
                                        .withOpacity(0.04),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
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
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    color: const Color(0xffFFF9F7),
                                    child: Image.network(
                                      product.image,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(
                                        Icons.image_not_supported_outlined,
                                        size: 24,
                                        color: Color(0xff8D7B7B),
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  product.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.manrope(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: const Color(0xff2D2323),
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    "Rs ${product.price.toStringAsFixed(0)}",
                                    style: GoogleFonts.manrope(
                                      color: const Color(0xff7F4F4F),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 16,
                                  color: Color(0xff8D7B7B),
                                ),
                              ),
                            );
                          },
                        ),
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

  Widget _buildSortTile(String title, IconData icon) {
    final isSelected = sort == title;
    return ListTile(
      selected: isSelected,
      selectedTileColor: const Color(0xffF8EEEB),
      leading: Icon(
        icon,
        color: isSelected ? const Color(0xff7F4F4F) : const Color(0xff8D7B7B),
      ),
      title: Text(
        title,
        style: GoogleFonts.manrope(
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          color: isSelected ? const Color(0xff7F4F4F) : const Color(0xff2D2323),
        ),
      ),
      onTap: () {
        setState(() {
          sort = title;
        });
        Navigator.pop(context);
      },
    );
  }
}