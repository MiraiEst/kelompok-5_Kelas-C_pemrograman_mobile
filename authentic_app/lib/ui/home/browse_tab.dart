import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import '../widgets/common.dart';
import '../widgets/listing_card.dart';

class BrowseTab extends ConsumerWidget {
  const BrowseTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(homeFilterProvider);
    final listings = ref.watch(filteredListingsProvider);
    final categories = ref.watch(categoriesProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search auctions',
              prefixIcon: Icon(Icons.search),
              isDense: true,
            ),
            onChanged: ref.read(homeFilterProvider.notifier).setQuery,
          ),
        ),
        // Categories from the DummyJSON open-source API.
        SizedBox(
          height: 48,
          child: categories.when(
            loading: () => const SizedBox(),
            error: (_, _) => const SizedBox(),
            data: (cats) => ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: const Text('All'),
                    selected: filter.category == null,
                    onSelected: (_) => ref.read(homeFilterProvider.notifier).setCategory(null),
                  ),
                ),
                for (final c in cats)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(c.name),
                      selected: filter.category == c.slug,
                      onSelected: (_) => ref.read(homeFilterProvider.notifier).setCategory(c.slug),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          child: listings.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => ErrorText(e),
            data: (items) => items.isEmpty
                ? const EmptyState(
                    icon: Icons.inventory_2_outlined,
                    text: 'No active auctions yet.\nTap "Sell" to list the first item.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 88),
                    itemCount: items.length,
                    itemBuilder: (_, i) => ListingCard(listing: items[i]),
                  ),
          ),
        ),
      ],
    );
  }
}
