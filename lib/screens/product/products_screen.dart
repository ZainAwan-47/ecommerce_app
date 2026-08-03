import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/tab_controller.dart';
import '../../models/product_model.dart';
import 'product_details_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/page_controller_holder.dart';

// Persistent filter states across tab switches
String? _globalSelectedCategory;
double _globalMaxPrice = 9999;
String _globalSortBy = "featured";
final ValueNotifier<String> _globalSearchQuery = ValueNotifier("");

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  bool isGrid = true;
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    searchController.text = _globalSearchQuery.value;
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocus.dispose();
    super.dispose();
  }

  void _openFilterBottomSheet(List<String> availableCategories) {
    String? tempCategory = _globalSelectedCategory;
    double tempPrice = _globalMaxPrice;
    String tempSort = _globalSortBy;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          "Filter Products",
                          style: GoogleFonts.manrope(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xff2D2323),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Category",
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xff2D2323),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: availableCategories.map((cat) {
                          final isSelected = tempCategory == cat;
                          return ChoiceChip(
                            label: Text(
                              cat,
                              style: GoogleFonts.manrope(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : const Color(0xff8D7B7B),
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: const Color(0xff7F4F4F),
                            backgroundColor: const Color(0xffFFF9F7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            showCheckmark: false,
                            onSelected: (_) {
                              setModalState(() {
                                tempCategory = isSelected ? null : cat;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Max Price",
                            style: GoogleFonts.manrope(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xff2D2323),
                            ),
                          ),
                          Text(
                            "Rs ${tempPrice.toInt()}",
                            style: GoogleFonts.manrope(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xff7F4F4F),
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: tempPrice,
                        min: 0,
                        max: 9999,
                        divisions: 100,
                        activeColor: const Color(0xff7F4F4F),
                        inactiveColor: const Color(0xffFFF9F7),
                        onChanged: (val) {
                          setModalState(() {
                            tempPrice = val;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Sort By",
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xff2D2323),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: tempSort,
                        dropdownColor: Colors.white,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: "featured", child: Text("Featured")),
                          DropdownMenuItem(value: "low", child: Text("Price Low - High")),
                          DropdownMenuItem(value: "high", child: Text("Price High - Low")),
                          DropdownMenuItem(value: "rating", child: Text("Highest Rated")),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() {
                              tempSort = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  _globalSelectedCategory = null;
                                  _globalMaxPrice = 9999;
                                  _globalSortBy = "featured";
                                  _globalSearchQuery.value = "";
                                  searchController.clear();
                                });
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Reset",
                                style: GoogleFonts.manrope(
                                  color: const Color(0xff7F4F4F),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff7F4F4F),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  _globalSelectedCategory = tempCategory;
                                  _globalMaxPrice = tempPrice;
                                  _globalSortBy = tempSort;
                                });
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Apply",
                                style: GoogleFonts.manrope(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

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
            size: 20,
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              goToTab(0);
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

          List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

          // Extract unique active categories for filter sheet
          List<String> categories = docs
              .map((doc) => (doc.data() as Map<String, dynamic>)["category"]?.toString() ?? "")
              .where((cat) => cat.isNotEmpty)
              .toSet()
              .toList();

          // Apply Category Filter
          if (_globalSelectedCategory != null) {
            docs = docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data["category"] == _globalSelectedCategory;
            }).toList();
          }

          // Apply Price Filter
          docs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final price = (data["price"] as num?)?.toDouble() ?? 0;
            return price <= _globalMaxPrice;
          }).toList();

          // Apply Search Query via ValueListenable
          return ValueListenableBuilder<String>(
            valueListenable: _globalSearchQuery,
            builder: (context, searchQuery, _) {
              List<QueryDocumentSnapshot> filteredDocs = docs;
              if (searchQuery.trim().isNotEmpty) {
                final query = searchQuery.trim().toLowerCase();
                filteredDocs = docs.where((doc) {
                  final name = ((doc.data() as Map<String, dynamic>)["name"] ?? "").toString().toLowerCase();
                  return name.contains(query);
                }).toList();
              }

              // Apply Sorting
              if (_globalSortBy == "low") {
                filteredDocs.sort((a, b) {
                  final aP = ((a.data() as Map<String, dynamic>)["price"] as num?)?.toDouble() ?? 0;
                  final bP = ((b.data() as Map<String, dynamic>)["price"] as num?)?.toDouble() ?? 0;
                  return aP.compareTo(bP);
                });
              } else if (_globalSortBy == "high") {
                filteredDocs.sort((a, b) {
                  final aP = ((a.data() as Map<String, dynamic>)["price"] as num?)?.toDouble() ?? 0;
                  final bP = ((b.data() as Map<String, dynamic>)["price"] as num?)?.toDouble() ?? 0;
                  return bP.compareTo(aP);
                });
              } else if (_globalSortBy == "rating") {
                filteredDocs.sort((a, b) {
                  final aR = ((a.data() as Map<String, dynamic>)["rating"] as num?)?.toDouble() ?? 0;
                  final bR = ((b.data() as Map<String, dynamic>)["rating"] as num?)?.toDouble() ?? 0;
                  return bR.compareTo(aR);
                });
              }

              // Dynamic Filter Subtitle Banner Text Construction
              bool isFilterActive = (_globalSelectedCategory != null) || (_globalMaxPrice < 9999);
              String filterSubtitle = "";
              if (isFilterActive) {
                if (_globalSelectedCategory != null) {
                  filterSubtitle = "$_globalSelectedCategory Under Rs ${_globalMaxPrice.toInt()}";
                } else {
                  filterSubtitle = "Products Under Rs ${_globalMaxPrice.toInt()}";
                }
              }

              return Padding(
                padding: EdgeInsets.fromLTRB(width * 0.04, 8, width * 0.04, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Clean Single Border Search Bar with persistent FocusNode (No keyboard dismiss on typing)
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black.withOpacity(0.12), width: 0.8),
                      ),
                      child: TextField(
                        controller: searchController,
                        focusNode: searchFocus,
                        onChanged: (val) {
                          _globalSearchQuery.value = val;
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xff7F4F4F), size: 21),
                          hintText: "Search Product",
                          hintStyle: GoogleFonts.manrope(color: const Color(0xff8D7B7B), fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 46,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.black.withOpacity(0.12), width: 0.8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(13),
                                    onTap: () => setState(() => isGrid = true),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isGrid ? const Color(0xff7F4F4F) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(13),
                                      ),
                                      child: Icon(Icons.grid_view_rounded,
                                          color: isGrid ? Colors.white : const Color(0xff8D7B7B), size: 20),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(13),
                                    onTap: () => setState(() => isGrid = false),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: !isGrid ? const Color(0xff7F4F4F) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(13),
                                      ),
                                      child: Icon(Icons.view_list_rounded,
                                          color: !isGrid ? Colors.white : const Color(0xff8D7B7B), size: 20),
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
                            onTap: () => _openFilterBottomSheet(categories),
                            child: const SizedBox(
                              width: 46,
                              height: 46,
                              child: Icon(Icons.tune_rounded, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // Subtle Dynamic Filter Subtitle Banner
                    if (isFilterActive) ...[
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          filterSubtitle,
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff7F4F4F),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),
                    Expanded(
                      child: filteredDocs.isEmpty
                          ? Center(
                              child: Text(
                                "No products found",
                                style: GoogleFonts.manrope(color: const Color(0xff8D7B7B)),
                              ),
                            )
                          : AnimatedCrossFade(
                              duration: const Duration(milliseconds: 280),
                              crossFadeState: isGrid ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                              firstChild: GridView.builder(
                                itemCount: filteredDocs.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.83, // Made slightly more compact vertically
                                ),
                                itemBuilder: (context, index) {
                                  final product = ProductModel.fromFirestore(
                                    filteredDocs[index].id,
                                    filteredDocs[index].data() as Map<String, dynamic>,
                                  );
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ProductDetailsScreen(product: product),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(22),
                                        border: Border.all(color: Colors.black.withOpacity(0.12), width: 0.8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Stack(
                                              children: [
                                                Container(
                                                  width: double.infinity,
                                                  decoration: const BoxDecoration(
                                                    color: Color(0xffFFF9F7),
                                                    borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                                                    child: Image.network(
                                                      product.image,
                                                      fit: BoxFit.contain,
                                                      width: double.infinity,
                                                      errorBuilder: (_, __, ___) => const Center(
                                                        child: Icon(Icons.image_not_supported_outlined, size: 36, color: Color(0xff8D7B7B)),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                if (product.discount > 0)
                                                  Positioned(
                                                    top: 8,
                                                    left: 8,
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: Colors.redAccent,
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Text(
                                                        "${product.discount}% OFF",
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.bold,
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
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  product.name,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: GoogleFonts.manrope(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 13,
                                                    color: const Color(0xff2D2323),
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                                                        const SizedBox(width: 2),
                                                        Text(
                                                          product.rating.toStringAsFixed(1),
                                                          style: GoogleFonts.manrope(
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.w600,
                                                            color: const Color(0xff8D7B7B),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Text(
                                                      "Rs ${product.price.toStringAsFixed(0)}",
                                                      style: GoogleFonts.manrope(
                                                        color: const Color(0xff7F4F4F),
                                                        fontWeight: FontWeight.w800,
                                                        fontSize: 14,
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
                              ),
                              secondChild: ListView.builder(
                                itemCount: filteredDocs.length,
                                itemBuilder: (context, index) {
                                  final product = ProductModel.fromFirestore(
                                    filteredDocs[index].id,
                                    filteredDocs[index].data() as Map<String, dynamic>,
                                  );
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(color: Colors.black.withOpacity(0.12), width: 0.8),
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ProductDetailsScreen(product: product),
                                          ),
                                        );
                                      },
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          width: 55,
                                          height: 55,
                                          color: const Color(0xffFFF9F7),
                                          child: Image.network(product.image, fit: BoxFit.contain),
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
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      // Perfectly aligned list view trailing layout: Discount badge on top, Rating on bottom
                                      trailing: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          if (product.discount > 0)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: Colors.redAccent,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                "${product.discount}% OFF",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 9.5,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          if (product.discount > 0) const SizedBox(height: 6),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                                              const SizedBox(width: 2),
                                              Text(
                                                product.rating.toStringAsFixed(1),
                                                style: GoogleFonts.manrope(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  color: const Color(0xff2D2323),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
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