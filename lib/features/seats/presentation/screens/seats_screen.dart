import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/providers/providers.dart';
import 'package:showscape/core/router/route_paths.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/features/seats/domain/models/seat_layout.dart';
import 'package:showscape/features/seats/domain/models/seat_selection_state.dart';
import 'package:showscape/features/seats/domain/services/seat_scorer.dart';
import 'package:showscape/features/seats/presentation/widgets/group_size_picker_sheet.dart';
import 'package:showscape/features/seats/presentation/widgets/interactive_seat_viewer.dart';
import 'package:showscape/features/seats/presentation/widgets/seat_booking_bottom_bar.dart';
import 'package:showscape/features/seats/presentation/widgets/seat_hold_timer_badge.dart';
import 'package:showscape/features/showtimes/domain/models/show.dart';

/// Seat Layout Screen with pinch-zoom CustomPainter, group size picker, orphan rule, and hold timer
class SeatsScreen extends ConsumerStatefulWidget {
  final String showId;

  const SeatsScreen({super.key, required this.showId});

  @override
  ConsumerState<SeatsScreen> createState() => _SeatsScreenState();
}

class _SeatsScreenState extends ConsumerState<SeatsScreen> {
  SeatSelectionState _selection = const SeatSelectionState();
  final TransformationController _transformationController = TransformationController();

  int _groupSize = 2;
  bool _hasPromptedGroupSize = false;
  bool _isBestForYouActive = false;
  List<ScoredSeatBlock> _highlightedBlocks = [];

  void _toggleBestForYou(SeatLayout layout, double userAislePref) {
    HapticFeedback.mediumImpact();
    setState(() {
      _isBestForYouActive = !_isBestForYouActive;
      if (_isBestForYouActive) {
        _highlightedBlocks = SeatScorer.findTopBlocks(
          layout: layout,
          groupSize: _groupSize,
          userAislePreference: userAislePref,
          limit: 3,
        );

        if (_highlightedBlocks.isNotEmpty) {
          _selectBlock(_highlightedBlocks.first, layout);
        }

        final topScore = _highlightedBlocks.isNotEmpty ? _highlightedBlocks.first.scoreLabel : '';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.marqueeAmber, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Top 3 blocks highlighted • Tap to select ($topScore)'),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.surfaceElevated,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        _highlightedBlocks = [];
      }
    });
  }

  void _selectBlock(ScoredSeatBlock block, SeatLayout layout) {
    HapticFeedback.mediumImpact();
    final prices = Map<String, double>.from(_selection.seatPrices);
    if (prices.isEmpty) {
      for (final r in layout.rows) {
        for (final s in r.seats) {
          prices[s.id] = r.price;
        }
      }
    }

    final newSelection = <String, Seat>{};
    for (final s in block.seats) {
      newSelection[s.id] = s;
    }

    setState(() {
      _selection = _selection.copyWith(
        selectedSeats: newSelection,
        seatPrices: prices,
      );
    });
  }

