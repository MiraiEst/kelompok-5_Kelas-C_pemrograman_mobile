import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/l10n.dart';
import '../../core/extensions.dart';
import '../../data/repositories/listing_repository.dart';
import '../../domain/models/listing.dart';
import '../../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/section_header.dart';
import '../widgets/segmented_tabs.dart';

/// Trending tab: ranked lists by bids / watchers / new, plus hot categories.
class TrendingScreen extends ConsumerWidget {
  const TrendingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sort = ref.watch(trendingSortProvider);
    final items = ref.watch(trendingProvider(sort));

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(trendingProvider(sort));
          ref.invalidate(activeListingsProvider);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: PageHeading(context.l10n.navTrending, subtitle: context.l10n.trendingSubtitle),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: SegmentedTabs<TrendingSort>(
                  values: TrendingSort.values,
                  selected: sort,
                  label: (s) => switch (s) {
                    TrendingSort.mostBids => context.l10n.mostBids,
                    TrendingSort.mostWatched => context.l10n.mostWatched,
                    TrendingSort.newToday => context.l10n.newToday,
                  },
                  onChanged: ref.read(trendingSortProvider.notifier).select,
                ),
              ),
            ),
            ...switch (items) {
              AsyncValue(:final value?) when value.isEmpty => [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 200,
                    child: EmptyState(
                      icon: Icons.trending_up,
                      text: sort == TrendingSort.newToday
                          ? context.l10n.nothingNewToday
                          : context.l10n.noActiveAuctions,
                    ),
                  ),
                ),
              ],
              AsyncValue(:final value?) => [
                SliverList.builder(
                  itemCount: value.length,
                  itemBuilder: (_, i) => _RankRow(rank: i + 1, listing: value[i]),
                ),
              ],
              AsyncValue(:final error?) => [
                SliverToBoxAdapter(
                  child: ErrorText(error, onRetry: () => ref.invalidate(trendingProvider(sort))),
                ),
              ],
              _ => [
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
              ],
            },
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: SectionHeader(context.l10n.hotCategories),
              ),
            ),
            const _HotCategories(),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _RankRow extends ConsumerWidget {
  const _RankRow({required this.rank, required this.listing});
  final int rank;
  final Listing listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = listing;
    final recent = l.recentBids(DateTime.now());
    return Semantics(
      button: true,
      label:
          context.l10n.trendingSemantics(rank, l.title, l.currentPrice.toRupiah(), l.bidCount) +
          (recent > 0 ? context.l10n.recentBidsSemantics(recent) : ''),
      excludeSemantics: true,
      child: InkWell(
        onTap: () => context.push('/listing/${l.id}'),
        child: Container(
          constraints: const BoxConstraints(minHeight: 84),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.line)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: Text(
                  '$rank',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: rank <= 3 ? AppColors.ink : AppColors.muted,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ListingImage(
                url: l.thumbnail,
                size: 64,
                borderRadius: BorderRadius.circular(AppRadius.photoSmall),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.small,
                    ),
                    const SizedBox(height: 2),
                    Text(l.currentPrice.toRupiah(), style: AppText.price),
                    const SizedBox(height: 2),
                    CountdownText(
                      endsAt: l.endsAt,
                      prefix: context.l10n.bidsWatchingPrefix(l.bidCount, l.watcherCount),
                      suffix: context.l10n.timeLeftSuffix,
                      format: (d) => d.toShort(),
                      style: AppText.caption,
                      onFinished: () => ref.read(auctionCloserProvider).ensureClosed(l),
                    ),
                  ],
                ),
              ),
              if (recent > 0) ...[
                const SizedBox(width: 8),
                Text('+$recent', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HotCategories extends ConsumerWidget {
  const _HotCategories();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hot = ref.watch(hotCategoriesProvider);
    final names = {for (final c in ref.watch(categoriesProvider).value ?? const []) c.slug: c.name};
    return switch (hot) {
      AsyncValue(:final value?) when value.isEmpty => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(context.l10n.noLiveCategories, style: AppText.meta),
        ),
      ),
      AsyncValue(:final value?) => SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: 64 * MediaQuery.textScalerOf(context).scale(1).clamp(1, 2),
          ),
          itemCount: value.length,
          itemBuilder: (_, i) {
            final c = value[i];
            final name = names[c.slug] ?? c.slug;
            return Semantics(
              button: true,
              label: '$name, ${context.l10n.liveCount(c.count)}',
              excludeSemantics: true,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.card),
                onTap: () {
                  ref.read(homeFilterProvider.notifier).setCategory(c.slug);
                  context.go('/home');
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.line),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                  ),
                  child: Row(
                    children: [
                      ListingImage(
                        url: c.image,
                        size: 40,
                        borderRadius: BorderRadius.circular(AppRadius.photoSmall),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                            Text(context.l10n.liveCount(c.count), style: AppText.caption),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      AsyncValue(:final error?) => SliverToBoxAdapter(child: ErrorText(error)),
      _ => const SliverToBoxAdapter(child: SizedBox(height: 64)),
    };
  }
}
