import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/order.dart';
import '../../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/app_text_field.dart';
import '../widgets/buttons.dart';
import '../widgets/common.dart';
import '../widgets/status_pill.dart';

/// Address card used in Checkout, Orders and the address list.
class AddressCard extends StatelessWidget {
  const AddressCard({super.key, required this.address, this.selected = false, this.trailing});
  final Address address;
  final bool selected;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final a = address;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: selected ? AppColors.ink : AppColors.line,
          width: selected ? 2 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(a.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                    if (a.isDefault) ...[const SizedBox(width: 8), const StatusPill('Default')],
                  ],
                ),
                const SizedBox(height: 2),
                Text(a.phone, style: AppText.meta),
                const SizedBox(height: 4),
                Text(a.street, style: AppText.small),
                Text('${a.city}, ${a.province} ${a.postalCode}', style: AppText.small),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// List of saved addresses. With [selectMode], tapping one returns it.
class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({super.key, this.selectMode = false});
  final bool selectMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addresses = ref.watch(addressesProvider);
    final uid = ref.watch(authStateProvider).value?.uid;

    Future<void> menu(Address a, String action) async {
      if (uid == null) return;
      final repo = ref.read(userRepositoryProvider);
      switch (action) {
        case 'edit':
          await context.push('/addresses/edit', extra: a);
        case 'default':
          await repo.setDefaultAddress(uid, a.id);
        case 'delete':
          final ok = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Delete this address?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
              ],
            ),
          );
          if (ok == true) await repo.deleteAddress(uid, a.id);
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(selectMode ? 'Choose address' : 'Addresses')),
      body: switch (addresses) {
        AsyncValue(:final value?) when value.isEmpty => EmptyState(
          icon: Icons.location_on_outlined,
          text: 'No saved addresses yet.',
          action: PrimaryButton(
            label: 'Add address',
            expand: false,
            onPressed: () => context.push('/addresses/edit'),
          ),
        ),
        AsyncValue(:final value?) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final a in value)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Semantics(
                  button: selectMode,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    onTap: selectMode
                        ? () => context.pop(a)
                        : () => context.push('/addresses/edit', extra: a),
                    child: AddressCard(
                      address: a,
                      trailing: PopupMenuButton<String>(
                        tooltip: 'Address options',
                        onSelected: (v) => menu(a, v),
                        itemBuilder: (_) => [
                          const PopupMenuItem(value: 'edit', child: Text('Edit')),
                          if (!a.isDefault)
                            const PopupMenuItem(value: 'default', child: Text('Set as default')),
                          const PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            SecondaryButton(
              label: 'Add address',
              icon: Icons.add,
              onPressed: () => context.push('/addresses/edit'),
            ),
          ],
        ),
        AsyncValue(:final error?) => ErrorText(
          error,
          onRetry: () => ref.invalidate(addressesProvider),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

/// Add / edit an address with validation.
class AddressFormScreen extends ConsumerStatefulWidget {
  const AddressFormScreen({super.key, this.address});
  final Address? address;

  @override
  ConsumerState<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends ConsumerState<AddressFormScreen> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.address?.name);
  late final _phone = TextEditingController(text: widget.address?.phone);
  late final _street = TextEditingController(text: widget.address?.street);
  late final _city = TextEditingController(text: widget.address?.city);
  late final _province = TextEditingController(text: widget.address?.province);
  late final _postal = TextEditingController(text: widget.address?.postalCode);
  late bool _default = widget.address?.isDefault ?? false;
  bool _busy = false;

  @override
  void dispose() {
    for (final c in [_name, _phone, _street, _city, _province, _postal]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final uid = ref.read(authStateProvider).value?.uid;
    if (uid == null) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(userRepositoryProvider)
          .saveAddress(
            uid,
            Address(
              id: widget.address?.id ?? '',
              name: _name.text.trim(),
              phone: _phone.text.replaceAll(' ', ''),
              street: _street.text.trim(),
              city: _city.text.trim(),
              province: _province.text.trim(),
              postalCode: _postal.text.trim(),
              isDefault: _default,
            ),
            makeDefault: _default,
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
    return Scaffold(
      appBar: AppBar(title: Text(widget.address == null ? 'Add address' : 'Edit address')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppTextField(label: 'Recipient name', controller: _name, validator: _required),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Phone number',
              controller: _phone,
              hint: '08xx xxxx xxxx',
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]'))],
              validator: (v) => RegExp(r'^08\d{8,11}$').hasMatch((v ?? '').replaceAll(' ', ''))
                  ? null
                  : 'Use an Indonesian number starting with 08',
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Street address',
              controller: _street,
              hint: 'Street, number, RT/RW, district',
              maxLines: 2,
              validator: _required,
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(label: 'City', controller: _city, validator: _required),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    label: 'Province',
                    controller: _province,
                    validator: _required,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Postal code',
              controller: _postal,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) => RegExp(r'^\d{5}$').hasMatch(v ?? '') ? null : 'Enter 5 digits',
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Use as default address'),
              value: _default,
              onChanged: (v) => setState(() => _default = v),
            ),
            const SizedBox(height: 16),
            PrimaryButton(label: 'Save address', loading: _busy, onPressed: _save),
          ],
        ),
      ),
    );
  }
}
