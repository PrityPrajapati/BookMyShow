import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:showscape/core/utils/motion_utils.dart';

/// 3D Flippable Ticket Card
/// Flips 180 degrees horizontally with perspective transform
class FlippableTicketCard extends StatefulWidget {
  const FlippableTicketCard({
    required this.front,
    required this.back,
    super.key,
    this.duration = const Duration(milliseconds: 320),
    this.onFlip,
  });

  final Widget front;
  final Widget back;
  final Duration duration;
  final ValueChanged<bool>? onFlip;

  @override
  State<FlippableTicketCard> createState() => FlippableTicketCardState();
}

class FlippableTicketCardState extends State<FlippableTicketCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _isFront = true;

  bool get isFront => _isFront;

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

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void flip() {
    HapticFeedback.lightImpact();
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      _isFront = !_isFront;
    });
    widget.onFlip?.call(_isFront);
  }

  @override
  Widget build(BuildContext context) {
    if (AppMotion.isReduceMotion(context)) {
      return GestureDetector(
        onTap: flip,
        child: _isFront ? widget.front : widget.back,
      );
    }

    return GestureDetector(
      onTap: flip,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * math.pi;
          final isUnder = (angle > math.pi / 2);

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: isUnder
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: widget.back,
                  )
                : widget.front,
          );
        },
      ),
    );
  }
}
