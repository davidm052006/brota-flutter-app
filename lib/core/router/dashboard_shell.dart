import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

/// Bottom navigation scaffold for the authenticated dashboard area.
///
/// Mirrors `frontend/src/components/layout/TopNavbar.jsx`, adapted to
/// mobile: the desktop's 6-tab horizontal bar doesn't fit a phone width,
/// so only the 5 primary destinations become tabs (Inicio, Explorar,
/// Test, Recursos, Comunidad). "Rutas formativas" y las icons
/// secundarias (favoritos, mensajes, ajustes) stay reachable from within
/// Inicio/perfil instead of competing for tab-bar space — see
/// `MOBILE_DESIGN_BRIEF.md` sección 2.2 y CLAUDE.md "Estado de la
/// implementación".
///
/// Íconos del set de marca (`assets/icons/icon-*.svg`, ver
/// `MOBILE_DESIGN_BRIEF.md` §1.2.2), re-tintados en runtime (no en
/// `BrotaIconBadge`, que preserva el color multicolor original): la
/// barra de tabs necesita un glyph plano de un solo color por estado
/// (activo/inactivo), como cualquier ícono de Material — el tratamiento
/// ilustrado multicolor con badge crema es para tarjetas grandes, no
/// para 24px en una barra.
///
/// Wraps [StatefulShellRoute.indexedStack]'s [navigationShell] so each
/// tab keeps its own navigation stack and scroll position when the user
/// switches away and back.
class DashboardShell extends StatelessWidget {
  const DashboardShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const List<_DashboardDestination> _destinations = [
    _DashboardDestination(
      iconAsset: 'assets/icons/icon-inicio.svg',
      label: 'Inicio',
    ),
    _DashboardDestination(
      iconAsset: 'assets/icons/icon-buscar.svg',
      label: 'Explorar',
    ),
    // icon-confirmar.svg pierde el checkmark al aplanarse a un color: el
    // check y el aro ya eran el mismo #360E0A en el original, solo se
    // distinguían por estar sobre relleno crema — con un solo tinte los
    // dos se fusionan y queda un círculo liso. Excepción con ícono de
    // Material hasta que se rehaga ese SVG con el check como hueco real.
    _DashboardDestination(materialIcon: Icons.quiz_outlined, label: 'Test'),
    _DashboardDestination(
      iconAsset: 'assets/icons/icon-recursos.svg',
      label: 'Recursos',
    ),
    _DashboardDestination(
      iconAsset: 'assets/icons/icon-comunidad.svg',
      label: 'Comunidad',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final int currentIndex = navigationShell.currentIndex;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (int index) => navigationShell.goBranch(
          index,
          initialLocation: index == currentIndex,
        ),
        destinations: [
          for (final _DashboardDestination destination in _destinations)
            NavigationDestination(
              icon: _TabIcon(
                destination: destination,
                color: scheme.onSurfaceVariant,
              ),
              selectedIcon: _TabIcon(
                destination: destination,
                color: scheme.primary,
              ),
              label: destination.label,
            ),
        ],
      ),
    );
  }
}

class _TabIcon extends StatelessWidget {
  const _TabIcon({required this.destination, required this.color});

  final _DashboardDestination destination;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (destination.materialIcon != null) {
      return Icon(destination.materialIcon, color: color, size: 24);
    }
    return SvgPicture.asset(
      destination.iconAsset!,
      width: 24,
      height: 24,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}

class _DashboardDestination {
  const _DashboardDestination({this.iconAsset, this.materialIcon, required this.label})
    : assert(
        (iconAsset == null) != (materialIcon == null),
        'Pasa exactamente uno de iconAsset o materialIcon.',
      );

  final String? iconAsset;
  final IconData? materialIcon;
  final String label;
}
