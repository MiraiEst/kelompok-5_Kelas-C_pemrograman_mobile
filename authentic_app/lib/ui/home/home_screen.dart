import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/l10n.dart';
import '../../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/auction_cards.dart';
import '../widgets/common.dart';
import '../widgets/section_header.dart';

/// Home tab: search, categories, "Ending soon" and the paged auction grid.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scroll = ScrollController();
  late final _search = TextEditingController(text: ref.read(homeFilterProvider).query);
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_maybeLoadMore);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  void _maybeLoadMore() {
    if (_scroll.position.extentAfter > 600) return;
    final feed = ref.read(homeFeedProvider);
    if (feed.isLoading || !(feed.value?.hasMore ?? false)) return;
    ref.read(homeFeedLimitProvider.notifier).loadMore();
  }

  void _onSearch(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(homeFilterProvider.notifier).setQuery(v);
    });
  }

  Future<void> _refresh() async {
    ref.invalidate(homeFeedProvider);
    ref.invalidate(endingSoonProvider);
    await ref
        .read(homeFeedProvider.future)
        .catchError((_) => (items: const <Never>[], hasMore: false));
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(filteredHomeFeedProvider);
    const pad = EdgeInsets.symmetric(horizontal: AppSizes.screenPadding);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/sell'),
        icon: const Icon(Icons.add),
        label: Text(context.l10n.sell),
        tooltip: context.l10n.sellAnItem,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            controller: _scroll,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: _Header()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: _SearchBox(controller: _search, onChanged: _onSearch),
                ),
              ),
              const SliverToBoxAdapter(child: _CategoryChips()),
              const SliverToBoxAdapter(child: _EndingSoon()),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 20, 8, 4),
                sliver: SliverToBoxAdapter(child: SectionHeader(context.l10n.allAuctions)),
              ),
              ...switch (feed) {
                AsyncValue(:final error?) when !feed.hasValue => [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: ErrorText(error, onRetry: () => ref.invalidate(homeFeedProvider)),
                  ),
                ],
                AsyncValue(:final value?) when value.items.isEmpty => [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.inventory_2_outlined,
                      text: context.l10n.noActiveAuctions,
                    ),
                  ),
                ],
                AsyncValue(:final value?) => [
                  SliverPadding(
                    padding: pad,
                    sliver: SliverGrid.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        mainAxisExtent: AuctionGridCard.extent(context),
                      ),
                      itemCount: value.items.length,
                      itemBuilder: (_, i) => AuctionGridCard(listing: value.items[i]),
                    ),
                  ),
                  if (value.hasMore)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                ],
                _ => [
                  SliverPadding(
                    padding: pad,
                    sliver: SliverGrid.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        mainAxisExtent: AuctionGridCard.extent(context),
                      ),
                      itemCount: 4,
                      itemBuilder: (_, _) => const AuctionGridSkeleton(),
                    ),
                  ),
                ],
              },
              // Room for the floating Sell button.
              const SliverToBoxAdapter(child: SizedBox(height: 96)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadCountProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: const Text('Authentic', style: AppText.title),
            ),
          ),
          IconButton(
            tooltip: unread == 0
                ? context.l10n.notifications
                : context.l10n.notificationsUnread(unread),
            onPressed: () => context.push('/notifications'),
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text(unread > 99 ? '99+' : '$unread'),
              child: const Icon(Icons.notifications_none),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const pill = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppRadius.pill)),
      borderSide: BorderSide(color: AppColors.inputBorder),
    );
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: context.l10n.searchAuctions,
        prefixIcon: const Icon(Icons.search),
        constraints: const BoxConstraints(minHeight: AppSizes.searchHeight),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: pill,
        enabledBorder: pill,
        focusedBorder: pill.copyWith(borderSide: const BorderSide(color: AppColors.ink, width: 2)),
      ),
    );
  }
}

class _CategoryChips extends ConsumerWidget {
  const _CategoryChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(homeFilterProvider.select((f) => f.category));
    final cats = ref.watch(categoriesProvider).value ?? const [];
    final filter = ref.read(homeFilterProvider.notifier);

    Widget chip(String label, String? slug) => Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected == slug,
        onSelected: (_) => filter.setCategory(slug),
        materialTapTargetSize: MaterialTapTargetSize.padded,
        visualDensity: VisualDensity.standard,
      ),
    );

    return SizedBox(
      height: AppSizes.touchTarget + 4,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [chip(context.l10n.all, null), for (final c in cats) chip(c.name, c.slug)],
      ),
    );
  }
}

class _EndingSoon extends ConsumerWidget {
  const _EndingSoon();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // While searching or filtering, only the filtered grid below is shown,
    // so results aren't mixed up with unrelated "ending soon" auctions.
    final filtering = ref.watch(
      homeFilterProvider.select((f) => f.query.trim().isNotEmpty || f.category != null),
    );
    if (filtering) return const SizedBox.shrink();
    final items = ref.watch(endingSoonProvider);
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
          child: SectionHeader(context.l10n.endingSoon, onSeeAll: () => context.go('/trending')),
        ),
        SizedBox(
          height: EndingSoonCard.height(scale),
          child: switch (items) {
            AsyncValue(:final value?) when value.isEmpty => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(context.l10n.noEndingSoon, style: AppText.meta),
              ),
            ),
            AsyncValue(:final value?) => ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: value.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, i) => EndingSoonCard(listing: value[i]),
            ),
            AsyncValue(:final error?) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(friendlyError(error), style: AppText.meta),
            ),
            _ => ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, _) => const SkeletonBox(width: EndingSoonCard.width, height: 104),
            ),
          },
        ),
      ],
    );
  }
}
