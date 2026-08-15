import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders one of the brand's illustrated SVGs (mascota o set de iconos
/// en `assets/icons/`) inside a fixed cream badge.
///
/// El fondo es siempre el mismo crema (`#E1CFC6`, el propio relleno de
/// las ilustraciones — ver `assets/icons/README.md`), sin importar el
/// tema activo: el contorno casi negro de estas piezas pierde contraste
/// sobre cualquier superficie oscura del tema, así que el badge no puede
/// reaccionar a [ColorScheme] como el resto de la UI.
class BrotaIconBadge extends StatelessWidget {
  const BrotaIconBadge({
    required this.assetPath,
    this.size = 44,
    this.iconPadding = 10,
    super.key,
  });

  final String assetPath;
  final double size;
  final double iconPadding;

  static const Color _badgeColor = Color(0xFFE1CFC6);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(iconPadding),
      decoration: const BoxDecoration(
        color: _badgeColor,
        shape: BoxShape.circle,
      ),
      child: SvgPicture.asset(assetPath),
    );
  }
}
