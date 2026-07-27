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
import '../../../widgets/admin/image_picker_box.dart';
import '../../../widgets/admin/responsive.dart';

class AddCategoryScreen extends StatefulWidget {
  final CategoryModel? category;

  const AddCategoryScreen({
    super.key,
    this.category,
  });

  bool get isEditing => category != null;

  @override
  State<AddCategoryScreen> createState() =>
      _AddCategoryScreenState();
}

class _AddCategoryScreenState
    extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController =
      TextEditingController();

  final CategoryService _categoryService =
      CategoryService();

  final StorageService _storageService =
      StorageService.instance;

  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;

  String? _imageUrl;

  bool _featured = false;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    if (!widget.isEditing) return;

    final category = widget.category!;

    _nameController.text = category.name;
    _imageUrl = category.image;
    _featured = category.featured;
  }

  @override
  void dispose() {
    _nameController.dispose();
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
          widget.isEditing
              ? "Edit Category"
              : "Add Category",
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
                "Category Image",
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 16),

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

              const SizedBox(height: 28),

              AdminTextField(
                controller: _nameController,
                hintText: "Category Name",
                prefixIcon:
                    Icons.category_outlined,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return "Category name is required";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  "Featured Category",
                ),
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

    if (_selectedImage == null &&
        (_imageUrl == null || _imageUrl!.isEmpty)) {
      AppNotifier.info(
        context,
        "Please select a category image.",
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final exists =
          await _categoryService.categoryExists(
        _nameController.text.trim(),
      );

      if (exists && !widget.isEditing) {
        if (!mounted) return;

        AppNotifier.info(
          context,
          "Category already exists.",
        );

        setState(() {
          _isLoading = false;
        });

        return;
      }

      String finalImage = _imageUrl ?? "";

      if (_selectedImage != null) {
        finalImage = await _storageService
            .uploadCategoryImage(
          image: _selectedImage!,
        );
      }

      final category = CategoryModel(
        id: widget.isEditing
            ? widget.category!.id
            : await _categoryService
                .generateCategoryId(),
        name: _nameController.text.trim(),
        image: finalImage,
        featured: _featured,
      );

      if (widget.isEditing) {
        await _categoryService.updateCategory(
          category,
        );

        if (!mounted) return;

        AppNotifier.success(
          context,
          "Category updated successfully.",
        );
      } else {
        await _categoryService.addCategory(
          category,
        );

        if (!mounted) return;

        AppNotifier.success(
          context,
          "Category added successfully.",
        );
      }

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      AppNotifier.error(
        context,
        e.toString(),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}