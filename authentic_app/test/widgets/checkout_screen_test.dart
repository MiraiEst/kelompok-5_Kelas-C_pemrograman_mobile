import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imagi_auction/core/config.dart';
import 'package:imagi_auction/domain/models/order.dart';
import 'package:imagi_auction/providers/providers.dart';
import 'package:imagi_auction/ui/checkout/checkout_screen.dart';

import '../helpers.dart';

void main() {
  setUpAll(useTestFonts);

  final order = AuctionOrder(
    id: 'o1',
    listingId: 'o1',
    buyerId: 'me',
    sellerId: 'seller',
    title: 'Vintage camera',
    imageUrl: null,
    itemPrice: 505000,
    shippingCost: 25000,
    serviceFee: AppConfig.serviceFee(505000),
    total: 0, // the screen computes the displayed total itself
    status: OrderStatus.awaitingPayment,
    payBy: DateTime.now().add(const Duration(days: 3)),
    createdAt: DateTime.now(),
  );
  const address = Address(
    id: 'a1',
    name: 'Andi',
    phone: '081234567890',
    street: 'Jl. Perintis Kemerdekaan 10',
    city: 'Makassar',
    province: 'Sulawesi Selatan',
    postalCode: '90245',
    isDefault: true,
  );

  test('service fee is 1% capped at Rp 10.000', () {
    expect(AppConfig.serviceFee(505000), 5050);
    expect(AppConfig.serviceFee(5000000), 10000);
  });

  test('priceBreakdown adds item, shipping and fee', () {
    final p = priceBreakdown(item: 505000, shipping: 25000, fee: 5050);
    expect(p.total, 535050);
  });

  testWidgets('checkout shows the price lines and the right total', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpApp(
      tester,
      const CheckoutScreen(orderId: 'o1'),
      overrides: [
        authStateProvider.overrideWith((ref) => Stream<User?>.value(null)),
        orderProvider('o1').overrideWith((ref) => Stream.value(order)),
        addressesProvider.overrideWith((ref) => Stream.value(const [address])),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Won for Rp 505.000'), findsOneWidget);
    expect(find.text('JNE REG'), findsOneWidget);
    expect(find.text('Andi'), findsOneWidget); // default address preselected
    expect(find.text('Winning price'), findsOneWidget);
    expect(find.text('Service fee'), findsOneWidget);
    final total = tester.widget<Text>(find.byKey(const Key('checkoutTotal')));
    expect(total.data, 'Rp 535.050');
    expect(find.text('Pay with Xendit'), findsOneWidget);
  });
}
