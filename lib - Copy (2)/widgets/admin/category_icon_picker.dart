import 'dart:math';

import 'package:flutter/material.dart';
import '../../models/category_icon_model.dart';
import '../../utils/category_icons.dart';

class CategoryIconPicker extends StatefulWidget {
  final String? selectedIcon;
  final ValueChanged<String?> onSelected; // Updated to String? to allow null on unselect

  const CategoryIconPicker({
    super.key,
    required this.selectedIcon,
    required this.onSelected,
  });

  @override
  State<CategoryIconPicker> createState() => _CategoryIconPickerState();
}

class _CategoryIconPickerState extends State<CategoryIconPicker> {
  String? _selectedCategory;

  late final List<String> _categories;
  late final List<CategoryIconModel> _randomIcons;
  int visibleIcons = 12;

  @override
  void initState() {
    super.initState();

    _categories = CategoryIcons.icons
        .map((e) => e.category)
        .toSet()
        .toList()
      ..sort();

    _randomIcons = List<CategoryIconModel>.from(
      CategoryIcons.icons,
    )..shuffle();
  }

  @override
  Widget build(BuildContext context) {
    List<CategoryIconModel> filtered;

    if (_selectedCategory == null) {
      filtered = _randomIcons;
    } else {
      filtered = CategoryIcons.icons
          .where(
            (icon) => icon.category == _selectedCategory,
          )
          .toList();
    }

    final visibleIconsList =
        filtered.take(min(visibleIcons, filtered.length)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Categories",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (_selectedCategory == null) ...[
              FilterChip(
                label: const Text("All"),
                selected: true,
                onSelected: (_) {},
              ),
              ..._categories.map(
                (category) => FilterChip(
                  label: Text(category),
                  selected: false,
                  onSelected: (_) {
                    setState(() {
                      _selectedCategory = category;
                      visibleIcons = 12;
                    });
                  },
                ),
              ),
            ] else
              InputChip(
                label: Text(_selectedCategory!),
                deleteIcon: const Icon(Icons.close),
                onDeleted: () {
                  setState(() {
                    _selectedCategory = null;
                    visibleIcons = 12;
                  });
                },
              ),
          ],
        ),

        const SizedBox(height: 20),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: visibleIconsList.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final icon = visibleIconsList[index];
            final selected = icon.key == widget.selectedIcon;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xff7F4F4F)
                    : const Color(0xff7F4F4F).withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  // ==================== TOGGLE UNSELECT FIX ====================
                  onTap: () {
                    if (selected) {
                      widget.onSelected(null); // Unselect if already selected
                    } else {
                      widget.onSelected(icon.key); // Select
                    }
                  },
                  // ==============================================================
                  child: Center(
                    child: Icon(
                      icon.icon,
                      size: 28,
                      color: selected
                          ? Colors.white
                          : const Color(0xff7F4F4F),
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 12),

        if (visibleIcons < filtered.length)
          Center(
            child: TextButton(
              onPressed: () {
                setState(() {
                  visibleIcons += 12;
                });
              },
              child: const Text("See More"),
            ),
          ),

        if (filtered.length > 12 && visibleIcons >= filtered.length)
  Center(
    child: TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Colors.red, // Changes the text color
      ),
      onPressed: () {
        setState(() {
          visibleIcons = 12;
        });
      },
      child: const Text("See Less"),
    ),
  ),
      ],
    );
  }
}