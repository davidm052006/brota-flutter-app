import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Empty-state body for a dashboard destination that exists in the
/// navigation but has no real content yet — mirrors the web's
/// `PaginaEnConstruccion` (ver `MOBILE_DESIGN_BRIEF.md` secciones 2.2-2.3).
class UnderConstructionView extends StatelessWidget {
  const UnderConstructionView({
    required this.icon,
    required this.title,
    super.key,
    this.message = 'Estamos construyendo esta sección. Vuelve pronto.',
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: scheme.onSurfaceVariant),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: AppTypography.headlineMd(scheme.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTypography.bodyMd(scheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
