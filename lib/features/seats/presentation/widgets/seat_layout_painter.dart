import 'dart:math';
import 'package:flutter/material.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/features/seats/domain/models/seat_layout.dart';

class SeatRenderBox {
  final Seat seat;
  final Rect rect;
  final double price;

  const SeatRenderBox({
    required this.seat,
    required this.rect,
    required this.price,
  });
}

/// CustomPainter rendering 300+ seat cinema layouts at 60fps with curved glowing screen arc
class SeatLayoutPainter extends CustomPainter {
  final SeatLayout layout;
  final Set<String> selectedSeatIds;
  final bool isDark;
  final ValueChanged<List<SeatRenderBox>>? onLayoutComputed;

  // Layout metrics
  static const double topOffset = 110.0;
  static const double leftOffset = 48.0; // Pinned row labels width
  static const double rightOffset = 24.0;
  static const double standardSeatWidth = 24.0;
  static const double reclinerSeatWidth = 34.0;
  static const double sofaSeatWidth = 52.0;
  static const double standardSeatHeight = 22.0;
  static const double reclinerSeatHeight = 26.0;
  static const double seatSpacing = 6.0;
  static const double rowSpacing = 8.0;
  static const double aisleGap = 18.0;

  final List<SeatRenderBox> computedBoxes = [];

  SeatLayoutPainter({
    required this.layout,
    required this.selectedSeatIds,
    required this.isDark,
    this.onLayoutComputed,
  });

  /// Calculate total canvas size required for the entire seat layout
  static Size computeCanvasSize(SeatLayout layout) {
    int maxCols = 0;
    for (final r in layout.rows) {
      if (r.seats.isNotEmpty) {
        final lastCol = r.seats.map((s) => s.col).reduce(max);
        if (lastCol > maxCols) maxCols = lastCol;
      }
    }
    maxCols = max(maxCols, 16);

    // Approximate width with 2 aisles
    final totalWidth = leftOffset +
        (maxCols * (standardSeatWidth + seatSpacing)) +
        (2 * aisleGap) +
        rightOffset;

    // Approximate height with category headers
    int categoryHeaderCount = 0;
    String lastCat = '';
    for (final r in layout.rows) {
      if (r.category != lastCat) {
        categoryHeaderCount++;
        lastCat = r.category;
      }
    }

    final totalHeight = topOffset +
        (layout.rows.length * (standardSeatHeight + rowSpacing)) +
        (categoryHeaderCount * 36.0) +
        80.0;

    return Size(max(totalWidth, 540.0), totalHeight);
  }

  @override
  void paint(Canvas canvas, Size size) {
    computedBoxes.clear();

    // 1. Draw Curved Glowing 'SCREEN THIS WAY' Arc
    _drawScreenArc(canvas, size);

    // 2. Draw Rows, Category Separators, Pinned Row Letters & Seats
    _drawSeatsAndRows(canvas, size);

    if (onLayoutComputed != null) {
      onLayoutComputed!(List.unmodifiable(computedBoxes));
    }
  }

