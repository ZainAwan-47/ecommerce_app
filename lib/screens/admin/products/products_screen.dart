import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/product_model.dart';
import '../../../services/product_service.dart';
import '../../../utils/app_notifier.dart';
import '../../../widgets/admin/admin_card.dart';
import '../../../widgets/admin/responsive.dart';
import 'add_product_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();

  // Pagination State
  int _currentPage = 0;
  static const int _itemsPerPage = 10;

  static const Color _primaryColor = Color(0xff7F4F4F);
  static const Color _backgroundColor = Color(0xffFFF9F7);
  static const Color _textColor = Color(0xff2D2323);
  static const Color _subtextColor = Color(0xff8D7B7B);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: Responsive.horizontalPadding(context),
        title: Text(
          "Products Catalog",
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w800,
            fontSize: Responsive.titleSize(context),
            color: _textColor,
            letterSpacing: -0.5,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        elevation: 4,
        highlightElevation: 6,
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddProductScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded, size: 22),
        label: Text(
          "Add Product",
          style: GoogleFonts.manrope(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: 0.2,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.horizontalPadding(context),
            vertical: Responsive.verticalPadding(context),
          ),
          child: Column(
            children: [
              // Elite Search Field
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryColor.withOpacity(0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _textColor,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: _subtextColor,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear_rounded,
                              size: 18,
                              color: _subtextColor,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _currentPage = 0;
                              });
                            },
                          )
                        : null,
                    hintText: "Search elite products...",
                    hintStyle: GoogleFonts.manrope(
                      color: _subtextColor,
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: _primaryColor.withOpacity(0.12),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: _primaryColor,
                        width: 1.5,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _currentPage = 0;
                    });
                  },
                ),
              ),
              const SizedBox(height: 18),

              // Product Stream & Tile View
              Expanded(
                child: StreamBuilder<List<ProductModel>>(
                  stream: _productService.getProducts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: _primaryColor,
                          strokeWidth: 2.5,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return _buildErrorState(
                        message: "Failed to load products: ${snapshot.error}",
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildEmptyState(
                        title: "No products found",
                        subtitle: "Tap the button below to add your first product.",
                      );
                    }

                    List<ProductModel> products = snapshot.data!;

                    if (_searchController.text.isNotEmpty) {
                      final query = _searchController.text.toLowerCase().trim();
                      products = products
                          .where((p) =>
                              p.name.toLowerCase().contains(query) ||
                              p.category.toLowerCase().contains(query))
                          .toList();
                    }

                    if (products.isEmpty) {
                      return _buildEmptyState(
                        title: "No matching products",
                        subtitle: 'No results found for "${_searchController.text}".',
                      );
                    }

                    final totalPages = (products.length / _itemsPerPage).ceil();
                    if (_currentPage >= totalPages) {
                      _currentPage = (totalPages > 0) ? totalPages - 1 : 0;
                    }

                    final startIndex = _currentPage * _itemsPerPage;
                    final endIndex = (startIndex + _itemsPerPage < products.length)
                        ? startIndex + _itemsPerPage
                        : products.length;
                    final currentPageProducts = products.sublist(startIndex, endIndex);

                    return Column(
                      children: [
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.only(bottom: 90, top: 4),
                            physics: const BouncingScrollPhysics(),
                            itemCount: currentPageProducts.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final product = currentPageProducts[index];
                              return _buildEliteTileItem(product);
                            },
                          ),
                        ),
                        if (totalPages > 1) ...[
                          const SizedBox(height: 8),
                          _buildPaginationControls(totalPages),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEliteTileItem(ProductModel product) {
    return AdminCard(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Product Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 78,
                height: 78,
                color: _primaryColor.withOpacity(0.05),
                child: Image.network(
                  product.image,
                  width: 78,
                  height: 78,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: _primaryColor.withOpacity(0.35),
                        size: 26,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Product Information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: _textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: _subtextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "PKR ${product.price.toStringAsFixed(0)}",
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: _primaryColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (product.featured)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100, // Light greyish background
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            "Featured",
                            style: GoogleFonts.manrope(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _textColor,
                            ),
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100, // Light greyish background instead of green/red
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1.2,
                          ),
                        ),
                        child: Text(
                          product.inStock ? "In Stock" : "Out of Stock",
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Action Buttons Column
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddProductScreen(product: product),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      color: _primaryColor,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _showDeleteDialog(product),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.redAccent,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationControls(int totalPages) {
    return Align(
      alignment: Alignment.centerLeft, // Moved to total left
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _primaryColor.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: _primaryColor.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
              icon: const Icon(Icons.chevron_left_rounded, size: 24),
              color: _primaryColor,
              disabledColor: Colors.grey.shade300,
              tooltip: "Previous Page",
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "Page ${_currentPage + 1} of $totalPages",
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _textColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: _currentPage < totalPages - 1 ? () => setState(() => _currentPage++) : null,
              icon: const Icon(Icons.chevron_right_rounded, size: 24),
              color: _primaryColor,
              disabledColor: Colors.grey.shade300,
              tooltip: "Next Page",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({required String title, required String subtitle}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 38,
                color: _primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: _subtextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState({required String message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 38,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Something went wrong",
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: _subtextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(ProductModel product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.redAccent,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              "Delete Product",
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: _textColor,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${product.name}"? This action cannot be undone.',
          style: GoogleFonts.manrope(
            fontSize: 14,
            color: const Color(0xff5D4E4E),
          ),
        ),
        actionsPadding: const EdgeInsets.only(right: 16, bottom: 16, left: 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "Cancel",
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w600,
                color: _subtextColor,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              "Delete",
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _productService.deleteProduct(product.id);
        if (!mounted) return;
        AppNotifier.success(context, "Product deleted successfully.");
      } catch (e) {
        if (!mounted) return;
        AppNotifier.error(context, "Failed to delete product: $e");
      }
    }
  }
}