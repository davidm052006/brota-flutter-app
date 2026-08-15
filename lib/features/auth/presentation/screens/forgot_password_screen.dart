import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brota_icon_badge.dart';
import '../../../../shared/widgets/brota_primary_button.dart';
import '../../../../shared/widgets/brota_text_field.dart';
import '../controllers/auth_form_state.dart';
import '../controllers/forgot_password_controller.dart';

/// Layout/spacing sigue el mockup 9/9b de
/// `design_reference/general/brota-handoff/mockups/01 Auth + Home.dc.html`
/// (ver `MOBILE_DESIGN_BRIEF.md` §1.8): vista de éxito "Revisa tu correo"
/// en vez del SnackBar anterior. `ForgotPasswordController` no cambia —
/// sigue exponiendo `AuthFormStatus.success`, solo cambia cómo reacciona
/// esta screen.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _linkSent = false;
  Timer? _resendCooldownTimer;
  int _resendCooldownSeconds = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _resendCooldownTimer?.cancel();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(forgotPasswordControllerProvider.notifier)
        .submit(_emailController.text.trim());
  }

  void _startResendCooldown() {
    _resendCooldownTimer?.cancel();
    setState(() => _resendCooldownSeconds = 45);
    _resendCooldownTimer = Timer.periodic(const Duration(seconds: 1), (
      timer,
    ) {
      if (_resendCooldownSeconds <= 1) {
        timer.cancel();
        setState(() => _resendCooldownSeconds = 0);
        return;
      }
      setState(() => _resendCooldownSeconds--);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    ref.listen<AuthFormState>(forgotPasswordControllerProvider, (
      previous,
      next,
    ) {
      if (next.status == AuthFormStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
      if (next.status == AuthFormStatus.success) {
        setState(() => _linkSent = true);
        _startResendCooldown();
      }
    });

    final AuthFormState state = ref.watch(forgotPasswordControllerProvider);
    final bool isLoading = state.status == AuthFormStatus.loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar contraseña')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenMargin,
          ),
          child: _linkSent
              ? _LinkSentView(
                  email: _emailController.text.trim(),
                  resendCooldownSeconds: _resendCooldownSeconds,
                  onResend: isLoading ? null : _submit,
                )
              : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Te enviaremos un enlace para restablecer tu contraseña.',
                        style: AppTypography.bodyMd(scheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      BrotaTextField(
                        controller: _emailController,
                        hintText: 'Correo electrónico',
                        leadingIcon: Icons.alternate_email,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa tu correo electrónico.';
                          }
                          if (!value.contains('@')) {
                            return 'Ingresa un correo válido.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      BrotaPrimaryButton(
                        label: 'Enviar enlace',
                        isLoading: isLoading,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _LinkSentView extends StatelessWidget {
  const _LinkSentView({
    required this.email,
    required this.resendCooldownSeconds,
    required this.onResend,
  });

  final String email;
  final int resendCooldownSeconds;
  final VoidCallback? onResend;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool canResend = resendCooldownSeconds == 0 && onResend != null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        children: [
          const BrotaIconBadge(
            assetPath: 'assets/icons/logo-feliz.svg',
            size: 72,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Revisa tu correo',
            style: AppTypography.headlineMd(scheme.onSurface),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            email.isEmpty
                ? 'Te enviamos un enlace para restablecer tu contraseña.'
                : 'Enviamos un enlace a $email para restablecer tu contraseña.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMd(scheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.xl),
          TextButton(
            onPressed: canResend ? onResend : null,
            child: Text(
              canResend
                  ? 'Reenviar enlace'
                  : 'Reenviar en 0:${resendCooldownSeconds.toString().padLeft(2, '0')}',
            ),
          ),
        ],
      ),
    );
  }
}
