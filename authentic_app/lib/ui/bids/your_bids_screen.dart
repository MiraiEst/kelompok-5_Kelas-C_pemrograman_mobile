import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/l10n.dart';
import '../../core/config.dart';
import '../../core/extensions.dart';
import '../../domain/models/listing.dart';
import '../../domain/models/order.dart';
import '../../providers/providers.dart';
import '../listing/place_bid_sheet.dart';
import '../theme/app_theme.dart';
import '../widgets/buttons.dart';
import '../widgets/common.dart';
import '../widgets/section_header.dart';
import '../widgets/status_pill.dart';

/// Derived lists for the four tabs + the summary strip.
typedef YourBids = ({
  List<Listing> bidding,
  List<Listing> won,
  List<Listing> lost,
  int winning,
  int outbid,
});

final yourBidsProvider = Provider<AsyncValue<YourBids>>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid ?? '';
  final bidOn = ref.watch(myBidsProvider);
  final wonDirect = ref.watch(wonListingsProvider);
  final now = DateTime.now();
  return bidOn.whenData((list) {
    final bidding = list.where((l) => l.isLive(now)).toList()
      ..sort((a, b) => a.endsAt.compareTo(b.endsAt));
    final won = {
      for (final l in [...list, ...?wonDirect.value])
        if (l.winnerId == uid) l.id: l,
    }.values.toList()..sort((a, b) => b.endsAt.compareTo(a.endsAt));
    final lost = list.where((l) => !l.isLive(now) && l.winnerId != uid).toList()
      ..sort((a, b) => b.endsAt.compareTo(a.endsAt));
    final winning = bidding.where((l) => l.leaderId == uid).length;
    return (
      bidding: bidding,
      won: won,
      lost: lost,
      winning: winning,
      outbid: bidding.length - winning,
    );
  });
});

/// Won items without a paid order yet.
final toPayCountProvider = Provider<int>((ref) {
  final won = ref.watch(yourBidsProvider).value?.won ?? const [];
  final orders = {for (final o in ref.watch(myPurchasesProvider).value ?? const []) o.id: o};
  return won.where((l) => !(orders[l.id]?.status.isPaid ?? false)).length;
});

class YourBidsScreen extends ConsumerStatefulWidget {
  const YourBidsScreen({super.key});

  @override
  ConsumerState<YourBidsScreen> createState() => _YourBidsScreenState();
}

class _YourBidsScreenState extends ConsumerState<YourBidsScreen>
    with SingleTickerProviderStateMixin {
  late final _tabs = TabController(length: 4, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(myBidsProvider);
    ref.invalidate(wonListingsProvider);
    ref.invalidate(watchlistIdsProvider);
    ref.invalidate(myPurchasesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(yourBidsProvider);
    final toPay = ref.watch(toPayCountProvider);
    final d = data.value;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeading(context.l10n.navYourBids),
          TabBar(
            controller: _tabs,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(
                text: d == null
                    ? context.l10n.bidding
                    : context.l10n.biddingCount(d.bidding.length),
              ),
              Tab(text: d == null ? context.l10n.won : context.l10n.wonCount(d.won.length)),
              Tab(text: context.l10n.didntWin),
              Tab(text: context.l10n.watchlist),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                _SummaryBox(
                  label: context.l10n.winning,
                  value: d?.winning,
                  onTap: () => _tabs.animateTo(0),
                ),
                const SizedBox(width: 8),
                _SummaryBox(
                  label: context.l10n.outbid,
                  value: d?.outbid,
                  onTap: () => _tabs.animateTo(0),
                ),
                const SizedBox(width: 8),
                _SummaryBox(
                  label: context.l10n.toPay,
                  value: d == null ? null : toPay,
                  onTap: () => _tabs.animateTo(1),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _Tab(
                  value: data.whenData((d) => d.bidding),
                  onRefresh: _refresh,
                  empty: EmptyState(icon: Icons.gavel_outlined, text: context.l10n.emptyBidding),
                  itemBuilder: (l) => _BiddingCard(listing: l),
                ),
                _Tab(
                  value: data.whenData((d) => d.won),
                  onRefresh: _refresh,
                  empty: EmptyState(icon: Icons.emoji_events_outlined, text: context.l10n.emptyWon),
                  itemBuilder: (l) => _WonCard(listing: l),
                ),
                _Tab(
                  value: data.whenData((d) => d.lost),
                  onRefresh: _refresh,
                  empty: EmptyState(icon: Icons.inbox_outlined, text: context.l10n.emptyLost),
                  itemBuilder: (l) => _LostCard(listing: l),
                ),
                _WatchlistTab(onRefresh: _refresh),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  const _SummaryBox({required this.label, required this.value, required this.onTap});
  final String label;
  final int? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Semantics(
      button: true,
      label: '$label: ${value ?? 'loading'}',
      excludeSemantics: true,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.input),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.input),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${value ?? '–'}', style: AppText.title),
                Text(label, style: AppText.caption),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.value,
    required this.onRefresh,
    required this.empty,
    required this.itemBuilder,
  });

  final AsyncValue<List<Listing>> value;
  final Future<void> Function() onRefresh;
  final Widget empty;
  final Widget Function(Listing) itemBuilder;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: onRefresh,
    child: switch (value) {
      AsyncValue(:final value?) when value.isEmpty => _ScrollableFill(child: empty),
      AsyncValue(:final value?) => ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: value.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, i) => itemBuilder(value[i]),
      ),
      AsyncValue(:final error?) => _ScrollableFill(child: ErrorText(error, onRetry: onRefresh)),
      _ => const Center(child: CircularProgressIndicator()),
    },
  );
}

