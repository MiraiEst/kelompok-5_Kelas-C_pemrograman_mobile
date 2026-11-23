import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imagi_auction/providers/providers.dart';
import 'package:imagi_auction/ui/listing/place_bid_sheet.dart';
import 'package:imagi_auction/ui/widgets/buttons.dart';

import '../helpers.dart';

void main() {
  setUpAll(useTestFonts);

  // Current Rp 305.000 -> increment 5.000 -> minimum Rp 310.000.
  final listing = fakeListing(currentPrice: 305000);

  List overrides() => [
    authStateProvider.overrideWith((ref) => Stream<User?>.value(null)),
    listingProvider('l1').overrideWith((ref) => Stream.value(listing)),
    myMaxProvider('l1').overrideWith((ref) => Stream.value(null)),
  ];

  Future<void> pumpSheet(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    addTearDown(tester.view.reset);
    await pumpApp(
      tester,
      const Scaffold(body: PlaceBidSheet(listingId: 'l1')),
      overrides: overrides(),
    );
    await tester.pump();
  }

  PrimaryButton confirmButton(WidgetTester tester) => tester.widget(find.byType(PrimaryButton));

  testWidgets('shows the minimum and quick-fill chips', (tester) async {
    await pumpSheet(tester);
    expect(find.text('Place your maximum bid'), findsOneWidget);
    expect(find.text('Enter Rp 310.000 or more'), findsOneWidget);
    expect(find.text('Rp 310.000'), findsOneWidget);
    expect(find.text('Rp 320.000'), findsOneWidget); // + 2 increments
    expect(find.text('Rp 335.000'), findsOneWidget); // + 5 increments
    expect(confirmButton(tester).onPressed, isNull);
  });

  testWidgets('amount below the minimum shows an error and disables confirm', (tester) async {
    await pumpSheet(tester);
    await tester.enterText(find.byKey(const Key('bidAmount')), '300000');
    await tester.pump();

    expect(find.text('300.000'), findsOneWidget); // thousands formatting
    expect(confirmButton(tester).onPressed, isNull);
    // The helper turns into an error message.
    final field = tester.widget<TextField>(find.byKey(const Key('bidAmount')));
    expect(field.decoration?.errorText, 'Enter Rp 310.000 or more');
  });

  testWidgets('valid amount enables confirm with the amount in the label', (tester) async {
    await pumpSheet(tester);
    await tester.tap(find.text('Rp 335.000'));
    await tester.pump();

    expect(find.text('Confirm bid · Rp 335.000'), findsOneWidget);
    expect(confirmButton(tester).onPressed, isNotNull);
  });

  test('addIncrements follows the increment table', () {
    expect(addIncrements(310000, 0), 310000);
    expect(addIncrements(310000, 2), 320000);
    expect(addIncrements(310000, 5), 335000);
    expect(addIncrements(495000, 2), 510000); // crosses into the 10.000 tier
  });
}
