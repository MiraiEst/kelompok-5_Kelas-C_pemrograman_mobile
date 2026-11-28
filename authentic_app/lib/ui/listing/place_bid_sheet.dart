import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/extensions.dart';
import '../../domain/bidding/increments.dart';
import '../../domain/bidding/proxy_engine.dart';
import '../../l10n/l10n.dart';
import '../../l10n/labels.dart';
import '../../domain/models/listing.dart';
import '../../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/app_text_field.dart';
import '../widgets/buttons.dart';
import '../widgets/common.dart';

/// Opens the "Place your maximum bid" sheet for [listingId].
Future<void> showPlaceBidSheet(BuildContext context, String listingId) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      barrierColor: const Color(0x42000000),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => PlaceBidSheet(listingId: listingId),
    );

/// One increment below [amount], never under [minimum].
int stepDown(int amount, int minimum) {
  // The increment that was added to reach [amount] comes from the tier below it.
  final down = amount - bidIncrement(amount - 1);
  return down < minimum ? minimum : down;
}

/// `min`, then `min` plus [steps] bid increments (310.000 → 320.000 → 335.000).
int addIncrements(int min, int steps) {
  var v = min;
  for (var i = 0; i < steps; i++) {
    v += bidIncrement(v);
  }
  return v;
}

class PlaceBidSheet extends ConsumerStatefulWidget {
  const PlaceBidSheet({super.key, required this.listingId});
  final String listingId;

  @override
  ConsumerState<PlaceBidSheet> createState() => _PlaceBidSheetState();
}

class _PlaceBidSheetState extends ConsumerState<PlaceBidSheet> {
  final _amount = TextEditingController();
  String? _serverError;
  String? _outbidMessage;

