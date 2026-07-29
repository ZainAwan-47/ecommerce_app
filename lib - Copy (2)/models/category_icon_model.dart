import 'package:flutter/material.dart';

class CategoryIconModel {
  final String key;
  final String category;
  final IconData icon;

  const CategoryIconModel({
    required this.category,
    required this.icon,
    required this.key,
  });
}