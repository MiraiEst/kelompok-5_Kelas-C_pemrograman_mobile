import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../core/config.dart';
import '../../core/extensions.dart';
import '../../data/services/courier_rate_service.dart';
import '../../domain/models/order.dart';
import '../../l10n/l10n.dart';
import '../../l10n/labels.dart';
import '../../providers/providers.dart';
import '../account/address_screens.dart';
import '../theme/app_theme.dart';
import '../widgets/app_text_field.dart';
import '../widgets/buttons.dart';
import '../widgets/common.dart';
import '../widgets/section_header.dart';
import '../widgets/segmented_tabs.dart';

DateFormat get _dateTime => DateFormat('d MMM, HH:mm');

final feedbackExistsProvider = StreamProvider.autoDispose
    .family<bool, ({String orderId, bool asBuyer})>(
      (ref, k) =>
          ref.watch(orderRepositoryProvider).watchFeedbackExists(k.orderId, asBuyer: k.asBuyer),
    );

class OrderScreen extends ConsumerWidget {
  const OrderScreen({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(orderProvider(orderId));
    final uid = ref.watch(authStateProvider).value?.uid;
    final o = order.value;
    final isSeller = o != null && o.sellerId == uid;

    return Scaffold(
      appBar: AppBar(
        title: o == null
            ? Text(context.l10n.order)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.l10n.orderNumber(o.shortNumber)),
                  Text(
                    isSeller
                        ? context.l10n.soldTo((o.buyerName ?? context.l10n.buyerFallback).masked())
                        : context.l10n.boughtFrom(
                            (o.sellerName ?? context.l10n.sellerFallback).masked(),
                          ),
                    style: AppText.caption,
                  ),
                ],
              ),
      ),
      body: switch (order) {
        AsyncValue(:final value?) => _OrderBody(order: value, isSeller: isSeller),
        AsyncData() => EmptyState(
          icon: Icons.receipt_long_outlined,
          text: context.l10n.orderNotFound,
        ),
        AsyncValue(:final error?) => ErrorText(
          error,
          onRetry: () => ref.invalidate(orderProvider(orderId)),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _OrderBody extends ConsumerWidget {
  const _OrderBody({required this.order, required this.isSeller});
  final AuctionOrder order;
  final bool isSeller;

  Future<void> _run(BuildContext context, Future<void> Function() action, String done) async {
    try {
      await action();
      if (context.mounted) showSnack(context, done);
    } catch (e) {
      if (context.mounted) showSnack(context, friendlyError(e));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final o = order;
    final repo = ref.read(orderRepositoryProvider);
    final canConfirm =
        !isSeller &&
        (o.status == OrderStatus.shipped ||
            o.status == OrderStatus.inTransit ||
            o.status == OrderStatus.delivered);
    final canRate =
        o.status == OrderStatus.completed &&
        DateTime.now().difference(o.completedAt ?? DateTime.now()).inDays <=
            AppConfig.ratingWindowDays;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            ListingImage(
              url: o.imageUrl,
              size: 64,
              borderRadius: BorderRadius.circular(AppRadius.photoSmall),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(o.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppText.small),
                  const SizedBox(height: 2),
                  Text(
                    o.status.isPaid
                        ? context.l10n.amountPaid(o.total.toRupiah())
                        : '${o.total.toRupiah()} · ${o.status.text(context)}',
                    style: AppText.price,
                  ),
                ],
              ),
            ),
          ],
        ),
        if (o.hasOpenCase) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.ink, width: 2),
              borderRadius: BorderRadius.circular(AppRadius.input),
            ),
            child: Text(
              context.l10n.problemReportedBanner,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
        const SizedBox(height: 24),
        if (o.status == OrderStatus.awaitingPayment)
          _AwaitingPayment(order: o, isSeller: isSeller)
        else if (o.status == OrderStatus.cancelled)
          Text(context.l10n.orderCancelled, style: AppText.sectionTitle)
        else
          OrderStepper(order: o),
        const SizedBox(height: 16),

        // --- Seller actions -----------------------------------------------------
        if (isSeller && o.status == OrderStatus.paid) _ShipForm(order: o),
        if (isSeller && o.status == OrderStatus.shipped)
          PrimaryButton(
            label: context.l10n.markInTransit,
            onPressed: () =>
                _run(context, () => repo.markInTransit(o.id), context.l10n.markedInTransit),
          ),
        if (isSeller && o.status == OrderStatus.inTransit)
          PrimaryButton(
            label: context.l10n.markDelivered,
            onPressed: () =>
                _run(context, () => repo.markDelivered(o.id), context.l10n.markedDelivered),
          ),
        if (isSeller && o.address != null) ...[
          const SizedBox(height: 16),
          SectionHeader(context.l10n.shipTo),
          const SizedBox(height: 8),
          AddressCard(address: o.address!),
        ],

        // --- Buyer actions ------------------------------------------------------
        if (!isSeller && o.status.isPaid && o.status != OrderStatus.completed) ...[
          PrimaryButton(
            label: context.l10n.iReceivedItem,
            onPressed: canConfirm
                ? () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(context.l10n.confirmReceivedQ),
                        content: Text(context.l10n.confirmReceivedBody),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(context.l10n.notYet),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(context.l10n.confirm),
                          ),
                        ],
                      ),
                    );
                    if (ok == true && context.mounted) {
                      await _run(
                        context,
                        () => repo.confirmReceived(o.id),
                        context.l10n.orderCompleted,
                      );
                    }
                  }
                : null,
          ),
          const SizedBox(height: 10),
          if (!o.hasOpenCase)
            SecondaryButton(
              label: context.l10n.reportProblem,
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                builder: (_) => _ReportSheet(order: o),
              ),
            ),
          const SizedBox(height: 8),
          Text(context.l10n.buyerProtectionNote, style: AppText.caption),
        ],
        if (canRate) ...[const SizedBox(height: 24), _RateCard(order: o, asBuyer: !isSeller)],
      ],
    );
  }
}

