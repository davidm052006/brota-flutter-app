import 'package:flutter/material.dart';

import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// "Continuar donde quedaste" — ver `ContinueSection` en
/// `frontend/src/pages/dashboard/Dashboard.jsx`. Siempre vacío hoy: el
/// contenido dinámico depende de la feature `perfil`, que aún no existe
/// (ver CLAUDE.md "Estado de la implementación"). Estado vacío honesto,
/// no una tarjeta con datos inventados.
class ContinueSection extends StatelessWidget {
  const ContinueSection({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: AppRadii.xxlRadius,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Continuar donde quedaste',
            style: AppTypography.headlineMd(scheme.onSurface),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Todavía no tienes actividad reciente. Empieza explorando '
            'profesiones o el test vocacional.',
            style: AppTypography.bodyMd(scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
