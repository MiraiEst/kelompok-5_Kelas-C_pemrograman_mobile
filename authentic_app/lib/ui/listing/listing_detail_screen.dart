import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/extensions.dart';
import '../../domain/bidding/proxy_engine.dart';
import '../../domain/models/app_user.dart';
import '../../domain/models/bid.dart';
import '../../domain/models/listing.dart';
import '../../providers/providers.dart';
import '../widgets/common.dart';

class ListingDetailScreen extends ConsumerWidget {
  const ListingDetailScreen({super.key, required this.listingId});
  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listing = ref.watch(listingProvider(listingId));
    final user = ref.watch(currentUserProvider).value;
    final watched = ref.watch(watchlistIdsProvider).value?.contains(listingId) ?? false;
    final l = listing.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Auction'),
        actions: [
          if (l != null && user != null && l.sellerId != user.uid)
            IconButton(
              tooltip: watched ? 'Remove from watchlist' : 'Add to watchlist',
              icon: Icon(watched ? Icons.favorite : Icons.favorite_border),
              onPressed: () => ref.read(userRepositoryProvider).toggleWatch(user.uid, l),
            ),
        ],
      ),
      body: listing.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorText(e),
        data: (item) => (item == null || user == null)
            ? const EmptyState(icon: Icons.search_off, text: 'This listing no longer exists.')
            : _DetailBody(listing: item, user: user),
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.listing, required this.user});
  final Listing listing;
  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = listing;
    final text = Theme.of(context).textTheme;
    final now = DateTime.now();
    final isSeller = l.sellerId == user.uid;
    final bids = ref.watch(bidsProvider(l.id));

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        _Gallery(urls: l.imageUrls),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.title, style: text.titleLarge),
              const SizedBox(height: 4),
              Text('${l.condition.label} · ${l.category} · Seller: ${l.sellerName}',
                  style: text.bodySmall),
              const SizedBox(height: 12),
              _StatusBanner(listing: l, user: user),
              _PriceCard(listing: l, bids: bids.value ?? const []),
              const SizedBox(height: 12),
              if (l.isLive(now) && !isSeller) _BidBox(listing: l),
              if (l.canBuyNow(now) && !isSeller) _BuyNowButton(listing: l),
              if (isSeller) _SellerControls(listing: l, user: user),
              if (user.isAdmin && !isSeller) _SellerControls(listing: l, user: user),
              const SizedBox(height: 16),
              Text('Description', style: text.titleMedium),
              const SizedBox(height: 4),
              Text(l.description.isEmpty ? '-' : l.description),
              const SizedBox(height: 8),
              Text('Shipping: ${l.shippingCost == 0 ? 'Free' : l.shippingCost.toRupiah()}'),
              const SizedBox(height: 16),
              Text('Bid history', style: text.titleMedium),
              bids.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('$e'),
                data: (list) => _BidHistory(bids: list),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Gallery extends StatelessWidget {
  const _Gallery({required this.urls});
  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) {
      return const SizedBox(height: 220, child: ListingImage(url: null));
    }
    return SizedBox(
      height: 260,
      child: PageView(
        children: [for (final u in urls) ListingImage(url: u, fit: BoxFit.contain)],
      ),
    );
  }
}

/// Personal status for the signed-in user (green / red / gray).
class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.listing, required this.user});
  final Listing listing;
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final l = listing;
    final uid = user.uid;
    final didBid = l.bidderIds.contains(uid);
    final ended = !l.isLive(DateTime.now());

    // Advanced Dart: switch expression over a record with guards.
    final banner = switch ((ended, l.leaderId == uid, didBid)) {
      (true, _, _) when l.winnerId == uid => (Colors.grey, 'You won this item!'),
      (true, _, true) => (Colors.grey, "You didn't win this item."),
      (false, true, _) => (
          Colors.green,
          "You're the highest bidder. Your max: ${(l.leaderMax ?? l.currentPrice).toRupiah()}"
        ),
      (false, false, true) => (Colors.red, "You've been outbid. Raise your max to get back in."),
      _ => null,
    };
    if (banner == null) return const SizedBox();
    final (color, message) = banner;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(message, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _PriceCard extends ConsumerWidget {
  const _PriceCard({required this.listing, required this.bids});
  final Listing listing;
  final List<Bid> bids;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = listing;
    final text = Theme.of(context).textTheme;
    final bidders = bids.map((b) => b.userId).toSet().length;
    final price = l.finalPrice ?? l.currentPrice;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.isActive ? 'Current price' : 'Final price', style: text.bodySmall),
            Text(price.toRupiah(), style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            _Conversion(amountIdr: price),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                Text('${l.bidCount} bids'),
                Text('$bidders bidders'),
                Text('${l.watcherCount} watching'),
                if (l.hasReserve) Text(l.reserveMet ? 'Reserve met' : 'Reserve not met'),
              ],
            ),
            const SizedBox(height: 8),
            if (l.isActive)
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 18),
                  const SizedBox(width: 4),
                  CountdownText(
                    endsAt: l.endsAt,
                    style: text.titleMedium,
                    onFinished: () => ref.read(auctionCloserProvider).ensureClosed(l),
                  ),
                  const Spacer(),
                  Text(DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(l.endsAt), style: text.bodySmall),
                ],
              )
            else
              Text('Status: ${l.status.value.toUpperCase()}', style: text.titleSmall),
          ],
        ),
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

        final parts = [fmt('USD', r'$'), fmt('EUR', '€'), fmt('SGD', r'S$'), fmt('MYR', 'RM')]
            .where((s) => s.isNotEmpty);
        return Text('≈ ${parts.join(' · ')}', style: Theme.of(context).textTheme.bodySmall);
      },
      orElse: () => const SizedBox(),
    );
  }
}

