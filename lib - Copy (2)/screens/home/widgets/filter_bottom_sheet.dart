import 'package:flutter/material.dart';

import '../../../core/filter_controller.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() =>
      _FilterBottomSheetState();
}

class _FilterBottomSheetState
    extends State<FilterBottomSheet> {
  String? category = selectedCategory.value;

  double price = maxPrice.value;

  String? sort =
      sortBy.value == "featured" ? null : sortBy.value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              "Filter",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 30),

          const Text(
            "Category",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          Wrap(
            spacing: 10,
            children: [
              "Makeup",
              "Skin Care",
              "Hair Care",
              "Perfume",
              "Hand Care",
            ].map(
              (e) => ChoiceChip(
                label: Text(e),
                selected: category == e,
                onSelected: (_) {
                  setState(() {
                    category = category == e ? null : e;
                  });
                },
              ),
            ).toList(),
          ),

          const SizedBox(height: 30),

          Text(
            "Max Price : Rs ${price.toInt()}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          Slider(
            value: price,
            min: 0,
            max: 9999,
            divisions: 100,
            onChanged: (value) {
              setState(() {
                price = value;
              });
            },
          ),

          const SizedBox(height: 20),

          DropdownButtonFormField<String>(
            value: sort,
            hint: const Text("Select sorting"),
            items: const [
              DropdownMenuItem(
                value: "featured",
                child: Text("Featured"),
              ),
              DropdownMenuItem(
                value: "low",
                child: Text("Price Low → High"),
              ),
              DropdownMenuItem(
                value: "high",
                child: Text("Price High → Low"),
              ),
              DropdownMenuItem(
                value: "rating",
                child: Text("Highest Rated"),
              ),
            ],
            onChanged: (value) {
              setState(() {
                sort = value;
              });
            },
          ),

          const SizedBox(height: 35),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      category = null;
                      price = 9999;
                      sort = null;
                    });

                    selectedCategory.value = null;
                    maxPrice.value = 9999;
                    sortBy.value = "featured";
                  },
                  child: const Text("Reset"),
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    selectedCategory.value = category;
                    maxPrice.value = price;
                    sortBy.value =
                        sort ?? "featured";

                    Navigator.pop(context);
                  },
                  child: const Text("Apply"),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}