class _AwaitingPayment extends StatelessWidget {
  const _AwaitingPayment({required this.order, required this.isSeller});
  final AuctionOrder order;
  final bool isSeller;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(context.l10n.waitingForPayment, style: AppText.sectionTitle),
      const SizedBox(height: 4),
      CountdownText(
        endsAt: order.payBy,
        prefix: isSeller ? context.l10n.buyerHas : context.l10n.payWithin,
        suffix: isSeller ? context.l10n.toPaySuffix : '',
        format: (d) => d.toShort(),
        style: AppText.meta,
      ),
      if (!isSeller) ...[
        const SizedBox(height: 16),
        PrimaryButton(
          label: context.l10n.payNow,
          onPressed: () => context.push('/checkout/${order.id}'),
        ),
      ],
    ],
  );
}

/// Vertical 4-step tracker: Paid, Shipped, In transit, Delivered.
class OrderStepper extends StatelessWidget {
  const OrderStepper({super.key, required this.order});
  final AuctionOrder order;

  @override
  Widget build(BuildContext context) {
    final o = order;
    String when(DateTime? t) => t == null ? '' : _dateTime.format(t);
    final payment = PaymentMethod.parse(o.paymentMethod)?.text(context);
    final steps = [
      (
        title: context.l10n.statusPaid,
        detail: [when(o.paidAt), ?payment].where((s) => s.isNotEmpty).join(' · '),
        copy: false,
      ),
      (
        title: context.l10n.statusShipped,
        detail: [
          when(o.shippedAt),
          if (o.courier != null && o.trackingNumber != null) '${o.courier} · ${o.trackingNumber}',
        ].where((s) => s.isNotEmpty).join('\n'),
        copy: o.trackingNumber != null,
      ),
      (
        title: context.l10n.statusInTransit,
        detail: [when(o.inTransitAt), ?o.lastUpdate].where((s) => s.isNotEmpty).join(' · '),
        copy: false,
      ),
      (
        title: context.l10n.statusDelivered,
        detail: [
          when(o.deliveredAt),
          context.l10n.autoConfirmed(AppConfig.autoConfirmDays),
        ].where((s) => s.isNotEmpty).join('\n'),
        copy: false,
      ),
    ];
    // Index of the step in progress; everything before it is done.
    final current = switch (o.status) {
      OrderStatus.paid => 1,
      OrderStatus.shipped => 2,
      OrderStatus.inTransit => 3,
      OrderStatus.delivered || OrderStatus.completed => 4,
      _ => 0,
    };

    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          _Step(
            title: steps[i].title,
            detail: i < current || (i == 3 && current == 4) ? steps[i].detail : '',
            state: i < current
                ? _StepState.done
                : (i == current ? _StepState.current : _StepState.upcoming),
            last: i == steps.length - 1,
            nextDone: i + 1 < current,
            onCopy: steps[i].copy
                ? () async {
                    await Clipboard.setData(ClipboardData(text: o.trackingNumber!));
                    if (context.mounted) showSnack(context, context.l10n.trackingCopied);
                  }
                : null,
          ),
      ],
    );
  }
}

