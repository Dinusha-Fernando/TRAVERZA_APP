import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('TRAVERZA Traveller App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TraverzaApp());

    // Verify that the core Trip Timeline renders with Truthful status
    expect(find.text('Trip Timeline'), findsOneWidget);
    expect(find.text('Partially Confirmed (2/3)'), findsOneWidget);
    expect(find.text('ID: TRIP-LK-2026-9041'), findsOneWidget);
  });
}
