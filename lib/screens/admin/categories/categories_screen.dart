import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/category_model.dart';
import '../../../services/category_service.dart';
import '../../../utils/app_notifier.dart';
import '../../../widgets/admin/responsive.dart';
import 'add_category_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() =>
      _CategoriesScreenState();
}

class _CategoriesScreenState
    extends State<CategoriesScreen> {
  final CategoryService _categoryService =
      CategoryService();

  final TextEditingController _searchController =
      TextEditingController();

  String _search = "";

  @override
  void dispose() {
    _searchController.dispose();
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
          "Categories",
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w700,
            fontSize: Responsive.titleSize(context),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const AddCategoryScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Category"),
      ),
      body: Padding(
        padding: EdgeInsets.all(
          Responsive.horizontalPadding(context),
        ),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search categories...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _search = value.toLowerCase();
                });
              },
            ),

            const SizedBox(height: 20),

            Expanded(
              child: StreamBuilder<List<CategoryModel>>(
                stream:
                    _categoryService.getCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child:
                          CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        snapshot.error.toString(),
                      ),
                    );
                  }

                  if (!snapshot.hasData ||
                      snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        "No categories found.",
                      ),
                    );
                  }

                  final categories = snapshot.data!
                      .where(
                        (category) => category.name
                            .toLowerCase()
                            .contains(_search),
                      )
                      .toList();

                  if (categories.isEmpty) {
                    return const Center(
                      child: Text(
                        "No matching categories.",
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category =
                          categories[index];
                                                return Card(
                        elevation: 1,
                        margin: const EdgeInsets.only(
                          bottom: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(10),
                            child: Image.network(
                              category.image,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) =>
                                      Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.image_not_supported,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            category.name,
                            style:
                                GoogleFonts.manrope(
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            category.featured
                                ? "Featured"
                                : "Normal",
                          ),
                          trailing: Row(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                ),
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          AddCategoryScreen(
                                        category:
                                            category,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  final confirm =
                                      await showDialog<bool>(
                                    context: context,
                                    builder: (_) =>
                                        AlertDialog(
                                      title: const Text(
                                        "Delete Category",
                                      ),
                                      content: Text(
                                        "Delete '${category.name}'?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(
                                            context,
                                            false,
                                          ),
                                          child:
                                              const Text(
                                            "Cancel",
                                          ),
                                        ),
                                        FilledButton(
                                          onPressed: () =>
                                              Navigator.pop(
                                            context,
                                            true,
                                          ),
                                          child:
                                              const Text(
                                            "Delete",
                                          ),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm !=
                                      true) {
                                    return;
                                  }

                                  await _categoryService
                                      .deleteCategory(
                                    category.id,
                                  );

                                  if (!mounted) {
                                    return;
                                  }

                                  AppNotifier.success(
                                    context,
                                    "Category deleted successfully.",
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
