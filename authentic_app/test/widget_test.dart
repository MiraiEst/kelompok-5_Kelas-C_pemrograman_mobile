import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imagi_auction/ui/auth/login_screen.dart';
import 'package:imagi_auction/ui/theme.dart';

/// Smoke tests for the login screen. They never reach Firebase: the form is
/// validated locally before the auth repository is used.
void main() {
  Future<void> pumpLogin(WidgetTester tester) => tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(theme: buildAppTheme(), home: const LoginScreen()),
        ),
      );

  testWidgets('login screen shows the Authentic design', (tester) async {
    await pumpLogin(tester);

    expect(find.text('Selamat Datang'), findsOneWidget);
    expect(find.text('email'), findsOneWidget);
    expect(find.text('password'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
    expect(find.text('Lupa password?'), findsOneWidget);
    expect(find.text('Register?'), findsOneWidget);
    expect(find.bySemanticsLabel('Authentic'), findsOneWidget);
  });

  testWidgets('empty form shows validation errors', (tester) async {
    await pumpLogin(tester);

    await tester.tap(find.text('Masuk'));
    await tester.pump();

    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(find.text('At least 6 characters'), findsOneWidget);
  });
}
