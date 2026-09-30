import 'package:flutter/material.dart';

import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/pregunta.dart';
import '../../domain/tipo_pregunta.dart';

class PreguntaTile extends StatelessWidget {
  const PreguntaTile({
    required this.pregunta,
    required this.onEditar,
    required this.onEliminar,
    this.habilitado = true,
    super.key,
  });

  final Pregunta pregunta;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;
  final bool habilitado;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.lgRadius),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    pregunta.texto,
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
                IconButton(
                  tooltip: 'Editar',
                  onPressed: habilitado ? onEditar : null,
                  icon: const Icon(Icons.edit_outlined, size: 20),
                ),
                IconButton(
                  tooltip: 'Eliminar',
                  onPressed: habilitado ? onEliminar : null,
                  icon: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _Badge(
                  texto: pregunta.tipo.label,
                  color: _colorDeTipo(theme.colorScheme, pregunta.tipo),
                  onColor: theme.colorScheme.onSurface,
                ),
                Text(
                  '${pregunta.opciones.length} opciones',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (pregunta.categoria?.isNotEmpty ?? false)
                  Text(
                    pregunta.categoria!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Un tinte por tipo derivado del esquema, no colores sueltos: así el badge
  /// sigue al tema claro/oscuro sin una tabla de hex propia.
  Color _colorDeTipo(ColorScheme scheme, TipoPregunta tipo) {
    return switch (tipo) {
      TipoPregunta.opcionUnica => scheme.primaryContainer,
      TipoPregunta.opcionMultiple => scheme.secondaryContainer,
      TipoPregunta.likert => scheme.tertiaryContainer,
    };
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.texto,
    required this.color,
    required this.onColor,
  });

  final String texto;
  final Color color;
  final Color onColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs / 2,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadii.fullRadius,
      ),
      child: Text(
        texto,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: onColor),
      ),
    );
  }
}
