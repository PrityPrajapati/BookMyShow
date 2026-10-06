import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:showscape/core/models/models.dart';
import 'package:showscape/core/providers/providers.dart';
import 'package:showscape/core/repositories/repositories.dart';
import 'package:showscape/core/widgets/ticket_stub_card.dart';
import 'package:showscape/features/booking/domain/models/booking_draft.dart';
import 'package:showscape/features/checkout/domain/models/price_breakdown.dart';
import 'package:showscape/features/food/domain/models/fnb_item.dart';
import 'package:showscape/features/parking/domain/models/parking_lot.dart';
import 'package:showscape/features/tickets/data/services/offline_ticket_service.dart';
import 'package:showscape/features/tickets/data/services/screen_brightness_service.dart';
import 'package:showscape/features/tickets/domain/models/booking.dart';
import 'package:showscape/features/tickets/domain/models/ticket.dart';
import 'package:showscape/features/tickets/presentation/providers/ticket_providers.dart';
import 'package:showscape/features/tickets/presentation/screens/ticket_detail_screen.dart';
import 'package:showscape/features/tickets/presentation/screens/tickets_screen.dart';
import 'package:showscape/features/tickets/presentation/widgets/transfer_ticket_sheet.dart';
import 'package:showscape/features/tickets/presentation/widgets/venue_map_sheet.dart';

class FakeBookingRepository implements BookingRepository {
  final List<Booking> bookings;

  FakeBookingRepository(this.bookings);

  @override
  Future<Booking> createBooking(Booking booking) async => booking;

  @override
  Future<Booking> confirmBooking({
    required BookingDraft draft,
    required String paymentId,
    String? userId,
  }) async {
    return bookings.first;
  }

