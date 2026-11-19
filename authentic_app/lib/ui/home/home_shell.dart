import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/providers.dart';
import '../activity/activity_tab.dart';
import '../notifications/notifications_tab.dart';
import '../profile/profile_tab.dart';
import '../widgets/brand.dart';
import 'browse_tab.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  static const _profileIndex = 3;
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final unread = ref.watch(unreadCountProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AuthenticTopBar(onAvatarTap: () => setState(() => _index = _profileIndex)),
      body: user.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load profile: $e')),
        data: (u) => u == null
            ? const Center(child: CircularProgressIndicator()) // profile doc being created
            : IndexedStack(
                index: _index,
                children: const [BrowseTab(), ActivityTab(), NotificationsTab(), ProfileTab()],
              ),
      ),
      floatingActionButton: _index == 0
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/sell'),
              icon: const Icon(Icons.add),
              label: const Text('Sell'),
            )
          : null,
      bottomNavigationBar: AuthenticNavBar(
        selectedIndex: _index,
        onSelected: (i) => setState(() => _index = i),
        items: [
          const NavItem(
            icon: Icons.storefront_outlined,
            activeIcon: Icons.storefront,
            label: 'Browse',
          ),
          const NavItem(
            icon: Icons.receipt_long_outlined,
            activeIcon: Icons.receipt_long,
            label: 'Activity',
          ),
          NavItem(
            icon: Icons.notifications_outlined,
            activeIcon: Icons.notifications,
            label: 'Alerts',
            badge: unread,
          ),
          const NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
        ],
      ),
    );
  }
}
