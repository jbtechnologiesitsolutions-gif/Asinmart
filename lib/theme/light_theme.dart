import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/asinmart_design_system.dart';
import 'package:flutter_sixvalley_ecommerce/theme/modern_page_transitions.dart';

ThemeData light({Color? primaryColor, Color? secondaryColor}) {
  // The uploaded Emerald & Gold template is the visual source of truth.
  // Do not let remote/admin accent values fragment the app palette.
  final primary = AsinDesign.primary;
  final secondary = AsinDesign.gold;

  final scheme = ColorScheme.light(
    primary: primary,
    onPrimary: Colors.white,
    primaryContainer: AsinDesign.primarySoft,
    onPrimaryContainer: AsinDesign.primaryInk,
    secondary: secondary,
    onSecondary: AsinDesign.text,
    secondaryContainer: const Color(0xFFFFDEA5),
    onSecondaryContainer: const Color(0xFF5D4200),
    tertiary: AsinDesign.text,
    onTertiary: Colors.white,
    error: const Color(0xFFBA1A1A),
    onError: Colors.white,
    errorContainer: const Color(0xFFFFDAD6),
    onErrorContainer: const Color(0xFF93000A),
    surface: AsinDesign.surface,
    onSurface: AsinDesign.text,
    outline: const Color(0xFF707977),
    outlineVariant: const Color(0xFFC0C8C6),
    shadow: Colors.black,
  );

  return ThemeData(
    useMaterial3: true,
    fontFamily: 'SF-Pro-Rounded-Regular',
    brightness: Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor: AsinDesign.background,
    cardColor: AsinDesign.surface,
    canvasColor: AsinDesign.surface,
    highlightColor: AsinDesign.surface,
    hintColor: AsinDesign.textMuted,
    splashColor: primary.withValues(alpha: .06),
    hoverColor: primary.withValues(alpha: .035),
    focusColor: primary.withValues(alpha: .08),
    dividerColor: AsinDesign.border,
    disabledColor: const Color(0xFFD8DADB),
    colorScheme: scheme,
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AsinDesign.text, fontSize: 28, height: 1.21, fontWeight: FontWeight.w700, letterSpacing: -.56),
      displayMedium: TextStyle(color: AsinDesign.text, fontSize: 22, height: 1.27, fontWeight: FontWeight.w700, letterSpacing: -.33),
      headlineLarge: TextStyle(color: AsinDesign.text, fontSize: 22, height: 1.27, fontWeight: FontWeight.w700),
      headlineMedium: TextStyle(color: AsinDesign.text, fontSize: 18, height: 1.33, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: AsinDesign.text, fontSize: 18, height: 1.33, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(color: AsinDesign.text, fontSize: 16, height: 1.38, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(color: AsinDesign.text, fontSize: 13, height: 1.38, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: AsinDesign.text, fontSize: 15, height: 1.47),
      bodyMedium: TextStyle(color: AsinDesign.text, fontSize: 13, height: 1.38),
      bodySmall: TextStyle(color: AsinDesign.textMuted, fontSize: 12, height: 1.33),
      labelLarge: TextStyle(color: AsinDesign.text, fontSize: 12, height: 1.33, fontWeight: FontWeight.w700),
      labelMedium: TextStyle(color: AsinDesign.textMuted, fontSize: 12, height: 1.33, fontWeight: FontWeight.w600),
      labelSmall: TextStyle(color: AsinDesign.textMuted, fontSize: 10, height: 1.4, fontWeight: FontWeight.w600, letterSpacing: .2),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AsinDesign.surface,
      foregroundColor: AsinDesign.text,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'SF-Pro-Rounded-Regular',
        color: AsinDesign.text,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AsinDesign.surface,
      hintStyle: const TextStyle(color: AsinDesign.textMuted, fontSize: 13),
      labelStyle: const TextStyle(color: AsinDesign.textMuted, fontSize: 12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AsinDesign.radius), borderSide: const BorderSide(color: AsinDesign.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AsinDesign.radius), borderSide: const BorderSide(color: AsinDesign.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AsinDesign.radius), borderSide: BorderSide(color: primary, width: 1.4)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AsinDesign.radius), borderSide: const BorderSide(color: AsinDesign.discount)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AsinDesign.radius), borderSide: const BorderSide(color: AsinDesign.discount, width: 1.4)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(44, 48),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AsinDesign.radius)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(44, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AsinDesign.radius)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        minimumSize: const Size(44, 44),
        side: const BorderSide(color: AsinDesign.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AsinDesign.radius)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AsinDesign.radius)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AsinDesign.surface,
      selectedColor: AsinDesign.primary,
      disabledColor: AsinDesign.surfaceLow,
      side: const BorderSide(color: AsinDesign.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      labelStyle: const TextStyle(color: AsinDesign.text, fontWeight: FontWeight.w600, fontSize: 12),
      secondaryLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AsinDesign.surface,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: Color(0xFFC0C8C6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AsinDesign.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 14,
      shadowColor: Colors.black.withValues(alpha: .16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AsinDesign.primaryDeep,
      contentTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AsinDesign.radius)),
      elevation: 8,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: primary,
      linearTrackColor: AsinDesign.surfaceHigh,
      circularTrackColor: AsinDesign.surfaceHigh,
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      fillColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? primary : null),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? primary : const Color(0xFF707977)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) => Colors.white),
      trackColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? primary : const Color(0xFFD8DADB)),
    ),
    dividerTheme: const DividerThemeData(color: AsinDesign.border, thickness: 1, space: 1),
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: ModernPageTransitionsBuilder(),
      TargetPlatform.iOS: ModernPageTransitionsBuilder(),
      TargetPlatform.macOS: ModernPageTransitionsBuilder(),
      TargetPlatform.windows: ModernPageTransitionsBuilder(),
      TargetPlatform.linux: ModernPageTransitionsBuilder(),
      TargetPlatform.fuchsia: ModernPageTransitionsBuilder(),
    }),
  );
}
