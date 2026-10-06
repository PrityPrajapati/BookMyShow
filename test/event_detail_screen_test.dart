import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:showscape/features/event_detail/presentation/screens/event_detail_screen.dart';
import 'package:showscape/features/event_detail/presentation/widgets/about_section.dart';
import 'package:showscape/features/event_detail/presentation/widgets/ai_summary_card.dart';
import 'package:showscape/features/event_detail/presentation/widgets/cast_carousel.dart';
import 'package:showscape/features/event_detail/presentation/widgets/event_detail_app_bar.dart';
import 'package:showscape/features/event_detail/presentation/widgets/event_meta_section.dart';
import 'package:showscape/features/event_detail/presentation/widgets/format_chips_section.dart';
import 'package:showscape/features/event_detail/presentation/widgets/format_explanation_sheet.dart';
import 'package:showscape/features/event_detail/presentation/widgets/live_event_info_section.dart';
import 'package:showscape/features/event_detail/presentation/widgets/sticky_booking_bar.dart';
import 'package:showscape/features/event_detail/presentation/widgets/trailer_modal_sheet.dart';

void main() {
  setUpAll(() async {
    final tempDir = Directory.systemTemp.createTempSync();
    Hive.init(tempDir.path);
    if (!Hive.isBoxOpen('explore_preferences')) {
      await Hive.openBox<dynamic>('explore_preferences');
    }
    if (!Hive.isBoxOpen('ai_review_summary_cache')) {
      await Hive.openBox<dynamic>('ai_review_summary_cache');
    }
    if (!Hive.isBoxOpen('event_mood_tags_cache')) {
      await Hive.openBox<dynamic>('event_mood_tags_cache');
    }
  });

  testWidgets(
      'EventDetailScreen renders movies and live concerts with all interactive features',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // =========================================================================
    // 1. Movie Test: Pushpa 2: The Rule (mov_001)
    // =========================================================================
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: EventDetailScreen(id: 'mov_001'),
        ),
      ),
    );

    // Initial pump and await repository delay
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Verify AppBar and Hero poster
    expect(find.byType(EventDetailAppBar), findsOneWidget);
    expect(find.byType(EventMetaSection), findsOneWidget);

    // Verify Title, Rating, and Certificate
    expect(find.text('Pushpa 2: The Rule'), findsWidgets);
    expect(find.text('9.2'), findsOneWidget);
    expect(find.text('UA 16+'), findsWidgets);

    // Verify Format Chips (For Movie: 2D, 3D, IMAX 2D, IMAX 3D, 4DX)
    expect(find.byType(FormatChipsSection), findsOneWidget);
    expect(find.text('2D (Base)'), findsOneWidget);
    expect(find.text('IMAX 2D (+₹180)'), findsOneWidget);

    // Tap format info icon to open FormatExplanationSheet modal
    final infoIconFinder = find.byIcon(Icons.info_outline_rounded);
    expect(infoIconFinder, findsWidgets);
    await tester.tap(infoIconFinder.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(FormatExplanationSheet), findsOneWidget);
    expect(find.text('Experience Formats Explained'), findsOneWidget);
    expect(find.text('IMAX 2D Laser'), findsOneWidget);
    expect(find.text('4DX Motion & Effects'), findsOneWidget);

    // Close format explanation sheet
    final closeIcon = find.byIcon(Icons.close_rounded);
    expect(closeIcon, findsOneWidget);
    await tester.tap(closeIcon);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(FormatExplanationSheet), findsNothing);

    // Tap Watch Trailer CTA to open TrailerModalSheet
    final trailerButton = find.text('Watch Trailer & Teaser');
    expect(trailerButton, findsOneWidget);
    await tester.tap(trailerButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(TrailerModalSheet), findsOneWidget);
    expect(find.text('Official Theatrical Trailer'), findsOneWidget);

    // Close trailer modal sheet
    final closeTrailerIcon = find.byIcon(Icons.close_rounded);
    expect(closeTrailerIcon, findsOneWidget);
    await tester.tap(closeTrailerIcon);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(TrailerModalSheet), findsNothing);

    // Allow AI summary provider to load and settle
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Verify AI Summary Card (3 bullets + spoiler-free verdict + AI-generated badge)
    expect(find.byType(AiSummaryCard), findsOneWidget);
    expect(find.text('What people say'), findsOneWidget);
    expect(find.textContaining('AI-generated'), findsOneWidget);
    expect(find.textContaining('Spoiler-Free Verdict'), findsOneWidget);

    // Interactive thumbs up feedback
    final thumbsUpFinder = find.byIcon(Icons.thumb_up_alt_outlined);
    expect(thumbsUpFinder, findsOneWidget);
    await tester.tap(thumbsUpFinder);
    await tester.pump();
    expect(find.byIcon(Icons.thumb_up_rounded), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));

    // Verify About Section with Read More toggle
    expect(find.byType(AboutSection), findsOneWidget);
    expect(find.text('About the Movie'), findsOneWidget);
    expect(find.text('Read more'), findsOneWidget);
    await tester.tap(find.text('Read more'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Show less'), findsOneWidget);

    // Verify Cast Carousel
    expect(find.byType(CastCarousel), findsOneWidget);
    expect(find.text('Cast & Artists'), findsOneWidget);
    expect(find.text('Allu Arjun'), findsOneWidget);

    // Verify Sticky Bottom Bar with Book Tickets button
    expect(find.byType(StickyBookingBar), findsOneWidget);
    expect(find.text('Book tickets'), findsOneWidget);

    // =========================================================================
    // 2. Live Concert Test: Coldplay (evt_001)
    // =========================================================================
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: EventDetailScreen(id: 'evt_001'),
        ),
      ),
    );

    // Pump and wait for repository load
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1000));

    // Verify Coldplay Concert info
    expect(find.text('Coldplay: Music of the Spheres World Tour'), findsWidgets);
    expect(find.byType(FormatChipsSection), findsNothing);
    expect(find.byType(LiveEventInfoSection), findsOneWidget);

    // Verify Venue & Schedule Date Card
    expect(find.byIcon(Icons.stadium_rounded), findsOneWidget);
    expect(find.byIcon(Icons.calendar_month_rounded), findsOneWidget);

    // Verify Ticket Categories & Pricing
    expect(find.text('Ticket Categories & Pricing'), findsOneWidget);
    expect(find.text('General Admission / Silver'), findsOneWidget);
    expect(find.text('Lounge & Hospitality VIP'), findsOneWidget);

    // Verify AI Summary Card
    expect(find.byType(AiSummaryCard), findsOneWidget);

    // Verify Sticky Bottom Bar with starting price and Book tickets
    expect(find.byType(StickyBookingBar), findsOneWidget);
    expect(find.text('Book tickets'), findsOneWidget);
  });
}
