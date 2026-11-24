import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

/// Indonesian mobile number: 08xx, 10-13 digits.
final _phonePattern = RegExp(r'^08\d{8,11}$');

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _termsTap = TapGestureRecognizer();
  final _privacyTap = TapGestureRecognizer();
  bool _busy = false;
  bool _agreed = false;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _termsTap.onTap = () => context.push('/legal/terms');
    _privacyTap.onTap = () => context.push('/legal/privacy');
  }

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _password]) {
      c.dispose();
    }
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .register(
            name: _name.text,
            email: _email.text,
            password: _password.text,
            phone: _phone.text.replaceAll(RegExp(r'\D'), ''),
          );
      // Router sends the new user to /verify-email.
    } catch (e) {
      if (mounted) showSnack(context, authErrorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: context.l10n.backToSignIn,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: Form(
        key: _form,
        child: AutofillGroup(
          child: AuthBody(
            children: [
              AuthHeading(
                title: context.l10n.createAccountTitle,
                subtitle: context.l10n.createAccountSubtitle,
                center: false,
              ),
              const SizedBox(height: 24),
              AppTextField(
                label: context.l10n.username,
                controller: _name,
                hint: context.l10n.usernameHint,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.username],
                validator: (v) => (v == null || v.trim().length < 3) ? context.l10n.atLeast3 : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: context.l10n.email,
                controller: _email,
                hint: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: (v) =>
                    (v == null || !v.contains('@')) ? context.l10n.enterValidEmail : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: context.l10n.phoneNumber,
                controller: _phone,
                hint: '08xx xxxx xxxx',
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.telephoneNumber],
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]'))],
                validator: (v) => _phonePattern.hasMatch((v ?? '').replaceAll(' ', ''))
                    ? null
                    : context.l10n.phoneInvalid,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: context.l10n.password,
                controller: _password,
                obscureText: !_showPassword,
                helper: context.l10n.atLeast8,
                autofillHints: const [AutofillHints.newPassword],
                validator: (v) => (v == null || v.length < 8) ? context.l10n.atLeast8 : null,
                suffix: IconButton(
                  tooltip: _showPassword ? context.l10n.hidePassword : context.l10n.showPassword,
                  icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _showPassword = !_showPassword),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _agreed,
                    semanticLabel:
                        '${context.l10n.agreePrefix}${context.l10n.termsOfService}${context.l10n.and}${context.l10n.privacyPolicy}',
                    onChanged: (v) => setState(() => _agreed = v ?? false),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text.rich(
                        TextSpan(
                          text: context.l10n.agreePrefix,
                          children: [
                            TextSpan(
                              text: context.l10n.termsOfService,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: _termsTap,
                            ),
                            TextSpan(text: context.l10n.and),
                            TextSpan(
                              text: context.l10n.privacyPolicy,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: _privacyTap,
                            ),
                          ],
                        ),
                        style: AppText.small,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: context.l10n.createAccount,
                loading: _busy,
                onPressed: _agreed ? _submit : null,
              ),
              const SizedBox(height: 12),
              Text(context.l10n.verifyNote, textAlign: TextAlign.center, style: AppText.caption),
            ],
          ),
        ),
      ),
    );
  }
}