  void _drawScreenArc(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    const arcWidth = 280.0;
    final leftX = centerX - (arcWidth / 2);
    final rightX = centerX + (arcWidth / 2);

    final path = Path()
      ..moveTo(leftX, 32)
      ..quadraticBezierTo(centerX, 68, rightX, 32);

    // Outer Ambient Glow
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12)
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          AppColors.spotlightCoral.withValues(alpha: 0.6),
          AppColors.marqueeAmber.withValues(alpha: 0.6),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 0.65, 1.0],
      ).createShader(Rect.fromLTRB(leftX, 20, rightX, 70));
    canvas.drawPath(path, glowPaint);

    // Core Crisp Glowing Arc
    final corePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        colors: [
          Colors.transparent,
          Colors.white,
          AppColors.spotlightCoral,
          Colors.white,
          Colors.transparent,
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ).createShader(Rect.fromLTRB(leftX, 20, rightX, 70));
    canvas.drawPath(path, corePaint);

    // Screen Label Text
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'SCREEN THIS WAY',
        style: TextStyle(
          color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 2.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(centerX - (textPainter.width / 2), 62),
    );

    // Downward arrow indicator
    final arrowPaint = Paint()
      ..color = AppColors.spotlightCoral.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(centerX, 76),
      Offset(centerX, 82),
      arrowPaint,
    );
    canvas.drawLine(
      Offset(centerX - 3, 79),
      Offset(centerX, 82),
      arrowPaint,
    );
    canvas.drawLine(
      Offset(centerX + 3, 79),
      Offset(centerX, 82),
      arrowPaint,
    );
  }

  void _drawSeatsAndRows(Canvas canvas, Size size) {
    double currentY = topOffset;
    String lastCategory = '';

    for (int rIdx = 0; rIdx < layout.rows.length; rIdx++) {
      final row = layout.rows[rIdx];

      // Draw Category Header if category changed
      if (row.category != lastCategory) {
        lastCategory = row.category;
        currentY += 14;

        _drawCategoryHeader(canvas, size, row.category, row.price, currentY);
        currentY += 28;
      }

      // Draw Pinned Row Label (A, B, C...)
      _drawRowLabel(canvas, row.rowLabel, currentY);

      // Draw Seats in this row
      double currentX = leftOffset;

      for (int sIdx = 0; sIdx < row.seats.length; sIdx++) {
        final seat = row.seats[sIdx];

        // Aisle gaps after columns 4 and 14
        if (seat.col == 5 || seat.col == 15) {
          currentX += aisleGap;
        }

        double width = standardSeatWidth;
        double height = standardSeatHeight;

        if (seat.type == SeatType.recliner) {
          width = reclinerSeatWidth;
          height = reclinerSeatHeight;
        } else if (seat.type == SeatType.sofa) {
          width = sofaSeatWidth;
          height = reclinerSeatHeight;
        }

        final seatRect = Rect.fromLTWH(currentX, currentY, width, height);

        // Record for hit-testing
        computedBoxes.add(
          SeatRenderBox(seat: seat, rect: seatRect, price: row.price),
        );

        final isSelected = selectedSeatIds.contains(seat.id);
        _drawSingleSeat(canvas, seat, seatRect, isSelected);

        currentX += width + seatSpacing;
      }

      currentY += (row.category.toLowerCase().contains('recliner')
              ? reclinerSeatHeight
              : standardSeatHeight) +
          rowSpacing;
    }
  }

  void _drawCategoryHeader(
    Canvas canvas,
    Size size,
    String category,
    double price,
    double y,
  ) {
    // Divider line
    final linePaint = Paint()
      ..color = isDark ? Colors.white12 : Colors.black12
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(leftOffset, y + 10), Offset(size.width - rightOffset, y + 10), linePaint);

    // Category badge with price (e.g. RECLINER — ₹550)
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${category.toUpperCase()} — ₹${price.toStringAsFixed(0)}',
        style: TextStyle(
          color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Badge pill background
    final badgeWidth = textPainter.width + 16;
    final badgeRect = Rect.fromLTWH(
      (size.width / 2) - (badgeWidth / 2),
      y,
      badgeWidth,
      20,
    );

    final badgePaint = Paint()
      ..color = isDark ? AppColors.surface : AppColors.lightSurface
      ..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(badgeRect, const Radius.circular(10)), badgePaint);

    final borderPaint = Paint()
      ..color = isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(RRect.fromRectAndRadius(badgeRect, const Radius.circular(10)), borderPaint);

    textPainter.paint(
      canvas,
      Offset(badgeRect.left + 8, badgeRect.top + 3),
    );
  }

  void _drawRowLabel(Canvas canvas, String label, double y) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(canvas, Offset(16, y + 4));
  }

  void _drawSingleSeat(
    Canvas canvas,
    Seat seat,
    Rect rect,
    bool isSelected,
  ) {
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4.5));

    if (isSelected) {
      // 1. SELECTED: Coral filled with glow & white check / seat number
      final fillPaint = Paint()
        ..color = AppColors.spotlightCoral
        ..style = PaintingStyle.fill;
      canvas.drawRRect(rrect, fillPaint);

      final glowPaint = Paint()
        ..color = AppColors.spotlightCoral.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawRRect(rrect, glowPaint);

      // Seat number inside selected seat
      final numPainter = TextPainter(
        text: TextSpan(
          text: '${seat.col}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      numPainter.paint(
        canvas,
        Offset(
          rect.center.dx - (numPainter.width / 2),
          rect.center.dy - (numPainter.height / 2),
        ),
      );
    } else if (seat.state == SeatState.booked) {
      // 2. BOOKED: Solid muted grey
      final fillPaint = Paint()
        ..color = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.12)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(rrect, fillPaint);

      final borderPaint = Paint()
        ..color = isDark ? Colors.white12 : Colors.black12
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;
      canvas.drawRRect(rrect, borderPaint);
    } else if (seat.state == SeatState.blocked) {
      // 3. BLOCKED: Dimmed with diagonal cross
      final fillPaint = Paint()
        ..color = isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.06)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(rrect, fillPaint);

      final linePaint = Paint()
        ..color = isDark ? Colors.white24 : Colors.black26
        ..strokeWidth = 1.0;
      canvas.drawLine(rect.topLeft, rect.bottomRight, linePaint);
    } else {
      // 4. AVAILABLE: Clean outline
      final fillPaint = Paint()
        ..color = isDark ? AppColors.surface : AppColors.lightSurface
        ..style = PaintingStyle.fill;
      canvas.drawRRect(rrect, fillPaint);

      final borderPaint = Paint()
        ..color = isDark
            ? (seat.type == SeatType.recliner
                ? AppColors.marqueeAmber.withValues(alpha: 0.6)
                : AppColors.lavender.withValues(alpha: 0.4))
            : (seat.type == SeatType.recliner
                ? AppColors.marqueeAmber
                : AppColors.textSecondaryLight.withValues(alpha: 0.5))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawRRect(rrect, borderPaint);

      // Wheelchair accessibility glyph
      if (seat.type == SeatType.wheelchair) {
        final iconPaint = Paint()
          ..color = AppColors.standardCyan
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(rect.center.dx, rect.center.dy - 3), 2.5, iconPaint);
        final bodyPaint = Paint()
          ..color = AppColors.standardCyan
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawLine(
          Offset(rect.center.dx, rect.center.dy - 1),
          Offset(rect.center.dx, rect.center.dy + 3),
          bodyPaint,
        );
      } else {
        // Seat number inside available seat
        final numPainter = TextPainter(
          text: TextSpan(
            text: '${seat.col}',
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
              fontSize: 8,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        numPainter.paint(
          canvas,
          Offset(
            rect.center.dx - (numPainter.width / 2),
            rect.center.dy - (numPainter.height / 2),
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant SeatLayoutPainter oldDelegate) {
    return oldDelegate.selectedSeatIds != selectedSeatIds ||
        oldDelegate.isDark != isDark ||
        oldDelegate.layout.id != layout.id;
  }
}