/// Lets pull-to-refresh work on empty/error states.
class _ScrollableFill extends StatelessWidget {
  const _ScrollableFill({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => CustomScrollView(
    physics: const AlwaysScrollableScrollPhysics(),
    slivers: [SliverFillRemaining(hasScrollBody: false, child: child)],
  );
}

/// Shared card layout: photo 72, pill, title, price row, extra line, action.
class _BidCard extends StatelessWidget {
  const _BidCard({
    required this.listing,
    required this.pill,
    required this.priceLine,
    this.meta,
    this.action,
    this.emphasised = false,
    this.trailing,
  });

  final Listing listing;
  final Widget pill;
  final Widget priceLine;
  final Widget? meta;
  final Widget? action;
  final bool emphasised;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final l = listing;
    return Material(
      color: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(
          color: emphasised ? AppColors.ink : AppColors.line,
          width: emphasised ? 2 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/listing/${l.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListingImage(
                    url: l.thumbnail,
                    size: 72,
                    borderRadius: BorderRadius.circular(AppRadius.photoSmall),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        pill,
                        const SizedBox(height: 4),
                        Text(
                          l.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.small,
                        ),
                        const SizedBox(height: 2),
                        priceLine,
                        if (meta != null) ...[const SizedBox(height: 2), meta!],
                      ],
                    ),
                  ),
                  ?trailing,
                ],
              ),
              if (action != null) ...[const SizedBox(height: 12), action!],
            ],
          ),
        ),
      ),
    );
  }
}

class _BiddingCard extends ConsumerWidget {
  const _BiddingCard({required this.listing});
  final Listing listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = listing;
    final uid = ref.watch(authStateProvider).value?.uid;
    final myMax = ref.watch(myMaxProvider(l.id)).value;
    final leading = l.leaderId == uid;
    return _BidCard(
      listing: l,
      emphasised: !leading,
      pill: leading
          ? const StatusPill('Highest bidder', variant: PillVariant.filled)
          : const StatusPill('Outbid', variant: PillVariant.outlined),
      priceLine: Text.rich(
        TextSpan(
          text: l.currentPrice.toRupiah(),
          style: AppText.price,
          children: [
            if (myMax != null)
              TextSpan(
                text: ' · your max ${myMax.toRupiah()}',
                style: AppText.caption.copyWith(fontWeight: FontWeight.w400),
              ),
          ],
        ),
      ),
      meta: CountdownText(
        endsAt: l.endsAt,
        prefix: 'Ends in ',
        style: AppText.caption,
        onFinished: () => ref.read(auctionCloserProvider).ensureClosed(l),
      ),
      action: leading
          ? null
          : PrimaryButton(
              label: context.l10n.raiseMaxBid,
              onPressed: () => showPlaceBidSheet(context, l.id),
            ),
    );
  }
}

