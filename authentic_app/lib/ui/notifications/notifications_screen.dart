import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/l10n.dart';
import '../../domain/models/app_notification.dart';
import '../../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/section_header.dart';

IconData notificationIcon(NotificationType t) => switch (t) {
  NotificationType.outbid => Icons.trending_down,
  NotificationType.endingSoon => Icons.schedule,
  NotificationType.won => Icons.emoji_events_outlined,
  NotificationType.lost => Icons.sentiment_dissatisfied_outlined,
  NotificationType.sold => Icons.account_balance_wallet_outlined,
  NotificationType.newBid => Icons.gavel,
  NotificationType.reserveMet => Icons.check,
  NotificationType.shipped => Icons.local_shipping_outlined,
  NotificationType.paymentReminder => Icons.credit_card,
  NotificationType.paymentReceived => Icons.payments_outlined,
  NotificationType.delivered => Icons.inventory_2_outlined,
  NotificationType.secondChance => Icons.local_offer_outlined,
  NotificationType.unsold => Icons.remove_shopping_cart_outlined,
  NotificationType.other => Icons.notifications_none,
};

/// "2 min ago", "1 h ago", "Yesterday", "3 days ago" (localized).
String relativeTime(DateTime t, DateTime now, AppLocalizations l) {
  final d = now.difference(t);
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(t.year, t.month, t.day);
  final days = today.difference(day).inDays;
  if (d.inMinutes < 1) return l.justNow;
  if (d.inMinutes < 60) return l.minAgo(d.inMinutes);
  if (days == 0) return l.hoursAgo(d.inHours);
  if (days == 1) return l.yesterday;
  return l.daysAgo(days);
}

enum NotificationGroup { today, yesterday, earlier }

/// TODAY / YESTERDAY / EARLIER.
NotificationGroup notificationGroup(DateTime t, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(t.year, t.month, t.day);
  return switch (today.difference(day).inDays) {
    <= 0 => NotificationGroup.today,
    1 => NotificationGroup.yesterday,
    _ => NotificationGroup.earlier,
  };
}

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final _scroll = ScrollController();

  /// Swiped away but not yet deleted (until the undo SnackBar closes).
  final _pendingDelete = <String>{};

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter > 400) return;
      final items = ref.read(notificationsPageProvider).value;
      final limit = ref.read(notificationsLimitProvider);
      if (items != null && items.length >= limit) {
        ref.read(notificationsLimitProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  String? get _uid => ref.read(authStateProvider).value?.uid;

  void _open(AppNotification n) {
    final uid = _uid;
    if (uid != null && !n.read) ref.read(userRepositoryProvider).markRead(uid, n.id);
    final route = n.route;
    if (route != null) context.push(route);
  }

  void _dismiss(AppNotification n) {
    final uid = _uid;
    if (uid == null) return;
    setState(() => _pendingDelete.add(n.id));
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    messenger
        .showSnackBar(
          SnackBar(
            content: Text(context.l10n.notificationDeleted),
            action: SnackBarAction(
              label: context.l10n.undo,
              onPressed: () {
                if (mounted) setState(() => _pendingDelete.remove(n.id));
              },
            ),
          ),
        )
        .closed
        .then((reason) {
          if (reason == SnackBarClosedReason.action) return;
          ref.read(userRepositoryProvider).deleteNotification(uid, n.id);
          if (mounted) setState(() => _pendingDelete.remove(n.id));
        });
  }

  @override
  Widget build(BuildContext context) {
    final page = ref.watch(notificationsPageProvider);
    final all = page.value ?? const <AppNotification>[];
    final hasUnread = all.any((n) => !n.read);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: context.l10n.back,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: Text(context.l10n.notifications),
        actions: [
          TextButton(
            onPressed: !hasUnread || _uid == null
                ? null
                : () => ref.read(userRepositoryProvider).markAllRead(_uid!, all),
            child: Text(context.l10n.markAllRead),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: switch (page) {
        AsyncValue(:final value?) => _buildList(
          value.where((n) => !_pendingDelete.contains(n.id)).toList(),
          hasMore: value.length >= ref.watch(notificationsLimitProvider),
        ),
        AsyncValue(:final error?) => ErrorText(
          error,
          onRetry: () => ref.invalidate(notificationsPageProvider),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _buildList(List<AppNotification> items, {required bool hasMore}) {
    if (items.isEmpty) {
      return EmptyState(icon: Icons.notifications_none, text: context.l10n.notificationsEmpty);
    }
    final now = DateTime.now();
    final rows = <Widget>[];
    NotificationGroup? group;
    final l = context.l10n;
    for (final n in items) {
      final g = notificationGroup(n.createdAt, now);
      if (g != group) {
        group = g;
        final label = switch (g) {
          NotificationGroup.today => l.today,
          NotificationGroup.yesterday => l.yesterday,
          NotificationGroup.earlier => l.earlier,
        };
        rows.add(GroupLabel(label, padding: const EdgeInsets.fromLTRB(16, 16, 16, 8)));
      }
      rows.add(
        Dismissible(
          key: ValueKey(n.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: AppColors.ink,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete_outline, color: AppColors.onInk),
          ),
          onDismissed: (_) => _dismiss(n),
          child: NotificationTile(notification: n, now: now, onTap: () => _open(n)),
        ),
      );
    }
    if (hasMore) {
      rows.add(
        const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    return ListView(
      controller: _scroll,
      padding: const EdgeInsets.only(bottom: 24),
      children: rows,
    );
  }
}

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.now,
    required this.onTap,
  });
  final AppNotification notification;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final n = notification;
    final unread = !n.read;
    final when = relativeTime(n.createdAt, now, context.l10n);
    return Semantics(
      button: true,
      label: '${unread ? context.l10n.unreadPrefix : ''}${n.title}. ${n.body}. $when',
      excludeSemantics: true,
      child: Material(
        color: unread ? AppColors.surface : AppColors.background,
        child: InkWell(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 72),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: unread ? AppColors.ink : AppColors.background,
                    border: Border.all(color: AppColors.ink),
                  ),
                  child: Icon(
                    notificationIcon(n.type),
                    size: 20,
                    color: unread ? AppColors.onInk : AppColors.ink,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        n.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(n.body, style: const TextStyle(fontSize: 13, color: AppColors.body)),
                      const SizedBox(height: 4),
                      Text(when, style: AppText.caption),
                    ],
                  ),
                ),
                if (unread)
                  Container(
                    margin: const EdgeInsets.only(left: 8, top: 4),
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(color: AppColors.ink, shape: BoxShape.circle),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
