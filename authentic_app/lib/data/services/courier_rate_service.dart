/// A shipping option shown at checkout.
typedef CourierRate = ({String id, String name, String eta, int price});

/// Shipping rates. Swap [FixedCourierRates] for a real rate API later
/// (e.g. RajaOngkir / Biteship) without touching the Checkout screen.
abstract interface class CourierRateService {
  Future<List<CourierRate>> ratesFor({required int listingShippingCost, String? destinationCity});
}

/// Fixed list; every courier costs the shipping price the seller entered.
class FixedCourierRates implements CourierRateService {
  const FixedCourierRates();

  @override
  Future<List<CourierRate>> ratesFor({
    required int listingShippingCost,
    String? destinationCity,
  }) async => [
    (id: 'jne_reg', name: 'JNE REG', eta: '2-3 days', price: listingShippingCost),
    (id: 'sicepat_best', name: 'SiCepat BEST', eta: '1-2 days', price: listingShippingCost),
    (id: 'jnt_ez', name: 'J&T EZ', eta: '2-4 days', price: listingShippingCost),
  ];
}

/// Payment methods offered through Xendit Invoice.
enum PaymentMethod {
  virtualAccount('virtual_account', 'Virtual account', 'BCA · BNI · Mandiri · BRI'),
  qris('qris', 'QRIS', 'Scan with any banking or e-wallet app'),
  eWallet('ewallet', 'E-wallet', 'GoPay · OVO · DANA · ShopeePay');

  const PaymentMethod(this.value, this.label, this.detail);
  final String value;
  final String label;
  final String detail;

  static PaymentMethod? parse(Object? raw) => values.where((m) => m.value == raw).firstOrNull;
}
