import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/extensions.dart';
import '../../domain/models/app_user.dart';
import '../../domain/models/bid.dart';
import '../../domain/models/listing.dart';
import '../../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/buttons.dart';
import '../widgets/common.dart';
import '../widgets/section_header.dart';
import '../widgets/user_avatar.dart';
import 'place_bid_sheet.dart';

/// "Sun 22 Nov, 18:30" in the device time zone.
final endDateFormat = DateFormat('EEE d MMM, HH:mm');

class ListingDetailScreen extends ConsumerWidget {
  const ListingDetailScreen({super.key, required this.listingId});
  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listing = ref.watch(listingProvider(listingId));
    final user = ref.watch(currentUserProvider).value;

    return switch (listing) {
      AsyncValue(:final value?) when user != null => _Detail(listing: value, user: user),
      AsyncValue(:final error?) when !listing.hasValue => Scaffold(
        appBar: AppBar(),
        body: ErrorText(error, onRetry: () => ref.invalidate(listingProvider(listingId))),
      ),
      AsyncData() => Scaffold(
        appBar: AppBar(),
        body: const EmptyState(icon: Icons.search_off, text: 'This listing no longer exists.'),
      ),
      _ => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
    };
  }
}

class _Detail extends ConsumerWidget {
  const _Detail({required this.listing, required this.user});
  final Listing listing;
  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = listing;
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final category = categories.where((c) => c.slug == l.category).firstOrNull?.name ?? l.category;
    final meta = [
      l.condition.label,
      category,
      if (l.location != null && l.location!.isNotEmpty) 'Ships from ${l.location}',
    ].join(' · ');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _Gallery(listing: l, user: user),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            sliver: SliverList.list(
              children: [
                Text(l.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppText.title),
                const SizedBox(height: 4),
                Text(meta, style: AppText.meta),
                const SizedBox(height: 12),
                _SellerRow(listing: l),
                const SizedBox(height: 12),
                _StatusBanner(listing: l, user: user),
                _PriceCard(listing: l),
                if (user.isAdmin || l.sellerId == user.uid) _SellerControls(listing: l, user: user),
                const SizedBox(height: 24),
                const SectionHeader('Description'),
                const SizedBox(height: 6),
                _Description(text: l.description),
                const SizedBox(height: 16),
                _InfoTable(listing: l),
                const SizedBox(height: 24),
                _BidHistorySection(listing: l),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomBar(listing: l, user: user),
    );
  }
}

// ---------------------------------------------------------------------------
// Gallery
// ---------------------------------------------------------------------------

class _Gallery extends ConsumerStatefulWidget {
  const _Gallery({required this.listing, required this.user});
  final Listing listing;
  final AppUser user;

