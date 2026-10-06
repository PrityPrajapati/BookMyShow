import 'package:flutter/material.dart';
import 'package:showscape/core/widgets/price_summary_bar.dart';
import 'package:showscape/features/seats/domain/models/seat_selection_state.dart';

/// Bottom bar displaying selected seats list and running total, reusing PriceSummaryBar
class SeatBookingBottomBar extends StatelessWidget {
  final SeatSelectionState selection;
  final VoidCallback onProceed;

  const SeatBookingBottomBar({
    super.key,
    required this.selection,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    final hasSeats = selection.count > 0;
    final seatCodesStr = selection.selectedSeatCodes.join(', ');

    return PriceSummaryBar(
      totalAmount: selection.totalPrice,
      label: hasSeats
          ? '${selection.count} ${selection.count == 1 ? 'SEAT' : 'SEATS'} SELECTED'
          : 'NO SEATS SELECTED',
      subtitle: hasSeats ? seatCodesStr : 'Tap seats on the map above',
      buttonText: hasSeats ? 'Pay & Proceed' : 'Select Seats',
      buttonIcon: Icons.fastfood_rounded,
      isButtonEnabled: hasSeats,
      onButtonPressed: onProceed,
    );
  }
}
