import 'package:flutter/material.dart';

import '../../core/theme/app_radii.dart';
import '../../core/theme/app_typography.dart';

/// Rounded, icon-leading text field matching the Stitch login mockup
/// (`design_reference/login_light/screen.png`): soft filled background,
/// no visible border until focus, leading icon, optional trailing
/// action (e.g. the password visibility toggle).
class BrotaTextField extends StatelessWidget {
  const BrotaTextField({
    required this.controller,
    required this.hintText,
    required this.leadingIcon,
    super.key,
    this.obscureText = false,
    this.trailing,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData leadingIcon;
  final bool obscureText;
  final Widget? trailing;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      autofillHints: autofillHints,
      style: AppTypography.bodyMd(scheme.onSurface),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(leadingIcon, color: scheme.onSurfaceVariant),
        suffixIcon: trailing,
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        border: const OutlineInputBorder(
          borderRadius: AppRadii.xlRadius,
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.xlRadius,
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadii.xlRadius,
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
      ),
    );
  }
}
