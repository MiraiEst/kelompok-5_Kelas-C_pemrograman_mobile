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
      appBar: brandAppBar(
        context,
        o == null
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
            PhotoCard(url: o.imageUrl, size: 72),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    o.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    o.status.isPaid
                        ? context.l10n.amountPaid(o.total.toRupiah())
                        : '${o.total.toRupiah()} · ${o.status.text(context)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
            color: AppColors.ocean,
            label: context.l10n.markInTransit,
            onPressed: () =>
                _run(context, () => repo.markInTransit(o.id), context.l10n.markedInTransit),
          ),
        if (isSeller && o.status == OrderStatus.inTransit)
          PrimaryButton(
            color: AppColors.ocean,
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
          const SizedBox(height: 16),
          PrimaryButton(
            color: AppColors.ocean,
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
              color: AppColors.ocean,
              label: context.l10n.reportProblem,
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                builder: (_) => _ReportSheet(order: o),
              ),
            ),
          const SizedBox(height: 12),
          Text(
            context.l10n.buyerProtectionNote,
            textAlign: TextAlign.center,
            style: AppText.meta.copyWith(color: AppColors.body),
          ),
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
        prefix: '${isSeller ? context.l10n.buyerHas : context.l10n.payWithin} ',
        suffix: isSeller ? ' ${context.l10n.toPaySuffix}' : '',
        format: (d) => d.toShort(),
        style: AppText.meta,
      ),
      if (!isSeller) ...[
        const SizedBox(height: 16),
        PrimaryButton(
          color: AppColors.ocean,
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
        detail: [when(o.paidAt), ?payment].where((s) => s.isNotEmpty).join(', '),
        copy: false,
      ),
      (
        title: context.l10n.statusShipped,
        detail: [when(o.shippedAt), ?o.courier].where((s) => s.isNotEmpty).join(', '),
        copy: o.trackingNumber != null,
      ),
      (
        title: context.l10n.statusInTransit,
        detail: [when(o.inTransitAt), ?o.lastUpdate].where((s) => s.isNotEmpty).join('\n'),
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
            tracking: steps[i].copy && i < current ? o.trackingNumber : null,
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
    this.tracking,
    this.onCopy,
  });

  final String title;
  final String detail;
  final _StepState state;
  final bool last;
  final bool nextDone;
  final String? tracking;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    const size = 32.0;
    final circle = switch (state) {
      _StepState.done => Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(color: AppColors.brandBright, shape: BoxShape.circle),
        child: const Icon(Icons.check, size: 20, color: AppColors.onInk),
      ),
      _StepState.current => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.background,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.brandBright, width: 2.5),
        ),
      ),
      _StepState.upcoming => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.cyanFaded, width: 2.5),
        ),
      ),
    };
    final upcoming = state == _StepState.upcoming;
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
                    // Solid between finished steps, dotted towards future ones.
                    child: state == _StepState.done
                        ? Container(
                            width: 5,
                            constraints: const BoxConstraints(minHeight: 28),
                            color: AppColors.brandBright,
                          )
                        : const SizedBox(
                            width: 5,
                            child: CustomPaint(painter: _DottedLine(AppColors.cyanFaded)),
                          ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: upcoming ? AppColors.body : AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (detail.isNotEmpty || tracking != null)
                      Text.rich(
                        TextSpan(
                          text: detail,
                          children: [
                            if (tracking != null)
                              WidgetSpan(
                                alignment: PlaceholderAlignment.baseline,
                                baseline: TextBaseline.alphabetic,
                                child: Semantics(
                                  button: true,
                                  label: context.l10n.copyTracking,
                                  child: GestureDetector(
                                    onTap: onCopy,
                                    child: Text(
                                      ' [$tracking]',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          color: upcoming ? AppColors.body : AppColors.ink,
                        ),
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

/// Vertical dotted connector between order steps.
class _DottedLine extends CustomPainter {
  const _DottedLine(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const dash = 8.0, gap = 6.0;
    for (var y = gap; y + dash <= size.height; y += dash + gap) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, dash), paint);
    }
  }

  @override
  bool shouldRepaint(_DottedLine old) => old.color != color;
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
              PrimaryButton(
                color: AppColors.ocean,
                label: context.l10n.markAsShipped,
                loading: _busy,
                onPressed: _ship,
              ),
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

  /// 1-5; 0 = not chosen yet.
  int _stars = 0;
  bool _busy = false;

  /// The backend keeps eBay-style feedback: 4-5 stars positive, 3 neutral, 1-2 negative.
  _Rating get _rating => switch (_stars) {
    >= 4 => _Rating.positive,
    3 => _Rating.neutral,
    _ => _Rating.negative,
  };

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
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.oceanLight, width: 2),
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
                Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (var i = 1; i <= 5; i++)
                      IconButton(
                        tooltip: context.l10n.nStars(i),
                        isSelected: i <= _stars,
                        iconSize: 40,
                        color: AppColors.ocean,
                        icon: const Icon(Icons.star_border_rounded),
                        selectedIcon: const Icon(Icons.star_rounded),
                        onPressed: () => setState(() => _stars = i),
                      ),
                  ],
                ),
                if (_stars > 0) Center(child: Text(_rating.text(context), style: AppText.caption)),
                const SizedBox(height: 12),
                Text(
                  context.l10n.comment,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _comment,
                  maxLines: 4,
                  minLines: 4,
                  maxLength: 300,
                  decoration: InputDecoration(
                    hintText: context.l10n.commentHint,
                    counterText: '',
                    border: _commentBorder(AppColors.oceanMid),
                    enabledBorder: _commentBorder(AppColors.oceanMid),
                    focusedBorder: _commentBorder(AppColors.ocean),
                  ),
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  color: AppColors.ocean,
                  label: context.l10n.sendRating,
                  loading: _busy,
                  onPressed: done == null || _stars == 0 ? null : _send,
                ),
              ],
            ),
    );
  }
}

OutlineInputBorder _commentBorder(Color c) => OutlineInputBorder(
  borderRadius: BorderRadius.circular(AppRadius.input),
  borderSide: BorderSide(color: c, width: 2),
);
