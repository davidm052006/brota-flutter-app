import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brota_icon_badge.dart';
import '../../../../shared/widgets/brota_primary_button.dart';
import '../../../../shared/widgets/brota_text_field.dart';
import '../controllers/auth_form_state.dart';
import '../controllers/login_controller.dart';

/// Login screen. Layout/spacing sigue el mockup 7 de
/// `design_reference/general/brota-handoff/mockups/01 Auth + Home.dc.html`
/// (ver `MOBILE_DESIGN_BRIEF.md` §1.8) — color y tipografía son los
/// tokens reales de marca, no los del mockup.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(loginControllerProvider.notifier)
        .submit(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    ref.listen<AuthFormState>(loginControllerProvider, (previous, next) {
      if (next.status == AuthFormStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
      // Successful sign-in flips authStateChangesProvider, which the
      // router's redirect picks up — no explicit navigation needed here.
    });

    final AuthFormState state = ref.watch(loginControllerProvider);
    final bool isLoading = state.status == AuthFormStatus.loading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenMargin,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.xxl),
                _Header(scheme: scheme),
                const SizedBox(height: AppSpacing.xl),
                BrotaTextField(
                  controller: _emailController,
                  hintText: 'Correo electrónico',
                  leadingIcon: Icons.alternate_email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
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
                const SizedBox(height: AppSpacing.md),
                BrotaTextField(
                  controller: _passwordController,
                  hintText: 'Contraseña',
                  leadingIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa tu contraseña.';
                    }
                    return null;
                  },
                  trailing: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: scheme.onSurfaceVariant,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: isLoading
                        ? null
                        : () => context.push('/forgot-password'),
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                BrotaPrimaryButton(
                  label: 'Ingresar',
                  isLoading: isLoading,
                  trailingIcon: Icons.arrow_forward,
                  onPressed: _submit,
                ),
                const SizedBox(height: AppSpacing.xl),
                _RegisterFooter(isLoading: isLoading),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const BrotaIconBadge(
          assetPath: 'assets/icons/logo-base-limpio.svg',
          size: 64,
        ),
        const SizedBox(height: AppSpacing.md),
        Text('Brota', style: AppTypography.headlineMd(scheme.primary)),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Tu camino sigue justo donde lo dejaste.',
          textAlign: TextAlign.center,
          style: AppTypography.headlineLgMobile(scheme.onSurface),
        ),
      ],
    );
  }
}

class _RegisterFooter extends StatelessWidget {
  const _RegisterFooter({required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Center(
      child: RichText(
        text: TextSpan(
          style: AppTypography.bodyMd(scheme.onSurfaceVariant),
          children: [
            const TextSpan(text: '¿No tienes una cuenta? '),
            TextSpan(
              text: 'Regístrate',
              style: AppTypography.bodyMd(
                scheme.primary,
              ).copyWith(fontWeight: FontWeight.bold),
              recognizer: TapGestureRecognizer()
                ..onTap = isLoading ? null : () => context.push('/register'),
            ),
          ],
        ),
      ),
    );
  }
}