enum _StepState { done, current, upcoming }

class _Step extends StatelessWidget {
  const _Step({
    required this.title,
    required this.detail,
    required this.state,
    required this.last,
    required this.nextDone,
    this.onCopy,
  });

  final String title;
  final String detail;
  final _StepState state;
  final bool last;
  final bool nextDone;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final circle = switch (state) {
      _StepState.done => Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(color: AppColors.ink, shape: BoxShape.circle),
        child: const Icon(Icons.check, size: 16, color: AppColors.onInk),
      ),
      _StepState.current => Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AppColors.background,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.ink, width: 3),
        ),
      ),
      _StepState.upcoming => Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.inputBorder, width: 2),
        ),
      ),
    };
    return Semantics(
      label:
          '$title, ${switch (state) {
            _StepState.done => context.l10n.stepDone,
            _StepState.current => context.l10n.stepCurrent,
            _StepState.upcoming => context.l10n.stepUpcoming,
          }}${detail.isEmpty ? '' : '. $detail'}',
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                circle,
                if (!last)
                  Expanded(
                    child: Container(
                      width: 2,
                      constraints: const BoxConstraints(minHeight: 24),
                      color: state == _StepState.done && (nextDone || state == _StepState.done)
                          ? AppColors.ink
                          : AppColors.line,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: state == _StepState.upcoming ? AppColors.muted : AppColors.ink,
                      ),
                    ),
                    if (detail.isNotEmpty) Text(detail, style: AppText.caption),
                    if (onCopy != null)
                      TextButton(
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        onPressed: onCopy,
                        child: Text(context.l10n.copyTracking),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Seller: courier + tracking number -> "Mark as shipped".
class _ShipForm extends ConsumerStatefulWidget {
  const _ShipForm({required this.order});
  final AuctionOrder order;

  @override
  ConsumerState<_ShipForm> createState() => _ShipFormState();
}

class _ShipFormState extends ConsumerState<_ShipForm> {
  final _form = GlobalKey<FormState>();
  final _tracking = TextEditingController();
  late String _courier = widget.order.courier ?? 'JNE REG';
  bool _busy = false;

  @override
  void dispose() {
    _tracking.dispose();
    super.dispose();
  }

  Future<void> _ship() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(orderRepositoryProvider)
          .markShipped(widget.order.id, courier: _courier, trackingNumber: _tracking.text.trim());
      if (mounted) showSnack(context, context.l10n.markedShipped);
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rates = ref.watch(courierRateServiceProvider);
    return FutureBuilder(
      future: rates.ratesFor(listingShippingCost: widget.order.shippingCost),
      builder: (context, snap) {
        final names = [for (final r in snap.data ?? const <CourierRate>[]) r.name];
        if (!names.contains(_courier)) names.insert(0, _courier);
        return Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeader(context.l10n.shipThisOrder),
              if (widget.order.handlingDays != null)
                Text(
                  context.l10n.shipWithinDays(widget.order.handlingDays!),
                  style: AppText.caption,
                ),
              const SizedBox(height: 12),
              Text(context.l10n.courier, style: AppText.fieldLabel),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _courier,
                items: [for (final n in names) DropdownMenuItem(value: n, child: Text(n))],
                onChanged: (v) => setState(() => _courier = v ?? _courier),
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: context.l10n.trackingNumber,
                controller: _tracking,
                validator: (v) =>
                    (v == null || v.trim().length < 6) ? context.l10n.enterTracking : null,
              ),
              const SizedBox(height: 16),
              PrimaryButton(label: context.l10n.markAsShipped, loading: _busy, onPressed: _ship),
            ],
          ),
        );
      },
    );
  }
}

enum _Reason {
  notReceived('Not received'),
  notAsDescribed('Not as described'),
  damaged('Damaged'),
  other('Other');

  const _Reason(this.label);

  /// English, stored on the case document.
  final String label;

  String text(BuildContext context) => switch (this) {
    notReceived => context.l10n.reasonNotReceived,
    notAsDescribed => context.l10n.reasonNotAsDescribed,
    damaged => context.l10n.reasonDamaged,
    other => context.l10n.reasonOther,
  };
}

class _ReportSheet extends ConsumerStatefulWidget {
  const _ReportSheet({required this.order});
  final AuctionOrder order;