  @override
  ConsumerState<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends ConsumerState<_Gallery> {
  int _page = 0;

  void _openFullScreen(int index) {
    final urls = widget.listing.imageUrls;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => _FullScreenGallery(urls: urls, initial: index),
      ),
    );
  }

  Future<void> _share() async {
    final l = widget.listing;
    await SharePlus.instance.share(
      ShareParams(
        text:
            '${l.title} · ${l.currentPrice.toRupiah()} on Imagi Auction\nimagiauction://listing/${l.id}',
        subject: l.title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.listing;
    final urls = l.imageUrls;
    final watched = ref.watch(watchlistIdsProvider).value?.contains(l.id) ?? false;
    final canWatch = l.sellerId != widget.user.uid;

    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          Positioned.fill(
            child: urls.isEmpty
                ? const ListingImage(url: null)
                : PageView.builder(
                    itemCount: urls.length,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (_, i) => GestureDetector(
                      onTap: () => _openFullScreen(i),
                      child: ListingImage(
                        url: urls[i],
                        semanticLabel: 'Photo ${i + 1} of ${urls.length}. Tap to zoom.',
                      ),
                    ),
                  ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    RoundIconButton(
                      icon: Icons.arrow_back,
                      tooltip: 'Back',
                      onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
                    ),
                    const Spacer(),
                    RoundIconButton(
                      icon: Icons.share_outlined,
                      tooltip: 'Share',
                      onPressed: _share,
                    ),
                    if (canWatch) ...[
                      const SizedBox(width: 8),
                      RoundIconButton(
                        icon: watched ? Icons.favorite : Icons.favorite_border,
                        tooltip: watched ? 'Remove from watchlist' : 'Add to watchlist',
                        onPressed: () =>
                            ref.read(userRepositoryProvider).toggleWatch(widget.user.uid, l),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (urls.length > 1)
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.ink.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  '${_page + 1} / ${urls.length}',
                  style: const TextStyle(color: AppColors.onInk, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FullScreenGallery extends StatelessWidget {
  const _FullScreenGallery({required this.urls, required this.initial});
  final List<String> urls;
  final int initial;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.photoViewer,
    appBar: AppBar(
      backgroundColor: AppColors.photoViewer,
      foregroundColor: AppColors.onInk,
      leading: IconButton(
        tooltip: 'Close',
        icon: const Icon(Icons.close),
        onPressed: () => Navigator.of(context).pop(),
      ),
    ),
    body: PageView.builder(
      controller: PageController(initialPage: initial),
      itemCount: urls.length,
      itemBuilder: (_, i) => InteractiveViewer(
        maxScale: 5,
        child: Center(
          child: ListingImage(url: urls[i], fit: BoxFit.contain),
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Seller, status banner, price card
// ---------------------------------------------------------------------------

class _SellerRow extends ConsumerWidget {
  const _SellerRow({required this.listing});
  final Listing listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(publicProfileProvider(listing.sellerId)).value;
    final name = listing.sellerName.masked();
    final rating = profile?.summary() ?? 'New seller';
    return Semantics(
      button: true,
      label: 'Seller $name, $rating',
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.input),
        onTap: () => showModalBottomSheet<void>(
          context: context,
          builder: (_) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: double.infinity), // full-width sheet
                  UserAvatar(name: listing.sellerName, size: 64),
                  const SizedBox(height: 12),
                  Text('$name (seller)', style: AppText.sectionTitle),
                  const SizedBox(height: 4),
                  Text(rating, style: AppText.meta),
                  if (profile?.memberSince != null)
                    Text('Member since ${profile!.memberSince!.year}', style: AppText.meta),
                ],
              ),
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              UserAvatar(name: listing.sellerName, size: 36),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$name (seller)', style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(rating, style: AppText.caption),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

/// Personal status for the signed-in user. Hidden if they never bid.
class _StatusBanner extends ConsumerWidget {
  const _StatusBanner({required this.listing, required this.user});
  final Listing listing;
  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = listing;
    final uid = user.uid;
    final didBid = l.bidderIds.contains(uid) || l.winnerId == uid;
    if (!didBid) return const SizedBox();
    final ended = !l.isLive(DateTime.now());
    final myMax = ref.watch(myMaxProvider(l.id)).value;

    // Advanced Dart: switch expression over a record with guards.
    final (message, action) = switch ((ended, l.leaderId == uid)) {
      (true, _) when l.winnerId == uid => ('You won this item!', true),
      (true, _) => ("You didn't win this item.", false),
      (false, true) => (
        "You're the highest bidder · your max ${(myMax ?? l.leaderMax ?? l.currentPrice).toRupiah()}",
        false,
      ),
      (false, false) => ("You've been outbid. Raise your max to get back in.", false),
    };

    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.ink, width: 2),
          borderRadius: BorderRadius.circular(AppRadius.input),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(message, style: const TextStyle(fontWeight: FontWeight.w700)),
            if (action) ...[
              const SizedBox(height: 10),
              PrimaryButton(label: 'Pay now', onPressed: () => context.push('/checkout/${l.id}')),
            ],
          ],
        ),
      ),
    );
  }
}

class _PriceCard extends ConsumerWidget {
  const _PriceCard({required this.listing});
  final Listing listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = listing;
    final bids = ref.watch(bidsProvider(l.id)).value ?? const <Bid>[];
    final bidders = bids.map((b) => b.userId).toSet().length;
    final price = l.isBuyNowOnly
        ? l.finalPrice ?? l.buyNowPrice ?? l.currentPrice
        : l.finalPrice ?? l.currentPrice;
    final label = switch (l) {
      _ when l.isBuyNowOnly => 'Buy It Now price',
      _ when l.isActive => 'Current price',
      _ => 'Final price',
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.caption),
          Text(price.toRupiah(), style: AppText.priceHero),
          _Conversion(amountIdr: price),
          const SizedBox(height: 10),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              if (!l.isBuyNowOnly) ...[
                Text('${l.bidCount} bids', style: AppText.small),
                Text('$bidders bidders', style: AppText.small),
              ],
              Text('${l.watcherCount} watching', style: AppText.small),
              if (l.hasReserve && !l.isBuyNowOnly)
                Text(
                  l.reserveMet ? 'Reserve met' : 'Reserve not met',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider()),
          if (l.isActive)
            Row(
              children: [
                Expanded(
                  child: CountdownText(
                    endsAt: l.endsAt,
                    prefix: 'Ends in ',
                    style: AppText.emphasis,
                    onFinished: () => ref.read(auctionCloserProvider).ensureClosed(l),
                  ),
                ),
                Text(endDateFormat.format(l.endsAt), style: AppText.caption),
              ],
            )
          else
            Text(switch (l.status) {
              ListingStatus.sold => 'Sold',
              ListingStatus.unsold => 'Ended · not sold',
              ListingStatus.ended => 'Ended by seller',
              ListingStatus.active => '',
            }, style: AppText.emphasis),
        ],
      ),
    );
  }
}

/// Price in other currencies via the open-source Frankfurter API.
class _Conversion extends ConsumerWidget {
  const _Conversion({required this.amountIdr});
  final int amountIdr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rates = ref.watch(idrRatesProvider);
    return rates.maybeWhen(
      data: (r) {
        String fmt(String code, String symbol) {
          final rate = r[code];
          return rate == null ? '' : '$symbol${(amountIdr * rate).toStringAsFixed(2)}';
        }

        final parts = [
          fmt('USD', r'$'),
          fmt('EUR', '€'),
          fmt('SGD', r'S$'),
        ].where((s) => s.isNotEmpty);
        return Text('≈ ${parts.join(' · ')}', style: AppText.caption);
      },
      orElse: () => const SizedBox(),
    );
  }
}

