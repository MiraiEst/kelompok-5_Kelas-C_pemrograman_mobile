import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imagi_auction/domain/models/listing.dart';
import 'package:imagi_auction/l10n/l10n.dart';
import 'package:imagi_auction/ui/theme/app_theme.dart';

/// Use the platform font in tests (no Google Fonts download).
void useTestFonts() => appTextTheme = ([base]) => base ?? const TextTheme();

/// Pumps [child] inside the app theme + localizations with provider overrides.
Future<void> pumpApp(WidgetTester tester, Widget child, {List overrides = const []}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [...overrides],
      child: MaterialApp(
        theme: buildAppTheme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    ),
  );
}

Listing fakeListing({
  String id = 'l1',
  String title = 'Vintage camera',
  int currentPrice = 305000,
  int startPrice = 100000,
  int bidCount = 8,
  String? leaderId = 'someone',
  int? leaderMax = 400000,
  Duration endsIn = const Duration(hours: 2),
  int? buyNowPrice,
}) => Listing(
  id: id,
  sellerId: 'seller',
  sellerName: 'seller',
  title: title,
  description: '',
  category: 'smartphones',
  condition: ItemCondition.used,
  imageUrls: const [],
  startPrice: startPrice,
  reservePrice: null,
  buyNowPrice: buyNowPrice,
  shippingCost: 25000,
  endsAt: DateTime.now().add(endsIn),
  createdAt: DateTime.now(),
  status: ListingStatus.active,
  currentPrice: currentPrice,
  bidCount: bidCount,
  bidderIds: const ['someone'],
  leaderId: leaderId,
  leaderName: 's***e',
  leaderMax: leaderMax,
  reserveMet: true,
  buyNowAvailable: buyNowPrice != null && bidCount == 0,
  watcherCount: 3,
  winnerId: null,
  finalPrice: null,
);
