import 'package:showscape/features/food/domain/models/fnb_combo.dart';
import 'package:showscape/features/tickets/domain/models/booking.dart';

/// Pure Dart Combo Recommendation Engine:
/// Chooses the combo with the best savings per person for the group size,
/// preferring flavours from order history.
class ComboRecommender {
  /// Known cinema flavour and snack keywords to match against past orders
  static const List<String> recognizedFlavours = [
    'caramel',
    'cheese',
    'butter',
    'salted',
    'peri-peri',
    'peri peri',
    'chocolate',
    'nachos',
    'coke',
    'orange',
    'churros',
    'coffee',
    'hazelnut',
    'truffle',
    'jalapeno',
    'bbq',
    'spicy',
  ];

  /// Extracts favourite flavour keywords from a user's past bookings
  static List<String> extractFlavoursFromBookings(List<Booking> bookings) {
    final flavours = <String>{};

    for (final booking in bookings) {
      for (final fnb in booking.fnbItems) {
        final text = '${fnb.name} ${fnb.description}'.toLowerCase();
        for (final flavour in recognizedFlavours) {
          if (text.contains(flavour)) {
            flavours.add(flavour);
          }
        }
      }
    }

    return flavours.toList();
  }

  /// Counts matching flavours between a combo and the user's order history flavours
  static int countMatchingFlavours(FnbCombo combo, List<String> orderHistoryFlavours) {
    if (orderHistoryFlavours.isEmpty) return 0;

    final comboText = [
      combo.name,
      combo.description,
      ...combo.items.map((i) => '${i.name} ${i.description}'),
    ].join(' ').toLowerCase();

    int matches = 0;
    for (final flavour in orderHistoryFlavours) {
      if (comboText.contains(flavour.toLowerCase())) {
        matches++;
      }
    }
    return matches;
  }

  /// Calculates the savings per person for a combo given the party size
  static double calculateSavingsPerPerson(FnbCombo combo, int groupSize) {
    final effectiveGroupSize = groupSize > 0 ? groupSize : 1;
    final totalSavings = combo.computedSavings;
    return totalSavings / effectiveGroupSize;
  }

  /// Chooses the combo with the best savings per person for the group size,
  /// preferring flavours from order history.
  static FnbCombo? recommendCombo({
    required List<FnbCombo> combos,
    required int groupSize,
    List<String> orderHistoryFlavours = const [],
  }) {
    if (combos.isEmpty) return null;

    final effectiveGroupSize = groupSize > 0 ? groupSize : 1;

    // Check which combos match flavour history
    final flavourMatchedCombos = combos.where((combo) {
      return countMatchingFlavours(combo, orderHistoryFlavours) > 0;
    }).toList();

    // If any combos match order history flavours, select from them
    final pool = flavourMatchedCombos.isNotEmpty ? flavourMatchedCombos : combos;

    // Sort by savings per person descending (break ties by total savings)
    final sorted = List<FnbCombo>.from(pool)..sort((a, b) {
      final savingsA = calculateSavingsPerPerson(a, effectiveGroupSize);
      final savingsB = calculateSavingsPerPerson(b, effectiveGroupSize);
      final diff = savingsB.compareTo(savingsA);
      if (diff != 0) return diff;
      return b.computedSavings.compareTo(a.computedSavings);
    });

    return sorted.first;
  }
}
