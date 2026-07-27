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
import '../../../utils/app_notifier.dart';
import '../../../models/category_model.dart';
import '../../../services/category_service.dart';

class AddProductScreen extends StatefulWidget {
  final ProductModel? product;

  const AddProductScreen({
    super.key,
    this.product,
  });

  bool get isEditing => product != null;

  @override
  State<AddProductScreen> createState() =>
      _AddProductScreenState();
}

class _AddProductScreenState
    extends State<AddProductScreen> {
        bool showGalleryPicker = true;
bool showUrlField = true;
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

         final TextEditingController imageUrlController =
    TextEditingController();

  final ImagePicker picker = ImagePicker();

  final ProductService _productService =
    ProductService();

final StorageService _storageService =
    StorageService.instance;

    final CategoryService _categoryService =
    CategoryService();

String? selectedCategory;

  List<File> images = [];
  List<String> imageUrls = [];
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
    imageUrlController.dispose();
    super.dispose();
  }
@override
void initState() {
  super.initState();

  if (widget.product == null) return;

  final product = widget.product!;

  nameController.text = product.name;
  selectedCategory = product.category;
  descriptionController.text = product.description;
  categoryController.text = product.category;
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF9F7),

      appBar: AppBar(
        backgroundColor: const Color(0xffFFF9F7),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
       title: Text(
  widget.isEditing
      ? "Edit Product"
      : "Add Product",
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
LayoutBuilder(
  builder: (context, constraints) {
    final isMobile = constraints.maxWidth < 700;

    return isMobile
        ? Column(
            children: [
              // Gallery
            if (showGalleryPicker)
  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

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
            child: const Text("Switch to URL"),
          ),
        ),
    ],
  ),
              if (showGalleryPicker && showUrlField)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text("OR"),
                ),

              // URL
             if (showUrlField)
  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

     AdminTextField(
  controller: imageUrlController,
  hintText: imageUrls.isEmpty
      ? "Paste Image URL"
      : "Add More URL",
  prefixIcon: Icons.link,
),

      const SizedBox(height: 12),

      SizedBox(
        width: double.infinity,
        child: AdminButton(
          text: "Add URL",
         onPressed: () {
  final url = imageUrlController.text.trim();

  // Empty
  if (url.isEmpty) {
    AppNotifier.info(
      context,
      "Please enter an image URL.",
    );
    return;
  }

  // Valid URL
  final uri = Uri.tryParse(url);

  if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
    AppNotifier.info(
      context,
      "Please enter a valid URL.",
    );
    return;
  }

  // Duplicate
  if (imageUrls.contains(url)) {
    AppNotifier.info(
      context,
      "This image has already been added.",
    );
    return;
  }

  setState(() {
    imageUrls.add(url);
print(imageUrls);
    showGalleryPicker = false;

    imageUrlController.clear();
  });

  AppNotifier.success(
    context,
    "URL added successfully.",
  );
},
        ),
      ),

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
            child: const Text("Switch to Gallery"),
          ),
        ),
        buildUrlPreviewList(),
    ],
  ),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showGalleryPicker)
                Expanded(
                  child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [

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
              onTap: pickImages,
            );
          }

          return ImagePickerBox(
            image: images[index],
            onTap: () {},
            onRemove: () {
              setState(() {
                images.removeAt(index);

                if (images.isEmpty) {
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
          child: const Text("Switch to URL"),
        ),
      ),
  ],
),
                ),

              if (showGalleryPicker && showUrlField)
                const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 18),
                  child: Text("OR"),
                ),

              if (showUrlField)
                Expanded(
                  child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [

    AdminTextField(
      controller: imageUrlController,
      hintText: "Paste Image URL",
      prefixIcon: Icons.link,
    ),

    const SizedBox(height: 12),

    SizedBox(
      width: double.infinity,
      child: AdminButton(
        text: "Add URL",
        onPressed: () {
          final url = imageUrlController.text.trim();

          if (url.isEmpty) return;

          setState(() {
            imageUrls.add(url);

            showGalleryPicker = false;

            imageUrlController.clear();
          });
        },
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
          child: const Text("Switch to Gallery"),
        ),
      ),
  ],
),
                ),
            ],
          );
  },
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

             StreamBuilder<List<CategoryModel>>(
  stream: _categoryService.getCategories(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final categories = snapshot.data!;

    return DropdownButtonFormField<String>(
      value: selectedCategory,
      decoration: const InputDecoration(
        labelText: "Category",
        border: OutlineInputBorder(),
      ),
      items: categories
          .map(
            (category) => DropdownMenuItem(
              value: category.name,
              child: Text(category.name),
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
  text: widget.isEditing
      ? "Update Product"
      : "Save Product",
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
       showUrlField = false;
    });
  }
  Widget buildUrlPreviewList() {
  if (imageUrls.isEmpty) return const SizedBox();

  return Column(
    children: [
      const SizedBox(height: 16),

      SizedBox(
        height: 120,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: imageUrls.length,
          separatorBuilder: (_, __) =>
              const SizedBox(width: 12),

          itemBuilder: (context, index) {
            return Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(12),
                  child: Image.network(
                    imageUrls[index],
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,

                    errorBuilder:
                        (_, __, ___) => Container(
                      width: 120,
                      height: 120,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.broken_image_outlined,
                        size: 40,
                      ),
                    ),

                    loadingBuilder:
                        (context, child, progress) {
                      if (progress == null) return child;

                      return Container(
                        width: 120,
                        height: 120,
                        alignment: Alignment.center,
                        child:
                            const CircularProgressIndicator(),
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
                    child: const CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.red,
                      child: Icon(
                        Icons.close,
                        size: 15,
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
  finalImageUrls =
      await _storageService.uploadProductImages(
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
      price:
          double.tryParse(priceController.text) ??
              0,
      oldPrice: double.tryParse(
              oldPriceController.text) ??
          0,
      rating: double.tryParse(
              ratingController.text) ??
          0,
     category: selectedCategory!,
      description:
          descriptionController.text.trim(),
      featured: featured,
      discount:
          int.tryParse(discountController.text) ??
              0,
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

}
    if (!mounted) return;

   AppNotifier.success(
  context,
  "Product added successfully.",
);

    Navigator.pop(context);
  } catch (e) {
   AppNotifier.error(
  context,
  e.toString(),
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