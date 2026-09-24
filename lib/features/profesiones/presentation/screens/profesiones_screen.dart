import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/brota_icon_badge.dart';
import '../../domain/programa.dart';
import '../../domain/programas_stats.dart';
import '../controllers/programas_controller.dart';
import '../controllers/programas_state.dart';

/// `/dashboard/profesiones` — ver `frontend/src/pages/dashboard/
/// Profesiones.jsx` y `FUNCTIONAL_CONTENT_BRIEF.md` sección 2.
///
/// 4 de las 14 categorías académicas tienen ícono propio de marca
/// (`assets/icons/icon-categoria-*.svg`); el resto usa el mismo emoji
/// que ya usa el web — no hay una fuente de íconos única entre
/// features, a propósito (ver la nota de la sección 2 del brief).
const Map<String, String> _areaEmoji = {
  'tecnologia': '💻',
  'salud': '🩺',
  'ciencias': '🔬',
  'diseño': '🎨',
  'arte': '🎭',
  'educacion': '🎓',
  'social': '🤝',
  'comunicacion': '📡',
  'juridico': '⚖️',
  'negocios': '📈',
  'administrativo': '🏛️',
  'humanidades': '📖',
  'ambiental': '🌱',
  'deporte': '⚽',
};

const Map<String, String> _areaIconAsset = {
  'tecnologia': 'assets/icons/icon-categoria-tecnologia.svg',
  'salud': 'assets/icons/icon-categoria-salud.svg',
  'ciencias': 'assets/icons/icon-categoria-ciencias.svg',
  'arte': 'assets/icons/icon-categoria-arte.svg',
};

const List<String> _modalidades = ['Presencial', 'A distancia', 'Virtual'];

class ProfesionesScreen extends ConsumerWidget {
  const ProfesionesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ProgramasState state = ref.watch(programasControllerProvider);
    final ColorScheme scheme = Theme.of(context).colorScheme;

