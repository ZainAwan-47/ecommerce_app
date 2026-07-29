import 'package:flutter/material.dart';

class Responsive {
  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static bool isMobile(BuildContext context) =>
      width(context) < 600;

  static bool isTablet(BuildContext context) =>
      width(context) >= 600 && width(context) < 1024;

  static bool isDesktop(BuildContext context) =>
      width(context) >= 1024;

  static int columns(BuildContext context) {
    final w = width(context);

    if (w >= 1400) return 4;
    if (w >= 1000) return 3;
    return 2;
  }

  static double horizontalPadding(BuildContext context) {
    final w = width(context);

    if (w >= 1400) return 40;
    if (w >= 1000) return 30;
    return 16;
  }

  static double verticalPadding(BuildContext context) {
    return 20;
  }

  static double titleSize(BuildContext context) {
    final w = width(context);

    if (w >= 1400) return 30;
    if (w >= 1000) return 26;
    return 22;
  }
  // Border Radius
static double get radius => 16;

// Standard button height
static double buttonHeight(BuildContext context) {
  if (isDesktop(context)) return 56;
  if (isTablet(context)) return 52;
  return 48;
}

// Card padding
static double cardPadding(BuildContext context) {
  if (isDesktop(context)) return 24;
  if (isTablet(context)) return 20;
  return 16;
}

// Grid spacing
static double gridSpacing(BuildContext context) {
  return 16;
}
}