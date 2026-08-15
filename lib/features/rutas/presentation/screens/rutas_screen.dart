import 'package:flutter/material.dart';

import '../../../../shared/widgets/under_construction_view.dart';

/// `/dashboard/rutas` — actualmente `PaginaEnConstruccion` también en el
/// web (ver `MOBILE_DESIGN_BRIEF.md` sección 2.2, fila "Placeholders").
/// No es una pestaña de la barra inferior porque hoy no tiene
/// funcionalidad real; se alcanza desde el quick action "Rutas
/// formativas" de Inicio.
class RutasScreen extends StatelessWidget {
  const RutasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rutas formativas')),
      body: const UnderConstructionView(
        icon: Icons.route_outlined,
        title: 'Rutas formativas',
        message: 'Trazaremos aquí tu camino paso a paso.',
      ),
    );
  }
}
