import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/l10n.dart';
import '../../core/extensions.dart';
import '../../domain/models/listing.dart';
import '../../providers/providers.dart';
import '../theme/app_theme.dart';
import 'common.dart';

/// "Ending soon" card: 140 wide, photo 140x104, price, live "Ends in".
class EndingSoonCard extends ConsumerWidget {
  const EndingSoonCard({super.key, required this.listing});
  final Listing listing;

  static const width = 140.0;

  /// Row height for the horizontal list at the given text scale.
  static double height(double textScale) => 104 + 10 + 56 * textScale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = listing;
    return Semantics(
      button: true,
      label: '${l.title}, ${l.currentPrice.toRupiah()}',
      child: InkWell(
        onTap: () => context.push('/listing/${l.id}'),
        borderRadius: BorderRadius.circular(AppRadius.photo),
        child: SizedBox(
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListingImage(
                url: l.thumbnail,
                width: width,
                height: 104,
                borderRadius: BorderRadius.circular(AppRadius.photo),
              ),
              const SizedBox(height: 8),
              Text(l.currentPrice.toRupiah(), style: AppText.price, maxLines: 1),
              const SizedBox(height: 2),
              CountdownText(
                endsAt: l.endsAt,
                prefix: context.l10n.endsIn,
                style: AppText.caption,
                onFinished: () => ref.read(auctionCloserProvider).ensureClosed(l),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Grid card: photo 130 high, 2-line title, price, "12 bids · 3h 20m".
class AuctionGridCard extends ConsumerWidget {
  const AuctionGridCard({super.key, required this.listing});
  final Listing listing;

  /// Height for a grid cell at the current text scale.
  static double extent(BuildContext context) =>
      130 + 14 + MediaQuery.textScalerOf(context).scale(1) * 100;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = listing;
    final showBuyNow = l.buyNowPrice != null && l.bidCount == 0 && l.buyNowAvailable;
    final price = l.isBuyNowOnly ? l.buyNowPrice ?? l.currentPrice : l.currentPrice;
    return Semantics(
      button: true,
      label: context.l10n.auctionCardSemantics(l.title, price.toRupiah(), l.bidCount),
      excludeSemantics: true,
      child: InkWell(
        onTap: () => context.push('/listing/${l.id}'),
        borderRadius: BorderRadius.circular(AppRadius.photo),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListingImage(
              url: l.thumbnail,
              width: double.infinity,
              height: 130,
              borderRadius: BorderRadius.circular(AppRadius.photo),
            ),
            const SizedBox(height: 8),
            Text(l.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppText.small),
            const SizedBox(height: 4),
            Text(price.toRupiah(), style: AppText.price, maxLines: 1),
            const SizedBox(height: 2),
            CountdownText(
              endsAt: l.endsAt,
              prefix: showBuyNow
                  ? context.l10n.buyItNowPrefix
                  : context.l10n.nBidsPrefix(l.bidCount),
              format: (d) => d.toShort(),
              style: AppText.caption,
              onFinished: () => ref.read(auctionCloserProvider).ensureClosed(l),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grey skeleton for the grid while loading.
class AuctionGridSkeleton extends StatelessWidget {
  const AuctionGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SkeletonBox(height: 130, width: double.infinity),
      SizedBox(height: 8),
      SkeletonBox(height: 12, width: 120, radius: 4),
      SizedBox(height: 6),
      SkeletonBox(height: 14, width: 80, radius: 4),
      SizedBox(height: 6),
      SkeletonBox(height: 10, width: 100, radius: 4),
    ],
  );
}
