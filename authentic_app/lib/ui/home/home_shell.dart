import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/l10n.dart';

import '../../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Bottom navigation shell with 4 tabs. Each tab keeps its own navigation
/// stack and scroll position (StatefulShellRoute.indexedStack).
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  static const _items = [
    Icons.home_outlined,
    Icons.trending_up,
    Icons.gavel_outlined,
    Icons.person_outline,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    return Scaffold(
      body: user.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorText(e, onRetry: () => ref.invalidate(currentUserProvider)),
        // null = profile doc is still being created right after sign-up.
        data: (u) => u == null ? const Center(child: CircularProgressIndicator()) : shell,
      ),
      bottomNavigationBar: _NavBar(
        selected: shell.currentIndex,
        onSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar({required this.selected, required this.onSelected});
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.outlineSoft)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppSizes.navBarHeight,
          child: Row(
            children: [
              for (var i = 0; i < HomeShell._items.length; i++)
                Expanded(
                  child: _NavItem(index: i, selected: i == selected, onTap: () => onSelected(i)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.index, required this.selected, required this.onTap});
  final int index;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final label = [l.navHome, l.navTrending, l.navYourBids, l.navAccount][index];
    final color = selected ? AppColors.brand : AppColors.navInactive;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      // Icons only; the label is kept for screen readers and the long-press tooltip.
      child: Tooltip(
        message: label,
        child: InkWell(
          onTap: onTap,
          child: Column(
            children: [
              // Full-width bar along the top edge of the active tab.
              Container(
                height: AppSizes.indicator,
                color: selected ? AppColors.brandBright : Colors.transparent,
              ),
              const Spacer(),
              Icon(HomeShell._items[index], color: color, size: 30),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
