import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/l10n.dart';
import '../../domain/models/app_user.dart';
import '../../domain/models/listing.dart';
import '../../domain/models/order.dart';
import '../../data/repositories/user_repository.dart';
import '../../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/user_avatar.dart';

/// Account tab: profile header, stats, and Selling / Buying / Settings menus.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref, String uid) async {
    final service = ref.read(notificationServiceProvider);
    final users = ref.read(userRepositoryProvider);
    final auth = ref.read(authRepositoryProvider);
    try {
      // Stop pushes to this device for this account. Never let a slow token
      // fetch or a write that is waiting for the network block signing out.
      final token = await service.getToken().timeout(const Duration(seconds: 4));
      if (token != null) {
        await users.removeFcmToken(uid, token).timeout(const Duration(seconds: 4));
      }
    } catch (_) {}
    try {
      await auth.signOut();
    } catch (e) {
      if (context.mounted) showSnack(context, context.l10n.couldNotSignOut('$e'));
      return;
    }
    // The router also redirects on the auth change; go there directly too.
    if (context.mounted) context.go('/login');
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final first = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.deleteAccountQ),
        content: Text(context.l10n.deleteAccountBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.continueLabel),
          ),
        ],
      ),
    );
    if (first != true || !context.mounted) return;
    final confirm = TextEditingController();
    final word = context.l10n.deleteWord;
    final second = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(context.l10n.typeToConfirm(word)),
          content: TextField(
            controller: confirm,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(hintText: word),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(context.l10n.cancel),
            ),
            TextButton(
              onPressed: confirm.text.trim().toUpperCase() == word
                  ? () => Navigator.pop(ctx, true)
                  : null,
              child: Text(context.l10n.deleteAccount),
            ),
          ],
        ),
      ),
    );
    confirm.dispose();
    if (second != true || !context.mounted) return;

    final auth = ref.read(authRepositoryProvider);
    final uid = ref.read(authStateProvider).value?.uid;
    if (uid == null) return;
    // Firebase requires a fresh login before deleting: password or Google again.
    String? password;
    if (auth.usesPassword) {
      password = await _askPassword(context);
      if (password == null || !context.mounted) return;
    }
    try {
      await auth.reauthenticate(password: password);
      await ref.read(userRepositoryProvider).deleteMyData(uid);
      await auth.deleteLogin();
      if (context.mounted) showSnack(context, context.l10n.accountDeleted);
    } on AccountDeletionBlocked catch (e) {
      if (context.mounted) showSnack(context, e.message);
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        showSnack(context, switch (e.code) {
          'wrong-password' || 'invalid-credential' => context.l10n.wrongPasswordNothingDeleted,
          'popup-closed-by-user' ||
          'cancelled-popup-request' => context.l10n.cancelledNothingDeleted,
          _ => e.message ?? context.l10n.couldNotDeleteAccount,
        });
      }
    } catch (e) {
      if (context.mounted) showSnack(context, friendlyError(e));
    }
  }

  Future<String?> _askPassword(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.enterYourPassword),
        content: TextField(
          controller: controller,
          autofocus: true,
          obscureText: true,
          decoration: InputDecoration(hintText: context.l10n.password),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(context.l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: Text(context.l10n.deleteAccount),
          ),
        ],
      ),
    );
    controller.dispose();
    return (result == null || result.isEmpty) ? null : result;
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
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
            child: Row(
              children: [
                UserAvatar(name: user.displayName, photoUrl: user.photoUrl, size: 80),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(user.displayName, style: AppText.profileName),
                          if (verified) _VerifiedPill(context.l10n.verified),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        user.ratingCount == 0
                            ? context.l10n.noRatingsYet
                            : context.l10n.ratingSummary(user.positivePct, user.ratingCount),
                        style: _headerMeta,
                      ),
                      if (user.createdAt != null) ...[
                        const SizedBox(height: 6),
                        Text(context.l10n.memberSince(user.createdAt!.year), style: _headerMeta),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  tooltip: context.l10n.editProfile,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.line,
                    foregroundColor: AppColors.body,
                    fixedSize: const Size(36, 36),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: () => context.push('/account/edit'),
                ),
              ],
            ),
          ),
          // --- Stats ------------------------------------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.cardBorder, width: 1.5),
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
                    const VerticalDivider(width: 1.5, thickness: 1.5, color: AppColors.cardBorder),
                    _Stat(
                      label: context.l10n.sold,
                      value: sold,
                      onTap: () => context.push('/account/listings?filter=sold'),
                    ),
                    const VerticalDivider(width: 1.5, thickness: 1.5, color: AppColors.cardBorder),
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
          _Group(context.l10n.selling),
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
          _Group(context.l10n.buying),
          _MenuRow(
            label: context.l10n.purchasesAndOrders,
            onTap: () => context.push('/account/orders?mode=purchases'),
          ),
          _MenuRow(label: context.l10n.addresses, onTap: () => context.push('/addresses')),
          _Group(context.l10n.settings),
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
            onTap: () => _signOut(context, ref, user.uid),
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
              Text('$value', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(label, style: const TextStyle(fontSize: 13, color: AppColors.body)),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Name-block meta lines ("98% positive · 124 ratings").
const _headerMeta = TextStyle(fontSize: 14, color: AppColors.ink);

/// Teal outlined "VERIFIED USER" pill.
class _VerifiedPill extends StatelessWidget {
  const _VerifiedPill(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.brand, width: 1.5),
      borderRadius: BorderRadius.circular(AppRadius.pill),
    ),
    child: Text(
      label.toUpperCase(),
      style: AppText.pill.copyWith(color: AppColors.brand, letterSpacing: 0),
    ),
  );
}

/// Bold cyan group title ("SELLING", "BUYING", "SETTINGS").
class _Group extends StatelessWidget {
  const _Group(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 28, 16, 4),
    child: Semantics(
      header: true,
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.brandBright,
        ),
      ),
    ),
  );
}

/// Menu row: height 56, full-width bottom line, grey value + chevron on the right.
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
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.only(left: 16, right: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.line, width: 1.5)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
            if (value != null)
              Text(value!, style: const TextStyle(fontSize: 14, color: AppColors.navInactive)),
            if (chevron) const Icon(Icons.chevron_right, color: AppColors.navInactive),
          ],
        ),
      ),
    ),
  );
}

/// Used by Notification settings to read the current user's prefs.
PrefChannels prefOf(AppUser? u, NotificationPref p) => u?.prefFor(p) ?? (push: true, email: false);
