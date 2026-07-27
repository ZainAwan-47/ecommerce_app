import 'dart:io';

import 'package:flutter/material.dart';

class ImagePickerBox extends StatelessWidget {
  final File? image;
  final String? imageUrl;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const ImagePickerBox({
    super.key,
    required this.image,
    this.imageUrl,
    required this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (image != null) {
      child = Image.file(
        image!,
        fit: BoxFit.cover,
      );
    } else if (imageUrl != null &&
        imageUrl!.isNotEmpty) {
      child = Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(
            Icons.broken_image_outlined,
            size: 40,
          ),
        ),
      );
    } else {
      child = const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 32,
          ),
          SizedBox(height: 8),
          Text("Add Image"),
        ],
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius:
                  BorderRadius.circular(14),
              border: Border.all(
                color: Colors.grey.shade300,
              ),
            ),
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(14),
              child: child,
            ),
          ),
          if (image != null ||
              (imageUrl != null &&
                  imageUrl!.isNotEmpty))
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  padding:
                      const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}