// ---------------------------------------------------------------------------
// Description, info table, bid history
// ---------------------------------------------------------------------------

class _Description extends StatefulWidget {
  const _Description({required this.text});
  final String text;

  @override
  State<_Description> createState() => _DescriptionState();
}

class _DescriptionState extends State<_Description> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final text = widget.text.isEmpty ? '-' : widget.text;
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: text, style: AppText.body),
          maxLines: 4,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: constraints.maxWidth);
        final overflows = painter.didExceedMaxLines;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: AppText.body,
              maxLines: _expanded ? null : 4,
              overflow: _expanded ? null : TextOverflow.ellipsis,
            ),
            if (overflows || _expanded)
              TextButton(
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                onPressed: () => setState(() => _expanded = !_expanded),
                child: Text(_expanded ? 'Show less' : 'Read more'),
              ),
          ],
        );
      },
    );
  }
}

class _InfoTable extends StatelessWidget {
  const _InfoTable({required this.listing});
  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final l = listing;
    final hasNewFields = l.handlingDays != null;
    final rows = [
      (
        'Shipping',
        l.shippingCost == 0
            ? 'Free · JNE / SiCepat'
            : '${l.shippingCost.toRupiah()} · JNE / SiCepat',
      ),
      ('Handling time', hasNewFields ? 'Ships in ${l.handlingDays} days' : '-'),
      (
        'Returns',
        !hasNewFields
            ? '-'
            : l.acceptsReturns
            ? '${l.returnDays} days · buyer protection'
            : 'No returns',
      ),
    ];
    return Column(
      children: [
        for (final (label, value) in rows)
          Container(
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.line)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 120, child: Text(label, style: AppText.meta)),
                Expanded(child: Text(value, style: AppText.small)),
              ],
            ),
          ),
      ],
    );
  }
}

class _BidHistorySection extends ConsumerWidget {
  const _BidHistorySection({required this.listing});
  final Listing listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (listing.isBuyNowOnly) return const SizedBox();
    final bids = ref.watch(bidsProvider(listing.id));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader('Bid history'),
        switch (bids) {
          AsyncValue(:final value?) when value.isEmpty => const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('No bids yet.', style: AppText.meta),
          ),
          AsyncValue(:final value?) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BidHistoryList(bids: value, limit: 3),
              if (value.length > 3)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      builder: (_) => DraggableScrollableSheet(
                        expand: false,
                        initialChildSize: 0.7,
                        builder: (_, controller) => ListView(
                          controller: controller,
                          padding: const EdgeInsets.all(16),
                          children: [
                            SectionHeader('All ${value.length} bids'),
                            BidHistoryList(bids: value),
                          ],
                        ),
                      ),
                    ),
                    child: Text('See all ${value.length} bids'),
                  ),
                ),
            ],
          ),
          AsyncValue(:final error?) => Text(friendlyError(error), style: AppText.meta),
          _ => const LinearProgressIndicator(),
        },
        const SizedBox(height: 8),
        const Text("Names are masked. Nobody's maximum bid is ever shown.", style: AppText.caption),
      ],
    );
  }
}