  @override
  void initState() {
    super.initState();
    _amount.addListener(() => setState(() => _serverError = null));
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  void _fill(int v) {
    final text = formatThousands(v);
    _amount.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  Future<void> _confirm(Listing l, int amount) async {
    setState(() {
      _serverError = null;
      _outbidMessage = null;
    });
    final decision = await ref
        .read(bidControllerProvider.notifier)
        .place(listingId: l.id, maxAmount: amount);
    if (!mounted) return;

    switch (decision) {
      case BidAccepted(:final kind) when kind.bidderLeads:
        HapticFeedback.lightImpact();
        final messenger = ScaffoldMessenger.of(context);
        Navigator.of(context).pop();
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(context.l10n.youreHighestBidder)));
      case BidAccepted(:final newPrice):
        // outbidByProxy / tieLostToEarlier: stay open, suggest a higher max.
        setState(() {
          _outbidMessage = context.l10n.outbidByMax(newPrice.toRupiah());
          _amount.clear();
        });
      case BidRejected(:final reason):
        setState(() => _serverError = reason.text(context));
      case null:
        final error = ref.read(bidControllerProvider).error;
        setState(
          () => _serverError = context.l10n.couldNotPlaceBid(friendlyError(error ?? 'unknown')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final listing = ref.watch(listingProvider(widget.listingId)).value;
    final uid = ref.watch(authStateProvider).value?.uid;
    final myMax = ref.watch(myMaxProvider(widget.listingId)).value;
    final busy = ref.watch(bidControllerProvider).isLoading;

    if (listing == null) {
      return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
    }
    final l = listing;
    final isLeader = l.leaderId != null && l.leaderId == uid;
    final ended = !l.isLive(DateTime.now());
    final currentMax = myMax ?? l.leaderMax ?? l.currentPrice;
    // Leader must go above their own max; others need the minimum next bid.
    final minimum = isLeader ? currentMax + 1 : l.minimumNextBid;
    final chipBase = isLeader ? addIncrements(currentMax, 1) : l.minimumNextBid;
    final amount = parseMoney(_amount.text);
    final tooLow = amount != null && amount < minimum;
    final valid = amount != null && !tooLow && !ended;

    // Base for the -/+ step buttons: what's typed, else the minimum.
    final base = amount ?? minimum;
    final step = bidIncrement(base);

    final helper = isLeader
        ? context.l10n.enterMoreThanMax(currentMax.toRupiah())
        : context.l10n.enterOrMore(minimum.toRupiah());
    final error = _serverError ?? (tooLow ? helper : null);

    return AnimatedPadding(
      duration: const Duration(milliseconds: 120),
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.inputBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                PhotoCard(url: l.thumbnail, size: 60),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      CountdownText(
                        endsAt: l.endsAt,
                        prefix:
                            '${context.l10n.currentPriceBids(l.currentPrice.toRupiah(), l.bidCount)} ',
                        suffix: ' ${context.l10n.timeLeftSuffix}',
                        style: AppText.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Semantics(
              header: true,
              child: Text(
                isLeader ? context.l10n.raiseYourMaxBid : context.l10n.placeYourMaxBid,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 12),
            Semantics(
              label: context.l10n.yourMaxBid,
              child: TextField(
                key: const Key('bidAmount'),
                controller: _amount,
                enabled: !ended,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, ThousandsFormatter()],
                style: AppText.bidInput.copyWith(fontSize: 24),
                decoration: InputDecoration(
                  prefixText: 'Rp  ',
                  prefixStyle: AppText.bidInput.copyWith(
                    fontSize: 24,
                    color: AppColors.navInactive,
                    fontWeight: FontWeight.w600,
                  ),
                  constraints: const BoxConstraints(minHeight: 60),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    borderSide: const BorderSide(color: AppColors.ocean, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    borderSide: const BorderSide(color: AppColors.ocean, width: 2.5),
                  ),
                  helperText: error == null ? helper : null,
                  errorText: error,
                ),
              ),
            ),
            if (_outbidMessage != null) ...[
              const SizedBox(height: 8),
              Semantics(
                liveRegion: true,
                child: Text(
                  _outbidMessage!,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ],
            const SizedBox(height: 16),
            // -increment / append "000" / +increment.
            Row(
              children: [
                _StepButton(
                  key: const Key('bidStepDown'),
                  label: '-${formatThousands(bidIncrement(base - 1))}',
                  onPressed: ended || amount == null || amount <= minimum
                      ? null
                      : () => _fill(stepDown(amount, minimum)),
                ),
                const SizedBox(width: 12),
                _StepButton(
                  key: const Key('bidTimes1000'),
                  label: '+000',
                  tooltip: context.l10n.addThreeZeros,
                  onPressed: ended || amount == null || amount > 999999999
                      ? null
                      : () => _fill(amount * 1000),
                ),
                const SizedBox(width: 12),
                _StepButton(
                  key: const Key('bidStepUp'),
                  label: '+${formatThousands(step)}',
                  onPressed: ended ? null : () => _fill(amount == null ? chipBase : amount + step),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.oceanLight,
                borderRadius: BorderRadius.circular(AppRadius.input),
              ),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${context.l10n.howItWorks} ',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(text: context.l10n.howItWorksBody),
                  ],
                ),
                style: AppText.small,
              ),
            ),
            const SizedBox(height: 12),
            Text.rich(
              textAlign: TextAlign.center,
              TextSpan(
                text: '${context.l10n.agreeToBuy} ',
                children: [
                  TextSpan(
                    text: context.l10n.bidsBinding,
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink),
                  ),
                ],
              ),
              style: AppText.caption,
            ),
            const SizedBox(height: 16),
            if (ended)
              Semantics(
                liveRegion: true,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    context.l10n.auctionHasEnded,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            PrimaryButton(
              color: AppColors.ocean,
              label: valid
                  ? context.l10n.confirmBidAmount(amount.toRupiah())
                  : context.l10n.confirmBid,
              loading: busy,
              onPressed: valid ? () => _confirm(l, amount) : null,
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.softButton,
                  foregroundColor: AppColors.ink,
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(context.l10n.cancel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Square-ish outlined quick-amount button ("-25.000", "+000", "+25.000").
class _StepButton extends StatelessWidget {
  const _StepButton({super.key, required this.label, required this.onPressed, this.tooltip});
  final String label;
  final String? tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        foregroundColor: AppColors.ink,
        side: const BorderSide(color: AppColors.oceanMid, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.input)),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
      child: FittedBox(child: Text(label)),
    );
    return Expanded(
      child: tooltip == null ? button : Tooltip(message: tooltip!, child: button),
    );
  }
}
