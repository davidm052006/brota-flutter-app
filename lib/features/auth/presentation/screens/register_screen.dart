import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brota_primary_button.dart';
import '../../../../shared/widgets/brota_text_field.dart';
import '../controllers/auth_form_state.dart';
import '../controllers/register_controller.dart';

/// Layout/spacing sigue el mockup 8 de
/// `design_reference/general/brota-handoff/mockups/01 Auth + Home.dc.html`
/// (ver `MOBILE_DESIGN_BRIEF.md` §1.8) — sin el registro en 2 pasos del
/// mockup: `RegisterController` es de un solo paso, no se le agregó una
/// máquina de estados nueva solo por el visual.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(registerControllerProvider.notifier)
        .submit(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    ref.listen<AuthFormState>(registerControllerProvider, (previous, next) {
      if (next.status == AuthFormStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });

    final AuthFormState state = ref.watch(registerControllerProvider);
    final bool isLoading = state.status == AuthFormStatus.loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
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
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Crea tu cuenta y empieza a crecer.',
                  style: AppTypography.headlineMd(scheme.onSurface),
                ),
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
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Mínimo 6 caracteres.';
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
                _PasswordStrengthMeter(controller: _passwordController),
                const SizedBox(height: AppSpacing.sm),
                BrotaTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Confirmar contraseña',
                  leadingIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Las contraseñas no coinciden.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                _TermsCheckbox(
                  value: _acceptedTerms,
                  onChanged: (value) =>
                      setState(() => _acceptedTerms = value),
                ),
                const SizedBox(height: AppSpacing.lg),
                BrotaPrimaryButton(
                  label: 'Registrarme',
                  isLoading: isLoading,
                  onPressed: _acceptedTerms ? _submit : null,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 0 = vacío, 1 = débil, 2 = media, 3 = fuerte — cálculo puramente local
/// (longitud + variedad de caracteres), no depende del backend.
int _passwordStrength(String password) {
  if (password.length < 6) return password.isEmpty ? 0 : 1;
  final bool hasDigit = password.contains(RegExp(r'[0-9]'));
  final bool hasUpper = password.contains(RegExp(r'[A-Z]'));
  final bool hasSymbol = password.contains(RegExp(r'[^A-Za-z0-9]'));
  final int variety = [hasDigit, hasUpper, hasSymbol].where((v) => v).length;
  if (password.length >= 8 && variety >= 2) return 3;
  return 2;
}

class _PasswordStrengthMeter extends StatelessWidget {
  const _PasswordStrengthMeter({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final int strength = _passwordStrength(value.text);
        final Color filledColor = switch (strength) {
          1 => scheme.error,
          2 => scheme.tertiary,
          3 => scheme.primary,
          _ => scheme.outlineVariant,
        };

        return Row(
          children: [
            for (int i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: SizedBox(
                  height: 4,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: i < strength ? filledColor : scheme.outlineVariant,
                      borderRadius: AppRadii.fullRadius,
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: AppRadii.mdRadius,
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: (checked) => onChanged(checked ?? false),
          ),
          Expanded(
            child: Text(
              'Acepto los términos y condiciones.',
              style: AppTypography.bodyMd(scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
