import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/bookings/data/booking_models.dart';
import 'package:mobile/features/bookings/presentation/bookings_tab_screen.dart';
import 'package:mobile/features/bookings/presentation/widgets/booking_detail_sheet.dart';
import 'package:mobile/features/bookings/presentation/widgets/service_detail_modal.dart';
import 'package:mobile/theme/app_theme.dart';

void main() {
  testWidgets('BookingTabScreen: Explore mode displays corridor, segmented switch, and verified services', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: const Scaffold(
          body: BookingsTabScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Header and Corridor Context
    expect(find.text('Services for your trip'), findsOneWidget);
    expect(find.textContaining('Colombo (CMB) → Sigiriya → Kandy → Nuwara Eliya'), findsOneWidget);
    expect(find.text('Fit-to-Trip Verified Services'), findsOneWidget);

    // 2. Dual-mode Segmented Switch
    expect(find.text('Explore Services'), findsOneWidget);
    expect(find.text('My Bookings (4)'), findsOneWidget);

    // 3. Category shortcuts & inventory cards
    expect(find.text('All'), findsWidgets);
    expect(find.text('Transport'), findsWidgets);
    expect(find.text('Stays'), findsWidgets);
    expect(find.text('Guides'), findsWidgets);

    expect(find.text('Airport to Sigiriya Luxury Transfer'), findsOneWidget);
    expect(find.text('Sigiriya Water Garden Eco Villa'), findsOneWidget);
    expect(find.text('Sigiriya Rock Fortress Guided Archaeological Ascent'), findsOneWidget);

    // 4. Verification badges and Fit-to-Trip indicators
    expect(find.text('SLTDA Verified'), findsWidgets);
    expect(find.text('Matches Day 1 arrival corridor · Verified highway transit buffer'), findsOneWidget);
  });

  testWidgets('BookingTabScreen: filter chips and search bar interaction', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: const Scaffold(
          body: BookingsTabScreen(
            initialCategory: 'TRANSFER',
            initialSearchQuery: 'Sigiriya',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial active filter chips
    expect(find.text('Filtered: TRANSFER'), findsOneWidget);
    expect(find.text('Search: "Sigiriya"'), findsOneWidget);

    // Tap on the Search filter chip to remove it
    await tester.tap(find.text('Search: "Sigiriya"'));
    await tester.pumpAndSettle();

    // Verify search chip is cleared while Category chip remains
    expect(find.text('Search: "Sigiriya"'), findsNothing);
    expect(find.text('Filtered: TRANSFER'), findsOneWidget);
  });

  testWidgets('ServiceDetailModal: opens from card and displays quote snapshot and transparent terms', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final service = TraverzaServiceItem.getCuratedInventory().first;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => ServiceDetailModal.show(
                context,
                service: service,
                onAddToTrip: () {},
                onRequestBooking: () {},
              ),
              child: const Text('Open Service Modal'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Service Modal'));
    await tester.pumpAndSettle();

    // Verify modal contents
    expect(find.text(service.title), findsOneWidget);
    expect(find.text('What is verified?'), findsOneWidget);
    expect(find.text('Inclusions & Highlights'), findsOneWidget);
    expect(find.text('Cancellation & Change Terms'), findsOneWidget);
    expect(find.text('Pricing Breakdown (Quote Snapshot)'), findsOneWidget);
    expect(find.text('Base Rate'), findsOneWidget);
    expect(find.text('Total Estimated Quote'), findsOneWidget);
    expect(find.text('Request Booking'), findsOneWidget);
  });

  testWidgets('BookingTabScreen: My Bookings mode displays segmented filters, cards, and countdown', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: const Scaffold(
          body: BookingsTabScreen(
            initialMode: BookingTabMode.myBookings,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify My Bookings sub-segments
    expect(find.text('Needs Action'), findsOneWidget);
    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('Past'), findsOneWidget);
    expect(find.text('Cancelled & Refunds'), findsOneWidget);

    // Verify booking items exist in default Needs Action segment
    expect(find.text('TRIP-LK-2026-9041-B02'), findsOneWidget);
    expect(find.text('Awaiting Provider (12h SLA)'), findsOneWidget);

    // Filter by 'Upcoming'
    await tester.tap(find.text('Upcoming'));
    await tester.pumpAndSettle();

    // Needs action booking is filtered out
    expect(find.text('TRIP-LK-2026-9041-B02'), findsNothing);
    expect(find.text('TRIP-LK-2026-9041-B01'), findsOneWidget);
    expect(find.text('View Voucher'), findsWidgets);
  });

  testWidgets('BookingDetailSheet & BookingVoucherSheet: timeline events, acceptance simulation, and QR pass', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final booking = TraverzaBooking.getSampleBookings().firstWhere(
      (b) => b.status == BookingStatus.requestSubmitted,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => BookingDetailSheet.show(
                context,
                booking: booking,
                onBookingUpdated: () {},
              ),
              child: const Text('Open Booking Detail'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Booking Detail'));
    await tester.pumpAndSettle();

    // Verify Authoritative Event Timeline
    expect(find.text('Authoritative Event Timeline'), findsOneWidget);
    expect(find.text('Quote Snapshot Generated'), findsOneWidget);
    expect(find.text('Booking Request Submitted'), findsOneWidget);

    // Verify 12-Hour SLA banner and Demo Acceptance Action
    expect(find.text('Provider Response Window (12h SLA)'), findsOneWidget);
    expect(find.text('Simulate Provider Accept (Demo Mode)'), findsOneWidget);

    // Simulate provider acceptance
    await tester.tap(find.text('Simulate Provider Accept (Demo Mode)'));
    await tester.pumpAndSettle();

    // Verify status updated to Confirmed
    expect(find.text('CONFIRMED'), findsOneWidget);
    expect(find.text('View Digital Voucher'), findsOneWidget);

    // Tap View Digital Voucher to open voucher sheet
    await tester.tap(find.text('View Digital Voucher'));
    await tester.pumpAndSettle();

    // Verify Voucher pass details
    expect(find.text('TRAVERZA BOARDING PASS'), findsOneWidget);
    expect(find.textContaining('CRYPTOGRAPHIC TOKEN (SHA-256)'), findsOneWidget);
    expect(find.text('Cached for Offline Travel'), findsOneWidget);
    expect(find.text('Download PDF'), findsOneWidget);
    expect(find.text('Apple / Google Wallet'), findsOneWidget);
  });
}
