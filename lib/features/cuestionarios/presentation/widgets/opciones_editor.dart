import 'package:flutter/material.dart';

import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/categoria_vocacional.dart';
import '../../domain/opcion_pregunta.dart';
import '../../domain/tipo_pregunta.dart';

/// Editor de la lista de opciones de una pregunta: texto, emoji, orden y el
/// mapa de pesos por categoría vocacional.
///
/// Es la parte que de verdad hace que una pregunta puntúe: los pesos terminan
/// en `pesos_opciones`, la tabla que el motor del test lee para armar el
/// perfil. Una opción sin ningún peso es válida (no suma nada), pero una
/// pregunta entera sin pesos no mueve la aguja de ninguna categoría.
class OpcionesEditor extends StatelessWidget {
  const OpcionesEditor({
    required this.opciones,
    required this.tipo,
    required this.onChanged,
    this.habilitado = true,
    super.key,
  });

  final List<OpcionPregunta> opciones;
  final TipoPregunta tipo;
  final ValueChanged<List<OpcionPregunta>> onChanged;
  final bool habilitado;

  static const int minimoOpciones = 2;

  void _reemplazar(int index, OpcionPregunta nueva) {
    final List<OpcionPregunta> copia = [...opciones];
    copia[index] = nueva;
    onChanged(copia);
  }

  void _quitar(int index) {
    final List<OpcionPregunta> copia = [...opciones]..removeAt(index);
    onChanged(copia);
  }

  void _agregar() {
    onChanged([
      ...opciones,
      OpcionPregunta(label: '', orden: opciones.length),
    ]);
  }

  void _mover(int index, int delta) {
    final int destino = index + delta;
    if (destino < 0 || destino >= opciones.length) return;
    final List<OpcionPregunta> copia = [...opciones];
    final OpcionPregunta movida = copia.removeAt(index);
    copia.insert(destino, movida);
    onChanged(copia);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool avisoLikert =
        tipo == TipoPregunta.likert &&
        opciones.length != TipoPregunta.opcionesEsperadasLikert;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Opciones', style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Cada opción puede sumar puntos a una o más categorías. '
          'Mínimo $minimoOpciones opciones para poder guardar.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (avisoLikert) ...[
          const SizedBox(height: AppSpacing.sm),
          // Advertencia, no bloqueo: el backend acepta cualquier cantidad ≥ 2,
          // y la escala del web se degrada sola si no son 5.
          _Aviso(
            texto:
                'La escala Likert se ve mejor con '
                '${TipoPregunta.opcionesEsperadasLikert} opciones; ahora hay '
                '${opciones.length}.',
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        for (final (int i, OpcionPregunta opcion) in opciones.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _OpcionCard(
              key: ValueKey<String>(opcion.id ?? 'nueva-$i'),
              indice: i,
              total: opciones.length,
              opcion: opcion,
              habilitado: habilitado,
              puedeQuitar: opciones.length > minimoOpciones,
              onChanged: (nueva) => _reemplazar(i, nueva),
              onQuitar: () => _quitar(i),
              onSubir: () => _mover(i, -1),
              onBajar: () => _mover(i, 1),
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: habilitado ? _agregar : null,
            icon: const Icon(Icons.add),
            label: const Text('Agregar opción'),
          ),
        ),
      ],
    );
  }
}

class _OpcionCard extends StatelessWidget {
  const _OpcionCard({
    required this.indice,
    required this.total,
    required this.opcion,
    required this.habilitado,
    required this.puedeQuitar,
    required this.onChanged,
    required this.onQuitar,
    required this.onSubir,
    required this.onBajar,
    super.key,
  });

