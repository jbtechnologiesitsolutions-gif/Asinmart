import 'package:flutter/material.dart';

/// Lightweight app-wide route transition used by the modern marketplace UI.
/// It relies only on Flutter SDK animations, so no dependency changes are needed.
class ModernPageTransitionsBuilder extends PageTransitionsBuilder {
  const ModernPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final fade = Tween<double>(begin: 0.0, end: 1.0).animate(curved);
    final slide = Tween<Offset>(
      begin: const Offset(0.025, 0.018),
      end: Offset.zero,
    ).animate(curved);

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }
}
