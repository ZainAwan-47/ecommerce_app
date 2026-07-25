import 'package:flutter/material.dart';

class Responsive {
  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static bool isMobile(BuildContext context) =>
      width(context) < 600;

  static bool isTablet(BuildContext context) =>
      width(context) >= 600 &&
      width(context) < 1024;

  static bool isDesktop(BuildContext context) =>
      width(context) >= 1024;

  static int columns(BuildContext context) {
    final w = width(context);

    if (w >= 1400) return 5;
    if (w >= 1200) return 4;
    if (w >= 900) return 3;

    return 2;
  }

  static double horizontalPadding(BuildContext context) {
    if (isDesktop(context)) return 32;
    if (isTablet(context)) return 24;

    return 16;
  }

  static double verticalPadding(BuildContext context) => 16;

  static double titleSize(BuildContext context) {
    if (isDesktop(context)) return 24;
    if (isTablet(context)) return 22;

    return 20;
  }

  static double bodySize(BuildContext context) {
    if (isDesktop(context)) return 15;
    if (isTablet(context)) return 14;

    return 14;
  }

  static double buttonHeight(BuildContext context) {
    return isDesktop(context) ? 48 : 44;
  }

  static double radius = 16;
}