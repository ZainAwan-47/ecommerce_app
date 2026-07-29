import 'package:flutter/material.dart';

class UserFilterTabs extends StatelessWidget {
  const UserFilterTabs({
    super.key,
    required this.selectedFilter,
    required this.onChanged,
    required this.counts, // Added to receive real-time numbers
  });

  final String selectedFilter;
  final ValueChanged<String> onChanged;
  final Map<String, int> counts; 

  static const filters = [
    "All",
    "Customers",
    "Admins",
    "Active",
    "Inactive",
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38, // Slightly taller to comfortably fit the text and count badge
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;
          final count = counts[filter] ?? 0;

          return GestureDetector(
            onTap: () => onChanged(filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                // Pure black for selected, clean light gray for unselected
                color: isSelected ? Colors.black : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(30), 
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    filter,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF424242),
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(width: 6),
                  // PREMIUM COUNT BADGE
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Colors.white.withOpacity(0.15) // Subtle white overlay for selected
                          : const Color(0xFFE0E0E0),       // Slightly darker gray for unselected
                      borderRadius: BorderRadius.circular(10), // Pill shape for the badge
                    ),
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : const Color(0xFF616161),
                        height: 1.1, // Keeps the badge tightly wrapped
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}