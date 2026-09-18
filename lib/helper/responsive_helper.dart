import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ResponsiveHelper {
  static bool isMobilePhone() => !kIsWeb;

  static bool isWeb() => kIsWeb;

  /// Width-based breakpoints are used on every platform. The previous helper
  /// treated every Android/iOS device as mobile, including large tablets.
  static bool isMobile(BuildContext context) => MediaQuery.sizeOf(context).width < 600;

  static bool isTab(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= 600 && width < 1100;
  }

  static bool isDesktop(BuildContext context) => MediaQuery.sizeOf(context).width >= 1100;

  static double horizontalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1300) return 32;
    if (width >= 900) return 24;
    if (width >= 600) return 20;
    return 14;
  }

  static int productGridCount(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1500) return 6;
    if (width >= 1200) return 5;
    if (width >= 900) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  static double maxContentWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width > 1320 ? 1320 : width;
  }
}