    final List<Programa> visibleProgramas = state.modalidad == null
        ? state.programas
        : state.programas
              .where((p) => p.modalidad == state.modalidad)
              .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Explorar profesiones')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenMargin,
                AppSpacing.md,
                AppSpacing.screenMargin,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SearchField(onChanged: (query) {
                    ref
                        .read(programasControllerProvider.notifier)
                        .onSearchChanged(query);
                  }),
                  const SizedBox(height: AppSpacing.md),
                  if (state.stats != null)
                    _AreaChipsRow(
                      areas: state.stats!.areas,
                      selected: state.area,
                      onSelected: (area) => ref
                          .read(programasControllerProvider.notifier)
                          .onAreaSelected(area),
                    ),
                  const SizedBox(height: AppSpacing.sm),
                  _ModalidadChipsRow(
                    selected: state.modalidad,
                    onSelected: (modalidad) => ref
                        .read(programasControllerProvider.notifier)
                        .onModalidadSelected(modalidad),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
            Expanded(
              child: switch (state.status) {
                ProgramasStatus.loading => const Center(
                  child: CircularProgressIndicator(),
                ),
                ProgramasStatus.error => _ErrorView(
                  message: state.errorMessage ?? 'Ocurrió un error inesperado.',
                  onRetry: () =>
                      ref.read(programasControllerProvider.notifier).loadInitial(),
                ),
                ProgramasStatus.idle || ProgramasStatus.loadingMore =>
                  visibleProgramas.isEmpty
                      ? const _EmptyView()
                      : _ProgramasList(
                          programas: visibleProgramas,
                          total: state.total,
                          canLoadMore: state.page < state.totalPages,
                          isLoadingMore: state.status == ProgramasStatus.loadingMore,
                          onLoadMore: () =>
                              ref.read(programasControllerProvider.notifier).loadMore(),
                        ),
              },
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenMargin,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: scheme.outlineVariant)),
              ),
              child: Text(
                'Datos oficiales del Ministerio de Educación Nacional — '
                'Programas activos del SNIES · fuente: datos.gov.co · '
                'licencia CC-BY-SA 4.0',
                style: AppTypography.labelMd(scheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return TextField(
      onChanged: onChanged,
      style: AppTypography.bodyMd(scheme.onSurface),
      decoration: InputDecoration(
        hintText: 'Buscar programas o instituciones',
        hintStyle: AppTypography.bodyMd(scheme.onSurfaceVariant),
        prefixIcon: Icon(Icons.search, color: scheme.onSurfaceVariant),
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        border: const OutlineInputBorder(
          borderRadius: AppRadii.xlRadius,
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _AreaChipsRow extends StatelessWidget {
  const _AreaChipsRow({
    required this.areas,
    required this.selected,
    required this.onSelected,
  });

  final List<AreaCount> areas;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: areas.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final AreaCount area = areas[index];
          final String key = area.area;
          final int count = area.count;
          final bool isSelected = selected == key;
          final String? iconAsset = _areaIconAsset[key];

          return ChoiceChip(
            selected: isSelected,
            onSelected: (_) => onSelected(isSelected ? null : key),
            avatar: iconAsset != null
                ? BrotaIconBadge(assetPath: iconAsset, size: 20, iconPadding: 3)
                : Text(_areaEmoji[key] ?? '🌟'),
            label: Text('${_capitalize(key)} ($count)'),
            labelStyle: AppTypography.labelMd(
              isSelected ? scheme.onPrimary : scheme.onSurface,
            ),
            selectedColor: scheme.primary,
            backgroundColor: scheme.surfaceContainerLowest,
            shape: const RoundedRectangleBorder(borderRadius: AppRadii.fullRadius),
          );
        },
      ),
    );
  }
}

class _ModalidadChipsRow extends StatelessWidget {
  const _ModalidadChipsRow({required this.selected, required this.onSelected});

  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: AppSpacing.sm,
      children: [
        for (final String modalidad in _modalidades)
          ChoiceChip(
            selected: selected == modalidad,
            onSelected: (_) =>
                onSelected(selected == modalidad ? null : modalidad),
            label: Text(modalidad),
            labelStyle: AppTypography.labelMd(
              selected == modalidad ? scheme.onPrimary : scheme.onSurface,
            ),
            selectedColor: scheme.primary,
            backgroundColor: scheme.surfaceContainerLowest,
            shape: const RoundedRectangleBorder(borderRadius: AppRadii.fullRadius),
          ),
      ],
    );
  }
}

class _ProgramasList extends StatelessWidget {
  const _ProgramasList({
    required this.programas,
    required this.total,
    required this.canLoadMore,
    required this.isLoadingMore,
    required this.onLoadMore,
  });

  final List<Programa> programas;
  final int total;
  final bool canLoadMore;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenMargin,
        AppSpacing.sm,
        AppSpacing.screenMargin,
        AppSpacing.lg,
      ),
      children: [
        Text(
          '$total programas',
          style: AppTypography.headlineMd(scheme.onSurface),
        ),
        const SizedBox(height: AppSpacing.md),
        for (final Programa programa in programas) ...[
          _ProgramaCard(programa: programa),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (canLoadMore)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: OutlinedButton(
              onPressed: isLoadingMore ? null : onLoadMore,
              child: isLoadingMore
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : const Text('Cargar más'),
            ),
          ),
      ],
    );
  }
}

class _ProgramaCard extends StatelessWidget {
  const _ProgramaCard({required this.programa});

  final Programa programa;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: AppRadii.xlRadius,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            programa.nombre,
            style: AppTypography.bodyLg(scheme.onSurface).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            programa.institucionNombre,
            style: AppTypography.bodyMd(scheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              _MetaChip(label: _capitalize(programa.areaAcademica)),
              if (programa.modalidad.isNotEmpty)
                _MetaChip(label: programa.modalidad),
              if (programa.duracion.isNotEmpty)
                _MetaChip(label: programa.duracion),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: AppRadii.fullRadius,
      ),
      child: Text(label, style: AppTypography.labelMd(scheme.onPrimaryContainer)),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BrotaIconBadge(
              assetPath: 'assets/icons/logo-triste.svg',
              size: 64,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTypography.bodyMd(scheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(
          'No encontramos programas con esos filtros.',
          style: AppTypography.bodyMd(scheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

String _capitalize(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1);
}
