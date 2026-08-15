import 'package:flutter/material.dart';

import '../../../../shared/widgets/under_construction_view.dart';

/// `/dashboard/test` — ver `frontend/src/pages/dashboard/
/// TestVocacional.jsx`. Llega con la feature `test_vocacional` real
/// (flujo `intro` → preguntas con `ProgressBand` → `TestResult` sobre
/// `GET/POST /api/perfil/cuestionario`).
class TestVocacionalScreen extends StatelessWidget {
  const TestVocacionalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test vocacional')),
      body: const UnderConstructionView(
        icon: Icons.quiz_outlined,
        title: 'Test vocacional',
        message: 'El test para descubrir tu camino está en camino.',
      ),
    );
  }
}