  @override
  ConsumerState<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends ConsumerState<_ReportSheet> {
  final _description = TextEditingController();
  _Reason _reason = _Reason.notReceived;
  Uint8List? _photo;
  bool _busy = false;

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final f = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 80,
    );
    if (f == null) return;
    final bytes = await f.readAsBytes();
    if (mounted) setState(() => _photo = bytes);
  }

  Future<void> _submit() async {
    final uid = ref.read(authStateProvider).value?.uid;
    if (uid == null) return;
    if (_description.text.trim().length < 10) {
      showSnack(context, context.l10n.describeProblem);
      return;
    }
    setState(() => _busy = true);
    final repo = ref.read(orderRepositoryProvider);
    try {
      final caseId = repo.newCaseId();
      final photos = <String>[
        if (_photo != null)
          await ref
              .read(storageRepositoryProvider)
              .uploadCasePhoto(uid: uid, caseId: caseId, index: 0, bytes: _photo!),
      ];
      await repo.reportProblem(
        caseId: caseId,
        order: widget.order,
        buyerUid: uid,
        reason: _reason.label,
        description: _description.text.trim(),
        photoUrls: photos,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      showSnack(context, context.l10n.problemReported);
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.l10n.reportProblem, style: AppText.title),
          const SizedBox(height: 12),
          RadioGroup<_Reason>(
            groupValue: _reason,
            onChanged: (v) => setState(() => _reason = v ?? _reason),
            child: Column(
              children: [
                for (final r in _Reason.values)
                  RadioListTile<_Reason>(
                    contentPadding: EdgeInsets.zero,
                    value: r,
                    title: Text(r.text(context)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          AppTextField(
            label: context.l10n.whatHappened,
            controller: _description,
            maxLines: 4,
            minLines: 3,
            hint: context.l10n.whatHappenedHint,
          ),
          const SizedBox(height: 12),
          if (_photo != null)
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.photoSmall),
                  child: Image.memory(_photo!, width: 64, height: 64, fit: BoxFit.cover),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => setState(() => _photo = null),
                  child: Text(context.l10n.removePhoto),
                ),
              ],
            )
          else
            SecondaryButton(
              label: context.l10n.addPhotoOptional,
              icon: Icons.photo_outlined,
              onPressed: _pickPhoto,
            ),
          const SizedBox(height: 16),
          PrimaryButton(label: context.l10n.submitReport, loading: _busy, onPressed: _submit),
        ],
      ),
    ),
  );
}

enum _Rating {
  positive('positive', 'Positive'),
  neutral('neutral', 'Neutral'),
  negative('negative', 'Negative');

  const _Rating(this.value, this.label);
  final String value;
  final String label;

  String text(BuildContext context) => switch (this) {
    positive => context.l10n.ratingPositive,
    neutral => context.l10n.ratingNeutral,
    negative => context.l10n.ratingNegative,
  };
}

class _RateCard extends ConsumerStatefulWidget {
  const _RateCard({required this.order, required this.asBuyer});
  final AuctionOrder order;
  final bool asBuyer;

  @override
  ConsumerState<_RateCard> createState() => _RateCardState();
}

class _RateCardState extends ConsumerState<_RateCard> {
  final _comment = TextEditingController();
  _Rating _rating = _Rating.positive;
  bool _busy = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final uid = ref.read(authStateProvider).value?.uid;
    if (uid == null) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(orderRepositoryProvider)
          .leaveFeedback(
            order: widget.order,
            fromUid: uid,
            asBuyer: widget.asBuyer,
            rating: _rating.value,
            comment: _comment.text.trim(),
          );
      if (mounted) showSnack(context, context.l10n.thanksFeedback);
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final done = ref
        .watch(feedbackExistsProvider((orderId: widget.order.id, asBuyer: widget.asBuyer)))
        .value;
    final title = widget.asBuyer ? context.l10n.rateSeller : context.l10n.rateBuyer;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: done == true
          ? Text(
              widget.asBuyer ? context.l10n.ratedSeller : context.l10n.ratedBuyer,
              style: AppText.meta,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionHeader(title),
                const SizedBox(height: 8),
                SegmentedTabs<_Rating>(
                  values: _Rating.values,
                  selected: _rating,
                  label: (r) => r.text(context),
                  onChanged: (r) => setState(() => _rating = r),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: context.l10n.comment,
                  controller: _comment,
                  maxLines: 3,
                  minLines: 2,
                  maxLength: 300,
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: context.l10n.sendRating,
                  loading: _busy,
                  onPressed: done == null ? null : _send,
                ),
              ],
            ),
    );
  }
}