  final int indice;
  final int total;
  final OpcionPregunta opcion;
  final bool habilitado;
  final bool puedeQuitar;
  final ValueChanged<OpcionPregunta> onChanged;
  final VoidCallback onQuitar;
  final VoidCallback onSubir;
  final VoidCallback onBajar;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: AppRadii.lgRadius,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Opción ${indice + 1}',
                style: theme.textTheme.labelLarge,
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Subir',
                onPressed: habilitado && indice > 0 ? onSubir : null,
                icon: const Icon(Icons.arrow_upward, size: 18),
              ),
              IconButton(
                tooltip: 'Bajar',
                onPressed: habilitado && indice < total - 1 ? onBajar : null,
                icon: const Icon(Icons.arrow_downward, size: 18),
              ),
              IconButton(
                tooltip: puedeQuitar
                    ? 'Quitar opción'
                    : 'Se necesitan al menos ${OpcionesEditor.minimoOpciones}',
                onPressed: habilitado && puedeQuitar ? onQuitar : null,
                icon: Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: puedeQuitar ? theme.colorScheme.error : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 76,
                child: TextFormField(
                  initialValue: opcion.icon ?? '',
                  enabled: habilitado,
                  decoration: const InputDecoration(
                    labelText: 'Emoji',
                    hintText: '🎨',
                  ),
                  onChanged: (v) => onChanged(opcion.copyWith(icon: v)),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextFormField(
                  initialValue: opcion.label,
                  enabled: habilitado,
                  decoration: const InputDecoration(labelText: 'Texto *'),
                  onChanged: (v) => onChanged(opcion.copyWith(label: v)),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _PesosEditor(
            pesos: opcion.pesos,
            habilitado: habilitado,
            onChanged: (pesos) => onChanged(opcion.copyWith(pesos: pesos)),
          ),
        ],
      ),
    );
  }
}

/// Mapa `categoria -> puntos`. Se muestra como chips de lo ya asignado más un
/// selector para sumar una categoría nueva, en vez de 15 campos numéricos
/// siempre visibles (la mayoría de las opciones puntúa 1 o 2 categorías).
class _PesosEditor extends StatelessWidget {
  const _PesosEditor({
    required this.pesos,
    required this.habilitado,
    required this.onChanged,
  });

  final Map<String, int> pesos;
  final bool habilitado;
  final ValueChanged<Map<String, int>> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<({String value, String label})> disponibles =
        CategoriaVocacional.opciones
            .where((c) => !pesos.containsKey(c.value))
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Puntos por categoría',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        if (pesos.isEmpty)
          Text(
            'Sin puntos: esta opción no suma a ninguna categoría.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        for (final MapEntry<String, int> entrada in pesos.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    CategoriaVocacional.labelDe(entrada.key),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                SizedBox(
                  width: 72,
                  child: TextFormField(
                    initialValue: '${entrada.value}',
                    enabled: habilitado,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      isDense: true,
                      labelText: 'Pts',
                    ),
                    onChanged: (v) {
                      final int puntos = int.tryParse(v) ?? 0;
                      final Map<String, int> copia = {...pesos};
                      // 0 o menos = quitar: el backend filtra los pesos que no
                      // son positivos, así que guardarlos no tendría efecto.
                      if (puntos > 0) {
                        copia[entrada.key] = puntos;
                      } else {
                        copia.remove(entrada.key);
                      }
                      onChanged(copia);
                    },
                  ),
                ),
                IconButton(
                  tooltip: 'Quitar categoría',
                  onPressed: habilitado
                      ? () => onChanged({...pesos}..remove(entrada.key))
                      : null,
                  icon: const Icon(Icons.close, size: 16),
                ),
              ],
            ),
          ),
        if (disponibles.isNotEmpty)
          DropdownButtonFormField<String>(
            isExpanded: true,
            decoration: const InputDecoration(
              isDense: true,
              labelText: 'Agregar categoría',
            ),
            items: [
              for (final c in disponibles)
                DropdownMenuItem<String>(value: c.value, child: Text(c.label)),
            ],
            onChanged: habilitado
                ? (value) {
                    if (value == null) return;
                    onChanged({...pesos, value: 1});
                  }
                : null,
          ),
      ],
    );
  }
}

class _Aviso extends StatelessWidget {
  const _Aviso({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: AppRadii.mdRadius,
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: theme.colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              texto,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
