import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/product_model.dart';
import '../../../services/product_service.dart';
import '../../../services/storage_service.dart';
import '../../../widgets/admin/admin_button.dart';
import '../../../widgets/admin/admin_text_field.dart';
import '../../../widgets/admin/image_picker_box.dart';
import '../../../widgets/admin/responsive.dart';
import '../../../widgets/admin/image_source_bottom_sheet.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});
  @override
  State<AddProductScreen> createState() =>
      _AddProductScreenState();
}

class _AddProductScreenState
    extends State<AddProductScreen> {
        Future<void> openImageSourceSheet() async {
  final source =
      await showModalBottomSheet<ImageSourceType>(
    context: context,
    builder: (_) =>
        const ImageSourceBottomSheet(),
  );

  if (source == null) return;

  switch (source) {
    case ImageSourceType.gallery:
      pickImages();
      break;

    case ImageSourceType.url:
      // We'll implement next
      break;
  }
}
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController descriptionController =
      TextEditingController();

  final TextEditingController categoryController =
      TextEditingController();

  final TextEditingController priceController =
      TextEditingController();

  final TextEditingController oldPriceController =
      TextEditingController();

  final TextEditingController discountController =
      TextEditingController();

  final TextEditingController ratingController =
      TextEditingController();

  final ImagePicker picker = ImagePicker();

  final ProductService _productService =
    ProductService();

final StorageService _storageService =
    StorageService.instance;

  List<File> images = [];

  bool featured = false;
  bool inStock = true;

  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    priceController.dispose();
    oldPriceController.dispose();
    discountController.dispose();
    ratingController.dispose();
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
          "Add Product",
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w700,
            fontSize:
                Responsive.titleSize(context),
          ),
        ),
      ),

      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(
            Responsive.horizontalPadding(context),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                "Product Images",
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length + 1,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    if (index == images.length) {
                      return ImagePickerBox(
                        image: null,
                      onTap: openImageSourceSheet,
                      );
                    }

                    return ImagePickerBox(
                      image: images[index],
                      onTap: () {},
                      onRemove: () {
                        setState(() {
                          images.removeAt(index);
                        });
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              AdminTextField(
                controller: nameController,
                hintText: "Product Name",
                prefixIcon: Icons.shopping_bag_outlined,
              ),

              const SizedBox(height: 16),

              AdminTextField(
                controller: descriptionController,
                hintText: "Description",
                prefixIcon: Icons.description_outlined,
                maxLines: 4,
              ),

              const SizedBox(height: 16),

              AdminTextField(
                controller: categoryController,
                hintText: "Category",
                prefixIcon: Icons.category_outlined,
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: AdminTextField(
                      controller: priceController,
                      hintText: "Price",
                      prefixIcon: Icons.payments_outlined,
                      keyboardType:
                          TextInputType.number,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: AdminTextField(
                      controller: oldPriceController,
                      hintText: "Old Price",
                      prefixIcon: Icons.sell_outlined,
                      keyboardType:
                          TextInputType.number,
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
                      prefixIcon:
                          Icons.local_offer_outlined,
                      keyboardType:
                          TextInputType.number,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: AdminTextField(
                      controller: ratingController,
                      hintText: "Rating",
                      prefixIcon: Icons.star_outline,
                      keyboardType:
                          TextInputType.number,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              SwitchListTile(
                value: featured,
                title: const Text("Featured Product"),
                onChanged: (value) {
                  setState(() {
                    featured = value;
                  });
                },
              ),

              SwitchListTile(
                value: inStock,
                title: const Text("In Stock"),
                onChanged: (value) {
                  setState(() {
                    inStock = value;
                  });
                },
              ),

              const SizedBox(height: 30),

              AdminButton(
                text: "Save Product",
                isLoading: isLoading,
             onPressed: saveProduct,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> pickImages() async {
    final picked =
        await picker.pickMultiImage();

    if (picked.isEmpty) return;

    setState(() {
      images.addAll(
        picked.map(
          (image) => File(image.path),
        ),
      );
    });
  }
  Future<void> saveProduct() async {
  if (!_formKey.currentState!.validate()) return;

  if (images.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Please select at least one image.",
        ),
      ),
    );
    return;
  }

  setState(() {
    isLoading = true;
  });

  try {
    final imageUrls =
        await _storageService.uploadProductImages(
      images: images,
    );

    final productId =
        await _productService.generateProductId();

    final product = ProductModel(
      id: productId,
      name: nameController.text.trim(),
      images: imageUrls,
      price:
          double.tryParse(priceController.text) ??
              0,
      oldPrice: double.tryParse(
              oldPriceController.text) ??
          0,
      rating: double.tryParse(
              ratingController.text) ??
          0,
      category:
          categoryController.text.trim(),
      description:
          descriptionController.text.trim(),
      featured: featured,
      discount:
          int.tryParse(discountController.text) ??
              0,
      inStock: inStock,
    );

    await _productService.addProduct(product);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text("Product added successfully."),
      ),
    );

    Navigator.pop(context);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString()),
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
}
}