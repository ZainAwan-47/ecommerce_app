import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/category_model.dart';
import '../../../services/category_service.dart';
import '../../../services/storage_service.dart';
import '../../../utils/app_notifier.dart';
import '../../../widgets/admin/admin_button.dart';
import '../../../widgets/admin/admin_text_field.dart';
import '../../../widgets/admin/category_icon_picker.dart';
import '../../../widgets/admin/image_picker_box.dart';
import '../../../widgets/admin/responsive.dart';

enum CategoryImageSource {
  gallery,
  url,
  icon,
}

class AddCategoryScreen extends StatefulWidget {
  final CategoryModel? category;

  const AddCategoryScreen({
    super.key,
    this.category,
  });

  bool get isEditing => category != null;

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _imageUrlController = TextEditingController();

  final CategoryService _categoryService = CategoryService();
  final StorageService _storageService = StorageService.instance;
  final ImagePicker _picker = ImagePicker();

  List<CategoryModel> _categories = [];
  String? _selectedCategoryId;

  File? _selectedImage;
  String? _imageUrl;
  String? _selectedIcon;
  CategoryImageSource _imageSource = CategoryImageSource.gallery;

  bool _featured = false;
  bool _isLoading = false;
  bool _allowRenaming = false; // Controls manual editing in Edit Mode

  @override
  void initState() {
    super.initState();
    _loadCategories();

    if (widget.isEditing && widget.category != null) {
      _loadCategory(widget.category!);
    }
  }

