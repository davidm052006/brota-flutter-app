import 'package:flutter/material.dart';

import '../../../../shared/widgets/under_construction_view.dart';

/// `/dashboard/recursos` — ver `frontend/src/pages/dashboard/
/// Recursos.jsx`. Llega con la feature `recursos` real (tabs por
/// categoría, búsqueda inline, grid de `RecursoCard`).
class RecursosScreen extends StatelessWidget {
  const RecursosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recursos')),
      body: const UnderConstructionView(
        icon: Icons.menu_book_outlined,
        title: 'Recursos',
        message: 'Guías, videos, becas y podcasts, todo en un solo lugar.',
      ),
    );
  }
}
