import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config.dart';
import '../../core/extensions.dart';
import '../../domain/models/app_user.dart';
import '../../domain/models/listing.dart';
import '../../domain/models/order.dart';
import '../../domain/models/payout_account.dart';
import '../../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/app_text_field.dart';
import '../widgets/buttons.dart';
import '../widgets/common.dart';
import '../widgets/status_pill.dart';
import '../widgets/user_avatar.dart';
import 'account_screen.dart' show prefOf;

// ============================================================================
// My listings (Active / Sold / Unsold / Ended) with Relist / End
// ============================================================================

class MyListingsScreen extends ConsumerStatefulWidget {
  const MyListingsScreen({super.key, this.initial = ListingStatus.active});
  final ListingStatus initial;

  @override
  ConsumerState<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends ConsumerState<MyListingsScreen> {
  late ListingStatus _filter = widget.initial;

  Future<void> _end(Listing l) async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;
    try {
      await ref.read(listingRepositoryProvider).endEarly(l, user);
      if (mounted) showSnack(context, 'Listing ended.');
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e));
    }
  }

  Future<void> _relist(Listing l) async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;
    try {
      final id = await ref
          .read(listingRepositoryProvider)
          .relist(l, user, AuctionDuration.sevenDays);
      if (mounted) {
        showSnack(context, 'Relisted for 7 days.');
        context.push('/listing/$id');
      }
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final mine = ref.watch(myListingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My listings')),
      body: Column(
        children: [
          SizedBox(
            height: AppSizes.touchTarget + 8,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              children: [
                for (final s in ListingStatus.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        '${s.value[0].toUpperCase()}${s.value.substring(1)} '
                        '(${mine.value?.where((l) => l.status == s).length ?? 0})',
                      ),
                      selected: _filter == s,
                      onSelected: (_) => setState(() => _filter = s),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: switch (mine) {
              AsyncValue(:final value?) => () {
                final items = value.where((l) => l.status == _filter).toList();
                if (items.isEmpty) {
                  return const EmptyState(icon: Icons.sell_outlined, text: 'No listings here.');
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final l = items[i];
                    final canEnd = l.isActive && l.bidCount == 0;
                    final canRelist =
                        l.status == ListingStatus.unsold || l.status == ListingStatus.ended;
                    return _ListingRow(
                      listing: l,
                      action: canEnd
                          ? TextButton(onPressed: () => _end(l), child: const Text('End'))
                          : canRelist
                          ? TextButton(onPressed: () => _relist(l), child: const Text('Relist'))
                          : null,
                    );
                  },
                );
              }(),
              AsyncValue(:final error?) => ErrorText(
                error,
                onRetry: () => ref.invalidate(myListingsProvider),
              ),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ],
      ),
    );
  }
}

class _ListingRow extends StatelessWidget {
  const _ListingRow({required this.listing, this.action});
  final Listing listing;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final l = listing;
    return InkWell(
      onTap: () => context.push('/listing/${l.id}'),
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Row(
          children: [
            ListingImage(
              url: l.thumbnail,
              size: 56,
              borderRadius: BorderRadius.circular(AppRadius.photoSmall),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.small),
                  Text((l.finalPrice ?? l.currentPrice).toRupiah(), style: AppText.price),
                  Text('${l.bidCount} bids · ${l.watcherCount} watching', style: AppText.caption),
                ],
              ),
            ),
            ?action,
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Orders (to ship as seller / purchases as buyer)
// ============================================================================

class OrdersListScreen extends ConsumerWidget {
  const OrdersListScreen({super.key, required this.toShip});
  final bool toShip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(toShip ? mySalesProvider : myPurchasesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(toShip ? 'Orders to ship' : 'Purchases & orders')),
      body: switch (orders) {
        AsyncValue(:final value?) => () {
          final items = toShip ? value.where((o) => o.status == OrderStatus.paid).toList() : value;
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.local_shipping_outlined,
              text: toShip ? 'Nothing to ship right now.' : 'Items you buy will appear here.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _OrderRow(order: items[i]),
          );
        }(),
        AsyncValue(:final error?) => ErrorText(
          error,
          onRetry: () => ref.invalidate(toShip ? mySalesProvider : myPurchasesProvider),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.order});
  final AuctionOrder order;

  @override
  Widget build(BuildContext context) {
    final o = order;
    final variant = switch (o.status) {
      OrderStatus.awaitingPayment => PillVariant.outlined,
      OrderStatus.completed || OrderStatus.cancelled => PillVariant.soft,
      _ => PillVariant.filled,
    };
    return InkWell(
      onTap: () => context.push('/orders/${o.id}'),
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Row(
          children: [
            ListingImage(
              url: o.imageUrl,
              size: 56,
              borderRadius: BorderRadius.circular(AppRadius.photoSmall),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatusPill(o.status.label, variant: variant),
                  const SizedBox(height: 4),
                  Text(o.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.small),
                  Text('#${o.shortNumber} · ${o.total.toRupiah()}', style: AppText.caption),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Payout account
// ============================================================================

class PayoutScreen extends ConsumerStatefulWidget {
  const PayoutScreen({super.key});

  @override
  ConsumerState<PayoutScreen> createState() => _PayoutScreenState();
}

class _PayoutScreenState extends ConsumerState<PayoutScreen> {
  final _form = GlobalKey<FormState>();
  final _number = TextEditingController();
  final _holder = TextEditingController();
  String? _bank;
  bool _editing = false;
  bool _busy = false;

  @override
  void dispose() {
    _number.dispose();
    _holder.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final uid = ref.read(authStateProvider).value?.uid;
    if (uid == null) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(userRepositoryProvider)
          .savePayout(
            uid,
            PayoutAccount(
              bankName: _bank!,
              accountNumber: _number.text.trim(),
              accountHolder: _holder.text.trim(),
            ),
          );
      if (!mounted) return;
      setState(() => _editing = false);
      showSnack(context, 'Payout account saved.');
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = ref.watch(payoutProvider);
    final saved = current.value;
    final showForm = _editing || (current.hasValue && saved == null);

    return Scaffold(
      appBar: AppBar(title: const Text('Payout account')),
      body: current.isLoading && !current.hasValue
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  "Sale proceeds are paid to this account after the buyer confirms delivery.",
                  style: AppText.meta,
                ),
                const SizedBox(height: 16),
                if (!showForm && saved != null) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.line),
                      borderRadius: BorderRadius.circular(AppRadius.card),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(saved.masked, style: AppText.sectionTitle),
                        Text(saved.accountHolder, style: AppText.meta),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SecondaryButton(
                    label: 'Change account',
                    onPressed: () => setState(() {
                      _editing = true;
                      _bank = saved.bankName;
                      _holder.text = saved.accountHolder;
                      _number.clear(); // never pre-fill the full number
                    }),
                  ),
                ] else
                  Form(
                    key: _form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Bank', style: AppText.fieldLabel),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _bank,
                          hint: const Text('Choose your bank'),
                          items: [
                            for (final b in PayoutAccount.banks)
                              DropdownMenuItem(value: b, child: Text(b)),
                          ],
                          onChanged: (v) => setState(() => _bank = v),
                          validator: (v) => v == null ? 'Choose a bank' : null,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'Account number',
                          controller: _number,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (v) =>
                              (v == null || v.length < 8) ? 'Enter a valid account number' : null,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'Account holder name',
                          controller: _holder,
                          validator: (v) => (v == null || v.trim().length < 3)
                              ? 'Enter the name on the account'
                              : null,
                        ),
                        const SizedBox(height: 24),
                        PrimaryButton(label: 'Save', loading: _busy, onPressed: _save),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

// ============================================================================
// Notification settings
// ============================================================================

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    Future<void> set(NotificationPref p, PrefChannels v) async {
      if (user == null) return;
      try {
        await ref.read(userRepositoryProvider).setNotificationPref(user.uid, p, v);
      } catch (e) {
        if (context.mounted) showSnack(context, friendlyError(e));
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Notification settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Expanded(child: SizedBox()),
                SizedBox(
                  width: 64,
                  child: Center(child: Text('Push', style: AppText.groupLabel)),
                ),
                SizedBox(
                  width: 64,
                  child: Center(child: Text('Email', style: AppText.groupLabel)),
                ),
              ],
            ),
          ),
          for (final p in NotificationPref.values)
            Container(
              constraints: const BoxConstraints(minHeight: 56),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.line)),
              ),
              child: Row(
                children: [
                  Expanded(child: Text(p.label)),
                  SizedBox(
                    width: 64,
                    child: Switch(
                      value: prefOf(user, p).push,
                      onChanged: (v) => set(p, (push: v, email: prefOf(user, p).email)),
                    ),
                  ),
                  SizedBox(
                    width: 64,
                    child: Switch(
                      value: prefOf(user, p).email,
                      onChanged: (v) => set(p, (push: prefOf(user, p).push, email: v)),
                    ),
                  ),
                ],
              ),
            ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'In-app notifications always appear in the Notifications list. '
              'These switches control pushes to your phone and emails.',
              style: AppText.caption,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Help, terms & privacy
// ============================================================================

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _faq = [
    (
      'How does proxy bidding work?',
      'Enter the most you are willing to pay. We bid for you only as much as needed to keep you in '
          'the lead, up to that maximum. Nobody else ever sees your maximum.',
    ),
    (
      'What is a reserve price?',
      'A hidden minimum set by the seller. If bidding ends below it, the item does not sell. '
          'The listing shows "Reserve met" once a bid reaches it.',
    ),
    (
      'What is buyer protection?',
      'Your payment is held by Imagi Auction and only released to the seller after you confirm '
          'delivery. If the item does not arrive or is not as described, use "Report a problem" on the order.',
    ),
    (
      'What does it cost?',
      'Buyers pay the winning price, shipping and a service fee of ${AppConfig.serviceFeePercent}% '
          '(max Rp 10.000). Sellers pay a final value fee of ${AppConfig.finalValueFeePercent}% of the sale price.',
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Help, terms & privacy')),
    body: ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        for (final (q, a) in _faq)
          ExpansionTile(
            title: Text(q, style: const TextStyle(fontWeight: FontWeight.w600)),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            expandedAlignment: Alignment.topLeft,
            children: [Text(a, style: AppText.body)],
          ),
        const SizedBox(height: 16),
        ListTile(
          title: const Text('Terms of Service'),
          trailing: const Icon(Icons.open_in_new),
          onTap: () => launchUrl(Uri.parse(AppConfig.termsUrl), mode: LaunchMode.inAppBrowserView),
        ),
        ListTile(
          title: const Text('Privacy Policy'),
          trailing: const Icon(Icons.open_in_new),
          onTap: () =>
              launchUrl(Uri.parse(AppConfig.privacyUrl), mode: LaunchMode.inAppBrowserView),
        ),
      ],
    ),
  );
}

// ============================================================================
// Edit profile
// ============================================================================

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _form = GlobalKey<FormState>();
  late final AppUser? _user = ref.read(currentUserProvider).value;
  late final _name = TextEditingController(text: _user?.displayName);
  late final _phone = TextEditingController(text: _user?.phone);
  Uint8List? _newPhoto;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final f = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (f == null) return;
    final bytes = await f.readAsBytes();
    if (mounted) setState(() => _newPhoto = bytes);
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final uid = _user?.uid;
    if (uid == null) return;
    setState(() => _busy = true);
    try {
      final photoUrl = _newPhoto == null
          ? null
          : await ref.read(storageRepositoryProvider).uploadAvatar(uid: uid, bytes: _newPhoto!);
      await ref
          .read(userRepositoryProvider)
          .updateProfile(
            uid,
            displayName: _name.text.trim(),
            phone: _phone.text.replaceAll(' ', ''),
            photoUrl: photoUrl,
          );
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = _user;
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Semantics(
                button: true,
                label: 'Change profile photo',
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _pickPhoto,
                  child: _newPhoto != null
                      ? CircleAvatar(radius: 44, backgroundImage: MemoryImage(_newPhoto!))
                      : UserAvatar(name: u?.displayName ?? '?', photoUrl: u?.photoUrl, size: 88),
                ),
              ),
            ),
            Center(
              child: TextButton(onPressed: _pickPhoto, child: const Text('Change photo')),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Username',
              controller: _name,
              helper: 'Shown masked when you bid',
              validator: (v) => (v == null || v.trim().length < 3) ? 'At least 3 characters' : null,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Phone number',
              controller: _phone,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]'))],
              validator: (v) =>
                  (v == null ||
                      v.isEmpty ||
                      RegExp(r'^08\d{8,11}$').hasMatch(v.replaceAll(' ', '')))
                  ? null
                  : 'Use an Indonesian number starting with 08',
            ),
            const SizedBox(height: 16),
            const Text('Email', style: AppText.fieldLabel),
            const SizedBox(height: 6),
            Text(u?.email ?? '', style: AppText.meta),
            const Text("Email can't be changed here.", style: AppText.caption),
            const SizedBox(height: 24),
            PrimaryButton(label: 'Save', loading: _busy, onPressed: _save),
          ],
        ),
      ),
    );
  }
}
