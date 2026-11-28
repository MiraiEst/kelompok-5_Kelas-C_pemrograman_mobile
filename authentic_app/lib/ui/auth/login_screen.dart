import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/l10n.dart';

import '../../data/repositories/auth_repository.dart';
import '../../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/app_text_field.dart';
import '../widgets/buttons.dart';
import '../widgets/common.dart';
import 'auth_widgets.dart';
import '../widgets/brand_form_theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  bool _googleBusy = false;
  bool _showPassword = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).signIn(email: _email.text, password: _password.text);
      // The router redirects automatically when auth state changes.
    } catch (e) {
      if (mounted) showSnack(context, authErrorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _google() async {
    setState(() => _googleBusy = true);
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
    } catch (e) {
      if (mounted) showSnack(context, authErrorMessage(e));
    } finally {
      if (mounted) setState(() => _googleBusy = false);
    }
  }

  Future<void> _resetPassword() async {
    if (!_email.text.contains('@')) {
      showSnack(context, context.l10n.enterEmailFirst);
      return;
    }
    try {
      await ref.read(authRepositoryProvider).sendPasswordReset(_email.text);
      if (mounted) showSnack(context, context.l10n.resetEmailSent);
    } catch (e) {
      if (mounted) showSnack(context, authErrorMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BrandFormTheme(
        child: Form(
          key: _form,
          child: AutofillGroup(
            child: AuthBody(
              children: [
                Center(
                  child: Semantics(
                    label: 'Authentic',
                    image: true,
                    child: Image.asset(
                      'assets/brand/logo_wordmark.png',
                      height: 40,
                      excludeFromSemantics: true,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                AuthHeading(title: context.l10n.welcomeBack, subtitle: context.l10n.signInSubtitle),
                const SizedBox(height: 28),
                AppTextField(
                  label: context.l10n.email,
                  controller: _email,
                  hint: 'yourname@email.com',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  validator: (v) =>
                      (v == null || !v.contains('@')) ? context.l10n.enterValidEmail : null,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: context.l10n.password,
                  controller: _password,
                  obscureText: !_showPassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  validator: (v) => (v == null || v.isEmpty) ? context.l10n.enterPassword : null,
                  onSubmitted: (_) => _submit(),
                  suffix: IconButton(
                    tooltip: _showPassword ? context.l10n.hidePassword : context.l10n.showPassword,
                    icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _resetPassword,
                    child: Text(context.l10n.forgotPassword, style: _underlinedBold),
                  ),
                ),
                const SizedBox(height: 8),
                PrimaryButton(
                  color: AppColors.ocean,
                  label: context.l10n.signIn,
                  loading: _busy,
                  onPressed: _submit,
                ),
                const SizedBox(height: 16),
                const Divider(thickness: 1.5),
                const SizedBox(height: 16),
                SecondaryButton(
                  color: AppColors.ocean,
                  label: context.l10n.continueWithGoogle,
                  icon: Icons.g_mobiledata,
                  loading: _googleBusy,
                  onPressed: _google,
                ),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(context.l10n.noAccount, style: const TextStyle(fontSize: 15)),
                    TextButton(
                      onPressed: () => context.go('/register'),
                      child: Text(context.l10n.register, style: _underlinedBold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const _underlinedBold = TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w700,
  color: AppColors.ink,
  decoration: TextDecoration.underline,
);