  void _loadCategory(CategoryModel category) {
    _selectedCategoryId = category.id;
    _nameController.text = category.name;
    _featured = category.featured;
    _allowRenaming = false; // Always lock manual rename by default on load

    // Reset unused state variables to prevent lingering data
    _selectedImage = null;
    _imageUrl = null;
    _selectedIcon = null;
    _imageUrlController.clear();

    switch (category.imageType) {
      case "gallery":
        _imageSource = CategoryImageSource.gallery;
        _imageUrl = category.image;
        break;
      case "icon":
        _imageSource = CategoryImageSource.icon;
        _selectedIcon = category.image;
        break;
      case "url":
      default:
        _imageSource = CategoryImageSource.url;
        _imageUrlController.text = category.image;
        _imageUrl = category.image;
        break;
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryService.getCategories().first;
      if (!mounted) return;
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      if (!mounted) return;
      AppNotifier.error(
        context,
        "Failed to load categories: ${e.toString()}",
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageUrlController.dispose();
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
          widget.isEditing ? "Edit Category" : "Add Category",
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w700,
            fontSize: Responsive.titleSize(context),
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 750),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.horizontalPadding(context),
                  vertical: 16,
                ).copyWith(
                  bottom: MediaQuery.of(context).padding.bottom + 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Category Image",
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      "Image Source",
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RadioListTile<CategoryImageSource>(
                      value: CategoryImageSource.gallery,
                      groupValue: _imageSource,
                      title: const Text("Gallery"),
                      onChanged: (value) {
                        setState(() {
                          _imageSource = value!;
                        });
                      },
                    ),
                    RadioListTile<CategoryImageSource>(
                      value: CategoryImageSource.url,
                      groupValue: _imageSource,
                      title: const Text("Image URL"),
                      onChanged: (value) {
                        setState(() {
                          _imageSource = value!;
                        });
                      },
                    ),
                    RadioListTile<CategoryImageSource>(
                      value: CategoryImageSource.icon,
                      groupValue: _imageSource,
                      title: const Text("Built-in Icon"),
                      onChanged: (value) {
                        setState(() {
                          _imageSource = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 18),
                    if (_imageSource == CategoryImageSource.gallery)
                      Center(
                        child: ImagePickerBox(
                          image: _selectedImage,
                          imageUrl: _imageUrl,
                          onTap: _pickImage,
                          onRemove: () {
                            setState(() {
                              _selectedImage = null;
                              _imageUrl = null;
                            });
                          },
                        ),
                      ),
                    if (_imageSource == CategoryImageSource.url)
                      Column(
                        children: [
                          AdminTextField(
                            controller: _imageUrlController,
                            hintText: "Paste Image URL",
                            prefixIcon: Icons.link,
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: 170,
                            height: 170,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: _imageUrlController.text.trim().isEmpty
                                  ? Container(
                                      color: Colors.grey.shade200,
                                      child: const Icon(Icons.image),
                                    )
                                  : Image.network(
                                      _imageUrlController.text.trim(),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.broken_image,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    if (_imageSource == CategoryImageSource.icon)
                      CategoryIconPicker(
                        selectedIcon: _selectedIcon,
                        onSelected: (value) {
                          setState(() {
                            _selectedIcon = value;
                          });
                        },
                      ),
                    const SizedBox(height: 28),
                    // EDIT MODE: Dropdown + Rename Switch Toggle
                    if (widget.isEditing) ...[
                      DropdownButtonFormField<String>(
                        value: _selectedCategoryId,
                        decoration: const InputDecoration(
                          labelText: "Select Category",
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category.id,
                            child: Text(category.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          final selected = _categories.firstWhere(
                            (e) => e.id == value,
                          );
                          setState(() {
                            _loadCategory(selected);
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Allow Renaming Category",
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Switch.adaptive(
                            value: _allowRenaming,
                            onChanged: (value) {
                              setState(() {
                                _allowRenaming = value;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    // Category Name Field (Editable in Add Mode, Toggle-controlled in Edit Mode)
                    AdminTextField(
                      controller: _nameController,
                      hintText: "Category Name",
                      prefixIcon: Icons.category_outlined,
                      enabled: !widget.isEditing || _allowRenaming,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Category name is required";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Featured Category"),
                      value: _featured,
                      onChanged: (value) {
                        setState(() {
                          _featured = value;
                        });
                      },
                    ),
                    const SizedBox(height: 30),
                    AdminButton(
                      text: widget.isEditing
                          ? "Update Category"
                          : "Save Category",
                      isLoading: _isLoading,
                      onPressed: _saveCategory,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    setState(() {
      _selectedImage = File(pickedFile.path);
      _imageUrl = null;
    });
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.isEditing && _selectedCategoryId == null) {
      AppNotifier.info(context, "Please select a category to update.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final categoryName = _nameController.text.trim();

      if (!widget.isEditing) {
        final exists = await _categoryService.categoryExists(categoryName);
        if (exists) {
          if (!mounted) return;
          AppNotifier.info(context, "Category already exists.");
          setState(() => _isLoading = false);
          return;
        }
      }

      String finalImage = "";
      String imageType = "";

      switch (_imageSource) {
        case CategoryImageSource.gallery:
          if (_selectedImage == null && _imageUrl == null) {
            AppNotifier.info(context, "Please select an image.");
            setState(() => _isLoading = false);
            return;
          }

          if (_selectedImage != null) {
            finalImage = await _storageService.uploadCategoryImage(
              image: _selectedImage!,
            );
          } else {
            finalImage = _imageUrl!;
          }

          imageType = "gallery";
          break;

        case CategoryImageSource.url:
          final url = _imageUrlController.text.trim();

          if (url.isEmpty) {
            AppNotifier.info(context, "Please enter an image URL.");
            setState(() => _isLoading = false);
            return;
          }

          finalImage = url;
          imageType = "url";
          break;

        case CategoryImageSource.icon:
          if (_selectedIcon == null) {
            AppNotifier.info(context, "Please select an icon.");
            setState(() => _isLoading = false);
            return;
          }

          finalImage = _selectedIcon!;
          imageType = "icon";
          break;
      }

      final categoryId = widget.isEditing
          ? (_selectedCategoryId ?? widget.category!.id)
          : await _categoryService.generateCategoryId();

      final category = CategoryModel(
        id: categoryId,
        name: categoryName,
        image: finalImage,
        imageType: imageType,
        featured: _featured,
      );

      if (widget.isEditing) {
        await _categoryService.updateCategory(category);
        if (!mounted) return;
        AppNotifier.success(context, "Category updated successfully.");
      } else {
        await _categoryService.addCategory(category);
        if (!mounted) return;
        AppNotifier.success(context, "Category added successfully.");
      }

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      AppNotifier.error(context, e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}