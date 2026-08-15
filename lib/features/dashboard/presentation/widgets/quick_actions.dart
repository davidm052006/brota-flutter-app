import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brota_icon_badge.dart';

/// Grid 2×2 de accesos directos — ver `QuickActions` en
/// `frontend/src/pages/dashboard/Dashboard.jsx`.
///
/// Iconos del set de marca (`assets/icons/icon-*.svg`, ver
/// `MOBILE_DESIGN_BRIEF.md` §1.2.2) en vez de `Icons.*` de Material.
class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  static const List<_QuickAction> _actions = [
    _QuickAction(
      iconAsset: 'assets/icons/icon-profesiones.svg',
      label: 'Explorar profesiones',
      route: '/dashboard/profesiones',
    ),
    _QuickAction(
      iconAsset: 'assets/icons/icon-confirmar.svg',
      label: 'Realizar test',
      route: '/dashboard/test',
    ),
    _QuickAction(
      iconAsset: 'assets/icons/icon-ruta.svg',
      label: 'Rutas formativas',
      route: '/dashboard/rutas',
      // '/dashboard/rutas' vive fuera del StatefulShellRoute (no es una
      // pestaña) — hay que empujarla para dejar algo en el stack y poder
      // volver. Los demás quick actions sí son ramas del shell: `go`
      // cambia de pestaña sin apilar una segunda instancia del shell.
      isPush: true,
    ),
    _QuickAction(
      iconAsset: 'assets/icons/icon-recursos.svg',
      label: 'Explorar recursos',
      route: '/dashboard/recursos',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.3,
      children: [
        for (final _QuickAction action in _actions) _QuickActionCard(action: action),
      ],
    );
  }
}

class _QuickAction {
  const _QuickAction({
    required this.iconAsset,
    required this.label,
    required this.route,
    this.isPush = false,
  });

  final String iconAsset;
  final String label;
  final String route;
  final bool isPush;
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.action});

  final _QuickAction action;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: AppRadii.xlRadius,
      child: InkWell(
        borderRadius: AppRadii.xlRadius,
        onTap: () => action.isPush
            ? context.push(action.route)
            : context.go(action.route),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              BrotaIconBadge(assetPath: action.iconAsset, size: 28, iconPadding: 6),
              const SizedBox(height: AppSpacing.sm),
              Text(action.label, style: AppTypography.labelMd(scheme.onSurface)),
            ],
          ),
        ),
      ),
    );
  }
}
