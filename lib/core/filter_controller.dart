import 'package:flutter/material.dart';

final ValueNotifier<String?> selectedCategory =
    ValueNotifier(null);

final ValueNotifier<double> maxPrice =
    ValueNotifier(9999);

final ValueNotifier<String> sortBy =
    ValueNotifier("featured");