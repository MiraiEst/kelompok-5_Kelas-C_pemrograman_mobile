import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/extensions.dart';
import '../../domain/models/app_user.dart';
import '../../domain/models/bid.dart';
import '../../domain/models/listing.dart';
import '../../l10n/l10n.dart';
import '../../l10n/labels.dart';
import '../../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/buttons.dart';
import '../widgets/common.dart';
import '../widgets/section_header.dart';
import '../widgets/user_avatar.dart';
import 'place_bid_sheet.dart';
import '../../domain/models/item_category.dart';

/// "Sun 22 Nov, 18:30" in the device time zone.
DateFormat get endDateFormat => DateFormat('EEE d MMM, HH:mm');

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
        body: EmptyState(icon: Icons.search_off, text: context.l10n.listingGone),
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
    final category = ItemCategory.parse(l.category).text(context);
    final meta = [
      l.condition.text(context),
      category,
      if (l.location != null && l.location!.isNotEmpty) context.l10n.shipsFrom(l.location!),
    ].join(' • ');

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
                Text(meta, style: AppText.meta.copyWith(color: AppColors.navInactive)),
                const SizedBox(height: 12),
                _PriceCard(listing: l, user: user),
                const SizedBox(height: 12),
                _SellerRow(listing: l),
                if (user.isAdmin || l.sellerId == user.uid) _SellerControls(listing: l, user: user),
                const SizedBox(height: 24),
                Semantics(
                  header: true,
                  child: Text(context.l10n.description, style: _sectionTitle),
                ),
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
            '${context.l10n.shareText(l.title, l.currentPrice.toRupiah())}\n'
            'authentic://listing/${l.id}',
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

    return Container(
      height: 340,
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.line, width: 1.5)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            top: 56,
            bottom: 28,
            child: urls.isEmpty
                ? const ListingImage(url: null)
                : PageView.builder(
                    itemCount: urls.length,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (_, i) => GestureDetector(
                      onTap: () => _openFullScreen(i),
                      child: ListingImage(
                        url: urls[i],
                        fit: BoxFit.contain,
                        semanticLabel: context.l10n.photoOf(i + 1, urls.length),
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
                      color: AppColors.ocean,
                      icon: Icons.arrow_back_ios_new,
                      tooltip: context.l10n.back,
                      onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
                    ),
                    const Spacer(),
                    RoundIconButton(
                      color: AppColors.ocean,
                      icon: Icons.ios_share,
                      tooltip: context.l10n.share,
                      onPressed: _share,
                    ),
                    if (canWatch) ...[
                      const SizedBox(width: 8),
                      RoundIconButton(
                        color: AppColors.ocean,
                        icon: watched ? Icons.bookmark : Icons.bookmark_border,
                        tooltip: watched
                            ? context.l10n.removeFromWatchlist
                            : context.l10n.addToWatchlist,
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
              right: 16,
              bottom: 6,
              child: Text(
                '${_page + 1} / ${urls.length}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
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
        tooltip: context.l10n.close,
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
    final rating = profile == null || profile.ratingCount == 0
        ? context.l10n.newSeller
        : context.l10n.ratingSummary(profile.positivePct, profile.ratingCount);
    return Semantics(
      button: true,
      label: context.l10n.sellerSemantics(name, rating),
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
                  Text(context.l10n.nameSeller(name), style: AppText.sectionTitle),
                  const SizedBox(height: 4),
                  Text(rating, style: AppText.meta),
                  if (profile?.memberSince != null)
                    Text(context.l10n.memberSince(profile!.memberSince!.year), style: AppText.meta),
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
                    Text(
                      context.l10n.nameSeller(name),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
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

/// Personal status for the signed-in user, or null if they never bid.
/// `pay` is true when they won and still have to pay.
({String message, bool pay})? _myStatus(BuildContext context, Listing l, String uid, int? myMax) {
  final didBid = l.bidderIds.contains(uid) || l.winnerId == uid;
  if (!didBid) return null;
  final ended = !l.isLive(DateTime.now());
  // Advanced Dart: switch expression over a record with guards.
  return switch ((ended, l.leaderId == uid)) {
    (true, _) when l.winnerId == uid => (message: context.l10n.youWonItem, pay: true),
    (true, _) => (message: context.l10n.youDidntWin, pay: false),
    (false, true) => (
      message: context.l10n.youreHighestMax((myMax ?? l.leaderMax ?? l.currentPrice).toRupiah()),
      pay: false,
    ),
    (false, false) => (message: context.l10n.youveBeenOutbid, pay: false),
  };
}

/// Ocean card: status strip, current price, conversions, counts and the timer.
class _PriceCard extends ConsumerWidget {
  const _PriceCard({required this.listing, required this.user});
  final Listing listing;
  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = listing;
    final bids = ref.watch(bidsProvider(l.id)).value ?? const <Bid>[];
    final bidders = bids.map((b) => b.userId).toSet().length;
    final myMax = ref.watch(myMaxProvider(l.id)).value;
    final status = _myStatus(context, l, user.uid, myMax);
    final price = l.isBuyNowOnly
        ? l.finalPrice ?? l.buyNowPrice ?? l.currentPrice
        : l.finalPrice ?? l.currentPrice;
    final label = switch (l) {
      _ when l.isBuyNowOnly => context.l10n.buyNowPrice,
      _ when l.isActive => context.l10n.currentPrice,
      _ => context.l10n.finalPrice,
    };
    const small = TextStyle(fontSize: 12, color: AppColors.onInk);
    final faded = small.copyWith(color: AppColors.onInk.withValues(alpha: 0.75));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.input),
          child: ColoredBox(
            color: AppColors.ocean,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (status != null)
                  Semantics(
                    liveRegion: true,
                    child: Container(
                      color: AppColors.brandBright,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      child: Text(
                        status.message,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onInk,
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: faded),
                      Text(
                        price.toRupiah(),
                        style: AppText.priceHero.copyWith(color: AppColors.onInk),
                      ),
                      _Conversion(amountIdr: price, style: faded),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 16,
                        runSpacing: 4,
                        children: [
                          if (!l.isBuyNowOnly) ...[
                            Text(context.l10n.nBids(l.bidCount), style: small),
                            Text(context.l10n.nBidders(bidders), style: small),
                          ],
                          Text(context.l10n.nWatching(l.watcherCount), style: small),
                          if (l.hasReserve && !l.isBuyNowOnly)
                            Text(
                              l.reserveMet ? context.l10n.reserveMet : context.l10n.reserveNotMet,
                              style: small.copyWith(fontWeight: FontWeight.w700),
                            ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Divider(color: AppColors.onInk.withValues(alpha: 0.4)),
                      ),
                      if (l.isActive)
                        Row(
                          children: [
                            Expanded(
                              child: CountdownText(
                                endsAt: l.endsAt,
                                prefix: context.l10n.endsIn,
                                style: AppText.emphasis.copyWith(
                                  fontSize: 18,
                                  color: AppColors.onInk,
                                ),
                                onFinished: () => ref.read(auctionCloserProvider).ensureClosed(l),
                              ),
                            ),
                            Text(endDateFormat.format(l.endsAt), style: small),
                          ],
                        )
                      else
                        Text(switch (l.status) {
                          ListingStatus.sold => context.l10n.sold,
                          ListingStatus.unsold => context.l10n.endedNotSold,
                          ListingStatus.ended => context.l10n.endedBySeller,
                          ListingStatus.active => '',
                        }, style: AppText.emphasis.copyWith(color: AppColors.onInk)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (status?.pay ?? false) ...[
          const SizedBox(height: 12),
          PrimaryButton(
            color: AppColors.ocean,
            label: context.l10n.payNow,
            onPressed: () => context.push('/checkout/${l.id}'),
          ),
        ],
      ],
    );
  }
}

/// Price in other currencies via the open-source Frankfurter API.
class _Conversion extends ConsumerWidget {
  const _Conversion({required this.amountIdr, this.style});
  final int amountIdr;
  final TextStyle? style;

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
        return Text('≈ ${parts.join(' · ')}', style: style ?? AppText.caption);
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
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: AppColors.ocean,
                ),
                onPressed: () => setState(() => _expanded = !_expanded),
                child: Text(_expanded ? context.l10n.showLess : context.l10n.readMore),
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
        context.l10n.shipping,
        l.shippingCost == 0
            ? context.l10n.freeCouriers
            : '${l.shippingCost.toRupiah()} · JNE / SiCepat',
      ),
      (context.l10n.handlingTime, hasNewFields ? context.l10n.shipsInDays(l.handlingDays!) : '-'),
      (
        context.l10n.returns,
        !hasNewFields
            ? '-'
            : l.acceptsReturns
            ? context.l10n.returnDaysProtection(l.returnDays)
            : context.l10n.noReturns,
      ),
    ];
    return Column(
      children: [
        for (final (label, value) in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppText.body),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(value, textAlign: TextAlign.end, style: AppText.body),
                ),
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
        Semantics(header: true, child: Text(context.l10n.bidHistory, style: _sectionTitle)),
        const SizedBox(height: 4),
        switch (bids) {
          AsyncValue(:final value?) when value.isEmpty => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(context.l10n.noBidsYet, style: AppText.meta),
          ),
          AsyncValue(:final value?) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BidHistoryList(bids: value, limit: 3),
              if (value.length > 3)
                Align(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.ocean,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                      ),
                    ),
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
                            SectionHeader(context.l10n.allNBids(value.length)),
                            BidHistoryList(bids: value),
                          ],
                        ),
                      ),
                    ),
                    child: Text(context.l10n.seeAllNBids(value.length)),
                  ),
                ),
            ],
          ),
          AsyncValue(:final error?) => Text(friendlyError(error), style: AppText.meta),
          _ => const LinearProgressIndicator(),
        },
        const SizedBox(height: 8),
        Text(
          context.l10n.namesMasked,
          textAlign: TextAlign.center,
          style: AppText.caption.copyWith(color: AppColors.navInactive),
        ),
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
          Semantics(
            label: fmt.format(b.createdAt),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${b.maskedName} (${context.l10n.nBids(perBidder[b.userId] ?? 0)})',
                      style: AppText.body,
                    ),
                  ),
                  Text(
                    b.priceAfter.toRupiah(),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
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
        title: Text(context.l10n.endListingQ),
        content: Text(context.l10n.endListingBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.endListingAction),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(listingRepositoryProvider).endEarly(listing, user);
      if (context.mounted) showSnack(context, context.l10n.listingEndedSnack);
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
        showSnack(context, context.l10n.relistedSnack);
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
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(context.l10n.adminControls, style: AppText.groupLabel),
            ),
          if (canEnd)
            SecondaryButton(
              label: context.l10n.endListingAction,
              onPressed: () => _end(context, ref),
            ),
          if (canRelist)
            PrimaryButton(label: context.l10n.relist7Days, onPressed: () => _relist(context, ref)),
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
        title: Text(context.l10n.buyItNow),
        content: Text(context.l10n.buyNowConfirm(listing.title, price.toRupiah())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.l10n.cancel)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(context.l10n.buy)),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(listingRepositoryProvider).buyNow(listingId: listing.id, buyer: user);
      if (context.mounted) showSnack(context, context.l10n.youBoughtIt);
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
                  color: AppColors.ocean,
                  label: context.l10n.buyItNowPrice((l.buyNowPrice ?? 0).toRupiah()),
                  onPressed: showBuyNow ? () => _buyNow(context, ref) : null,
                )
              else ...[
                if (showBuyNow) ...[
                  SecondaryButton(
                    color: AppColors.ocean,
                    label: context.l10n.buyItNowPrice(l.buyNowPrice!.toRupiah()),
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
                          Text(context.l10n.minimumBid, style: AppText.caption),
                          Text(l.minimumNextBid.toRupiah(), style: AppText.emphasis),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: PrimaryButton(
                        color: AppColors.ocean,
                        label: isLeader ? context.l10n.raiseMaxBid : context.l10n.placeMaxBid,
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

const _sectionTitle = TextStyle(fontSize: 16, fontWeight: FontWeight.w700);