class _BidBox extends ConsumerStatefulWidget {
  const _BidBox({required this.listing});
  final Listing listing;

  @override
  ConsumerState<_BidBox> createState() => _BidBoxState();
}

class _BidBoxState extends ConsumerState<_BidBox> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = widget.listing;
    final amount = int.tryParse(_controller.text.replaceAll(RegExp(r'[^0-9]'), ''));
    if (amount == null) {
      showSnack(context, 'Enter your maximum bid.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm your bid'),
        content: Text(
          'Your maximum bid: ${amount.toRupiah()}\n\n'
          'We will bid for you only as much as needed to keep you in the lead, '
          'up to this amount.\n\nBids are binding.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirm bid')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final decision =
        await ref.read(bidControllerProvider.notifier).place(listingId: l.id, maxAmount: amount);
    if (!mounted) return;

    final error = ref.read(bidControllerProvider).error;
    final message = switch (decision) {
      BidAccepted(:final kind) => kind.message,
      BidRejected(:final reason) => reason.message,
      null => 'Could not place bid: ${error ?? 'unknown error'}',
    };
    showSnack(context, message);
    if (decision is BidAccepted) _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.listing;
    final busy = ref.watch(bidControllerProvider).isLoading;
    final isLeader = l.leaderId == ref.watch(currentUserProvider).value?.uid;
    final hint = isLeader
        ? 'Raise above ${(l.leaderMax ?? l.currentPrice).toRupiah()}'
        : 'Minimum ${l.minimumNextBid.toRupiah()}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: isLeader ? 'Raise your maximum bid (Rp)' : 'Your maximum bid (Rp)',
            helperText: hint,
            prefixText: 'Rp ',
          ),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: busy ? null : _submit,
          icon: busy
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.gavel),
          label: Text(isLeader ? 'Raise max bid' : 'Place max bid'),
        ),
      ],
    );
  }
}

class _BuyNowButton extends ConsumerWidget {
  const _BuyNowButton({required this.listing});
  final Listing listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final price = listing.buyNowPrice!;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: OutlinedButton.icon(
        icon: const Icon(Icons.flash_on),
        label: Text('Buy It Now for ${price.toRupiah()}'),
        onPressed: () async {
          final ok = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Buy It Now'),
              content: Text('Buy "${listing.title}" for ${price.toRupiah()}? This ends the auction.'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Buy')),
              ],
            ),
          );
          if (ok != true) return;
          final user = ref.read(currentUserProvider).value;
          if (user == null) return;
          try {
            await ref.read(listingRepositoryProvider).buyNow(listingId: listing.id, buyer: user);
            if (context.mounted) showSnack(context, 'You bought it!');
          } catch (e) {
            if (context.mounted) showSnack(context, '$e');
          }
        },
      ),
    );
  }
}

class _SellerControls extends ConsumerWidget {
  const _SellerControls({required this.listing, required this.user});
  final Listing listing;
  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = listing;
    final repo = ref.read(listingRepositoryProvider);
    final canEnd = l.isActive && (l.bidCount == 0 || user.isAdmin);
    final canRelist = l.sellerId == user.uid &&
        (l.status == ListingStatus.unsold || l.status == ListingStatus.ended);

    return Wrap(
      spacing: 8,
      children: [
        if (user.isAdmin) const Chip(label: Text('Admin')),
        if (canEnd)
          OutlinedButton(
            onPressed: () async {
              try {
                await repo.endEarly(l, user);
                if (context.mounted) showSnack(context, 'Listing ended.');
              } catch (e) {
                if (context.mounted) showSnack(context, '$e');
              }
            },
            child: const Text('End listing'),
          ),
        if (canRelist)
          FilledButton.tonal(
            onPressed: () async {
              final id = await repo.relist(l, user, AuctionDuration.sevenDays);
              if (context.mounted) {
                showSnack(context, 'Relisted for 7 days.');
                context.pushReplacement('/listing/$id');
              }
            },
            child: const Text('Relist (7 days)'),
          ),
      ],
    );
  }
}

class _BidHistory extends StatelessWidget {
  const _BidHistory({required this.bids});
  final List<Bid> bids;

  @override
  Widget build(BuildContext context) {
    if (bids.isEmpty) {
      return const Padding(padding: EdgeInsets.all(8), child: Text('No bids yet.'));
    }
    // Total number of bids per bidder (shown next to the masked name).
    final perBidder = <String, int>{};
    for (final b in bids) {
      perBidder.update(b.userId, (c) => c + 1, ifAbsent: () => 1);
    }
    final fmt = DateFormat('d MMM, HH:mm:ss', 'id_ID');
    return Column(
      children: [
        for (final b in bids)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.person_outline),
            title: Text('${b.maskedName} (${perBidder[b.userId]} bids)'),
            subtitle: Text(fmt.format(b.createdAt)),
            trailing: Text(b.priceAfter.toRupiah()),
          ),
      ],
    );
  }
}
