import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:showscape/features/explore/presentation/screens/explore_screen.dart';
import 'package:showscape/features/explore/presentation/widgets/category_tabs_bar.dart';
import 'package:showscape/features/explore/presentation/widgets/collapsible_calendar.dart';
import 'package:showscape/features/explore/presentation/widgets/explore_search_bar.dart';

void main() {
  setUpAll(() async {
    final tempDir = Directory.systemTemp.createTempSync();
    Hive.init(tempDir.path);
    await Hive.openBox<dynamic>('explore_preferences');
  });

  testWidgets('ExploreScreen renders all core UI components and responds to interactions',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ExploreScreen(),
        ),
      ),
    );

    // Initial pump
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify main components are present
    expect(find.byType(ExploreSearchBar), findsOneWidget);
    expect(find.byType(CategoryTabsBar), findsOneWidget);
    expect(find.byType(CollapsibleCalendar), findsOneWidget);

    // Verify Category Tabs exist
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Movies'), findsOneWidget);
    expect(find.text('Events'), findsOneWidget);
    expect(find.text('Sports'), findsOneWidget);
    expect(find.text('Comedy'), findsOneWidget);
    expect(find.text('Dining'), findsOneWidget);

    // Tap 'Movies' category tab
    await tester.tap(find.text('Movies'));
    await tester.pump(const Duration(milliseconds: 300));

    // Verify calendar expand/collapse button
    expect(find.text('Expand'), findsOneWidget);
    await tester.tap(find.text('Expand'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Collapse'), findsOneWidget);

    // Verify Grid/List view mode toggle button exists
    expect(find.byIcon(Icons.view_list_rounded), findsOneWidget);
    await tester.tap(find.byIcon(Icons.view_list_rounded));
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Filter button opens bottom sheet
    final filterButton = find.byIcon(Icons.tune_rounded);
    expect(filterButton, findsOneWidget);
    await tester.tap(filterButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Bottom sheet title should be visible
    expect(find.text('Filters & Preferences'), findsOneWidget);
    expect(find.text('Apply Filters'), findsOneWidget);
    expect(find.text('Reset All'), findsOneWidget);

    // Close bottom sheet
    await tester.tap(find.text('Apply Filters'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  });
}
