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
  final FirestoreService _firestoreService =
      FirestoreService();

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

    recentSearches =
        prefs.getStringList("recent_searches") ?? [];

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

    await prefs.setStringList(
      "recent_searches",
      recentSearches,
    );

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
        automaticallyImplyLeading: false,

        title: Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: TextField(
            autofocus: true,

            onChanged: (value) {
  setState(() {
    query = value.trim().toLowerCase();
  });
},

            decoration: InputDecoration(
              hintText: "Search products...",
              hintStyle: GoogleFonts.manrope(
                color: Colors.grey.shade500,
              ),

              border: InputBorder.none,

              prefixIcon: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),

              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          query = "";
                        });
                      },
                    )
                  : const Icon(
                      Icons.search,
                      color: Color(0xff7F4F4F),
                    ),
            ),
          ),
        ),
      ),

      body: StreamBuilder<List<ProductModel>>(
        stream: _firestoreService.getProducts(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final products = snapshot.data!;
          suggestions = products.where((product) {
  return query.isNotEmpty &&
      product.name
          .toLowerCase()
          .contains(query);
}).take(6).toList();
          final filtered = products.where((product) {
            return product.name
                    .toLowerCase()
                    .contains(query) ||
                product.category
                    .toLowerCase()
                    .contains(query) ||
                product.description
                    .toLowerCase()
                    .contains(query);
          }).toList();

          final featuredProducts = products
              .where((p) => p.featured)
              .take(3)
              .toList();
                        if (query.isEmpty) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  Center(
                    child: Icon(
                      Icons.search_rounded,
                      size: 80,
                      color: Colors.grey.shade300,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: Text(
                      "Discover Beauty",
 style: GoogleFonts.dmSerifDisplay(                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Center(
                    child: Text(
                      "Search skincare, makeup,\nperfume and more.",
                      textAlign: TextAlign.center,
  style: GoogleFonts.manrope(                        color: Colors.grey,
                      ),
                    ),
                  ),

                  if (recentSearches.isNotEmpty) ...[
                    const SizedBox(height: 40),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Recent Searches",
 style: GoogleFonts.dmSerifDisplay(                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        TextButton(
                          onPressed: _clearRecentSearches,
                          child: const Text("Clear All"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    ...recentSearches.map(
                      (search) => Card(
                        elevation: 0,
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.history,
                            color: Color(0xff7F4F4F),
                          ),
                          title: Text(
                            search,
                            style: GoogleFonts.manrope(),
                          ),
                          trailing: const Icon(
                              Icons.manage_search_rounded,
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

                  const SizedBox(height: 35),

                  Text(
                    "Trending Products",
 style: GoogleFonts.dmSerifDisplay(                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    height: 190,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: featuredProducts.length,
                      itemBuilder: (context, index) {

                        final product =
                            featuredProducts[index];
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
                            width: 145,
                            margin: const EdgeInsets.only(right: 15),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(.05),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(14),
                                    child: Image.network(
                                      product.image,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  product.name,
                                  maxLines: 2,
                                  overflow:
                                      TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.manrope(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  "Rs ${product.price.toStringAsFixed(0)}",
  style: GoogleFonts.manrope(                                    color: const Color(0xff7F4F4F),
                                    fontWeight: FontWeight.bold,
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
              ),
            );
          }
          if (query.isNotEmpty && suggestions.isNotEmpty) {
  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: suggestions.length,
    itemBuilder: (context, index) {
      final product = suggestions[index];

      return ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 6,
        ),

        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            product.image,
            width: 55,
            height: 55,
            fit: BoxFit.contain,
          ),
        ),

       title: RichText(
  text: TextSpan(
  style: GoogleFonts.manrope(      color: Colors.black,
      fontSize: 15,
    ),
    children: [
      TextSpan(
        text: product.name.substring(
          0,
          product.name
              .toLowerCase()
              .indexOf(query),
        ),
      ),
      TextSpan(
        text: product.name.substring(
          product.name
              .toLowerCase()
              .indexOf(query),
          product.name
                  .toLowerCase()
                  .indexOf(query) +
              query.length,
        ),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xff7F4F4F),
        ),
      ),
      TextSpan(
        text: product.name.substring(
          product.name
                  .toLowerCase()
                  .indexOf(query) +
              query.length,
        ),
      ),
    ],
  ),
),

        subtitle: Text(
          product.category,
          style: GoogleFonts.manrope(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),

        trailing: const Icon(
  Icons.manage_search_rounded,
           color: Color(0xff7F4F4F),
        ),

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
      );
    },
  );
}
                    if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),

                  const SizedBox(height: 22),

                  Text(
                    "No Results Found",
 style: GoogleFonts.dmSerifDisplay(                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Try searching with another keyword.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(18),
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
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.05),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          product.image,
                          width: 80,
                          height: 80,
                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
 style: GoogleFonts.dmSerifDisplay(                                fontSize: 18,
                                fontWeight: FontWeight.bold,
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
                                  product.rating.toStringAsFixed(1),
                                  style: GoogleFonts.manrope(),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            Text(
                              "Rs ${product.price.toStringAsFixed(0)}",
                              style: GoogleFonts.manrope(
                                color: const Color(0xff7F4F4F),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Color(0xff7F4F4F),
                        size: 18,
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