  void _openGroupSizePicker(SeatLayout layout) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GroupSizePickerSheet(
        initialCount: _groupSize,
        onCountSelected: (newCount) {
          setState(() {
            _groupSize = newCount;
          });
          _autoSelectBlock(layout, newCount);
        },
      ),
    );
  }

  void _autoSelectBlock(SeatLayout layout, int count) {
    final bestBlock = SeatSelectionState.findBestContiguousBlock(layout, count);
    if (bestBlock.isNotEmpty) {
      final prices = <String, double>{};
      for (final r in layout.rows) {
        for (final s in r.seats) {
          prices[s.id] = r.price;
        }
      }

      setState(() {
        _selection = _selection.copyWith(
          selectedSeats: bestBlock,
          seatPrices: prices,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Auto-selected $count contiguous seats in the best view zone'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleSeatTap(Seat seat, SeatLayout layout) {
    final isCurrentlySelected = _selection.selectedSeats.containsKey(seat.id);

    // Max 10 seats check
    if (!isCurrentlySelected && _selection.count >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 10 seats allowed per booking'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Orphan seat rule check
    final orphanWarning = SeatSelectionState.checkOrphanSeatRule(
      layout: layout,
      targetSeat: seat,
      willSelect: !isCurrentlySelected,
      currentSelection: _selection.selectedSeats,
    );

    if (orphanWarning != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(orphanWarning),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Toggle selection
    final updatedMap = Map<String, Seat>.from(_selection.selectedSeats);
    if (isCurrentlySelected) {
      updatedMap.remove(seat.id);
    } else {
      updatedMap[seat.id] = seat;
    }

    // Build price map if not populated
    final prices = Map<String, double>.from(_selection.seatPrices);
    if (prices.isEmpty) {
      for (final r in layout.rows) {
        for (final s in r.seats) {
          prices[s.id] = r.price;
        }
      }
    }

    setState(() {
      _selection = _selection.copyWith(
        selectedSeats: updatedMap,
        seatPrices: prices,
      );
    });
  }

  void _handleTimerExpired() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).brightness == Brightness.dark
            ? AppColors.surface
            : AppColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.border20),
        title: const Row(
          children: [
            Icon(Icons.timer_off_rounded, color: AppColors.spotlightCoral, size: 24),
            SizedBox(width: 8),
            Text('Seat Hold Expired'),
          ],
        ),
        content: const Text(
          'Your 8-minute reservation window has expired. The selected seats have been released for other moviegoers.',
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.spotlightCoral,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _selection = _selection.copyWith(selectedSeats: {});
              });
            },
            child: const Text('Select Seats Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final showAsync = ref.watch(showDetailProvider(widget.showId));

    return showAsync.when(
      loading: () => Scaffold(
        backgroundColor: isDark ? AppColors.midnight : AppColors.lightBackground,
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.spotlightCoral),
          ),
        ),
      ),
      error: (err, _) => Scaffold(
        backgroundColor: isDark ? AppColors.midnight : AppColors.lightBackground,
        body: Center(
          child: Text('Failed to load show: $err'),
        ),
      ),
      data: (show) {
        if (show == null) {
          return Scaffold(
            backgroundColor: isDark ? AppColors.midnight : AppColors.lightBackground,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Show not found'),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        final layoutAsync = ref.watch(seatLayoutProvider(show.seatLayoutId));

        return layoutAsync.when(
          loading: () => Scaffold(
            backgroundColor: isDark ? AppColors.midnight : AppColors.lightBackground,
            body: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.spotlightCoral),
              ),
            ),
          ),
          error: (err, _) => Scaffold(
            backgroundColor: isDark ? AppColors.midnight : AppColors.lightBackground,
            body: Center(child: Text('Failed to load layout: $err')),
          ),
          data: (layout) {
            if (layout == null) {
              return Scaffold(
                backgroundColor: isDark ? AppColors.midnight : AppColors.lightBackground,
                body: const Center(child: Text('Layout not found')),
              );
            }

            // Prompt group size on first load if no seats selected yet
            if (!_hasPromptedGroupSize) {
              _hasPromptedGroupSize = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _openGroupSizePicker(layout);
              });
            }

            final timeStr = DateFormat('h:mm a').format(show.startTime);
            final pastBookings = ref.watch(allUserBookingsProvider.select((a) => a.value ?? const []));
            final userAislePref = SeatScorer.learnAislePreference(pastBookings);

            return Scaffold(
              backgroundColor: isDark ? AppColors.midnight : AppColors.lightBackground,
              appBar: AppBar(
                backgroundColor: isDark ? AppColors.midnight : AppColors.lightBackground,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  onPressed: () => context.pop(),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      show.screenName,
                      style: AppTypography.heading20(
                        color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                      ).copyWith(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${show.format.label} • $timeStr',
                      style: AppTypography.caption12(
                        color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                actions: [
                  // 'Best for you' Button with Sparkle Icon
                  TextButton.icon(
                    onPressed: () => _toggleBestForYou(layout, userAislePref),
                    icon: const Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: AppColors.marqueeAmber,
                    ),
                    label: Text(
                      'Best for you',
                      style: TextStyle(
                        color: _isBestForYouActive ? AppColors.marqueeAmber : AppColors.lavender,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: _isBestForYouActive
                          ? AppColors.marqueeAmber.withValues(alpha: 0.15)
                          : null,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: _isBestForYouActive
                            ? const BorderSide(color: AppColors.marqueeAmber, width: 1.2)
                            : BorderSide.none,
                      ),
                    ),
                  ),

                  // Group Size Button
                  TextButton.icon(
                    onPressed: () => _openGroupSizePicker(layout),
                    icon: const Icon(Icons.group_outlined, size: 16),
                    label: Text('$_groupSize Seats'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.spotlightCoral,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),

                  // 8-Minute Hold Timer Badge
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Center(
                      child: SeatHoldTimerBadge(
                        onTimerExpired: _handleTimerExpired,
                      ),
                    ),
                  ),
                ],
              ),
              body: Column(
                children: [
                  // Top Seat State Legend
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surface : AppColors.lightSurface,
                      border: Border(
                        bottom: BorderSide(
                          color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildLegend(
                          context,
                          border: isDark ? Colors.white38 : Colors.black38,
                          label: 'Available',
                        ),
                        _buildLegend(
                          context,
                          color: AppColors.spotlightCoral,
                          label: 'Selected',
                        ),
                        _buildLegend(
                          context,
                          color: isDark ? Colors.white12 : Colors.black12,
                          label: 'Booked',
                        ),
                        _buildLegend(
                          context,
                          border: AppColors.marqueeAmber,
                          label: 'Recliner',
                        ),
                      ],
                    ),
                  ),

                  // Interactive Pinch-Zoom Seat Layout Viewer
                  Expanded(
                    child: InteractiveSeatViewer(
                      layout: layout,
                      selectedSeatIds: _selection.selectedSeats.keys.toSet(),
                      highlightedBlocks: _highlightedBlocks,
                      onBlockTapped: (block) => _selectBlock(block, layout),
                      transformationController: _transformationController,
                      onSeatTapped: (seat) => _handleSeatTap(seat, layout),
                    ),
                  ),

                  // Bottom Bar with selected seats and animated total
                  SeatBookingBottomBar(
                    selection: _selection,
                    onProceed: () {
                      HapticFeedback.mediumImpact();
                      final ids = _selection.selectedSeats.keys.toList();
                      final prices = ids.map((id) => _selection.seatPrices[id] ?? 250.0).toList();
                      ref.read(bookingDraftProvider.notifier).initForShow(
                        draftId: 'draft_${widget.showId}',
                        showId: widget.showId,
                        seatIds: ids,
                        seatPrices: prices,
                      );
                      context.push(AppRoutes.foodPath('draft_${widget.showId}'));
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLegend(
    BuildContext context, {
    Color? color,
    Color? border,
    required String label,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: border != null ? Border.all(color: border, width: 1.2) : null,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: AppTypography.caption12(
            color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
          ).copyWith(fontSize: 11),
        ),
      ],
    );
  }
}
