import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:showscape/core/providers/providers.dart';
import 'package:showscape/features/booking/domain/models/booking_draft.dart';
import 'package:showscape/features/food/domain/models/fnb_combo.dart';
import 'package:showscape/features/food/domain/models/fnb_item.dart';
import 'package:showscape/features/food/presentation/screens/food_screen.dart';
import 'package:showscape/features/food/presentation/widgets/combo_card.dart';
import 'package:showscape/features/food/presentation/widgets/indian_diet_badge.dart';
import 'package:showscape/features/food/presentation/widgets/item_customisation_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testPopcornItem = const FnbItem(
    id: 'test_popcorn_1',
    name: 'Caramel & Cheese Popcorn',
    description: 'Sweet and savory collision',
    imageUrl: 'https://images.unsplash.com/photo-1578849278619-e73505e9610f',
    price: 360.0,
    category: 'Popcorn',
    isVeg: true,
  );

  final testDrinkItem = const FnbItem(
    id: 'test_drink_1',
    name: 'Coca-Cola Zero Sugar',
    description: 'Refreshing cold beverage',
    imageUrl: 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97',
    price: 190.0,
    category: 'Beverages',
    isVeg: true,
  );

  final testCombo = FnbCombo(
    id: 'test_cmb_1',
    name: 'Blockbuster Duo Combo',
    description: 'Popcorn + 2 Cokes',
    imageUrl: 'https://images.unsplash.com/photo-1585647347384-2593bc35786b',
    items: [testPopcornItem, testDrinkItem, testDrinkItem],
    comboPrice: 599.0,
    originalPrice: 740.0,
    savings: 141.0,
  );

  group('Food Screen & Components Tests', () {
    testWidgets('IndianDietBadge renders veg and non-veg marks accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                IndianDietBadge(isVeg: true),
                IndianDietBadge(isVeg: false),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(IndianDietBadge), findsNWidgets(2));
    });

    testWidgets(
        'ComboCard displays items included, strikethrough sum, computed savings badge, and Recommended for 4',
        (tester) async {
      int quantity = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (context, setState) {
                  return ComboCard(
                    combo: testCombo,
                    quantity: quantity,
                    isRecommended: true,
                    recommendedSeatCount: 4,
                    onAdd: () {
                      setState(() => quantity = 1);
                    },
                    onQuantityChanged: (newQty) {
                      setState(() => quantity = newQty);
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify combo title and items included
      expect(find.text('Blockbuster Duo Combo'), findsOneWidget);
      expect(find.text('Caramel & Cheese Popcorn'), findsOneWidget);

      // Verify computed savings badge: 740 - 599 = 141 (19%)
      expect(find.text('Save ₹141 (19%)'), findsOneWidget);

      // Verify Recommended for 4 label
      expect(find.text('Recommended for 4'), findsOneWidget);

      // Verify price and strikethrough
      expect(find.text('₹599'), findsOneWidget);
      expect(find.text('₹740'), findsOneWidget);

      // Tap ADD button
      expect(find.text('ADD'), findsOneWidget);
      await tester.tap(find.text('ADD'));
      await tester.pump();

      // Should now show stepper with quantity 1
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('ComboCard displays Picked for you badge when isPickedForYou is true',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ComboCard(
              combo: testCombo,
              isPickedForYou: true,
              onAdd: () {},
              onQuantityChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Picked for you'), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome_rounded), findsOneWidget);
    });

    testWidgets('ItemCustomisationSheet provides size, flavour, and stepper',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      FnbCartItem? addedItem;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemCustomisationSheet(
              item: testPopcornItem,
              onAddToCart: (item) {
                addedItem = item;
              },
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Select Size'), findsOneWidget);
      expect(find.text('Select Flavour / Dip'), findsOneWidget);
      expect(find.text('Add Item'), findsOneWidget);

      // Select Butter Burst flavour
      await tester.tap(find.text('Butter Burst'));
      await tester.pump();

      // Tap Add Item
      await tester.tap(find.text('Add Item'));
      await tester.pump();

      expect(addedItem, isNotNull);
      expect(addedItem!.flavour, 'Butter Burst');
    });

    testWidgets(
        'FoodScreen renders Category Tabs and Pickup Options and updates draft',
        (tester) async {
      final container = ProviderContainer(
        overrides: [
          fnbCombosProvider.overrideWith((ref) => Future.value([testCombo])),
          fnbItemsProvider.overrideWith(
              (ref) => Future.value([testPopcornItem, testDrinkItem])),
          venueDetailProvider.overrideWith((ref, id) => Future.value(null)),
          allUserBookingsProvider.overrideWith((ref) => Future.value([])),
        ],
      );
      addTearDown(container.dispose);

      // Set seat count in draft to 4
      container.read(bookingDraftProvider.notifier).initForShow(
            draftId: 'draft_test_1',
            showId: 'show_001',
            seatIds: ['A1', 'A2', 'A3', 'A4'],
            seatPrices: [320.0, 320.0, 320.0, 320.0],
          );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: FoodScreen(bookingDraftId: 'draft_test_1'),
          ),
        ),
      );

      // Allow future providers to resolve (currentUser 400ms + userBookings 400ms)
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1200));

      // Check Tabs
      expect(find.text('Combos'), findsOneWidget);
      expect(find.text('Popcorn'), findsOneWidget);
      expect(find.text('Beverages'), findsOneWidget);
      expect(find.text('Meals'), findsOneWidget);

      // Check Pickup timing buttons
      expect(find.text('Before show'), findsOneWidget);
      expect(find.text('At interval'), findsOneWidget);

      // Tap 'At interval'
      await tester.tap(find.text('At interval'));
      await tester.pump();

      expect(container.read(bookingDraftProvider).pickupTiming,
          PickupTiming.atInterval);
    });
  });
}
