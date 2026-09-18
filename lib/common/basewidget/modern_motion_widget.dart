import 'dart:async';
import 'package:flutter/material.dart';

/// Small entrance animation that can be reused without a third-party package.
class ModernFadeSlide extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Offset beginOffset;

  const ModernFadeSlide({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 420),
    this.delay = Duration.zero,
    this.beginOffset = const Offset(0, .035),
  });

  @override
  State<ModernFadeSlide> createState() => _ModernFadeSlideState();
}

class _ModernFadeSlideState extends State<ModernFadeSlide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _configureAnimations();
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      _timer = Timer(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  void _configureAnimations() {
    final curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _opacity = Tween<double>(begin: 0, end: 1).animate(curve);
    _offset = Tween<Offset>(begin: widget.beginOffset, end: Offset.zero).animate(curve);
  }

  @override
  void didUpdateWidget(covariant ModernFadeSlide oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.beginOffset != widget.beginOffset) _configureAnimations();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}

/// Gives cards and buttons a subtle tactile scale animation on press.
class ModernPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final double pressedScale;

  const ModernPressable({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
    this.pressedScale = .985,
  });

  @override
  State<ModernPressable> createState() => _ModernPressableState();
}

class _ModernPressableState extends State<ModernPressable> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      scale: _pressed ? widget.pressedScale : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: widget.borderRadius,
          onTap: widget.onTap,
          onHighlightChanged: _setPressed,
          child: widget.child,
        ),
      ),
    );
  }
}
