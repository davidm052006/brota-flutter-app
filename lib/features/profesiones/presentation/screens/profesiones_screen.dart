import 'package:flutter/material.dart';

import '../../../../shared/widgets/under_construction_view.dart';

/// `/dashboard/profesiones` — ver `frontend/src/pages/dashboard/
/// Profesiones.jsx`. Llega con la feature `profesiones` real (búsqueda,
/// `FilterSidebar`, grid paginado de `ProgramaCard` sobre
/// `GET /api/programas`).
class ProfesionesScreen extends StatelessWidget {
  const ProfesionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explorar profesiones')),
      body: const UnderConstructionView(
        icon: Icons.explore_outlined,
        title: 'Explorar profesiones',
        message: 'Aquí podrás buscar y filtrar entre miles de programas.',
      ),
    );
  }
}
