import 'package:flutter/material.dart';

/// AsinMart visual system derived from the supplied Emerald & Gold Commerce
/// template. Keep colors and spacing centralized so every screen can share the
/// same marketplace language without duplicating magic values.
abstract final class AsinDesign {
  static const Color primary = Color(0xFF063D39);
  static const Color primaryDeep = Color(0xFF072A20);
  static const Color primaryInk = Color(0xFF002623);
  static const Color primarySoft = Color(0xFFE7F3F1);
  static const Color gold = Color(0xFFF5B82E);
  static const Color goldSoft = Color(0xFFFFF4D1);
  static const Color text = Color(0xFF17231F);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color background = Color(0xFFF8FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLow = Color(0xFFF2F4F5);
  static const Color surfaceHigh = Color(0xFFE6E8E9);
  static const Color border = Color(0xFFE5E7EB);
  static const Color discount = Color(0xFFE02424);
  static const Color discountSoft = Color(0xFFFDF2F2);
  static const Color star = Color(0xFFF59E0B);
  static const Color success = Color(0xFF16A34A);

  static const Color darkBackground = Color(0xFF0B1210);
  static const Color darkSurface = Color(0xFF121B18);
  static const Color darkSurfaceLow = Color(0xFF17221E);
  static const Color darkSurfaceHigh = Color(0xFF202C28);
  static const Color darkBorder = Color(0xFF2A3934);
  static const Color darkText = Color(0xFFF4F7F6);
  static const Color darkMuted = Color(0xFF9DA9A4);

  static const double radiusSm = 4;
  static const double radius = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;

  static const double gutterMobile = 8;
  static const double gutter = 12;
  static const double pagePaddingMobile = 12;
  static const double pagePadding = 16;

  static Color canvas(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkBackground : background;

  static Color card(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSurface : surface;

  static Color softCard(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSurfaceLow : surfaceLow;

  static Color line(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkBorder : border;

  static Color foreground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkText : text;

  static Color muted(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkMuted : textMuted;

  static BoxDecoration cardDecoration(
    BuildContext context, {
    double radius = AsinDesign.radius,
    bool elevated = false,
    Color? color,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: color ?? card(context),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor ?? line(context)),
      boxShadow: elevated
          ? [
              BoxShadow(
                color: primary.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? .16 : .08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
          : null,
    );
  }
}
