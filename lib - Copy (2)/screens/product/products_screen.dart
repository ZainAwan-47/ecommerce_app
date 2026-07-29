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
  State<ProductsScreen> createState() =>
      _ProductsScreenState();
}

class _ProductsScreenState
    extends State<ProductsScreen> {
  bool isGrid = true;

  String sort = "Random";

  final ValueNotifier<String> search =
      ValueNotifier("");

  final TextEditingController searchController =
      TextEditingController();

  final FocusNode searchFocus = FocusNode();

  @override
  void dispose() {
    searchController.dispose();
    search.dispose();
    searchFocus.dispose();
    super.dispose();
  }

  void sortProducts(
    List<QueryDocumentSnapshot> products,
  ) {
    switch (sort) {
      case "Random":
        products.shuffle();
        break;

      case "A-Z":
        products.sort(
          (a, b) => a["name"]
              .toString()
              .toLowerCase()
              .compareTo(
                b["name"]
                    .toString()
                    .toLowerCase(),
              ),
        );
        break;

      case "Z-A":
        products.sort(
          (a, b) => b["name"]
              .toString()
              .toLowerCase()
              .compareTo(
                a["name"]
                    .toString()
                    .toLowerCase(),
              ),
        );
        break;

      case "Price Low-High":
        products.sort(
          (a, b) => (a["price"] as num)
              .compareTo(
            b["price"] as num,
          ),
        );
        break;

      case "Price High-Low":
        products.sort(
          (a, b) => (b["price"] as num)
              .compareTo(
            a["price"] as num,
          ),
        );
        break;

      case "Newest":
        products.sort((a, b) {
          final aData =
              a.data() as Map<String, dynamic>;
          final bData =
              b.data() as Map<String, dynamic>;

          final aTime =
              aData["createdAt"] as Timestamp?;
          final bTime =
              bData["createdAt"] as Timestamp?;

          if (aTime == null &&
              bTime == null) {
            return 0;
          }

          if (aTime == null) return 1;
          if (bTime == null) return -1;

          return bTime.compareTo(aTime);
        });
        break;

      case "Oldest":
        products.sort((a, b) {
          final aData =
              a.data() as Map<String, dynamic>;
          final bData =
              b.data() as Map<String, dynamic>;

          final aTime =
              aData["createdAt"] as Timestamp?;
          final bTime =
              bData["createdAt"] as Timestamp?;

          if (aTime == null &&
              bTime == null) {
            return 0;
          }

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
      backgroundColor:
          const Color(0xffFFF9F7),

     appBar: AppBar(
  backgroundColor: const Color(0xffFFF9F7),
  elevation: 0,
  scrolledUnderElevation: 0,
  centerTitle: true,

 leading: IconButton(
  icon: const Icon(
    Icons.arrow_back_ios_new_rounded,
    color: Color(0xff3A2B2B),
  ),
  onPressed: () {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
     goToTab(0);
    }
  },
),

  title: const Text(
    "Products",
    style: TextStyle(
      color: Color(0xff3A2B2B),
      fontWeight: FontWeight.bold,
    ),
  ),
),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("products")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No Products Found",
              ),
            );
          }

        List<QueryDocumentSnapshot> allProducts =
    List.from(snapshot.data!.docs);

return ValueListenableBuilder<String>(
  valueListenable: search,
  builder: (context, searchText, _) {

    List<QueryDocumentSnapshot> products =
        List.from(allProducts);

    sortProducts(products);

    if (searchText.trim().isNotEmpty) {
      products = products.where((doc) {
        final data =
            doc.data() as Map<String, dynamic>;

        final name =
            (data["name"] ?? "")
                .toString()
                .trim()
                .toLowerCase();

        return name.contains(
          searchText.trim().toLowerCase(),
        );
      }).toList();
    }

              return Padding(
              padding: EdgeInsets.fromLTRB(
  width * 0.03,
  8,
  width * 0.03,
  12,
),
                child: Column(
                  children: [
                                        /// SEARCH BAR
                    Container(
                 height: width * 0.11,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller:
                            searchController,
                        focusNode: searchFocus,
                        textInputAction:
                            TextInputAction.search,
                        onChanged: (value) {
                          search.value = value;
                        },
                        decoration:
                            const InputDecoration(
                          border:
                              InputBorder.none,
                          prefixIcon: Icon(
                            Icons.search,
                            color: Color(
                                0xff7F4F4F),
                          ),
                          hintText:
                              "Search products...",
                        ),
                      ),
                    ),

                    const SizedBox(height: 13),

                    /// GRID/LIST + FILTER
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                      height: width * 0.11,
                            decoration:
                                BoxDecoration(
                              color:
                                  Colors.white,
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          14),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child:
                                      InkWell(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                                14),
                                    onTap: () {
                                      setState(() {
                                        isGrid =
                                            true;
                                      });
                                    },
                                    child:
                                        Container(
                                      decoration:
                                          BoxDecoration(
                                        color: isGrid
                                            ? const Color(
                                                0xff7F4F4F)
                                            : Colors
                                                .transparent,
                                        borderRadius:
                                            BorderRadius.circular(
                                                14),
                                      ),
                                      child:
                                          Icon(
                                        Icons
                                            .grid_view_rounded,
                                        color: isGrid
                                            ? Colors
                                                .white
                                            : Colors
                                                .grey,
                                      ),
                                    ),
                                  ),
                                ),

                                Expanded(
                                  child:
                                      InkWell(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                                14),
                                    onTap: () {
                                      setState(() {
                                        isGrid =
                                            false;
                                      });
                                    },
                                    child:
                                        Container(
                                      decoration:
                                          BoxDecoration(
                                        color: !isGrid
                                            ? const Color(
                                                0xff7F4F4F)
                                            : Colors
                                                .transparent,
                                        borderRadius:
                                            BorderRadius.circular(
                                                14),
                                      ),
                                      child:
                                          Icon(
                                        Icons
                                            .view_list_rounded,
                                        color: !isGrid
                                            ? Colors
                                                .white
                                            : Colors
                                                .grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(
                            width: 12),

                        InkWell(
                          borderRadius:
                              BorderRadius
                                  .circular(14),
                          onTap: () {
                            showModalBottomSheet(
                              context:
                                  context,
                              isScrollControlled:
                                  true,
                              backgroundColor:
                                  Colors.white,
                              shape:
                                  const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.vertical(
                                  top: Radius
                                      .circular(
                                          24),
                                ),
                              ),
                              builder: (_) {
                                return SafeArea(
                                  child: Wrap(
                                    children: [
                                      const SizedBox(
                                          height:
                                              10),

                                      const Center(
                                        child:
                                            SizedBox(
                                          width:
                                              45,
                                          child:
                                              Divider(
                                            thickness:
                                                4,
                                          ),
                                        ),
                                      ),
                                                                            ListTile(
                                        selected:
                                            sort ==
                                                "Random",
                                        selectedTileColor:
                                            const Color(
                                                0xffF2E5E5),
                                        leading:
                                            const Icon(
                                          Icons
                                              .shuffle,
                                        ),
                                        title:
                                            const Text(
                                          "Random",
                                        ),
                                        onTap: () {
                                          setState(
                                              () {
                                            sort =
                                                "Random";
                                          });
                                          Navigator.pop(
                                              context);
                                        },
                                      ),

                                      ListTile(
                                        selected:
                                            sort ==
                                                "A-Z",
                                        selectedTileColor:
                                            const Color(
                                                0xffF2E5E5),
                                        leading:
                                            const Icon(
                                          Icons
                                              .sort_by_alpha,
                                        ),
                                        title:
                                            const Text(
                                          "A - Z",
                                        ),
                                        onTap: () {
                                          setState(
                                              () {
                                            sort =
                                                "A-Z";
                                          });
                                          Navigator.pop(
                                              context);
                                        },
                                      ),

                                      ListTile(
                                        selected:
                                            sort ==
                                                "Z-A",
                                        selectedTileColor:
                                            const Color(
                                                0xffF2E5E5),
                                        leading:
                                            const Icon(
                                          Icons
                                              .sort_by_alpha,
                                        ),
                                        title:
                                            const Text(
                                          "Z - A",
                                        ),
                                        onTap: () {
                                          setState(
                                              () {
                                            sort =
                                                "Z-A";
                                          });
                                          Navigator.pop(
                                              context);
                                        },
                                      ),

                                      ListTile(
                                        selected:
                                            sort ==
                                                "Price Low-High",
                                        selectedTileColor:
                                            const Color(
                                                0xffF2E5E5),
                                        leading:
                                            const Icon(
                                          Icons
                                              .arrow_upward,
                                        ),
                                        title:
                                            const Text(
                                          "Price Low - High",
                                        ),
                                        onTap: () {
                                          setState(
                                              () {
                                            sort =
                                                "Price Low-High";
                                          });
                                          Navigator.pop(
                                              context);
                                        },
                                      ),

                                      ListTile(
                                        selected:
                                            sort ==
                                                "Price High-Low",
                                        selectedTileColor:
                                            const Color(
                                                0xffF2E5E5),
                                        leading:
                                            const Icon(
                                          Icons
                                              .arrow_downward,
                                        ),
                                        title:
                                            const Text(
                                          "Price High - Low",
                                        ),
                                        onTap: () {
                                          setState(
                                              () {
                                            sort =
                                                "Price High-Low";
                                          });
                                          Navigator.pop(
                                              context);
                                        },
                                      ),

                                      ListTile(
                                        selected:
                                            sort ==
                                                "Newest",
                                        selectedTileColor:
                                            const Color(
                                                0xffF2E5E5),
                                        leading:
                                            const Icon(
                                          Icons
                                              .fiber_new,
                                        ),
                                        title:
                                            const Text(
                                          "Newest",
                                        ),
                                        onTap: () {
                                          setState(
                                              () {
                                            sort =
                                                "Newest";
                                          });
                                          Navigator.pop(
                                              context);
                                        },
                                      ),

                                      ListTile(
                                        selected:
                                            sort ==
                                                "Oldest",
                                        selectedTileColor:
                                            const Color(
                                                0xffF2E5E5),
                                        leading:
                                            const Icon(
                                          Icons
                                              .history,
                                        ),
                                        title:
                                            const Text(
                                          "Oldest",
                                        ),
                                        onTap: () {
                                          setState(
                                              () {
                                            sort =
                                                "Oldest";
                                          });
                                          Navigator.pop(
                                              context);
                                        },
                                      ),

                                      const Divider(
                                          height: 1),

                                      ListTile(
                                        leading:
                                            const Icon(
                                          Icons
                                              .refresh,
                                        ),
                                        title:
                                            const Text(
                                          "Reset",
                                        ),
                                        onTap: () {
                                          setState(
                                              () {
                                            sort =
                                                "Random";
                                            search.value =
                                                "";
                                            searchController
                                                .clear();
                                          });

                                          Navigator.pop(
                                              context);
                                        },
                                      ),

                                      const SizedBox(
                                          height:
                                              8),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: Container(
                         height: width * 0.11,
width: width * 0.11,
                            decoration:
                                BoxDecoration(
                              color:
                                  const Color(
                                      0xff7F4F4F),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          14),
                            ),
                            child:
                                const Icon(
                              Icons.tune,
                              color:
                                  Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                        height: 18),

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
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: .82,
      ),
      itemBuilder: (context, index) {
                            final data = products[index]
                                    .data()
                                as Map<String, dynamic>;

                            final product =
                                ProductModel.fromFirestore(
                              products[index].id,
                              data,
                            );

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
                                decoration:
                                    BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                              18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors
                                          .black
                                          .withOpacity(
                                              .05),
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
   children: [
  SizedBox(
 height: width * 0.31,
    child: Stack(
      children: [
      Padding(
  padding: const EdgeInsets.only(top: 8),
  child: Center(
    child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(18),
            ),
            child: Image.network(
              product.image,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
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
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(16),
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

  Expanded(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(8, 11, 8, 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 45,
            child: Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Rs ${product.price.toStringAsFixed(0)}",
                style: GoogleFonts.manrope(
                  color: const Color(0xff7F4F4F),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),

              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Colors.amber,
                    size: 15,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    product.rating.toStringAsFixed(1),
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
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
                        ),
                       secondChild: ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
                            final data = products[index]
                                    .data()
                                as Map<String, dynamic>;

                            final product =
                                ProductModel.fromFirestore(
                              products[index].id,
                              data,
                            );

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
                                                            child: Card(
                                elevation: 2,
                                margin:
                                    const EdgeInsets.only(
                                  bottom: 12,
                                ),
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(16),
                                ),
                                child: ListTile(
                                  contentPadding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  leading: ClipRRect(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                                10),
                                    child: Image.network(
                                      product.image,
                                  width: width * 0.16,
height: width * 0.16,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  title: Text(
                                    product.name,
                                    maxLines: 2,
                                    overflow:
                                        TextOverflow
                                            .ellipsis,
                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "Rs ${product.price}",
                                    style:
                                        const TextStyle(
                                      color: Color(
                                          0xff7F4F4F),
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),
                                  trailing:
                                      const Icon(
                                    Icons
                                        .arrow_forward_ios,
                                    size: 16,
                                  ),
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
}