import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/widgets/ticket_stub_card.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget buildTestTicket({required bool isDark}) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: isDark ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: isDark ? AppColors.midnight : AppColors.lightBackground,
      ),
      home: Scaffold(
        backgroundColor: isDark ? AppColors.midnight : AppColors.lightBackground,
        body: Center(
          child: SizedBox(
            width: 360,
            child: TicketStubCard(
              backgroundColor: isDark ? AppColors.surface : Colors.white,
              topChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'CINEMA PASS',
                        style: TextStyle(
                          color: AppColors.spotlightCoral,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.marqueeAmber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'IMAX 3D',
                          style: TextStyle(
                            color: AppColors.marqueeAmber,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Dune: Part Two',
                    style: TextStyle(
                      color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'PVR ICON: Phoenix Palladium • Audi 4',
                    style: TextStyle(
                      color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('DATE', style: TextStyle(color: Colors.grey, fontSize: 10)),
                            Text('Sat, 3 Oct', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('TIME', style: TextStyle(color: Colors.grey, fontSize: 10)),
                            Text('7:30 PM', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('SEATS', style: TextStyle(color: Colors.grey, fontSize: 10)),
                            Text('A5, A6', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              bottomChild: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('BOOKING ID', style: TextStyle(color: Colors.grey, fontSize: 10)),
                      Text('SS-202610-8901', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  Icon(Icons.qr_code_2_rounded, size: 40, color: AppColors.spotlightCoral),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  group('TicketStubCard Golden Tests', () {
    testWidgets('TicketStubCard matches golden in Dark Theme', (tester) async {
      tester.view.physicalSize = const Size(500, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestTicket(isDark: true));
      await tester.pumpAndSettle();

      expect(find.byType(TicketStubCard), findsOneWidget);
      await expectLater(
        find.byType(TicketStubCard),
        matchesGoldenFile('goldens/ticket_stub_card_dark.png'),
      );
    });

    testWidgets('TicketStubCard matches golden in Light Theme', (tester) async {
      tester.view.physicalSize = const Size(500, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestTicket(isDark: false));
      await tester.pumpAndSettle();

      expect(find.byType(TicketStubCard), findsOneWidget);
      await expectLater(
        find.byType(TicketStubCard),
        matchesGoldenFile('goldens/ticket_stub_card_light.png'),
      );
    });
  });
}
