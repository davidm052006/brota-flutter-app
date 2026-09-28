import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/cuestionario.dart';
import '../controllers/cuestionarios_controller.dart';
import '../widgets/cuestionario_card.dart';
import '../widgets/estado_placeholders.dart';

/// Lista de los cuestionarios propios de la institución.
///
/// Solo llega acá una cuenta con rol `institucion` — el backend rechaza el
/// resto con 403 y la entrada de navegación ni se muestra.
class CuestionariosScreen extends ConsumerWidget {
  const CuestionariosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CuestionariosState state = ref.watch(cuestionariosControllerProvider);
    final CuestionariosController controller = ref.read(
      cuestionariosControllerProvider.notifier,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Cuestionarios')),
      floatingActionButton: state.status == CuestionariosStatus.ready
          ? FloatingActionButton.extended(
              onPressed: state.guardando
                  ? null
                  : () => context.push('/dashboard/cuestionarios/nuevo'),
              icon: const Icon(Icons.add),
              label: const Text('Nuevo'),
            )
          : null,
      body: switch (state.status) {
        CuestionariosStatus.initial ||
        CuestionariosStatus.loading => const EstadoCargando(),
        CuestionariosStatus.error => EstadoError(
          mensaje: state.errorMessage ?? 'No se pudieron cargar.',
          onReintentar: controller.cargar,
        ),
        CuestionariosStatus.ready when state.cuestionarios.isEmpty =>
          EstadoVacio(
            titulo: 'Todavía no tenés cuestionarios',
            descripcion:
                'Creá uno para armar tu propio test vocacional. Mientras no '
                'actives ninguno, tus estudiantes ven el cuestionario general '
                'de Brota.',
            textoAccion: 'Crear cuestionario',
            onAccion: () => context.push('/dashboard/cuestionarios/nuevo'),
          ),
        CuestionariosStatus.ready => RefreshIndicator(
          onRefresh: controller.cargar,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              // Espacio para que el FAB no tape la última card.
              AppSpacing.xxl * 2,
            ),
            children: [
              for (final Cuestionario c in state.cuestionarios)
                CuestionarioCard(
                  cuestionario: c,
                  habilitado: !state.guardando,
                  // El nombre viaja por `extra` para que la pantalla de
                  // preguntas pueda titularse sin re-pedir el cuestionario.
                  onAbrir: () => context.push(
                    '/dashboard/cuestionarios/${c.id}/preguntas',
                    extra: c.nombre,
                  ),
                  onEditar: () =>
                      context.push('/dashboard/cuestionarios/${c.id}/editar'),
                  onEliminar: () => _eliminar(context, controller, c),
                ),
            ],
          ),
        ),
      },
    );
  }

  Future<void> _eliminar(
    BuildContext context,
    CuestionariosController controller,
    Cuestionario cuestionario,
  ) async {
    final bool confirmado = await confirmarEliminacion(
      context,
      titulo: 'Eliminar cuestionario',
      mensaje:
          '¿Seguro que querés eliminar "${cuestionario.nombre}"? '
          'Se borran también todas sus preguntas, con sus opciones y pesos. '
          'Esta acción no se puede deshacer.',
    );
    if (!confirmado) return;

    final String? error = await controller.eliminar(cuestionario.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Cuestionario eliminado.'),
      ),
    );
  }
}
