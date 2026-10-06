import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/features/seats/domain/models/seat_layout.dart';
import 'package:showscape/features/seats/domain/services/seat_scorer.dart';
import 'package:showscape/features/seats/presentation/widgets/seat_layout_painter.dart';

/// InteractiveViewer hosting the SeatLayoutPainter with 0.8-3x zoom, pan, hit-testing, and semantics
class InteractiveSeatViewer extends StatefulWidget {
  final SeatLayout layout;
  final Set<String> selectedSeatIds;
  final ValueChanged<Seat> onSeatTapped;
  final List<ScoredSeatBlock> highlightedBlocks;
  final ValueChanged<ScoredSeatBlock>? onBlockTapped;
  final TransformationController? transformationController;

  const InteractiveSeatViewer({
    super.key,
    required this.layout,
    required this.selectedSeatIds,
    required this.onSeatTapped,
    this.highlightedBlocks = const [],
    this.onBlockTapped,
    this.transformationController,
  });

  @override
  State<InteractiveSeatViewer> createState() => InteractiveSeatViewerState();
}

class InteractiveSeatViewerState extends State<InteractiveSeatViewer>
    with SingleTickerProviderStateMixin {
  late TransformationController _transController;
  List<SeatRenderBox> _computedBoxes = [];

  List<SeatRenderBox> get computedBoxes => _computedBoxes;

  void handleTapAt(Offset localPosition) {
    _handleTapUp(TapUpDetails(kind: PointerDeviceKind.touch, localPosition: localPosition));
  }

  // Scale pop animation for last tapped seat
  String? _lastTappedSeatId;
  late AnimationController _popController;
  late Animation<double> _popAnimation;

  @override
  void initState() {
    super.initState();
    _transController = widget.transformationController ?? TransformationController();

    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _popAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _popController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    if (widget.transformationController == null) {
      _transController.dispose();
    }
    _popController.dispose();
    super.dispose();
  }

  Rect? _computeBlockRect(ScoredSeatBlock block) {
    Rect? rect;
    for (final seat in block.seats) {
      for (final box in _computedBoxes) {
        if (box.seat.id == seat.id) {
          rect = rect == null ? box.rect : rect.expandToInclude(box.rect);
          break;
        }
      }
    }
    return rect;
  }

  void _handleTapUp(TapUpDetails details) {
    final localPos = details.localPosition;

    // Check hit test against highlighted blocks first
    for (final block in widget.highlightedBlocks) {
      final blockRect = _computeBlockRect(block);
      if (blockRect != null) {
        final hitRect = Rect.fromLTRB(
          blockRect.left - 4,
          blockRect.top - 24,
          blockRect.right + 4,
          blockRect.bottom + 4,
        );
        if (hitRect.contains(localPos)) {
          HapticFeedback.mediumImpact();
          widget.onBlockTapped?.call(block);
          return;
        }
      }
    }

    for (final box in _computedBoxes) {
      if (box.rect.contains(localPos)) {
        if (box.seat.state == SeatState.available) {
          HapticFeedback.lightImpact();
          setState(() {
            _lastTappedSeatId = box.seat.id;
          });
          _popController.forward(from: 0.0);
          widget.onSeatTapped(box.seat);
        } else {
          HapticFeedback.selectionClick();
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvasSize = SeatLayoutPainter.computeCanvasSize(widget.layout);

    return InteractiveViewer(
      transformationController: _transController,
      minScale: 0.8,
      maxScale: 3.0,
      boundaryMargin: const EdgeInsets.all(120),
      child: Center(
        child: SizedBox(
          width: canvasSize.width,
          height: canvasSize.height,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: _handleTapUp,
            child: Stack(
              children: [
                // 1. High Performance Custom Painter inside RepaintBoundary
                RepaintBoundary(
                  child: CustomPaint(
                    size: canvasSize,
                    painter: SeatLayoutPainter(
                      layout: widget.layout,
                      selectedSeatIds: widget.selectedSeatIds,
                      isDark: isDark,
                      onLayoutComputed: (boxes) {
                        final wasEmpty = _computedBoxes.isEmpty;
                        _computedBoxes = boxes;
                        if (wasEmpty && mounted) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) setState(() {});
                          });
                        }
                      },
                    ),
                  ),
                ),

                // 2. Animated Pop Indicator for the selected seat
                AnimatedBuilder(
                  animation: _popAnimation,
                  builder: (context, child) {
                    if (_lastTappedSeatId == null || _popAnimation.value == 1.0) {
                      return const SizedBox.shrink();
                    }
                    final target = _computedBoxes.cast<SeatRenderBox?>().firstWhere(
                          (b) => b?.seat.id == _lastTappedSeatId,
                          orElse: () => null,
                        );
                    if (target == null) return const SizedBox.shrink();

                    return Positioned(
                      left: target.rect.left - ((target.rect.width * (_popAnimation.value - 1)) / 2),
                      top: target.rect.top - ((target.rect.height * (_popAnimation.value - 1)) / 2),
                      width: target.rect.width * _popAnimation.value,
                      height: target.rect.height * _popAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.spotlightCoral.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.spotlightCoral,
                            width: 1.5,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // 3. Highlighted Top Blocks with Glowing Outlines & Score Labels
                ...widget.highlightedBlocks.expand((block) {
                  final blockRect = _computeBlockRect(block);
                  if (blockRect == null) return <Widget>[];

                  final inflatedRect = blockRect.inflate(3.5);
                  const badgeWidth = 130.0;
                  final badgeLeft = blockRect.center.dx - (badgeWidth / 2.0);

                  return [
                    // Glowing Outline Box
                    Positioned.fromRect(
                      rect: inflatedRect,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          widget.onBlockTapped?.call(block);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.marqueeAmber,
                              width: 2.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.marqueeAmber.withValues(alpha: 0.55),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Floating Score Label Badge
                    Positioned(
                      left: badgeLeft,
                      top: inflatedRect.top - 24,
                      width: badgeWidth,
                      height: 22,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          widget.onBlockTapped?.call(block);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.marqueeAmber, AppColors.spotlightCoral],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.marqueeAmber.withValues(alpha: 0.6),
                                blurRadius: 6,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.auto_awesome,
                                  size: 11,
                                  color: Colors.black,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  block.scoreLabel,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ];
                }),

                // 3. Semantics Layer for Accessibility per Seat
                ..._computedBoxes.map((box) {
                  final isSelected = widget.selectedSeatIds.contains(box.seat.id);
                  final status = isSelected
                      ? 'Selected'
                      : (box.seat.state == SeatState.available
                          ? 'Available for ₹${box.price.toInt()}'
                          : (box.seat.state == SeatState.booked ? 'Booked' : 'Blocked'));

                  return Positioned.fromRect(
                    rect: box.rect,
                    child: Semantics(
                      button: box.seat.state == SeatState.available,
                      label: 'Seat ${box.seat.seatNumber}, ${box.seat.category} $status',
                      selected: isSelected,
                      child: const SizedBox.expand(),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
