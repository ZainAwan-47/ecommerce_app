import 'package:flutter/material.dart';

enum ImageSourceType {
  gallery,
  url,
}

class ImageSourceBottomSheet extends StatelessWidget {
  const ImageSourceBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Wrap(
        children: [
          const SizedBox(height: 12),

          const Center(
            child: Text(
              "Add Product Image",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 20),

          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text("Upload from Gallery"),
            onTap: () {
              Navigator.pop(
                context,
                ImageSourceType.gallery,
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.link),
            title: const Text("Add Image URL"),
            onTap: () {
              Navigator.pop(
                context,
                ImageSourceType.url,
              );
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.close),
            title: const Text("Cancel"),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}