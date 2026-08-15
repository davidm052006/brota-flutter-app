import 'package:flutter/material.dart';

import '../../../../shared/widgets/under_construction_view.dart';

/// `/dashboard/comunidad` — ver `frontend/src/pages/dashboard/
/// Comunidad.jsx`. Llega con la feature `comunidad` real (4 tabs: Foros,
/// Historias reales, Preguntas, Convocatorias + FAB contextual).
class ComunidadScreen extends StatelessWidget {
  const ComunidadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comunidad')),
      body: const UnderConstructionView(
        icon: Icons.forum_outlined,
        title: 'Comunidad',
        message: 'Foros, historias reales y preguntas de otros estudiantes.',
      ),
    );
  }
}
