import 'package:flutter/material.dart';
import 'package:showscape/core/utils/motion_utils.dart';

/// Staggered Fade Up transition for lists and cards
/// Clamped to ≤ 300 ms, disables when Reduce Motion is on
class StaggeredFadeUp extends StatefulWidget {
  const StaggeredFadeUp({
    required this.child,
    super.key,
    this.index = 0,
    this.duration = const Duration(milliseconds: 250),
    this.delayStep = const Duration(milliseconds: 35),
    this.slideOffset = 18.0,
  });

  final Widget child;
  final int index;
  final Duration duration;
  final Duration delayStep;
  final double slideOffset;

  @override
  State<StaggeredFadeUp> createState() => _StaggeredFadeUpState();
}

class _StaggeredFadeUpState extends State<StaggeredFadeUp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    final effectiveDuration = widget.duration > AppMotion.maxStandardDuration
        ? AppMotion.maxStandardDuration
        : widget.duration;

    _controller = AnimationController(
      vsync: this,
      duration: effectiveDuration,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, widget.slideOffset / 100),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    final totalDelay = widget.delayStep * widget.index;
    Future.delayed(totalDelay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AppMotion.isReduceMotion(context)) {
      return widget.child;
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
