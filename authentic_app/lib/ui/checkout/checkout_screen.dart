import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/extensions.dart';
import '../../data/services/courier_rate_service.dart';
import '../../domain/models/order.dart';
import '../../l10n/l10n.dart';
import '../../l10n/labels.dart';
import '../../providers/providers.dart';
import '../account/address_screens.dart';
import '../theme/app_theme.dart';
import '../widgets/buttons.dart';
import '../widgets/common.dart';
import '../widgets/section_header.dart';

/// Shipping options for an order (from the CourierRateService).
final courierRatesProvider = FutureProvider.autoDispose.family<List<CourierRate>, int>(
  (ref, shippingCost) =>
      ref.watch(courierRateServiceProvider).ratesFor(listingShippingCost: shippingCost),
);

/// Price lines shown at checkout. Pure so it can be unit/widget tested.
typedef PriceBreakdown = ({int item, int shipping, int fee, int total});

PriceBreakdown priceBreakdown({required int item, required int shipping, required int fee}) =>
    (item: item, shipping: shipping, fee: fee, total: item + shipping + fee);

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key, required this.orderId});
  final String orderId;

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  Address? _address;
  String? _courier;
  PaymentMethod _method = PaymentMethod.virtualAccount;
  bool _paying = false;
  bool _seeded = false;

  void _seed(AuctionOrder o, List<Address> saved) {
    if (_seeded) return;
    _seeded = true;
    _address = o.address ?? saved.where((a) => a.isDefault).firstOrNull ?? saved.firstOrNull;
    _courier = o.courier;
    _method = PaymentMethod.parse(o.paymentMethod) ?? _method;
  }

  Future<void> _changeAddress() async {
    final picked = await context.push<Address>('/addresses?select=1');
    if (picked != null && mounted) setState(() => _address = picked);
  }

  Future<void> _pay(AuctionOrder o, String courier) async {
    final address = _address;
    if (address == null) return;
    if (DateTime.now().isAfter(o.payBy)) {
      showSnack(context, context.l10n.paymentExpired);
      return;
    }
    setState(() => _paying = true);
    final repo = ref.read(orderRepositoryProvider);
    try {
      await repo.saveCheckoutChoices(
        o.id,
        address: address,
        courier: courier,
        paymentMethod: _method.value,
      );
      final url = await repo.createInvoice(o.id);
      final opened = await launchUrl(Uri.parse(url), mode: LaunchMode.inAppBrowserView);
      if (!opened && mounted) showSnack(context, context.l10n.couldNotOpenPayment);
      // The order stream flips to "paid" when Xendit calls our webhook.
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      showSnack(context, switch (e.code) {
        'unavailable' || 'deadline-exceeded' => context.l10n.noConnection,
        'failed-precondition' => e.message ?? context.l10n.orderCantBePaid,
        'not-found' => context.l10n.paymentsNotSetUp,
        _ => e.message ?? context.l10n.paymentFailed,
      });
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e));
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = ref.watch(orderProvider(widget.orderId));
    final saved = ref.watch(addressesProvider).value ?? const <Address>[];

    // Paid while the Xendit page was open -> success, then order tracking.
    ref.listen(orderProvider(widget.orderId), (prev, next) {
      final was = prev?.value?.status;
      final now = next.value?.status;
      if (now != null && now.isPaid && was != null && !was.isPaid) {
        Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => _PaymentSuccess(orderId: widget.orderId)));
      }
    });

    return Scaffold(
      appBar: brandAppBar(context, Text(context.l10n.checkout)),
      body: switch (order) {
        AsyncValue(:final value?) when value.status.isPaid => _AlreadyPaid(orderId: value.id),
        AsyncValue(:final value?) => Builder(
          builder: (context) {
            _seed(value, saved);
            return _body(value);
          },
        ),
        AsyncData() => EmptyState(
          icon: Icons.receipt_long_outlined,
          text: context.l10n.orderPreparing,
        ),
        AsyncValue(:final error?) => ErrorText(
          error,
          onRetry: () => ref.invalidate(orderProvider(widget.orderId)),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
      bottomNavigationBar: order.value == null || order.value!.status.isPaid
          ? null
          : _PayBar(
              enabled: _address != null && !_paying,
              loading: _paying,
              onPay: () async {
                final o = order.value!;
                final rates = await ref.read(courierRatesProvider(o.shippingCost).future);
                if (!mounted) return;
                await _pay(o, _courier ?? rates.first.name);
              },
            ),
    );
  }

  Widget _body(AuctionOrder o) {
    final rates = ref.watch(courierRatesProvider(o.shippingCost)).value ?? const [];
    final courier = rates.where((r) => r.name == _courier).firstOrNull ?? rates.firstOrNull;
    final prices = priceBreakdown(
      item: o.itemPrice,
      shipping: courier?.price ?? o.shippingCost,
      fee: o.serviceFee,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.cyanSoft, width: 1.5),
            borderRadius: BorderRadius.circular(AppRadius.input),
          ),
          child: Row(
            children: [
              ListingImage(
                url: o.imageUrl,
                size: 72,
                borderRadius: BorderRadius.circular(AppRadius.photoSmall),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      o.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.wonFor(o.itemPrice.toRupiah()),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    CountdownText(
                      endsAt: o.payBy,
                      prefix: '${context.l10n.payWithin} ',
                      format: (d) => d.toShort(),
                      style: AppText.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SectionHeader(
          context.l10n.shippingAddress,
          trailing: TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.ocean),
            onPressed: _changeAddress,
            child: Text(_address == null ? context.l10n.add : context.l10n.change),
          ),
        ),
        const SizedBox(height: 8),
        if (_address != null)
          AddressCard(address: _address!)
        else
          SecondaryButton(
            label: context.l10n.addShippingAddress,
            icon: Icons.add,
            onPressed: _changeAddress,
          ),
        const SizedBox(height: 24),
        SectionHeader(context.l10n.courier),
        const SizedBox(height: 8),
        for (final r in rates)
          _RadioCard(
            selected: r.name == courier?.name,
            title: r.name,
            subtitle: context.l10n.etaDays(r.eta),
            trailing: r.price == 0 ? context.l10n.free : r.price.toRupiah(),
            onTap: () => setState(() => _courier = r.name),
          ),
        const SizedBox(height: 16),
        SectionHeader(context.l10n.paymentMethod),
        const SizedBox(height: 8),
        for (final m in PaymentMethod.values)
          _RadioCard(
            selected: m == _method,
            title: m.text(context),
            subtitle: m.detailText(context),
            onTap: () => setState(() => _method = m),
          ),
        const SizedBox(height: 16),
        PriceSummary(prices: prices),
        const SizedBox(height: 12),
        Text(context.l10n.heldNote, style: AppText.caption.copyWith(color: AppColors.navInactive)),
      ],
    );
  }
}

