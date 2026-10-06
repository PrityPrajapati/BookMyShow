import 'package:flutter/material.dart';

/// Veg/non-veg marks following official Indian FSSAI convention:
/// - Green square border with a solid green circle inside (Vegetarian)
/// - Brown square border with a solid brown triangle inside (Non-Vegetarian)
class IndianDietBadge extends StatelessWidget {
  final bool isVeg;
  final double size;

  const IndianDietBadge({
    super.key,
    required this.isVeg,
    this.size = 14,
  });

  @override
  Widget build(BuildContext context) {
    final color = isVeg ? const Color(0xFF0F8A3C) : const Color(0xFF8B3A1C);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(2.5),
      ),
      alignment: Alignment.center,
      child: isVeg
          ? Container(
              width: size * 0.45,
              height: size * 0.45,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            )
          : CustomPaint(
              size: Size(size * 0.5, size * 0.5),
              painter: _TrianglePainter(color: color),
            ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;

  const _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) =>
      oldDelegate.color != color;
}
