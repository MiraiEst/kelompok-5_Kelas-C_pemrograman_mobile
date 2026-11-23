import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/l10n.dart';
import '../../domain/models/app_user.dart';
import '../../domain/models/listing.dart';
import '../../domain/models/order.dart';
import '../../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/section_header.dart';
import '../widgets/status_pill.dart';
import '../widgets/user_avatar.dart';

/// Account tab: profile header, stats, and Selling / Buying / Settings menus.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  Future<void> _signOut(WidgetRef ref, String uid) async {
    final service = ref.read(notificationServiceProvider);
    try {
      // Stop pushes to this device for this account.
      final token = await service.getToken();
      if (token != null) await ref.read(userRepositoryProvider).removeFcmToken(uid, token);
    } catch (_) {}
    await ref.read(authRepositoryProvider).signOut();
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final first = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete your account?'),
        content: const Text(
          'Your profile, addresses, payout account, drafts and watchlist will be deleted. '
          'Finished orders are kept for the other party. This cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Continue')),
        ],
      ),
    );
    if (first != true || !context.mounted) return;
    final confirm = TextEditingController();
    final second = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Type DELETE to confirm'),
          content: TextField(
            controller: confirm,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(hintText: 'DELETE'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            TextButton(
              onPressed: confirm.text.trim() == 'DELETE' ? () => Navigator.pop(ctx, true) : null,
              child: const Text('Delete account'),
            ),
          ],
        ),
      ),
    );
    confirm.dispose();
    if (second != true || !context.mounted) return;
    try {
      await ref.read(functionsProvider).httpsCallable('deleteAccount').call<void>();
      await ref.read(authRepositoryProvider).signOut();
    } on FirebaseFunctionsException catch (e) {
      if (context.mounted) {
        showSnack(context, switch (e.code) {
          'failed-precondition' => e.message ?? 'Finish your open orders first.',
          'not-found' => 'Account deletion needs the Cloud Functions to be deployed.',
          _ => e.message ?? 'Could not delete the account.',
        });
      }
    } catch (e) {
      if (context.mounted) showSnack(context, friendlyError(e));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    if (user == null) return const SizedBox();
    final verified = ref.watch(authStateProvider).value?.emailVerified ?? false;
    final mine = ref.watch(myListingsProvider).value ?? const <Listing>[];
    final purchases = ref.watch(myPurchasesProvider).value ?? const <AuctionOrder>[];
    final sales = ref.watch(mySalesProvider).value ?? const <AuctionOrder>[];
    final payout = ref.watch(payoutProvider).value;

    final active = mine.where((l) => l.isActive).length;
    final sold = mine.where((l) => l.status == ListingStatus.sold).length;
    final toShip = sales.where((o) => o.status == OrderStatus.paid).length;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          // --- Header ---------------------------------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserAvatar(name: user.displayName, photoUrl: user.photoUrl, size: 64),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(user.displayName, style: AppText.profileName),
                          if (verified)
                            StatusPill(context.l10n.verified, variant: PillVariant.outlined),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.ratingCount == 0
                            ? context.l10n.noRatingsYet
                            : context.l10n.ratingSummary(user.positivePct, user.ratingCount),
                        style: AppText.meta,
                      ),
                      if (user.createdAt != null)
                        Text(context.l10n.memberSince(user.createdAt!.year), style: AppText.meta),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: context.l10n.editProfile,
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => context.push('/account/edit'),
                ),
              ],
            ),
          ),
          // --- Stats ------------------------------------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.line),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    _Stat(
                      label: context.l10n.selling,
                      value: active,
                      onTap: () => context.push('/account/listings?filter=active'),
                    ),
                    const VerticalDivider(width: 1),
                    _Stat(
                      label: context.l10n.sold,
                      value: sold,
                      onTap: () => context.push('/account/listings?filter=sold'),
                    ),
                    const VerticalDivider(width: 1),
                    _Stat(
                      label: context.l10n.purchases,
                      value: purchases.length,
                      onTap: () => context.push('/account/orders?mode=purchases'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // --- Menus --------------------------------------------------------------
          GroupLabel(context.l10n.selling),
          _MenuRow(
            label: context.l10n.myListings,
            value: context.l10n.activeCount(active),
            onTap: () => context.push('/account/listings?filter=active'),
          ),
          _MenuRow(
            label: context.l10n.ordersToShip,
            value: '$toShip',
            onTap: () => context.push('/account/orders?mode=ship'),
          ),
          _MenuRow(
            label: context.l10n.payoutAccount,
            value: payout?.masked ?? context.l10n.notSet,
            onTap: () => context.push('/account/payout'),
          ),
          GroupLabel(context.l10n.buying),
          _MenuRow(
            label: context.l10n.purchasesAndOrders,
            onTap: () => context.push('/account/orders?mode=purchases'),
          ),
          _MenuRow(label: context.l10n.addresses, onTap: () => context.push('/addresses')),
          GroupLabel(context.l10n.settings),
          _MenuRow(
            label: context.l10n.notificationSettings,
            onTap: () => context.push('/account/notifications'),
          ),
          if (user.isAdmin)
            _MenuRow(
              label: context.l10n.adminPanel,
              value: context.l10n.adminsOnly,
              onTap: () => context.push('/admin'),
            ),
          _MenuRow(
            label: context.l10n.helpTermsPrivacy,
            onTap: () => context.push('/account/help'),
          ),
          _MenuRow(label: context.l10n.deleteAccount, onTap: () => _deleteAccount(context, ref)),
          if (kDebugMode)
            _MenuRow(
              label: 'Copy FCM token (debug)',
              onTap: () async {
                final token = await ref.read(notificationServiceProvider).getToken();
                if (token == null) {
                  if (context.mounted) showSnack(context, 'No FCM token on this platform.');
                  return;
                }
                await Clipboard.setData(ClipboardData(text: token));
                if (context.mounted) showSnack(context, 'FCM token copied.');
              },
            ),
          _MenuRow(
            label: context.l10n.signOut,
            bold: true,
            chevron: false,
            onTap: () => _signOut(ref, user.uid),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.onTap});
  final String label;
  final int value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Semantics(
      button: true,
      label: '$label: $value',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Text('$value', style: AppText.title),
              Text(label, style: AppText.caption),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Menu row: height 48, thin bottom line, value + chevron on the right.
class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.label,
    required this.onTap,
    this.value,
    this.bold = false,
    this.chevron = true,
  });
  final String label;
  final String? value;
  final VoidCallback onTap;
  final bool bold;
  final bool chevron;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: value == null ? label : '$label, $value',
    excludeSemantics: true,
    child: InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.line)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
            if (value != null) Text(value!, style: AppText.meta),
            if (chevron) const Icon(Icons.chevron_right, color: AppColors.muted),
          ],
        ),
      ),
    ),
  );
}

/// Used by Notification settings to read the current user's prefs.
PrefChannels prefOf(AppUser? u, NotificationPref p) => u?.prefFor(p) ?? (push: true, email: false);
