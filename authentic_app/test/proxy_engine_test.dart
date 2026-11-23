import 'package:flutter_test/flutter_test.dart';
import 'package:imagi_auction/domain/bidding/increments.dart';
import 'package:imagi_auction/domain/bidding/proxy_engine.dart';

final _now = DateTime(2026, 1, 1, 12);

AuctionState state({
  int start = 100000,
  int current = 100000,
  int bids = 0,
  String? leader,
  int? leaderMax,
  int? reserve,
  bool active = true,
  DateTime? endsAt,
}) => (
  sellerId: 'seller',
  isActive: active,
  endsAt: endsAt ?? _now.add(const Duration(days: 1)),
  startPrice: start,
  currentPrice: current,
  bidCount: bids,
  leaderId: leader,
  leaderMax: leaderMax,
  reservePrice: reserve,
);

BidAccepted accepted(BidDecision d) {
  expect(d, isA<BidAccepted>());
  return d as BidAccepted;
}

RejectReason rejected(BidDecision d) {
  expect(d, isA<BidRejected>());
  return (d as BidRejected).reason;
}

BidDecision bid(AuctionState s, String who, int max) =>
    ProxyBiddingEngine.evaluate(state: s, bidderId: who, maxAmount: max, now: _now);

void main() {
  group('increments', () {
    test('tiers', () {
      expect(bidIncrement(5000), 500);
      expect(bidIncrement(10000), 1000);
      expect(bidIncrement(99999), 2000);
      expect(bidIncrement(100000), 5000);
      expect(bidIncrement(20000000), 100000);
    });
  });

  group('validation', () {
    test('closed auction', () {
      expect(rejected(bid(state(active: false), 'a', 200000)), isA<AuctionClosed>());
      expect(rejected(bid(state(endsAt: _now), 'a', 200000)), isA<AuctionClosed>());
    });
    test('seller cannot bid', () {
      expect(rejected(bid(state(), 'seller', 200000)), isA<SellerCannotBid>());
    });
    test('below starting price', () {
      final r = rejected(bid(state(), 'a', 90000));
      expect(r, isA<BelowMinimum>());
      expect((r as BelowMinimum).minBid, 100000);
    });
  });

  group('proxy rules', () {
    test('first bid shows the starting price, not the max', () {
      final a = accepted(bid(state(), 'a', 300000));
      expect(a.kind, AcceptedKind.firstBid);
      expect(a.newPrice, 100000);
      expect(a.leaderMax, 300000);
    });

    test('higher max takes the lead at old max + increment', () {
      final s = state(current: 100000, bids: 1, leader: 'a', leaderMax: 300000);
      final a = accepted(bid(s, 'b', 500000));
      expect(a.kind, AcceptedKind.newLeader);
      expect(a.leaderId, 'b');
      expect(a.newPrice, 300000 + bidIncrement(300000)); // 305.000
      expect(a.previousLeaderId, 'a');
    });

    test('new leader price never exceeds their own max', () {
      final s = state(current: 100000, bids: 1, leader: 'a', leaderMax: 300000);
      final a = accepted(bid(s, 'b', 302000));
      expect(a.newPrice, 302000);
    });

    test('lower max is instantly outbid', () {
      final s = state(current: 100000, bids: 1, leader: 'a', leaderMax: 300000);
      final a = accepted(bid(s, 'b', 200000));
      expect(a.kind, AcceptedKind.outbidByProxy);
      expect(a.leaderId, 'a');
      expect(a.newPrice, 200000 + bidIncrement(200000)); // 205.000
    });

    test('lower max close to leader max caps at leader max', () {
      final s = state(current: 100000, bids: 1, leader: 'a', leaderMax: 300000);
      final a = accepted(bid(s, 'b', 299000));
      expect(a.newPrice, 300000);
    });

    test('tie: earlier bid wins at that max', () {
      final s = state(current: 100000, bids: 1, leader: 'a', leaderMax: 300000);
      final a = accepted(bid(s, 'b', 300000));
      expect(a.kind, AcceptedKind.tieLostToEarlier);
      expect(a.leaderId, 'a');
      expect(a.newPrice, 300000);
    });

    test('leader raising own max does not change the price', () {
      final s = state(current: 150000, bids: 2, leader: 'a', leaderMax: 300000);
      final a = accepted(bid(s, 'a', 400000));
      expect(a.kind, AcceptedKind.raisedOwnMax);
      expect(a.newPrice, 150000);
      expect(a.leaderMax, 400000);
    });

    test('leader cannot lower max', () {
      final s = state(current: 150000, bids: 2, leader: 'a', leaderMax: 300000);
      expect(rejected(bid(s, 'a', 250000)), isA<CannotLowerMax>());
    });

    test('minimum next bid is current + increment', () {
      final s = state(current: 150000, bids: 2, leader: 'a', leaderMax: 300000);
      final r = rejected(bid(s, 'b', 150000));
      expect((r as BelowMinimum).minBid, 155000);
    });
  });

  group('reserve price', () {
    test('max >= reserve jumps price to the reserve', () {
      final a = accepted(bid(state(reserve: 250000), 'a', 300000));
      expect(a.newPrice, 250000);
      expect(a.reserveMet, isTrue);
    });

    test('max below reserve keeps price, reserve not met', () {
      final a = accepted(bid(state(reserve: 250000), 'a', 200000));
      expect(a.newPrice, 100000);
      expect(a.reserveMet, isFalse);
    });

    test('leader raising max while reserve not met raises price to min(max, reserve)', () {
      final s = state(current: 100000, bids: 1, leader: 'a', leaderMax: 200000, reserve: 250000);
      final a = accepted(bid(s, 'a', 400000));
      expect(a.newPrice, 250000);
      expect(a.reserveMet, isTrue);
    });
  });
}