/// Winning price / Shipping / Service fee / Total.
class PriceSummary extends StatelessWidget {
  const PriceSummary({super.key, required this.prices});
  final PriceBreakdown prices;

  @override
  Widget build(BuildContext context) {
    const totalStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.w700);
    Widget row(String label, int value, {bool total = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: total ? totalStyle : AppText.body)),
          Text(
            value.toRupiah(),
            key: total ? const Key('checkoutTotal') : null,
            style: total ? totalStyle : AppText.body,
          ),
        ],
      ),
    );
    return Column(
      children: [
        const Padding(padding: EdgeInsets.only(bottom: 8), child: Divider()),
        row(context.l10n.winningPrice, prices.item),
        row(context.l10n.shipping, prices.shipping),
        row(context.l10n.serviceFee, prices.fee),
        const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider()),
        row(context.l10n.total, prices.total, total: true),
      ],
    );
  }
}

class _RadioCard extends StatelessWidget {
  const _RadioCard({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  final bool selected;
  final String title;
  final String subtitle;
  final String? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      label: '$title, $subtitle${trailing == null ? '' : ', $trailing'}',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.brandBright : AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.input),
            border: Border.all(
              color: selected ? AppColors.brandBright : AppColors.navInactive,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? AppColors.onInk : AppColors.navInactive,
                size: 26,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected ? AppColors.onInk : AppColors.ink,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppText.caption.copyWith(
                        color: selected ? AppColors.onInk.withValues(alpha: 0.75) : null,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null)
                Text(
                  trailing!,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: selected ? AppColors.onInk : AppColors.ink,
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _PayBar extends StatelessWidget {
  const _PayBar({required this.enabled, required this.loading, required this.onPay});
  final bool enabled;
  final bool loading;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(color: AppColors.background),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: PrimaryButton(
          color: AppColors.ocean,
          label: context.l10n.payWithXendit,
          loading: loading,
          onPressed: enabled ? onPay : null,
        ),
      ),
    ),
  );
}

class _AlreadyPaid extends StatelessWidget {
  const _AlreadyPaid({required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context) => EmptyState(
    icon: Icons.check_circle_outline,
    text: context.l10n.orderIsPaid,
    action: PrimaryButton(
      label: context.l10n.trackOrder,
      expand: false,
      onPressed: () => context.pushReplacement('/orders/$orderId'),
    ),
  );
}

class _PaymentSuccess extends StatelessWidget {
  const _PaymentSuccess({required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.check_circle, size: 72),
            const SizedBox(height: 16),
            Semantics(
              liveRegion: true,
              child: Text(
                context.l10n.paymentReceived,
                textAlign: TextAlign.center,
                style: AppText.heading,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.paymentReceivedBody,
              textAlign: TextAlign.center,
              style: AppText.meta,
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              label: context.l10n.trackOrder,
              onPressed: () {
                Navigator.of(context).pop();
                context.pushReplacement('/orders/$orderId');
              },
            ),
          ],
        ),
      ),
    ),
  );
}
