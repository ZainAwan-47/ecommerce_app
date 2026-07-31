import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/product_model.dart';
import '../../services/firestore_service.dart';
import '../product/product_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String query = "";
  List<ProductModel> suggestions = [];
  List<String> recentSearches = [];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    recentSearches = prefs.getStringList("recent_searches") ?? [];
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _saveSearch(String search) async {
    if (search.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    recentSearches.remove(search);
    recentSearches.insert(0, search);
    if (recentSearches.length > 5) {
      recentSearches.removeLast();
    }
    await prefs.setStringList("recent_searches", recentSearches);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("recent_searches");
    recentSearches.clear();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF9F7),
      appBar: AppBar(
        backgroundColor: const Color(0xffFFF9F7),
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
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
            autofocus: true,
            onChanged: (value) {
              setState(() {
                query = value.trim().toLowerCase();
              });
            },
            decoration: InputDecoration(
              hintText: "Search Product",
              hintStyle: GoogleFonts.manrope(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              prefixIcon: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xff3A2B2B),
                  size: 18,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      color: const Color(0xff8D7B7B),
                      onPressed: () {
                        setState(() {
                          query = "";
                        });
                      },
                    )
                  : const Icon(
                      Icons.search_rounded,
                      color: Color(0xff7F4F4F),
                      size: 20,
                    ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<ProductModel>>(
        stream: _firestoreService.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xff7F4F4F),
              ),
            );
          }
          if (!snapshot.hasData) {
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

          final products = snapshot.data!;
          
          suggestions = products.where((product) {
            return query.isNotEmpty &&
                product.name.toLowerCase().contains(query);
          }).take(6).toList();

          final filtered = products.where((product) {
            return product.name.toLowerCase().contains(query) ||
                product.category.toLowerCase().contains(query) ||
                product.description.toLowerCase().contains(query);
          }).toList();

          final featuredProducts = products
              .where((p) => p.featured)
              .take(3)
              .toList();

          // STATE 1: Query is empty -> Show Discover / Recent Searches / Trending
          if (query.isEmpty) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Center(
                    child: Icon(
                      Icons.search_rounded,
                      size: 70,
                      color: const Color(0xff7F4F4F).withOpacity(0.2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      "Discover Trending Products",
                      style: GoogleFonts.manrope(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff2D2323),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      "Search Perfume, Shampoo, FaceWash and More",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        color: const Color(0xff8D7B7B),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  
                  if (recentSearches.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Recent Searches",
                          style: GoogleFonts.manrope(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xff2D2323),
                          ),
                        ),
                        TextButton(
                          onPressed: _clearRecentSearches,
                          child: Text(
                            "Clear All",
                            style: GoogleFonts.manrope(
                              color: const Color(0xff7F4F4F),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...recentSearches.map(
                      (search) => Card(
                        elevation: 0,
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Colors.black.withOpacity(0.08),
                            width: 0.8,
                          ),
                        ),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          leading: const Icon(
                            Icons.history_rounded,
                            color: Color(0xff7F4F4F),
                            size: 20,
                          ),
                          title: Text(
                            search,
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xff2D2323),
                            ),
                          ),
                          trailing: const Icon(
                            Icons.manage_search_rounded,
                            color: Color(0xff8D7B7B),
                            size: 18,
                          ),
                          onTap: () {
                            setState(() {
                              query = search.toLowerCase();
                            });
                          },
                        ),
                      ),
                    ),
                  ],

                  if (featuredProducts.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    Text(
                      "Trending Items",
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff2D2323),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 195,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: featuredProducts.length,
                        itemBuilder: (context, index) {
                          final product = featuredProducts[index];
                          return GestureDetector(
                            onTap: () async {
                              await _saveSearch(product.name);
                              if (!mounted) return;
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
                              width: 140,
                              margin: const EdgeInsets.only(right: 14),
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
                                    color: const Color(0xff7F4F4F)
                                        .withOpacity(0.04),
                                    blurRadius: 14,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Container(
                                        color: const Color(0xffFFF9F7),
                                        width: double.infinity,
                                        child: Image.network(
                                          product.image,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    product.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.manrope(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12.5,
                                      color: const Color(0xff2D2323),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Rs ${product.price.toStringAsFixed(0)}",
                                    style: GoogleFonts.manrope(
                                      color: const Color(0xff7F4F4F),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          // STATE 2: No results found for query
          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 70,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No Results Found",
                    style: GoogleFonts.manrope(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff2D2323),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Try searching with another keyword.",
                    style: GoogleFonts.manrope(
                      color: const Color(0xff8D7B7B),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          }

          // STATE 3: Display filtered products search list
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final product = filtered[index];
              return GestureDetector(
                onTap: () async {
                  await _saveSearch(product.name);
                  if (!mounted) return;
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
                            product.image,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
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
                              product.category,
                              style: GoogleFonts.manrope(
                                color: const Color(0xff8D7B7B),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Rs ${product.price.toStringAsFixed(0)}",
                                  style: GoogleFonts.manrope(
                                    color: const Color(0xff7F4F4F),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: Colors.amber,
                                      size: 15,
                                    ),
                                    const SizedBox(width: 3),
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