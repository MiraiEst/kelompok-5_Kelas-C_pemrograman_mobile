import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/l10n.dart';
import '../../core/extensions.dart';
import '../../domain/models/listing.dart';
import '../../providers/providers.dart';
import '../theme/app_theme.dart';
import 'common.dart';

/// Photo in a white rounded card with a soft shadow and a live
/// "00:14:05" countdown badge in the top-left corner.
class _BadgedPhoto extends ConsumerWidget {
  const _BadgedPhoto({required this.listing, required this.height});
  final Listing listing;
  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const radius = BorderRadius.all(Radius.circular(AppRadius.photoSmall));
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: radius,
        boxShadow: [BoxShadow(color: Color(0x29000000), blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: Stack(
        children: [
          ListingImage(
            url: listing.thumbnail,
            width: double.infinity,
            height: height,
            borderRadius: radius,
          ),
          Positioned(
            left: 6,
            top: 6,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.brandBright,
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                child: CountdownText(
                  endsAt: listing.endsAt,
                  style: const TextStyle(
                    color: AppColors.onInk,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                  onFinished: () => ref.read(auctionCloserProvider).ensureClosed(listing),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Hot deals" card: 136 wide, badged photo, 1-line title, bold price.
class EndingSoonCard extends StatelessWidget {
  const EndingSoonCard({super.key, required this.listing});
  final Listing listing;

  static const width = 136.0;
  static const photoHeight = 90.0;

  /// Row height for the horizontal list at the given text scale
  /// (includes room for the photo shadow).
  static double height(double textScale) => photoHeight + 12 + 44 * textScale;

  @override
  Widget build(BuildContext context) {
    final l = listing;
    return Semantics(
      button: true,
      label: '${l.title}, ${l.currentPrice.toRupiah()}',
      child: InkWell(
        onTap: () => context.push('/listing/${l.id}'),
        borderRadius: BorderRadius.circular(AppRadius.photoSmall),
        child: SizedBox(
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BadgedPhoto(listing: l, height: photoHeight),
              const SizedBox(height: 8),
              Text(
                l.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.caption.copyWith(color: AppColors.ink),
              ),
              const SizedBox(height: 2),
              Text(
                l.currentPrice.toRupiah(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Grid card: badged photo, 1-line title, large price, "7 bids · 12h 40m".
class AuctionGridCard extends ConsumerWidget {
  const AuctionGridCard({super.key, required this.listing});
  final Listing listing;

  static const photoHeight = 116.0;

  /// Height for a grid cell at the current text scale.
  static double extent(BuildContext context) =>
      photoHeight + 14 + MediaQuery.textScalerOf(context).scale(1) * 80;

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
        borderRadius: BorderRadius.circular(AppRadius.photoSmall),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BadgedPhoto(listing: l, height: photoHeight),
            const SizedBox(height: 8),
            Text(l.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.small),
            const SizedBox(height: 2),
            Text(
              price.toRupiah(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            CountdownText(
              endsAt: l.endsAt,
              prefix:
                  '${showBuyNow ? context.l10n.buyItNowPrefix : context.l10n.nBidsPrefix(l.bidCount)} ',
              format: (d) => d.toShort(),
              style: const TextStyle(fontSize: 11, color: AppColors.ink),
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
      SkeletonBox(height: AuctionGridCard.photoHeight, width: double.infinity),
      SizedBox(height: 8),
      SkeletonBox(height: 12, width: 120, radius: 4),
      SizedBox(height: 6),
      SkeletonBox(height: 16, width: 90, radius: 4),
      SizedBox(height: 6),
      SkeletonBox(height: 10, width: 100, radius: 4),
    ],
  );
}