class BidHistoryList extends StatelessWidget {
  const BidHistoryList({super.key, required this.bids, this.limit});
  final List<Bid> bids;
  final int? limit;

  @override
  Widget build(BuildContext context) {
    final perBidder = <String, int>{};
    for (final b in bids) {
      perBidder.update(b.userId, (c) => c + 1, ifAbsent: () => 1);
    }
    final shown = limit == null ? bids : bids.take(limit!);
    final fmt = DateFormat('d MMM, HH:mm');
    return Column(
      children: [
        for (final b in shown)
          Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.line)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          text: b.maskedName,
                          children: [
                            TextSpan(
                              text: ' (${perBidder[b.userId]} bids)',
                              style: const TextStyle(color: AppColors.muted),
                            ),
                          ],
                        ),
                        style: AppText.small,
                      ),
                      Text(fmt.format(b.createdAt), style: AppText.caption),
                    ],
                  ),
                ),
                Text(b.priceAfter.toRupiah(), style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Seller / admin controls and sticky bottom bar
// ---------------------------------------------------------------------------

class _SellerControls extends ConsumerWidget {
  const _SellerControls({required this.listing, required this.user});
  final Listing listing;
  final AppUser user;

  Future<void> _end(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('End this listing?'),
        content: const Text('It will be removed from search right away.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('End listing')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(listingRepositoryProvider).endEarly(listing, user);
      if (context.mounted) showSnack(context, 'Listing ended.');
    } catch (e) {
      if (context.mounted) showSnack(context, friendlyError(e));
    }
  }

  Future<void> _relist(BuildContext context, WidgetRef ref) async {
    try {
      final id = await ref
          .read(listingRepositoryProvider)
          .relist(listing, user, AuctionDuration.sevenDays);
      if (context.mounted) {
        showSnack(context, 'Relisted for 7 days.');
        context.pushReplacement('/listing/$id');
      }
    } catch (e) {
      if (context.mounted) showSnack(context, friendlyError(e));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = listing;
    final isSeller = l.sellerId == user.uid;
    final canEnd = l.isActive && (l.bidCount == 0 || user.isAdmin);
    final canRelist =
        isSeller && (l.status == ListingStatus.unsold || l.status == ListingStatus.ended);
    if (!canEnd && !canRelist) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (user.isAdmin && !isSeller)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text('Admin controls', style: AppText.groupLabel),
            ),
          if (canEnd) SecondaryButton(label: 'End listing', onPressed: () => _end(context, ref)),
          if (canRelist)
            PrimaryButton(label: 'Relist (7 days)', onPressed: () => _relist(context, ref)),
        ],
      ),
    );
  }
}

class _BottomBar extends ConsumerWidget {
  const _BottomBar({required this.listing, required this.user});
  final Listing listing;
  final AppUser user;

  Future<void> _buyNow(BuildContext context, WidgetRef ref) async {
    final price = listing.buyNowPrice!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Buy It Now'),
        content: Text('Buy "${listing.title}" for ${price.toRupiah()}? This ends the listing.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Buy')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(listingRepositoryProvider).buyNow(listingId: listing.id, buyer: user);
      if (context.mounted) showSnack(context, 'You bought it!');
    } catch (e) {
      if (context.mounted) showSnack(context, friendlyError(e));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = listing;
    final now = DateTime.now();
    if (!l.isLive(now) || l.sellerId == user.uid) return const SizedBox.shrink();
    final isLeader = l.leaderId == user.uid;
    final showBuyNow = l.canBuyNow(now);

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (l.isBuyNowOnly)
                PrimaryButton(
                  label: 'Buy It Now · ${(l.buyNowPrice ?? 0).toRupiah()}',
                  onPressed: showBuyNow ? () => _buyNow(context, ref) : null,
                )
              else ...[
                if (showBuyNow) ...[
                  SecondaryButton(
                    label: 'Buy It Now ${l.buyNowPrice!.toRupiah()}',
                    onPressed: () => _buyNow(context, ref),
                  ),
                  const SizedBox(height: 10),
                ],
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Minimum bid', style: AppText.caption),
                          Text(l.minimumNextBid.toRupiah(), style: AppText.emphasis),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: PrimaryButton(
                        label: isLeader ? 'Raise max bid' : 'Place max bid',
                        onPressed: () => showPlaceBidSheet(context, l.id),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
