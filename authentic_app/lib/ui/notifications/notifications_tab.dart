import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/models/app_notification.dart';
import '../../providers/providers.dart';
import '../widgets/common.dart';

class NotificationsTab extends ConsumerWidget {
  const NotificationsTab({super.key});

  IconData _icon(NotificationType t) => switch (t) {
        NotificationType.outbid => Icons.trending_down,
        NotificationType.newBid => Icons.gavel,
        NotificationType.won => Icons.emoji_events,
        NotificationType.lost => Icons.sentiment_dissatisfied,
        NotificationType.sold => Icons.sell,
        NotificationType.unsold => Icons.inventory_2_outlined,
        NotificationType.other => Icons.notifications,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(currentUserProvider).value?.uid;
    final items = ref.watch(notificationsProvider);
    final fmt = DateFormat('d MMM, HH:mm', 'id_ID');

    return items.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorText(e),
      data: (list) => list.isEmpty
          ? const EmptyState(
              icon: Icons.notifications_none,
              text: 'Outbid alerts, wins and sales will show up here.',
            )
          : Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: uid == null
                        ? null
                        : () => ref.read(userRepositoryProvider).markAllRead(uid, list),
                    child: const Text('Mark all as read'),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final n = list[i];
                      return ListTile(
                        leading: Icon(_icon(n.type)),
                        title: Text(
                          n.title,
                          style: TextStyle(fontWeight: n.read ? FontWeight.normal : FontWeight.bold),
                        ),
                        subtitle: Text('${n.body}\n${fmt.format(n.createdAt)}'),
                        isThreeLine: true,
                        onTap: () {
                          if (uid != null && !n.read) {
                            ref.read(userRepositoryProvider).markRead(uid, n.id);
                          }
                          final id = n.listingId;
                          if (id != null) context.push('/listing/$id');
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
