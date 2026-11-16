import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/extensions.dart';
import '../../domain/models/listing.dart';
import '../../providers/providers.dart';
import 'common.dart';

class ListingCard extends ConsumerWidget {
  const ListingCard({super.key, required this.listing, this.trailing});
  final Listing listing;
  final Widget? trailing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = listing;
    final text = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/listing/${l.id}'),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ListingImage(url: l.thumbnail, size: 84),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: text.titleSmall),
                    const SizedBox(height: 4),
                    Text(
                      (l.finalPrice ?? l.currentPrice).toRupiah(),
                      style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text('${l.bidCount} bids · ', style: text.bodySmall),
                        if (l.isActive)
                          CountdownText(
                            endsAt: l.endsAt,
                            style: text.bodySmall,
                            onFinished: () => ref.read(auctionCloserProvider).ensureClosed(l),
                          )
                        else
                          Text(l.status.value.toUpperCase(), style: text.bodySmall),
                      ],
                    ),
                    if (l.canBuyNow(DateTime.now()))
                      Text('Buy It Now ${l.buyNowPrice!.toRupiah()}', style: text.bodySmall),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