  @override
  Future<Booking?> getBookingById(String bookingId) async {
    try {
      return bookings.firstWhere((b) => b.id == bookingId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Booking>> getUserBookings(String userId) async {
    return bookings;
  }

  @override
  Future<List<Ticket>> getUserTickets(String userId) async {
    final list = <Ticket>[];
    for (final b in bookings) {
      list.addAll(b.tickets);
    }
    return list;
  }

  @override
  Future<Transfer> transferTicket({
    required String bookingId,
    required String ticketId,
    required String fromUserId,
    String? fromUserName,
    required String toUserPhone,
    String? toUserEmail,
    String? note,
  }) async {
    return Transfer(
      id: 'trf_test',
      bookingId: bookingId,
      ticketId: ticketId,
      fromUserId: fromUserId,
      toUserPhone: toUserPhone,
      status: TransferStatus.accepted,
      initiatedAt: DateTime.now(),
      completedAt: DateTime.now(),
    );
  }

  @override
  Future<List<Transfer>> getUserTransfers(String userId) async => [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_ticket_test_');
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  final now = DateTime.now();

  final testUpcomingBooking = Booking(
    id: 'bkg_up_1',
    bookingNumber: 'SS-BOM-92841',
    userId: 'usr_001',
    eventId: 'mov_001',
    eventTitle: 'Pushpa 2: The Rule',
    eventPosterUrl: null,
    venueId: 'ven_001',
    venueName: 'PVR INOX: Phoenix Palladium',
    showId: 'show_001',
    showTime: now.add(const Duration(hours: 2, minutes: 10)), // 2h 10m later!
    showFormat: '4DX',
    bookingTime: now.subtract(const Duration(hours: 4)),
    tickets: [
      const Ticket(
        id: 'tkt_001',
        bookingId: 'bkg_up_1',
        seatId: 's1_G_7',
        seatNumber: 'G7',
        row: 'G',
        col: 7,
        category: 'Recliner',
        price: 550.0,
        qrData: 'SHOWSCAPE:TKT:001:G7',
        status: TicketStatus.active,
      ),
      const Ticket(
        id: 'tkt_002',
        bookingId: 'bkg_up_1',
        seatId: 's1_G_8',
        seatNumber: 'G8',
        row: 'G',
        col: 8,
        category: 'Recliner',
        price: 550.0,
        qrData: 'SHOWSCAPE:TKT:002:G8',
        status: TicketStatus.active,
      ),
    ],
    fnbItems: [
      const FnbItem(
        id: 'fnb_01',
        name: 'Golden Butter Gourmet Popcorn',
        description: 'Large tub',
        imageUrl: '',
        price: 360.0,
        category: 'Popcorn',
        isVeg: true,
      ),
    ],
    parkingLot: const ParkingLot(
      id: 'prk_01',
      name: 'Basement 2 Four Wheeler Valet',
      vehicleType: VehicleType.fourWheeler,
      capacity: 200,
      available: 50,
      hourlyRate: 80,
      flatRate: 250,
      hasValet: true,
    ),
    priceBreakdown: const PriceBreakdown(
      basePrice: 1100,
      convenienceFee: 76,
      gst: 13.68,
      fnbTotal: 360,
      parkingTotal: 250,
      discount: 50,
      grandTotal: 1749.68,
    ),
    status: BookingStatus.confirmed,
    qrCodeData: 'SHOWSCAPE:BKG:bkg_up_1',
  );

  final testPastBooking = Booking(
    id: 'bkg_past_1',
    bookingNumber: 'SS-BLR-11048',
    userId: 'usr_001',
    eventId: 'mov_002',
    eventTitle: 'Oppenheimer',
    eventPosterUrl: null,
    venueId: 'ven_002',
    venueName: 'PVR Forum Mall: Koramangala',
    showId: 'show_002',
    showTime: now.subtract(const Duration(days: 5)),
    showFormat: 'IMAX 70mm',
    bookingTime: now.subtract(const Duration(days: 6)),
    tickets: [
      const Ticket(
        id: 'tkt_003',
        bookingId: 'bkg_past_1',
        seatId: 's2_D_10',
        seatNumber: 'D10',
        row: 'D',
        col: 10,
        category: 'Classic',
        price: 380.0,
        qrData: 'SHOWSCAPE:TKT:003:D10',
        status: TicketStatus.used,
      ),
    ],
    fnbItems: [],
    parkingLot: null,
    priceBreakdown: const PriceBreakdown(
      basePrice: 380,
      convenienceFee: 40,
      gst: 7.2,
      grandTotal: 427.2,
    ),
    status: BookingStatus.confirmed,
    qrCodeData: 'SHOWSCAPE:BKG:bkg_past_1',
  );

  final testTransferredBooking = Booking(
    id: 'bkg_trf_1',
    bookingNumber: 'SS-MUM-77312',
    userId: 'usr_001',
    eventId: 'evt_003',
    eventTitle: 'Coldplay: Music of the Spheres',
    eventPosterUrl: null,
    venueId: 'ven_003',
    venueName: 'DY Patil Stadium',
    showId: 'show_003',
    showTime: now.add(const Duration(days: 10)),
    showFormat: 'Live Concert',
    bookingTime: now.subtract(const Duration(days: 2)),
    tickets: [
      const Ticket(
        id: 'tkt_004',
        bookingId: 'bkg_trf_1',
        seatId: 's3_B_4',
        seatNumber: 'B4',
        row: 'B',
        col: 4,
        category: 'Lounge',
        price: 4500.0,
        qrData: 'SHOWSCAPE:TKT:004:B4',
        status: TicketStatus.transferred,
      ),
    ],
    fnbItems: [],
    parkingLot: null,
    priceBreakdown: const PriceBreakdown(
      basePrice: 4500,
      convenienceFee: 320,
      gst: 57.6,
      grandTotal: 4877.6,
    ),
    status: BookingStatus.confirmed,
    qrCodeData: 'SHOWSCAPE_TRANSFERRED_BKG',
  );

  final allTestBookings = [
    testUpcomingBooking,
    testPastBooking,
    testTransferredBooking,
  ];

  group('formatTicketCountdown Helper Tests', () {
    test('formats Starts in 2h 10m correctly', () {
      final showTime = now.add(const Duration(hours: 2, minutes: 10));
      final countdown = formatTicketCountdown(showTime, currentTime: now);
      expect(countdown, equals('Starts in 2h 10m'));
    });

    test('formats Starts in 45m correctly', () {
      final showTime = now.add(const Duration(minutes: 45));
      final countdown = formatTicketCountdown(showTime, currentTime: now);
      expect(countdown, equals('Starts in 45m'));
    });

    test('formats Started 15m ago correctly', () {
      final showTime = now.subtract(const Duration(minutes: 15));
      final countdown = formatTicketCountdown(showTime, currentTime: now);
      expect(countdown, equals('Started 15m ago'));
    });

    test('formats Completed for long passed show', () {
      final showTime = now.subtract(const Duration(hours: 5));
      final countdown = formatTicketCountdown(showTime, currentTime: now);
      expect(countdown, equals('Completed'));
    });
  });

  group('OfflineTicketService Tests', () {
    test('Caches and retrieves bookings from Hive', () async {
      final service = OfflineTicketService();
      await service.cacheBookings([testUpcomingBooking]);

      final cached = await service.getCachedBookings();
      expect(cached, isNotEmpty);
      expect(cached.first.id, equals(testUpcomingBooking.id));
      expect(cached.first.eventTitle, equals('Pushpa 2: The Rule'));

      final single = await service.getCachedBooking('bkg_up_1');
      expect(single, isNotNull);
      expect(single!.bookingNumber, equals('SS-BOM-92841'));

      final hasIt = await service.hasCachedBooking('bkg_up_1');
      expect(hasIt, isTrue);
    });
  });

  group('ScreenBrightnessService Tests', () {
    test('boostBrightnessAndKeepAwake and restoreBrightnessAndSleep execute cleanly', () async {
      final service = ScreenBrightnessService();
      expect(service.isMaxBrightnessActive, isFalse);

      await service.boostBrightnessAndKeepAwake();
      expect(service.isMaxBrightnessActive, isTrue);

      await service.restoreBrightnessAndSleep();
      expect(service.isMaxBrightnessActive, isFalse);
    });
  });

  final testUser = AppUser(
    id: 'usr_001',
    name: 'Prity Prajapati',
    email: 'prity@showscape.ai',
    phone: '+91 98765 43210',
    createdAt: DateTime(2026, 1, 1),
  );

  group('TicketsScreen Widget Tests', () {
    testWidgets('Renders Upcoming, Past, Transferred tabs and TicketStubCard',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(600, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWith((ref) => Future.value(testUser)),
          allUserBookingsProvider.overrideWith((ref) => Future.value(allTestBookings)),
          bookingRepositoryProvider
              .overrideWithValue(FakeBookingRepository(allTestBookings)),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: TicketsScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Check AppBar and Segment tabs
      expect(find.text('My Tickets'), findsOneWidget);
      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('Past'), findsOneWidget);
      expect(find.text('Transferred'), findsOneWidget);

      // Check Upcoming TicketStubCard
      expect(find.byType(TicketStubCard), findsOneWidget);
      expect(find.text('Pushpa 2: The Rule'), findsOneWidget);
      expect(find.text('PVR INOX: Phoenix Palladium'), findsOneWidget);
      expect(find.text('4DX'), findsOneWidget);
      expect(find.text('SS-BOM-92841'), findsOneWidget);
      expect(find.text('View QR Pass'), findsOneWidget);

      // Tap Past tab
      await tester.tap(find.text('Past'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Check Oppenheimer in Past
      expect(find.text('Oppenheimer'), findsOneWidget);
      expect(find.text('PVR Forum Mall: Koramangala'), findsOneWidget);

      // Tap Transferred tab
      await tester.tap(find.text('Transferred'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Check Coldplay in Transferred
      expect(find.text('Coldplay: Music of the Spheres'), findsOneWidget);
      expect(find.text('DY Patil Stadium'), findsOneWidget);
    });

    testWidgets('Toggles offline mode chip', (tester) async {
      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWith((ref) => Future.value(testUser)),
          allUserBookingsProvider.overrideWith((ref) => Future.value(allTestBookings)),
          bookingRepositoryProvider
              .overrideWithValue(FakeBookingRepository(allTestBookings)),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: TicketsScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Initially shows Online pill
      expect(find.text('Online'), findsOneWidget);

      // Tap online pill to toggle offline
      await tester.tap(find.text('Online'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Now shows Offline
      expect(find.text('Offline'), findsWidgets);
    });
  });

  group('TicketDetailScreen Widget Tests', () {
    testWidgets('Renders details, 3D flip to QR, linked food, parking, and actions',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(600, 2000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWith((ref) => Future.value(testUser)),
          ticketDetailProvider('bkg_up_1').overrideWith((ref) => Future.value(testUpcomingBooking)),
          bookingRepositoryProvider
              .overrideWithValue(FakeBookingRepository(allTestBookings)),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: TicketDetailScreen(id: 'bkg_up_1'),
          ),
        ),
      );

      await tester.pump();

      // Front details
      expect(find.text('Pushpa 2: The Rule'), findsOneWidget);
      expect(find.text('PVR INOX: Phoenix Palladium'), findsOneWidget);
      expect(find.text('4DX'), findsOneWidget);
      expect(find.text('G7'), findsOneWidget);
      expect(find.text('G8'), findsOneWidget);

      // Linked Food Order
      expect(find.text('Linked Food Order'), findsOneWidget);
      expect(find.text('PREPARING'), findsOneWidget);
      expect(find.text('Golden Butter Gourmet Popcorn'), findsOneWidget);

      // Linked Parking Pass
      expect(find.text('PARKING PASS'), findsOneWidget);
      expect(find.text('Basement 2 Four Wheeler Valet'), findsOneWidget);

      // Action Buttons
      expect(find.text('Directions'), findsOneWidget);
      expect(find.text('Venue Map'), findsOneWidget);
      expect(find.text('Order Food'), findsOneWidget);
      expect(find.text('Transfer'), findsOneWidget);
      expect(find.text('Add to Calendar'), findsOneWidget);

      // Flip button
      final flipButton = find.byKey(const Key('flip_ticket_button'));
      expect(flipButton, findsOneWidget);

      // Tap flip to reveal QR code
      await tester.tap(flipButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // After 3D flip, QR image view and brightness banner should be visible
      expect(find.byType(QrImageView), findsWidgets);
      expect(find.text('Screen Brightness Boosted for Scanner'), findsOneWidget);
      expect(find.text('Seat 1 of 2'), findsOneWidget);

      // Swipe to seat 2
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Seat 2 of 2'), findsOneWidget);

      // Open Transfer Ticket Sheet
      await tester.tap(find.text('Transfer'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(TransferTicketSheet), findsOneWidget);
      expect(find.text('Select Seats'), findsOneWidget);

      // Close transfer sheet
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Open Venue Map
      await tester.tap(find.text('Venue Map'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(VenueMapSheet), findsOneWidget);
      expect(find.text('Venue Map & Directions'), findsOneWidget);
    });
  });
}
