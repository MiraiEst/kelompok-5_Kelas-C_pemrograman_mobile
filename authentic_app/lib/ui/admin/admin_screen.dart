import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/listing.dart';
import '../../providers/providers.dart';
import '../widgets/common.dart';
import '../widgets/listing_card.dart';

/// Admin-only moderation screen.
/// Guarded three times: hidden in the UI, blocked by the router redirect,
/// and enforced by Firestore security rules (isAdmin()).
class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);
    if (!isAdmin) {
      return const Scaffold(
        body: EmptyState(icon: Icons.lock, text: 'Admins only.'),
      );
    }
    final all = ref.watch(allListingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin · All listings')),
      body: all.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorText(e),
        data: (items) => items.isEmpty
            ? const EmptyState(icon: Icons.inbox_outlined, text: 'No listings.')
            : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: items.length,
                itemBuilder: (_, i) => ListingCard(
                  listing: items[i],
                  trailing: _AdminMenu(listing: items[i]),
                ),
              ),
      ),
    );
  }
}

enum _AdminAction { end, delete }

class _AdminMenu extends ConsumerWidget {
  const _AdminMenu({required this.listing});
  final Listing listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<_AdminAction>(
      onSelected: (action) async {
        final repo = ref.read(listingRepositoryProvider);
        final admin = ref.read(currentUserProvider).value;
        if (admin == null) return;
        try {
          switch (action) {
            case _AdminAction.end:
              await repo.endEarly(listing, admin);
            case _AdminAction.delete:
              await repo.delete(listing.id);
          }
          if (context.mounted) showSnack(context, 'Done.');
        } catch (e) {
          if (context.mounted) showSnack(context, '$e');
        }
      },
      itemBuilder: (_) => [
        if (listing.isActive)
          const PopupMenuItem(value: _AdminAction.end, child: Text('End listing now')),
        const PopupMenuItem(value: _AdminAction.delete, child: Text('Delete listing')),
      ],
    );
  }
}
