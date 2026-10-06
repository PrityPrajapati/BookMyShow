import 'package:flutter/material.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/theme/app_radius.dart';

/// Custom Clipper creating a ticket shape with semicircle notches on left and right edges
class TicketStubClipper extends CustomClipper<Path> {
  const TicketStubClipper({
    this.notchRadius = 14.0,
    this.notchPositionFraction = 0.68,
    this.cornerRadius = 20.0,
  });

  final double notchRadius;
  final double notchPositionFraction;
  final double cornerRadius;

  @override
  Path getClip(Size size) {
    final path = Path();
    final notchY = size.height * notchPositionFraction;
    final r = cornerRadius;
    final nr = notchRadius;

    // Start Top-Left
    path.moveTo(0, r);
    path.quadraticBezierTo(0, 0, r, 0);

    // Top Edge
    path.lineTo(size.width - r, 0);
    path.quadraticBezierTo(size.width, 0, size.width, r);

    // Right Edge down to Notch
    path.lineTo(size.width, notchY - nr);
    // Right Inward Notch (semicircle)
    path.arcToPoint(
      Offset(size.width, notchY + nr),
      radius: Radius.circular(nr),
      clockwise: false,
    );

    // Right Edge down to Bottom
    path.lineTo(size.width, size.height - r);
    path.quadraticBezierTo(size.width, size.height, size.width - r, size.height);

    // Bottom Edge
    path.lineTo(r, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - r);

    // Left Edge up to Notch
    path.lineTo(0, notchY + nr);
    // Left Inward Notch (semicircle)
    path.arcToPoint(
      Offset(0, notchY - nr),
      radius: Radius.circular(nr),
      clockwise: false,
    );

    // Left Edge back to Top-Left
    path.lineTo(0, r);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant TicketStubClipper oldClipper) =>
      oldClipper.notchRadius != notchRadius ||
      oldClipper.notchPositionFraction != notchPositionFraction ||
      oldClipper.cornerRadius != cornerRadius;
}

/// Dashed Divider Painter for Ticket Stub notch separator
class DashedDividerPainter extends CustomPainter {
  const DashedDividerPainter({
    this.color = AppColors.surfaceBorder,
    this.dashWidth = 6.0,
    this.dashSpace = 4.0,
    this.strokeWidth = 1.2,
  });

  final Color color;
  final double dashWidth;
  final double dashSpace;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant DashedDividerPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.dashWidth != dashWidth ||
      oldDelegate.dashSpace != dashSpace ||
      oldDelegate.strokeWidth != strokeWidth;
}

/// Ticket Stub Container with Semicircle Notches and Dashed Divider
class TicketStubCard extends StatelessWidget {
  const TicketStubCard({
    required this.topChild,
    required this.bottomChild,
    super.key,
    this.notchRadius = 14.0,
    this.notchPositionFraction = 0.68,
    this.backgroundColor,
    this.elevation = 4.0,
    this.padding = const EdgeInsets.all(16.0),
  });

  final Widget topChild;
  final Widget bottomChild;
  final double notchRadius;
  final double notchPositionFraction;
  final Color? backgroundColor;
  final double elevation;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = backgroundColor ??
        (isDark ? AppColors.surface : AppColors.lightSurface);
    final borderColor = isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder;

    return PhysicalShape(
      clipper: TicketStubClipper(
        notchRadius: notchRadius,
        notchPositionFraction: notchPositionFraction,
        cornerRadius: AppRadius.r20,
      ),
      color: bg,
      elevation: elevation,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor.withValues(alpha: 0.4)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: padding,
              child: topChild,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: notchRadius + 4),
              child: CustomPaint(
                size: const Size(double.infinity, 1),
                painter: DashedDividerPainter(
                  color: borderColor,
                ),
              ),
            ),
            Padding(
              padding: padding,
              child: bottomChild,
            ),
          ],
        ),
      ),
    );
  }
}
