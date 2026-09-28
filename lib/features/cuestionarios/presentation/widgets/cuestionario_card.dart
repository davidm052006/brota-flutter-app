import 'package:flutter/material.dart';

import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/cuestionario.dart';

class CuestionarioCard extends StatelessWidget {
  const CuestionarioCard({
    required this.cuestionario,
    required this.onAbrir,
    required this.onEditar,
    required this.onEliminar,
    this.habilitado = true,
    super.key,
  });

  final Cuestionario cuestionario;
  final VoidCallback onAbrir;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;
  final bool habilitado;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.lgRadius),
      child: InkWell(
        onTap: habilitado ? onAbrir : null,
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
                      cuestionario.nombre,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  if (cuestionario.activo)
                    Chip(
                      label: const Text('Activo'),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      labelStyle: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                [
                  'Versión ${cuestionario.version}',
                  if (cuestionario.numPreguntas != null)
                    '${cuestionario.numPreguntas} preguntas',
                ].join(' · '),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (cuestionario.descripcion?.isNotEmpty ?? false) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  cuestionario.descripcion!,
                  style: theme.textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: habilitado ? onAbrir : null,
                    icon: const Icon(Icons.list_alt, size: 18),
                    label: const Text('Preguntas'),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Editar',
                    onPressed: habilitado ? onEditar : null,
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    tooltip: 'Eliminar',
                    onPressed: habilitado ? onEliminar : null,
                    icon: Icon(
                      Icons.delete_outline,
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
