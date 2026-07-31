import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/filter_controller.dart';
import '../../../services/firestore_service.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? category = selectedCategory.value;
  double price = maxPrice.value;
  String? sort = sortBy.value == "featured" ? null : sortBy.value;

  // Cached stream to prevent re-subscribing and flickering on setState
  late final Stream<List<String>> _categoriesStream;

  @override
  void initState() {
    super.initState();
    _categoriesStream = FirestoreService().getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bottom Sheet Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  "Filter Products",
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xff2D2323),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Category Section (Dynamic from Firestore)[cite: 7]
              Text(
                "Category",
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff2D2323),
                ),
              ),
              const SizedBox(height: 12),
              StreamBuilder<List<String>>(
                stream: _categoriesStream, // Uses cached stream reference
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 40,
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xff7F4F4F),
                          ),
                        ),
                      ),
                    );
                  }
                  
                  final categories = snapshot.data ?? [];
                  if (categories.isEmpty) {
                    return Text(
                      "No categories available",
                      style: GoogleFonts.manrope(
                        color: const Color(0xff8D7B7B),
                        fontSize: 13,
                      ),
                    );
                  }

                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map(
                      (e) => ChoiceChip(
                        label: Text(
                          e,
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: category == e
                                ? Colors.white
                                : const Color(0xff8D7B7B),
                          ),
                        ),
                        selected: category == e,
                        selectedColor: const Color(0xff7F4F4F),
                        backgroundColor: const Color(0xffFFF9F7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: category == e
                                ? Colors.transparent
                                : Colors.black.withOpacity(0.12),
                            width: 0.8,
                          ),
                        ),
                        showCheckmark: false,
                        onSelected: (_) {
                          setState(() {
                            category = category == e ? null : e;
                          });
                        },
                      ),
                    ).toList(),
                  );
                },
              ),
              const SizedBox(height: 24),
              
              // Price Slider Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Max Price",
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xff2D2323),
                    ),
                  ),
                  Text(
                    "Rs ${price.toInt()}",
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xff7F4F4F),
                    ),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: const Color(0xff7F4F4F),
                  inactiveTrackColor: const Color(0xffFFF9F7),
                  thumbColor: const Color(0xff7F4F4F),
                  overlayColor: const Color(0xff7F4F4F).withOpacity(0.12),
                ),
                child: Slider(
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
              ),
              const SizedBox(height: 20),
              
              // Sort Section
              Text(
                "Sort By",
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff2D2323),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: sort,
                dropdownColor: Colors.white,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.black.withOpacity(0.12),
                      width: 0.8,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xff7F4F4F),
                      width: 1,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.black.withOpacity(0.12),
                      width: 0.8,
                    ),
                  ),
                ),
                hint: Text(
                  "Select sorting",
                  style: GoogleFonts.manrope(
                    color: const Color(0xff8D7B7B),
                    fontSize: 14,
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: "featured",
                    child: Text(
                      "Featured",
                      style: GoogleFonts.manrope(fontSize: 14),
                    ),
                  ),
                  DropdownMenuItem(
                    value: "low",
                    child: Text(
                      "Price Low - High",
                      style: GoogleFonts.manrope(fontSize: 14),
                    ),
                  ),
                  DropdownMenuItem(
                    value: "high",
                    child: Text(
                      "Price High - Low",
                      style: GoogleFonts.manrope(fontSize: 14),
                    ),
                  ),
                  DropdownMenuItem(
                    value: "rating",
                    child: Text(
                      "Highest Rated",
                      style: GoogleFonts.manrope(fontSize: 14),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    sort = value;
                  });
                },
              ),
              const SizedBox(height: 32),
              
              // Action Buttons (Reset & Apply)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                          color: const Color(0xff7F4F4F).withOpacity(0.5),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
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
                      child: Text(
                        "Reset",
                        style: GoogleFonts.manrope(
                          color: const Color(0xff7F4F4F),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff7F4F4F),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        selectedCategory.value = category;
                        maxPrice.value = price;
                        sortBy.value = sort ?? "featured";
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Apply",
                        style: GoogleFonts.manrope(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}