import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/providers.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    if (user == null) return const SizedBox();

    Future<void> signOut() async {
      final service = ref.read(notificationServiceProvider);
      try {
        // Stop pushes to this device for this account.
        final token = await service.getToken();
        if (token != null) await ref.read(userRepositoryProvider).removeFcmToken(user.uid, token);
      } catch (_) {}
      await ref.read(authRepositoryProvider).signOut();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.ink,
            foregroundColor: AppColors.paper,
            child: Text(
              user.displayName.isEmpty ? '?' : user.displayName[0].toUpperCase(),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(child: Text(user.displayName, style: Theme.of(context).textTheme.titleLarge)),
        Center(
          child: Text(user.email, style: const TextStyle(color: AppColors.muted)),
        ),
        const SizedBox(height: 8),
        Center(
          child: Chip(
            avatar: Icon(user.isAdmin ? Icons.admin_panel_settings : Icons.person, size: 18),
            label: Text('Role: ${user.role.value}'),
          ),
        ),
        const SizedBox(height: 24),
        const Divider(),
        // Authorization: only admins see (and can open) the admin panel.
        if (user.isAdmin)
          ListTile(
            leading: const Icon(Icons.admin_panel_settings),
            title: const Text('Admin panel'),
            subtitle: const Text('Moderate all listings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/admin'),
          ),
        ListTile(
          leading: const Icon(Icons.key_outlined),
          title: const Text('Copy FCM token'),
          subtitle: const Text('Use it to send a test push from the Firebase console'),
          onTap: () async {
            final token = await ref.read(notificationServiceProvider).getToken();
            if (token == null) return;
            await Clipboard.setData(ClipboardData(text: token));
            if (context.mounted) showSnack(context, 'FCM token copied.');
          },
        ),
        ListTile(leading: const Icon(Icons.logout), title: const Text('Sign out'), onTap: signOut),
      ],
    );
  }
}
