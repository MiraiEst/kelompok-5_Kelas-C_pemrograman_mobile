import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/providers.dart';
import '../activity/activity_tab.dart';
import '../notifications/notifications_tab.dart';
import '../profile/profile_tab.dart';
import 'browse_tab.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  static const _titles = ['Browse auctions', 'My activity', 'Notifications', 'Profile'];

  @override
  Widget build(BuildContext context) {
    final unread = ref.watch(unreadCountProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index])),
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          const NavigationDestination(icon: Icon(Icons.storefront_outlined), label: 'Browse'),
          const NavigationDestination(icon: Icon(Icons.history), label: 'Activity'),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text('$unread'),
              child: const Icon(Icons.notifications_outlined),
            ),
            label: 'Alerts',
          ),
          const NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
