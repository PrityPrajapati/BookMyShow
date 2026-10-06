import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:showscape/core/widgets/price_summary_bar.dart';

void main() {
  group('PriceSummaryBar Widget Tests', () {
    testWidgets('Renders running total, button, and responds to actions', (tester) async {
      bool buttonPressed = false;
      bool detailsPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: PriceSummaryBar(
              totalAmount: 1450.0,
              label: '2 SEATS SELECTED',
              subtitle: 'A5, A6',
              buttonText: 'Proceed to Food',
              buttonIcon: Icons.fastfood_rounded,
              onButtonPressed: () => buttonPressed = true,
              onDetailsPressed: () => detailsPressed = true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check label and subtitle
      expect(find.text('2 SEATS SELECTED'), findsOneWidget);
      expect(find.text('A5, A6'), findsOneWidget);
      expect(find.text('Proceed to Food'), findsOneWidget);

      // Check animated total price
      expect(find.textContaining('1,450'), findsOneWidget);

      // Tap action button
      await tester.tap(find.text('Proceed to Food'));
      await tester.pump();
      expect(buttonPressed, isTrue);

      // Tap details dropdown icon
      await tester.tap(find.byIcon(Icons.keyboard_arrow_up_rounded));
      await tester.pump();
      expect(detailsPressed, isTrue);
    });

    testWidgets('Disables action button when isButtonEnabled is false', (tester) async {
      bool buttonPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: PriceSummaryBar(
              totalAmount: 0.0,
              label: 'NO SEATS SELECTED',
              buttonText: 'Select Seats',
              isButtonEnabled: false,
              onButtonPressed: () => buttonPressed = true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Select Seats'));
      await tester.pump();
      expect(buttonPressed, isFalse);
    });
  });
}
