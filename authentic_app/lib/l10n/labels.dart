import 'package:flutter/widgets.dart';

import '../core/config.dart';
import '../core/extensions.dart';
import '../data/services/courier_rate_service.dart';
import '../domain/bidding/proxy_engine.dart';
import '../domain/models/app_user.dart';
import '../domain/models/item_category.dart';
import '../domain/models/listing.dart';
import '../domain/models/order.dart';
import '../ui/sell/sell_validation.dart';
import 'l10n.dart';

// Translated names for the domain enums (the enums themselves stay
// language-free; their `label`s are only the English fallback).

extension OrderStatusL10n on OrderStatus {
  String text(BuildContext context) {
    final l = context.l10n;
    return switch (this) {
      OrderStatus.awaitingPayment => l.statusAwaitingPayment,
      OrderStatus.paid => l.statusPaid,
      OrderStatus.shipped => l.statusShipped,
      OrderStatus.inTransit => l.statusInTransit,
      OrderStatus.delivered => l.statusDelivered,
      OrderStatus.completed => l.statusCompleted,
      OrderStatus.cancelled => l.statusCancelled,
    };
  }
}

extension ListingStatusL10n on ListingStatus {
  String text(BuildContext context) {
    final l = context.l10n;
    return switch (this) {
      ListingStatus.active => l.listingActive,
      ListingStatus.sold => l.listingSold,
      ListingStatus.unsold => l.listingUnsold,
      ListingStatus.ended => l.listingEnded,
    };
  }
}

extension ItemCategoryL10n on ItemCategory {
  String text(BuildContext context) {
    final l = context.l10n;
    return switch (this) {
      ItemCategory.electronics => l.catElectronics,
      ItemCategory.fashion => l.catFashion,
      ItemCategory.antique => l.catAntique,
      ItemCategory.hobbiesToys => l.catHobbiesToys,
      ItemCategory.home => l.catHome,
      ItemCategory.automotive => l.catAutomotive,
      ItemCategory.other => l.catOther,
    };
  }
}

extension ItemConditionL10n on ItemCondition {
  String text(BuildContext context) {
    final l = context.l10n;
    return switch (this) {
      ItemCondition.brandNew => l.conditionNew,
      ItemCondition.used => l.conditionUsed,
      ItemCondition.forParts => l.conditionForParts,
    };
  }
}

extension ListingFormatL10n on ListingFormat {
  String text(BuildContext context) {
    final l = context.l10n;
    return switch (this) {
      ListingFormat.auction => l.formatAuction,
      ListingFormat.buyNow => l.formatBuyNow,
      ListingFormat.both => l.formatBoth,
    };
  }
}

extension AuctionDurationL10n on AuctionDuration {
  String text(BuildContext context) => this == AuctionDuration.fiveMinutesTest
      ? context.l10n.durationTest
      : context.l10n.durationDays(duration.inDays);
}

extension NotificationPrefL10n on NotificationPref {
  String text(BuildContext context) {
    final l = context.l10n;
    return switch (this) {
      NotificationPref.outbid => l.prefOutbid,
      NotificationPref.endingSoon => l.prefEndingSoon,
      NotificationPref.wonLost => l.prefWonLost,
      NotificationPref.newBid => l.prefNewBid,
      NotificationPref.reserveMet => l.prefReserveMet,
      NotificationPref.orders => l.prefOrders,
      NotificationPref.secondChance => l.prefSecondChance,
    };
  }
}

extension PaymentMethodL10n on PaymentMethod {
  String text(BuildContext context) => switch (this) {
    PaymentMethod.virtualAccount => context.l10n.payVirtualAccount,
    PaymentMethod.qris => context.l10n.payQris,
    PaymentMethod.eWallet => context.l10n.payEWallet,
  };

  /// Bank / wallet names stay as they are; only the QRIS hint is translated.
  String detailText(BuildContext context) =>
      this == PaymentMethod.qris ? context.l10n.payQrisDetail : detail;
}

extension RejectReasonL10n on RejectReason {
  String text(BuildContext context) {
    final l = context.l10n;
    return switch (this) {
      AuctionClosed() => l.rejectClosed,
      SellerCannotBid() => l.rejectSeller,
      InvalidAmount() => l.rejectInvalid,
      BelowMinimum(:final minBid) => l.rejectBelowMin(minBid.toRupiah()),
      CannotLowerMax(:final currentMax) => l.rejectCannotLower(currentMax.toRupiah()),
    };
  }
}

extension SellErrorL10n on SellError {
  String text(BuildContext context) {
    final l = context.l10n;
    return switch (this) {
      SellError.noPhotos => l.errNoPhotos,
      SellError.tooManyPhotos => l.errTooManyPhotos(AppConfig.maxPhotos),
      SellError.titleTooShort => l.atLeast3,
      SellError.noCategory => l.errPickCategory,
      SellError.priceTooLow => l.errPriceTooLow,
      SellError.notAboveStart => l.errNotAboveStart,
      SellError.noBuyNowPrice => l.errNoBuyNow,
      SellError.belowReserve => l.errBelowReserve,
    };
  }
}
