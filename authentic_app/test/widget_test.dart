import 'package:flutter_test/flutter_test.dart';
import 'package:imagi_auction/ui/auth/login_screen.dart';

import 'helpers.dart';

/// Smoke tests for the sign-in screen. They never reach Firebase: the form is
/// validated locally before the auth repository is used.
void main() {
  setUpAll(useTestFonts);

  Future<void> pumpLogin(WidgetTester tester) => pumpApp(tester, const LoginScreen());

  testWidgets('sign in screen matches the wireframe', (tester) async {
    await pumpLogin(tester);

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in to bid, sell and track your orders'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
    expect(find.byTooltip('Show password'), findsOneWidget);
  });

  testWidgets('empty form shows validation errors', (tester) async {
    await pumpLogin(tester);

    await tester.tap(find.text('Sign in'));
    await tester.pump();

    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
  });
}
