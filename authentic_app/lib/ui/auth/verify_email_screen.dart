import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';

import '../../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/buttons.dart';
import '../widgets/common.dart';
import 'auth_widgets.dart';

/// Shown to email/password users until they click the link in the email.
class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  static const _cooldown = 60;
  int _wait = 0;
  Timer? _timer;
  bool _checking = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _check() async {
    setState(() => _checking = true);
    try {
      final ok = await ref.read(authRepositoryProvider).reloadAndCheckVerified();
      if (!ok && mounted) showSnack(context, context.l10n.notVerifiedYet);
      // When verified, userChanges() fires and the router leaves this page.
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e));
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _resend() async {
    try {
      await ref.read(authRepositoryProvider).resendVerification();
      if (!mounted) return;
      showSnack(context, context.l10n.verificationSent);
      setState(() => _wait = _cooldown);
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) return t.cancel();
        setState(() => _wait--);
        if (_wait <= 0) t.cancel();
      });
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = ref.watch(authStateProvider).value?.email ?? 'your email';
    return Scaffold(
      body: AuthBody(
        children: [
          const Center(child: Icon(Icons.mark_email_unread_outlined, size: 64)),
          const SizedBox(height: 16),
          AuthHeading(title: context.l10n.verifyTitle, subtitle: context.l10n.verifyBody(email)),
          const SizedBox(height: 32),
          PrimaryButton(label: context.l10n.iveVerified, loading: _checking, onPressed: _check),
          const SizedBox(height: 12),
          SecondaryButton(
            label: _wait > 0 ? context.l10n.resendEmailIn(_wait) : context.l10n.resendEmail,
            onPressed: _wait > 0 ? null : _resend,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
            child: Text(context.l10n.signOut),
          ),
          const SizedBox(height: 8),
          Text(context.l10n.checkSpam, textAlign: TextAlign.center, style: AppText.caption),
        ],
      ),
    );
  }
}
