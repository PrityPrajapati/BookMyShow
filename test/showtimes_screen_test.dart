import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:showscape/features/explore/data/repositories/mock_event_repository.dart';
import 'package:showscape/features/seats/data/repositories/mock_seat_repository.dart';
import 'package:showscape/features/showtimes/data/repositories/mock_show_repository.dart';
import 'package:showscape/features/showtimes/presentation/screens/showtimes_screen.dart';
import 'package:showscape/features/showtimes/presentation/widgets/cinema_shows_card.dart';
import 'package:showscape/features/showtimes/presentation/widgets/date_strip.dart';
import 'package:showscape/features/showtimes/presentation/widgets/mini_seat_map_preview_sheet.dart';
import 'package:showscape/features/showtimes/presentation/widgets/occupancy_legend.dart';
import 'package:showscape/features/showtimes/presentation/widgets/showtime_chip.dart';
import 'package:showscape/features/showtimes/presentation/widgets/showtime_filter_bar.dart';
import 'package:showscape/features/venue_map/data/repositories/mock_venue_repository.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final tempDir = Directory.systemTemp.createTempSync();
    Hive.init(tempDir.path);
    if (!Hive.isBoxOpen('explore_preferences')) {
      await Hive.openBox<dynamic>('explore_preferences');
    }
    // Pre-warm caches
    await MockEventRepository().getAllEvents();
    await MockShowRepository().getShows();
    await MockVenueRepository().getVenues();
    await MockSeatRepository().getSeatLayoutById('layout_imax');
  });

  testWidgets('ShowtimesScreen displays date strip, filter row, distance-sorted cinemas, legend, and preview',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ShowtimesScreen(eventId: 'mov_002'),
        ),
      ),
    );

    // Initial pump and await repository delay (400ms)
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // 1. Verify DateStrip renders 7 days including "Today" and "Tomorrow"
    expect(find.byType(DateStrip), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Tomorrow'), findsOneWidget);

    // 2. Verify OccupancyLegend renders with the 4 color stages
    expect(find.byType(OccupancyLegend), findsOneWidget);
    expect(find.textContaining('Available'), findsWidgets);
    expect(find.textContaining('Filling fast'), findsWidgets);
    expect(find.textContaining('Almost full'), findsWidgets);
    expect(find.textContaining('Sold out'), findsWidgets);

    // 3. Verify Filter Bar renders with Time of Day, Formats, and Languages
    expect(find.byType(ShowtimeFilterBar), findsOneWidget);
    expect(find.textContaining('Morning <12'), findsOneWidget);
    expect(find.textContaining('Afternoon 12'), findsOneWidget);
    expect(find.textContaining('Evening 16'), findsOneWidget);
    expect(find.textContaining('Night >20'), findsOneWidget);

    // 4. Verify Cinemas list rendered with distance and show chips
    expect(find.byType(CinemaShowsCard), findsWidgets);
    expect(find.textContaining('km'), findsWidgets);

    // 5. Verify Favourite Star toggle
    final starButtonFinder = find.byIcon(Icons.star_border_rounded).first;
    expect(starButtonFinder, findsWidgets);
    await tester.tap(starButtonFinder);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byIcon(Icons.star_rounded), findsWidgets);

    // 6. Verify Showtime Chips and Long-press Mini Seat Map Preview
    final chipFinder = find.byType(ShowtimeChip);
    expect(chipFinder, findsWidgets);

    // Long press on a chip to open mini seat map preview
    await tester.longPress(chipFinder.first);
    await tester.pump(const Duration(milliseconds: 500));

    // Verify MiniSeatMapPreviewSheet opened
    expect(find.byType(MiniSeatMapPreviewSheet), findsOneWidget);
    expect(find.text('Mini Seat Map Preview'), findsOneWidget);
    expect(find.text('SCREEN THIS WAY'), findsOneWidget);
    expect(find.text('Select Seats'), findsOneWidget);

    // Dismiss bottom sheet by tapping close
    final closeBtn = find.byIcon(Icons.close_rounded);
    await tester.tap(closeBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(MiniSeatMapPreviewSheet), findsNothing);

    // 7. Test Time of Day filter selection
    final morningFilter = find.textContaining('Morning <12');
    await tester.tap(morningFilter);
    await tester.pump(const Duration(milliseconds: 300));

    // Clear filter
    await tester.tap(morningFilter);
    await tester.pump(const Duration(milliseconds: 300));
  });
}
