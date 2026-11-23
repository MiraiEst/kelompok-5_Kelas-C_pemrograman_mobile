import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus {
  awaitingPayment('awaiting_payment', 'Awaiting payment'),
  paid('paid', 'Paid'),
  shipped('shipped', 'Shipped'),
  inTransit('in_transit', 'In transit'),
  delivered('delivered', 'Delivered'),
  completed('completed', 'Completed'),
  cancelled('cancelled', 'Cancelled');

  const OrderStatus(this.value, this.label);
  final String value;
  final String label;

  bool get isPaid => index >= OrderStatus.paid.index && this != cancelled;
  bool get isOpen => this != completed && this != cancelled;

  static OrderStatus parse(Object? raw) =>
      values.firstWhere((s) => s.value == raw, orElse: () => OrderStatus.awaitingPayment);
}

/// A shipping address (users/{uid}/addresses/{id}, copied onto orders).
class Address {
  const Address({
    this.id = '',
    required this.name,
    required this.phone,
    required this.street,
    required this.city,
    required this.province,
    required this.postalCode,
    this.isDefault = false,
  });

  final String id;
  final String name;
  final String phone;
  final String street;
  final String city;
  final String province;
  final String postalCode;
  final bool isDefault;

  Map<String, dynamic> toMap() => {
    'name': name,
    'phone': phone,
    'street': street,
    'city': city,
    'province': province,
    'postalCode': postalCode,
  };

  String get oneLine => '$street, $city, $province $postalCode';

  static Address? fromMap(Object? raw, {String id = '', bool isDefault = false}) {
    if (raw is! Map) return null;
    String s(String k) => raw[k] as String? ?? '';
    return Address(
      id: id,
      name: s('name'),
      phone: s('phone'),
      street: s('street'),
      city: s('city'),
      province: s('province'),
      postalCode: s('postalCode'),
      isDefault: isDefault || (raw['isDefault'] as bool? ?? false),
    );
  }

  factory Address.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) =>
      Address.fromMap(doc.data() ?? const {}, id: doc.id)!;
}

/// orders/{orderId}. The id equals the listing id (one order per sale).
class AuctionOrder {
  const AuctionOrder({
    required this.id,
    required this.listingId,
    required this.buyerId,
    required this.sellerId,
    required this.title,
    required this.imageUrl,
    required this.itemPrice,
    required this.shippingCost,
    required this.serviceFee,
    required this.total,
    required this.status,
    required this.payBy,
    required this.createdAt,
    this.address,
    this.courier,
    this.paymentMethod,
    this.invoiceUrl,
    this.paidAt,
    this.trackingNumber,
    this.shippedAt,
    this.inTransitAt,
    this.deliveredAt,
    this.completedAt,
    this.sellerName,
    this.buyerName,
    this.handlingDays,
    this.hasOpenCase = false,
    this.lastUpdate,
  });

  final String id;
  final String listingId;
  final String buyerId;
  final String sellerId;
  final String title;
  final String? imageUrl;
  final int itemPrice;
  final int shippingCost;
  final int serviceFee;
  final int total;
  final OrderStatus status;
  final DateTime payBy;
  final DateTime createdAt;
  final Address? address;
  final String? courier;
  final String? paymentMethod;
  final String? invoiceUrl;
  final DateTime? paidAt;
  final String? trackingNumber;
  final DateTime? shippedAt;
  final DateTime? inTransitAt;
  final DateTime? deliveredAt;
  final DateTime? completedAt;
  final String? sellerName;
  final String? buyerName;
  final int? handlingDays;
  final bool hasOpenCase;
  final String? lastUpdate;

  /// "IA-000123": short, human order number derived from the id.
  String get shortNumber {
    final n = id.codeUnits.fold<int>(0, (a, c) => (a * 31 + c) % 1000000);
    return 'IA-${n.toString().padLeft(6, '0')}';
  }

  static DateTime? _date(Object? v) => (v as Timestamp?)?.toDate();
  static int _int(Object? v) => (v as num?)?.toInt() ?? 0;

  factory AuctionOrder.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const <String, dynamic>{};
    return AuctionOrder(
      id: doc.id,
      listingId: d['listingId'] as String? ?? doc.id,
      buyerId: d['buyerId'] as String? ?? '',
      sellerId: d['sellerId'] as String? ?? '',
      title: d['title'] as String? ?? '',
      imageUrl: d['imageUrl'] as String?,
      itemPrice: _int(d['itemPrice']),
      shippingCost: _int(d['shippingCost']),
      serviceFee: _int(d['serviceFee']),
      total: _int(d['total']),
      status: OrderStatus.parse(d['status']),
      payBy: _date(d['payBy']) ?? DateTime.now(),
      createdAt: _date(d['createdAt']) ?? DateTime.now(),
      address: Address.fromMap(d['address']),
      courier: d['courier'] as String?,
      paymentMethod: d['paymentMethod'] as String?,
      invoiceUrl: d['invoiceUrl'] as String?,
      paidAt: _date(d['paidAt']),
      trackingNumber: d['trackingNumber'] as String?,
      shippedAt: _date(d['shippedAt']),
      inTransitAt: _date(d['inTransitAt']),
      deliveredAt: _date(d['deliveredAt']),
      completedAt: _date(d['completedAt']),
      sellerName: d['sellerName'] as String?,
      buyerName: d['buyerName'] as String?,
      handlingDays: (d['handlingDays'] as num?)?.toInt(),
      hasOpenCase: d['hasOpenCase'] as bool? ?? false,
      lastUpdate: d['lastUpdate'] as String?,
    );
  }
}
