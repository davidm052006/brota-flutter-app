import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brota_icon_badge.dart';

const List<String> _weekdays = [
  'lunes',
  'martes',
  'miércoles',
  'jueves',
  'viernes',
  'sábado',
  'domingo',
];
const List<String> _months = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

/// Saludo + fecha + CTA para retomar el test vocacional — ver
/// `HeroBanner` en `frontend/src/pages/dashboard/Dashboard.jsx`.
///
/// Sin barra de progreso del test: esa cifra la expondría la feature
/// `perfil`, que todavía no existe (ver CLAUDE.md "Estado de la
/// implementación") — se muestra una invitación, no un dato inventado.
class HeroBanner extends StatelessWidget {
  const HeroBanner({required this.userEmail, super.key});

  final String? userEmail;

  String get _formattedToday {
    final DateTime now = DateTime.now();
    final String weekday = _weekdays[now.weekday - 1];
    final String month = _months[now.month - 1];
    return '$weekday, ${now.day} de $month';
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hola${userEmail != null ? ', $userEmail' : ''} 🌱',
                    style: AppTypography.greeting(scheme.onSurface),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _formattedToday,
                    style: AppTypography.bodyMd(scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            const BrotaIconBadge(
              assetPath: 'assets/icons/logo-base-limpio.svg',
              size: 64,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        const _TestCtaCard(),
      ],
    );
  }
}

class _TestCtaCard extends StatelessWidget {
  const _TestCtaCard();

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: AppRadii.xxlRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Descubre quién quieres ser',
            style: AppTypography.headlineMd(scheme.onPrimaryContainer),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Responde el test vocacional y recibe recomendaciones hechas para ti.',
            style: AppTypography.bodyMd(scheme.onPrimaryContainer),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: () => context.go('/dashboard/test'),
            style: FilledButton.styleFrom(
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              minimumSize: const Size(0, 44),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadii.xlRadius,
              ),
              textStyle: AppTypography.button(scheme.onPrimary),
            ),
            child: const Text('Empezar test'),
          ),
        ],
      ),
    );
  }
}
