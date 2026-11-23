import 'dart:math' as math;

import '../../core/extensions.dart';
import 'increments.dart';

/// Everything the proxy engine needs to know about an auction.
/// Advanced Dart: a named record used as a lightweight value type.
typedef AuctionState = ({
  String sellerId,
  bool isActive,
  DateTime endsAt,
  int startPrice,
  int currentPrice,
  int bidCount,
  String? leaderId,
  int? leaderMax,
  int? reservePrice,
});

// ---------------------------------------------------------------------------
// Decisions (sealed class hierarchy -> exhaustive switch in the UI/data layer)
// ---------------------------------------------------------------------------

sealed class BidDecision {
  const BidDecision();
}

/// How an accepted bid changed the auction.
enum AcceptedKind {
  firstBid('You are the first bidder and the highest bidder.'),
  newLeader("You're the highest bidder."),
  outbidByProxy("You've been outbid by another bidder's maximum."),
  tieLostToEarlier("Same maximum as the leader. The earlier bid wins, so you've been outbid."),
  raisedOwnMax('Your maximum bid was raised. You are still the highest bidder.');

  const AcceptedKind(this.message);
  final String message;

  bool get bidderLeads => switch (this) {
    firstBid || newLeader || raisedOwnMax => true,
    outbidByProxy || tieLostToEarlier => false,
  };
}

final class BidAccepted extends BidDecision {
  const BidAccepted({
    required this.kind,
    required this.newPrice,
    required this.leaderId,
    required this.leaderMax,
    required this.reserveMet,
    this.previousLeaderId,
  });

  final AcceptedKind kind;

  /// The new visible current price.
  final int newPrice;

  /// Leader after this bid (may still be the old leader).
  final String leaderId;

  /// Leader's hidden maximum after this bid.
  final int leaderMax;

  final bool reserveMet;

  /// Set when the leader changed: the user who just lost the lead
  /// (should receive an "outbid" notification).
  final String? previousLeaderId;
}

final class BidRejected extends BidDecision {
  const BidRejected(this.reason);
  final RejectReason reason;
}

sealed class RejectReason {
  const RejectReason();
  String get message;
}

final class AuctionClosed extends RejectReason {
  const AuctionClosed();
  @override
  String get message => 'This auction has ended.';
}

final class SellerCannotBid extends RejectReason {
  const SellerCannotBid();
  @override
  String get message => 'Sellers cannot bid on their own listings.';
}

final class InvalidAmount extends RejectReason {
  const InvalidAmount();
  @override
  String get message => 'Enter a valid amount.';
}

final class BelowMinimum extends RejectReason {
  const BelowMinimum(this.minBid);
  final int minBid;
  @override
  String get message => 'Your maximum must be at least ${minBid.toRupiah()}.';
}

final class CannotLowerMax extends RejectReason {
  const CannotLowerMax(this.currentMax);
  final int currentMax;
  @override
  String get message =>
      'You are already leading with a maximum of ${currentMax.toRupiah()}. '
      'You can only raise it.';
}

// ---------------------------------------------------------------------------
// Engine
// ---------------------------------------------------------------------------

/// Pure, deterministic proxy (automatic) bidding engine.
///
/// It has no Firebase dependency, so it is fully unit-testable and is run
/// inside a Firestore transaction by the repository.
abstract final class ProxyBiddingEngine {
  /// Minimum maximum-bid a new bidder must enter.
  static int minimumBid(AuctionState s) => (s.bidCount == 0 || s.leaderId == null)
      ? s.startPrice
      : s.currentPrice + bidIncrement(s.currentPrice);

  static BidDecision evaluate({
    required AuctionState state,
    required String bidderId,
    required int maxAmount,
    required DateTime now,
  }) {
    if (!state.isActive || !now.isBefore(state.endsAt)) {
      return const BidRejected(AuctionClosed());
    }
    if (bidderId == state.sellerId) {
      return const BidRejected(SellerCannotBid());
    }
    if (maxAmount <= 0) return const BidRejected(InvalidAmount());

    final reserve = state.reservePrice;

    // When any max >= reserve, the price jumps to at least the reserve.
    int withReserve(int price, int leaderMax) =>
        (reserve != null && leaderMax >= reserve && price < reserve) ? reserve : price;
    bool reserveMet(int price) => reserve == null || price >= reserve;

    final leaderId = state.leaderId;
    final leaderMax = state.leaderMax;

    // 1) The current leader raises their own max: no bidding against yourself.
    if (leaderId != null && leaderId == bidderId) {
      final currentMax = leaderMax ?? state.currentPrice;
      if (maxAmount <= currentMax) {
        return BidRejected(CannotLowerMax(currentMax));
      }
      var price = state.currentPrice;
      // Exception: reserve not met yet -> price rises to min(new max, reserve).
      if (reserve != null && price < reserve) {
        price = math.max(price, math.min(maxAmount, reserve));
      }
      return BidAccepted(
        kind: AcceptedKind.raisedOwnMax,
        newPrice: price,
        leaderId: bidderId,
        leaderMax: maxAmount,
        reserveMet: reserveMet(price),
      );
    }

    final minBid = minimumBid(state);
    if (maxAmount < minBid) return BidRejected(BelowMinimum(minBid));

    // 2) First bid.
    if (leaderId == null || leaderMax == null) {
      final price = withReserve(state.startPrice, maxAmount);
      return BidAccepted(
        kind: AcceptedKind.firstBid,
        newPrice: price,
        leaderId: bidderId,
        leaderMax: maxAmount,
        reserveMet: reserveMet(price),
      );
    }

    // 3) Compare against the leader's hidden max (relational patterns).
    switch (maxAmount.compareTo(leaderMax)) {
      case > 0:
        // New max is higher -> new leader.
        final price = withReserve(
          math.min(maxAmount, leaderMax + bidIncrement(leaderMax)),
          maxAmount,
        );
        return BidAccepted(
          kind: AcceptedKind.newLeader,
          newPrice: price,
          leaderId: bidderId,
          leaderMax: maxAmount,
          reserveMet: reserveMet(price),
          previousLeaderId: leaderId,
        );
      case < 0:
        // New max is lower -> leader stays, bidder is instantly outbid.
        final price = withReserve(
          math.min(leaderMax, maxAmount + bidIncrement(maxAmount)),
          leaderMax,
        );
        return BidAccepted(
          kind: AcceptedKind.outbidByProxy,
          newPrice: price,
          leaderId: leaderId,
          leaderMax: leaderMax,
          reserveMet: reserveMet(price),
        );
      default:
        // Tie -> the earlier bid (existing leader) wins; price = that max.
        final price = withReserve(leaderMax, leaderMax);
        return BidAccepted(
          kind: AcceptedKind.tieLostToEarlier,
          newPrice: price,
          leaderId: leaderId,
          leaderMax: leaderMax,
          reserveMet: reserveMet(price),
        );
    }
  }
}
