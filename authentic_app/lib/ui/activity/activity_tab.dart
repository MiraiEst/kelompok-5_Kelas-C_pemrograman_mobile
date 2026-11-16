import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/listing.dart';
import '../../providers/providers.dart';
import '../widgets/common.dart';
import '../widgets/listing_card.dart';

/// "My Activity": buyer view (bidding, won, didn't win, watchlist) and
/// seller view (selling, sold, unsold).
class ActivityTab extends ConsumerWidget {
  const ActivityTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(currentUserProvider).value?.uid ?? '';
    final bidOn = ref.watch(myBidsProvider);
    final mine = ref.watch(myListingsProvider);
    final now = DateTime.now();

    return DefaultTabController(
      length: 5,
      child: Column(
        children: [
          const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Bidding'),
              Tab(text: 'Won'),
              Tab(text: "Didn't win"),
              Tab(text: 'Watchlist'),
              Tab(text: 'Selling'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _ListingList(
                  value: bidOn.whenData((l) => l.where((x) => x.isLive(now)).toList()),
                  empty: 'You have no active bids.',
                  trailing: (l) => Icon(
                    l.leaderId == uid ? Icons.emoji_events : Icons.trending_down,
                    color: l.leaderId == uid ? Colors.green : Colors.red,
                  ),
                ),
                _ListingList(
                  value: bidOn.whenData((l) => l.where((x) => x.winnerId == uid).toList()),
                  empty: 'Items you win will appear here.',
                ),
                _ListingList(
                  value: bidOn.whenData(
                    (l) => l.where((x) => !x.isActive && x.winnerId != uid).toList(),
                  ),
                  empty: 'Nothing here.',
                ),
                const _Watchlist(),
                _ListingList(
                  value: mine,
                  empty: 'You are not selling anything yet.',
                  trailing: (l) => _StatusChip(l.status),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ListingList extends StatelessWidget {
  const _ListingList({required this.value, required this.empty, this.trailing});
  final AsyncValue<List<Listing>> value;
  final String empty;
  final Widget Function(Listing)? trailing;

  @override
  Widget build(BuildContext context) => value.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorText(e),
        data: (items) => items.isEmpty
            ? EmptyState(icon: Icons.inbox_outlined, text: empty)
            : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: items.length,
                itemBuilder: (_, i) =>
                    ListingCard(listing: items[i], trailing: trailing?.call(items[i])),
              ),
      );
}

class _Watchlist extends ConsumerWidget {
  const _Watchlist();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ids = ref.watch(watchlistIdsProvider);
    return ids.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorText(e),
      data: (set) => set.isEmpty
          ? const EmptyState(
              icon: Icons.favorite_border,
              text: 'Tap the heart on an auction to watch it.',
            )
          : ListView(
              padding: const EdgeInsets.all(8),
              children: [
                for (final id in set)
                  Consumer(
                    builder: (_, ref, _) => switch (ref.watch(listingProvider(id))) {
                      AsyncData(value: final l?) => ListingCard(listing: l),
                      AsyncData() => const SizedBox(),
                      _ => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
                    },
                  ),
              ],
            ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip(this.status);
  final ListingStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      ListingStatus.active => Colors.blue,
      ListingStatus.sold => Colors.green,
      ListingStatus.unsold || ListingStatus.ended => Colors.grey,
    };
    return Chip(
      label: Text(status.value),
      labelStyle: TextStyle(color: color),
      side: BorderSide(color: color),
      visualDensity: VisualDensity.compact,
    );
  }
}
