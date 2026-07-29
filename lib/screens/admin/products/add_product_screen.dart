import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/category_model.dart';
import '../../../models/product_model.dart';
import '../../../services/category_service.dart';
import '../../../services/product_service.dart';
import '../../../services/storage_service.dart';
import '../../../utils/app_notifier.dart';
import '../../../widgets/admin/admin_button.dart';
import '../../../widgets/admin/admin_text_field.dart';
import '../../../widgets/admin/image_picker_box.dart';
import '../../../widgets/admin/image_source_bottom_sheet.dart';
import '../../../widgets/admin/responsive.dart';

class AddProductScreen extends StatefulWidget {
  final ProductModel? product;
  const AddProductScreen({super.key, this.product});

  bool get isEditing => product != null;

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController oldPriceController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController ratingController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();

  // Pickers & Services
  final ImagePicker picker = ImagePicker();
  final ProductService _productService = ProductService();
  final StorageService _storageService = StorageService.instance;
  final CategoryService _categoryService = CategoryService();

  // State Variables
  bool showGalleryPicker = true;
  bool showUrlField = true;
  String? selectedCategory;
  List<File> images = [];
  List<String> imageUrls = [];
  bool featured = false;
  bool inStock = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product == null) return;
    final product = widget.product!;
    nameController.text = product.name;
    selectedCategory = product.category;
    descriptionController.text = product.description;
    priceController.text = product.price.toString();
    oldPriceController.text = product.oldPrice.toString();
    discountController.text = product.discount.toString();
    ratingController.text = product.rating.toString();
    featured = product.featured;
    inStock = product.inStock;
    imageUrls = List<String>.from(product.images);
    if (imageUrls.isNotEmpty) {
      showGalleryPicker = false;
      showUrlField = true;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    oldPriceController.dispose();
    discountController.dispose();
    ratingController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  Future<void> openImageSourceSheet() async {
    final source = await showModalBottomSheet<ImageSourceType>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const ImageSourceBottomSheet(),
    );
    if (source == null) return;
    switch (source) {
      case ImageSourceType.gallery:
        pickImages();
        break;
      case ImageSourceType.url:
        break;
    }
  }

  Future<void> pickImages() async {
    final picked = await picker.pickMultiImage();
    if (picked.isEmpty) return;
    setState(() {
      images.addAll(picked.map((image) => File(image.path)));
      showUrlField = false;
    });
  }

  Future<void> saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (images.isEmpty && imageUrls.isEmpty) {
      AppNotifier.info(
        context,
        "Please add at least one product image.",
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      List<String> finalImageUrls = [];
      if (images.isNotEmpty) {
        finalImageUrls = await _storageService.uploadProductImages(
          images: images,
        );
      } else {
        finalImageUrls = imageUrls;
      }

      final productId = widget.isEditing
          ? widget.product!.id
          : await _productService.generateProductId();

      final product = ProductModel(
        id: productId,
        name: nameController.text.trim(),
        images: finalImageUrls,
        price: double.tryParse(priceController.text) ?? 0,
        oldPrice: double.tryParse(oldPriceController.text) ?? 0,
        rating: double.tryParse(ratingController.text) ?? 0,
        category: selectedCategory!,
        description: descriptionController.text.trim(),
        featured: featured,
        discount: int.tryParse(discountController.text) ?? 0,
        inStock: inStock,
      );

      if (widget.isEditing) {
        await _productService.updateProduct(product);
        if (!mounted) return;
        AppNotifier.success(
          context,
          "Product updated successfully.",
        );
      } else {
        await _productService.addProduct(product);
        if (!mounted) return;
        AppNotifier.success(
          context,
          "Product added successfully.",
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        AppNotifier.error(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF9F7), // Warm luxury canvas
      appBar: AppBar(
        backgroundColor: const Color(0xffFFF9F7),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text(
          widget.isEditing ? "Edit Product" : "New Product",
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w700,
            fontSize: Responsive.titleSize(context),
            color: const Color(0xff2D2323),
            letterSpacing: -0.5,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xff2D2323)),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.horizontalPadding(context),
              vertical: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SECTION 1: MEDIA CARD
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.015),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Product Media",
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xff2D2323),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isMobile = constraints.maxWidth < 700;
                          return isMobile
                              ? Column(
                                  children: [
                                    if (showGalleryPicker) buildGallerySection(),
                                    if (showGalleryPicker && showUrlField)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        child: Text(
                                          "OR",
                                          style: GoogleFonts.manrope(
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xff8D7B7B),
                                            fontSize: 12,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                      ),
                                    if (showUrlField) buildUrlSection(),
                                  ],
                                )
                              : Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (showGalleryPicker)
                                      Expanded(child: buildGallerySection()),
                                    if (showGalleryPicker && showUrlField)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 24),
                                        child: Center(
                                          child: Text(
                                            "OR",
                                            style: GoogleFonts.manrope(
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xff8D7B7B),
                                              fontSize: 12,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (showUrlField)
                                      Expanded(child: buildUrlSection()),
                                  ],
                                );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // SECTION 2: GENERAL INFORMATION CARD
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.015),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "General Information",
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xff2D2323),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AdminTextField(
                        controller: nameController,
                        hintText: "Product Name",
                        prefixIcon: Icons.shopping_bag_outlined,
                      ),
                      const SizedBox(height: 16),
                      AdminTextField(
                        controller: descriptionController,
                        hintText: "Detailed Description",
                        prefixIcon: Icons.description_outlined,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 16),
                      StreamBuilder<List<CategoryModel>>(
                        stream: _categoryService.getCategories(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xff7F4F4F)),
                              ),
                            );
                          }
                          final categories = snapshot.data!;
                          return DropdownButtonFormField<String>(
                            value: selectedCategory,
                            dropdownColor: Colors.white,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xff7F4F4F), size: 20),
                            decoration: InputDecoration(
                              labelText: "Category",
                              labelStyle: GoogleFonts.manrope(color: const Color(0xff8D7B7B), fontSize: 14),
                              filled: true,
                              fillColor: const Color(0xffFFF9F7),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: Color(0xff7F4F4F), width: 1.5),
                              ),
                            ),
                            items: categories
                                .map(
                                  (category) => DropdownMenuItem(
                                    value: category.name,
                                    child: Text(
                                      category.name,
                                      style: GoogleFonts.manrope(
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xff2D2323),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedCategory = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return "Please select a category";
                              }
                              return null;
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // SECTION 3: PRICING & INVENTORY CARD
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.015),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Pricing & Metrics",
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xff2D2323),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AdminTextField(
                              controller: priceController,
                              hintText: "Price",
                              prefixIcon: Icons.payments_outlined,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AdminTextField(
                              controller: oldPriceController,
                              hintText: "Old Price",
                              prefixIcon: Icons.sell_outlined,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AdminTextField(
                              controller: discountController,
                              hintText: "Discount %",
                              prefixIcon: Icons.local_offer_outlined,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AdminTextField(
                              controller: ratingController,
                              hintText: "Rating",
                              prefixIcon: Icons.star_outline,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(height: 1, color: Color(0xffF3F4F6)),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        value: featured,
                        activeColor: const Color(0xff7F4F4F),
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          "Featured Product",
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: const Color(0xff2D2323),
                          ),
                        ),
                        subtitle: Text(
                          "Highlight this item on the storefront",
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: const Color(0xff8D7B7B),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            featured = value;
                          });
                        },
                      ),
                      SwitchListTile(
                        value: inStock,
                        activeColor: const Color(0xff7F4F4F),
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          "In Stock Status",
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: const Color(0xff2D2323),
                          ),
                        ),
                        subtitle: Text(
                          "Toggle inventory availability",
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: const Color(0xff8D7B7B),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            inStock = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // SUBMIT ACTION BUTTON (Signature Brand Tone: 0xff7F4F4F)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff7F4F4F),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: isLoading ? null : saveProduct,
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            widget.isEditing ? "Update Product" : "Save Product",
                            style: GoogleFonts.manrope(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildGallerySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: images.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              if (index == images.length) {
                return ImagePickerBox(
                  image: null,
                  onTap: pickImages,
                );
              }
              return ImagePickerBox(
                image: images[index],
                onTap: () {},
                onRemove: () {
                  setState(() {
                    images.removeAt(index);
                    if (images.isEmpty && imageUrls.isEmpty) {
                      showUrlField = true;
                    }
                  });
                },
              );
            },
          ),
        ),
        if (!showUrlField)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                setState(() {
                  showGalleryPicker = false;
                  showUrlField = true;
                });
              },
              child: Text(
                "Switch to URL",
                style: GoogleFonts.manrope(
                  color: const Color(0xff7F4F4F),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget buildUrlSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminTextField(
          controller: imageUrlController,
          hintText: imageUrls.isEmpty ? "Paste Image URL" : "Add More URL",
          prefixIcon: Icons.link,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xff7F4F4F),
              side: const BorderSide(color: Color(0xff7F4F4F), width: 1.2),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final url = imageUrlController.text.trim();
              if (url.isEmpty) {
                AppNotifier.info(context, "Please enter an image URL.");
                return;
              }
              final uri = Uri.tryParse(url);
              if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
                AppNotifier.info(context, "Please enter a valid URL.");
                return;
              }
              if (imageUrls.contains(url)) {
                AppNotifier.info(context, "This image has already been added.");
                return;
              }
              setState(() {
                imageUrls.add(url);
              });
              showGalleryPicker = false;
              imageUrlController.clear();
              AppNotifier.success(context, "URL added successfully.");
            },
            child: Text(
              "Add URL",
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        buildUrlPreviewList(),
        if (!showGalleryPicker)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                setState(() {
                  showGalleryPicker = true;
                  showUrlField = false;
                });
              },
              child: Text(
                "Switch to Gallery",
                style: GoogleFonts.manrope(
                  color: const Color(0xff7F4F4F),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget buildUrlPreviewList() {
    if (imageUrls.isEmpty) return const SizedBox();
    return Column(
      children: [
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: imageUrls.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrls[index],
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 120,
                        height: 120,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xffFFF9F7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.broken_image_outlined,
                          size: 32,
                          color: Color(0xff8D7B7B),
                        ),
                      ),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          width: 120,
                          height: 120,
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(strokeWidth: 2, color: Color(0xff7F4F4F)),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          imageUrls.removeAt(index);
                          if (imageUrls.isEmpty) {
                            showGalleryPicker = true;
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xff7F4F4F),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}