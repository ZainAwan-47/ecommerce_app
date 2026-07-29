import 'package:flutter/material.dart';

class UserFilterTabs extends StatelessWidget {
  const UserFilterTabs({
    super.key,
    required this.selectedFilter,
    required this.onChanged,
  });

  final String selectedFilter;
  final ValueChanged<String> onChanged;

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
      height: 46,
      child: ListView.separated(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];

          return ChoiceChip(
            label: Text(filter),
            selected:
                selectedFilter == filter,
            onSelected: (_) =>
                onChanged(filter),
          );
        },
      ),
    );
  }
}