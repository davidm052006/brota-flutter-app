import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/pregunta.dart';
import '../controllers/preguntas_controller.dart';
import '../widgets/estado_placeholders.dart';
import '../widgets/pregunta_tile.dart';

/// Preguntas de un cuestionario. El título viene por `extra` del router para
/// no tener que re-pedir el cuestionario solo para mostrar su nombre.
class PreguntasScreen extends ConsumerWidget {
  const PreguntasScreen({
    required this.cuestionarioId,
    this.nombreCuestionario,
    super.key,
  });

  final String cuestionarioId;
  final String? nombreCuestionario;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PreguntasState state = ref.watch(
      preguntasControllerProvider(cuestionarioId),
    );
    final PreguntasController controller = ref.read(
      preguntasControllerProvider(cuestionarioId).notifier,
    );

    return Scaffold(
      appBar: AppBar(title: Text(nombreCuestionario ?? 'Preguntas')),
      floatingActionButton: state.status == PreguntasStatus.ready
          ? FloatingActionButton.extended(
              onPressed: state.guardando ? null : () => _nueva(context),
              icon: const Icon(Icons.add),
              label: const Text('Nueva'),
            )
          : null,
      body: switch (state.status) {
        PreguntasStatus.initial ||
        PreguntasStatus.loading => const EstadoCargando(),
        PreguntasStatus.error => EstadoError(
          mensaje: state.errorMessage ?? 'No se pudieron cargar las preguntas.',
          onReintentar: controller.cargar,
        ),
        PreguntasStatus.ready when state.preguntas.isEmpty => EstadoVacio(
          titulo: 'Este cuestionario no tiene preguntas',
          descripcion:
              'Agregá la primera. Cada opción puede sumar puntos a una o más '
              'categorías vocacionales — eso es lo que arma el perfil del '
              'estudiante.',
          textoAccion: 'Agregar pregunta',
          onAccion: () => _nueva(context),
        ),
        PreguntasStatus.ready => RefreshIndicator(
          onRefresh: controller.cargar,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.xxl * 2,
            ),
            children: [
              for (final Pregunta p in state.preguntas)
                PreguntaTile(
                  pregunta: p,
                  habilitado: !state.guardando,
                  onEditar: () => context.push(
                    '/dashboard/cuestionarios/$cuestionarioId/preguntas/${p.id}',
                  ),
                  onEliminar: () => _eliminar(context, controller, p),
                ),
            ],
          ),
        ),
      },
    );
  }

  void _nueva(BuildContext context) => context.push(
    '/dashboard/cuestionarios/$cuestionarioId/preguntas/nueva',
  );

  Future<void> _eliminar(
    BuildContext context,
    PreguntasController controller,
    Pregunta pregunta,
  ) async {
    final bool confirmado = await confirmarEliminacion(
      context,
      titulo: 'Eliminar pregunta',
      mensaje:
          '¿Seguro que querés eliminarla? Se borran también sus opciones y '
          'los puntos que cada una sumaba por categoría. Esta acción no se '
          'puede deshacer.',
    );
    if (!confirmado) return;

    final String? error = await controller.eliminar(pregunta.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error ?? 'Pregunta eliminada.')));
  }
}
