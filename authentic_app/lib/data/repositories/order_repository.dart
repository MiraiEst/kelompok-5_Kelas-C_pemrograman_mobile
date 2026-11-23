import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../domain/models/order.dart';

/// Orders are created by the `onListingSold` Cloud Function. Clients may only
/// fill in checkout choices and move the status along the allowed path
/// (enforced by firestore.rules). Payment status is set by the Xendit webhook.
class OrderRepository {
  OrderRepository(this._db, this._functions);
  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;

  CollectionReference<Map<String, dynamic>> get _orders => _db.collection('orders');

  Stream<AuctionOrder?> watchOrder(String id) =>
      _orders.doc(id).snapshots().map((s) => s.exists ? AuctionOrder.fromDoc(s) : null);

  Stream<List<AuctionOrder>> watchPurchases(String uid) => _orders
      .where('buyerId', isEqualTo: uid)
      .snapshots()
      .map(
        (q) =>
            q.docs.map(AuctionOrder.fromDoc).toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
      );

  Stream<List<AuctionOrder>> watchSales(String uid) => _orders
      .where('sellerId', isEqualTo: uid)
      .snapshots()
      .map(
        (q) =>
            q.docs.map(AuctionOrder.fromDoc).toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
      );

  // --- Checkout -----------------------------------------------------------------

  Future<void> saveCheckoutChoices(
    String orderId, {
    required Address address,
    required String courier,
    required String paymentMethod,
  }) => _orders.doc(orderId).update({
    'address': address.toMap(),
    'courier': courier,
    'paymentMethod': paymentMethod,
  });

  /// Asks the server to create (or reuse) a Xendit invoice. Returns its URL.
  Future<String> createInvoice(String orderId) async {
    final res = await _functions.httpsCallable('createInvoice').call<Map<String, dynamic>>({
      'orderId': orderId,
    });
    final url = res.data['invoiceUrl'] as String?;
    if (url == null || url.isEmpty) throw Exception('No invoice URL returned.');
    return url;
  }

  // --- Shipping (seller) and receipt (buyer) -------------------------------------

  Future<void> markShipped(
    String orderId, {
    required String courier,
    required String trackingNumber,
  }) => _orders.doc(orderId).update({
    'status': OrderStatus.shipped.value,
    'courier': courier,
    'trackingNumber': trackingNumber,
    'shippedAt': FieldValue.serverTimestamp(),
    'lastUpdate': 'Handed to $courier',
  });

  Future<void> markInTransit(String orderId) => _orders.doc(orderId).update({
    'status': OrderStatus.inTransit.value,
    'inTransitAt': FieldValue.serverTimestamp(),
    'lastUpdate': 'On the way',
  });

  Future<void> markDelivered(String orderId) => _orders.doc(orderId).update({
    'status': OrderStatus.delivered.value,
    'deliveredAt': FieldValue.serverTimestamp(),
    'lastUpdate': 'Delivered',
  });

  /// Buyer confirms receipt: completes the order; payout becomes pending.
  Future<void> confirmReceived(String orderId) => _orders.doc(orderId).update({
    'status': OrderStatus.completed.value,
    'completedAt': FieldValue.serverTimestamp(),
    'payoutStatus': 'pending',
  });

  /// Opens a buyer-protection case and puts the seller's payment on hold.
  Future<void> reportProblem({
    required String caseId,
    required AuctionOrder order,
    required String buyerUid,
    required String reason,
    required String description,
    required List<String> photoUrls,
  }) {
    final batch = _db.batch();
    batch.set(_db.collection('cases').doc(caseId), {
      'orderId': order.id,
      'buyerId': buyerUid,
      'sellerId': order.sellerId,
      'reason': reason,
      'description': description,
      'photoUrls': photoUrls,
      'status': 'open',
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.update(_orders.doc(order.id), {'hasOpenCase': true});
    return batch.commit();
  }

  String newCaseId() => _db.collection('cases').doc().id;

  // --- Feedback --------------------------------------------------------------------

  /// feedback/{orderId}_{role}: one rating per order per side.
  Future<void> leaveFeedback({
    required AuctionOrder order,
    required String fromUid,
    required bool asBuyer,
    required String rating,
    required String comment,
  }) => _db.collection('feedback').doc('${order.id}_${asBuyer ? 'buyer' : 'seller'}').set({
    'orderId': order.id,
    'fromUid': fromUid,
    'toUid': asBuyer ? order.sellerId : order.buyerId,
    'role': asBuyer ? 'buyer' : 'seller',
    'rating': rating,
    'comment': comment,
    'createdAt': FieldValue.serverTimestamp(),
  });

  Stream<bool> watchFeedbackExists(String orderId, {required bool asBuyer}) => _db
      .collection('feedback')
      .doc('${orderId}_${asBuyer ? 'buyer' : 'seller'}')
      .snapshots()
      .map((s) => s.exists);
}