class _WonCard extends ConsumerWidget {
  const _WonCard({required this.listing});
  final Listing listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = listing;
    final order = ref.watch(orderProvider(l.id)).value;
    final paid = order?.status.isPaid ?? false;
    final payBy =
        order?.payBy ?? (l.endedAt ?? l.endsAt).add(const Duration(days: AppConfig.payWithinDays));
    return _BidCard(
      listing: l,
      pill: paid
          ? const StatusPill('Paid', variant: PillVariant.filled)
          : _CountdownPill(until: payBy),
      priceLine: Text((l.finalPrice ?? l.currentPrice).toRupiah(), style: AppText.price),
      // The order is created by a Cloud Function; hide actions until it exists.
      action: order == null || order.status == OrderStatus.cancelled
          ? null
          : paid
          ? SecondaryButton(
              label: context.l10n.trackOrder,
              onPressed: () => context.push('/orders/${order.id}'),
            )
          : SecondaryButton(
              label: context.l10n.payNow,
              onPressed: () => context.push('/checkout/${order.id}'),
            ),
    );
  }
}

/// "WON · PAY IN 3D 23H" that updates every second.
class _CountdownPill extends StatelessWidget {
  const _CountdownPill({required this.until});
  final DateTime until;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: AppColors.soft,
      borderRadius: BorderRadius.circular(AppRadius.pill),
    ),
    child: CountdownText(
      endsAt: until,
      prefix: 'WON · PAY IN ',
      format: (d) => d.toShort().toUpperCase(),
      style: AppText.pill.copyWith(color: AppColors.ink),
    ),
  );
}

class _LostCard extends StatelessWidget {
  const _LostCard({required this.listing});
  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final l = listing;
    // Placeholder for Second Chance Offers: a seller may later offer the item
    // to a runner-up. The "View offer" button goes here once that exists.
    const Widget? secondChance = null;
    return _BidCard(
      listing: l,
      pill: const StatusPill('Ended'),
      priceLine: Text('Final ${(l.finalPrice ?? l.currentPrice).toRupiah()}', style: AppText.price),
      action: secondChance,
    );
  }
}

class _WatchlistTab extends ConsumerWidget {
  const _WatchlistTab({required this.onRefresh});
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ids = ref.watch(watchlistIdsProvider);
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: switch (ids) {
        AsyncValue(:final value?) when value.isEmpty => _ScrollableFill(
          child: EmptyState(icon: Icons.favorite_border, text: context.l10n.emptyWatchlist),
        ),
        AsyncValue(:final value?) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final id in value)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Consumer(
                  builder: (_, ref, _) => switch (ref.watch(listingProvider(id))) {
                    AsyncData(value: final l?) => _WatchCard(listing: l),
                    AsyncData() => const SizedBox(),
                    _ => const SkeletonBox(height: 96, radius: AppRadius.card),
                  },
                ),
              ),
          ],
        ),
        AsyncValue(:final error?) => _ScrollableFill(child: ErrorText(error, onRetry: onRefresh)),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _WatchCard extends ConsumerWidget {
  const _WatchCard({required this.listing});
  final Listing listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = listing;
    final uid = ref.watch(authStateProvider).value?.uid;
    return _BidCard(
      listing: l,
      pill: StatusPill(l.isLive(DateTime.now()) ? 'Watching' : 'Ended'),
      priceLine: Text(l.currentPrice.toRupiah(), style: AppText.price),
      meta: l.isActive
          ? CountdownText(
              endsAt: l.endsAt,
              suffix: ' left',
              format: (d) => d.toShort(),
              style: AppText.caption,
              onFinished: () => ref.read(auctionCloserProvider).ensureClosed(l),
            )
          : null,
      trailing: IconButton(
        tooltip: 'Remove from watchlist',
        icon: const Icon(Icons.favorite),
        onPressed: uid == null ? null : () => ref.read(userRepositoryProvider).toggleWatch(uid, l),
      ),
    );
  }
}
