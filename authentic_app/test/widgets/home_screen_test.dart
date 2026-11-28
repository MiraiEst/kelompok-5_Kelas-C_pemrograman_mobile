import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imagi_auction/domain/models/listing.dart';
import 'package:imagi_auction/providers/providers.dart';
import 'package:imagi_auction/ui/home/home_screen.dart';
import 'package:imagi_auction/ui/widgets/auction_cards.dart';

import '../helpers.dart';

void main() {
  setUpAll(useTestFonts);

  final listings = [
    fakeListing(id: 'a', title: 'Vintage camera'),
    fakeListing(id: 'b', title: 'Mechanical keyboard', currentPrice: 750000),
  ];

  List overrides({List<Listing>? feed}) => [
    authStateProvider.overrideWith((ref) => Stream<User?>.value(null)),
    homeFeedProvider.overrideWith((ref) => Stream.value((items: feed ?? listings, hasMore: false))),
    endingSoonProvider.overrideWith((ref) => Stream.value(listings)),
    unreadCountProvider.overrideWithValue(3),
  ];

  testWidgets('shows header, search, sections and auction cards', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    addTearDown(tester.view.reset);
    await pumpApp(tester, const HomeScreen(), overrides: overrides());
    await tester.pump();

    expect(find.bySemanticsLabel('Authentic'), findsOneWidget);
    expect(find.text('Search auctions'), findsOneWidget);
    expect(find.text('Hot deals'), findsOneWidget);
    expect(find.text('All auctions'), findsOneWidget);
    expect(find.byType(AuctionGridCard), findsNWidgets(2));
    expect(find.byType(EndingSoonCard), findsNWidgets(2));
    // Shown in both "Hot deals" and the grid.
    expect(find.text('Mechanical keyboard'), findsNWidgets(2));
    expect(find.text('Sell'), findsOneWidget);
    expect(find.byTooltip('Notifications, 3 unread'), findsOneWidget);
  });

  testWidgets('search filters the grid by title', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    addTearDown(tester.view.reset);
    await pumpApp(tester, const HomeScreen(), overrides: overrides());
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'keyboard');
    await tester.pump(const Duration(milliseconds: 350)); // debounce
    await tester.pump();

    expect(find.byType(AuctionGridCard), findsOneWidget);
    expect(find.text('Mechanical keyboard'), findsOneWidget);
  });

  testWidgets('empty feed shows the empty state', (tester) async {
    await pumpApp(tester, const HomeScreen(), overrides: overrides(feed: const []));
    await tester.pump();
    expect(find.text('No active auctions yet'), findsOneWidget);
  });

  testWidgets('no overflow with system font at 130%', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpApp(tester, const HomeScreen(), overrides: overrides());
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(AuctionGridCard), findsNWidgets(2));
  });
}
