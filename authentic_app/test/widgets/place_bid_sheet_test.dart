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

  testWidgets('shows the minimum and the -/+000/+ step buttons', (tester) async {
    await pumpSheet(tester);
    expect(find.text('Place your maximum bid'), findsOneWidget);
    expect(find.text('Enter Rp 310.000 or more'), findsOneWidget);
    expect(find.text('-5.000'), findsOneWidget);
    expect(find.text('+000'), findsOneWidget);
    expect(find.text('+5.000'), findsOneWidget);
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

  testWidgets('+ fills the minimum, then steps up and down by the increment', (tester) async {
    await pumpSheet(tester);
    await tester.tap(find.byKey(const Key('bidStepUp')));
    await tester.pump();
    expect(find.text('Confirm bid · Rp 310.000'), findsOneWidget);
    expect(confirmButton(tester).onPressed, isNotNull);

    await tester.tap(find.byKey(const Key('bidStepUp')));
    await tester.pump();
    expect(find.text('Confirm bid · Rp 315.000'), findsOneWidget);

    await tester.tap(find.byKey(const Key('bidStepDown')));
    await tester.pump();
    expect(find.text('Confirm bid · Rp 310.000'), findsOneWidget);
  });

  testWidgets('+000 appends three zeros', (tester) async {
    await pumpSheet(tester);
    await tester.enterText(find.byKey(const Key('bidAmount')), '320');
    await tester.pump();
    await tester.tap(find.byKey(const Key('bidTimes1000')));
    await tester.pump();
    expect(find.text('Confirm bid · Rp 320.000'), findsOneWidget);
  });

  test('stepDown removes one increment but never goes under the minimum', () {
    expect(stepDown(315000, 310000), 310000);
    expect(stepDown(312000, 310000), 310000);
    expect(stepDown(510000, 310000), 500000); // 10.000 tier back into the 5.000 tier
  });

  test('addIncrements follows the increment table', () {
    expect(addIncrements(310000, 0), 310000);
    expect(addIncrements(310000, 2), 320000);
    expect(addIncrements(310000, 5), 335000);
    expect(addIncrements(495000, 2), 510000); // crosses into the 10.000 tier
  });
}
