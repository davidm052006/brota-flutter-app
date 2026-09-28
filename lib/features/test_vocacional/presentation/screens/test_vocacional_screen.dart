import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../cuestionarios/domain/opcion_pregunta.dart';
import '../../../cuestionarios/domain/pregunta.dart';
import '../../../cuestionarios/domain/tipo_pregunta.dart';
import '../../domain/test_vocacional_session.dart';
import '../controllers/test_vocacional_controller.dart';
import '../controllers/test_vocacional_state.dart';
import '../providers/test_vocacional_providers.dart';

class TestVocacionalScreen extends ConsumerStatefulWidget {
  const TestVocacionalScreen({super.key});

  @override
  ConsumerState<TestVocacionalScreen> createState() =>
      _TestVocacionalScreenState();
}

class _TestVocacionalScreenState extends ConsumerState<TestVocacionalScreen> {
  String? _userId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) return;
      _userId = user.id;
      ref.read(testVocacionalControllerProvider.notifier).load(user.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final TestVocacionalState state = ref.watch(
      testVocacionalControllerProvider,
    );
    final TestVocacionalController controller = ref.read(
      testVocacionalControllerProvider.notifier,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Test vocacional')),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.session == null
            ? _TestLoadError(
                message: state.errorMessage ?? 'No se pudo cargar el test.',
                onRetry: _userId == null
                    ? null
                    : () => controller.load(_userId!),
              )
            : state.result != null
            ? _TestResultView(
                result: state.result!,
                onRestart: controller.start,
                onExit: () => context.go('/dashboard'),
              )
            : !state.started
            ? _TestIntroView(session: state.session!, onStart: controller.start)
            : _TestQuestionView(
                state: state,
                controller: controller,
                onExit: () => context.go('/dashboard'),
              ),
      ),
    );
  }
}

class _TestIntroView extends StatelessWidget {
  const _TestIntroView({required this.session, required this.onStart});

  final TestVocacionalSession session;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenMargin),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.eco_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                session.nombreCuestionario,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              if (session.version.isNotEmpty)
                Text('Versión ${session.version}', textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.md),
              Text(
                'No hay respuestas correctas o incorrectas. Responde según lo que realmente te interesa.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: AppSpacing.sm,
                children: [
                  Chip(label: Text('${session.preguntas.length} preguntas')),
                  Chip(label: Text(_roleLabel(session.rol))),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Comenzar test'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TestQuestionView extends StatelessWidget {
  const _TestQuestionView({
    required this.state,
    required this.controller,
    required this.onExit,
  });

  final TestVocacionalState state;
  final TestVocacionalController controller;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final TestVocacionalSession session = state.session!;
    final Pregunta question = state.currentQuestion!;
    final int number = state.currentIndex + 1;
    final List<String> selected = state.answers[question.id] ?? const [];
    final bool multiple = question.tipo == TipoPregunta.opcionMultiple;
    final bool textAnswer =
        question.tipo == TipoPregunta.respuestaCorta ||
        question.tipo == TipoPregunta.respuestaLarga;
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenMargin,
            AppSpacing.md,
            AppSpacing.screenMargin,
            0,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Pregunta $number de ${session.preguntas.length}'),
                  Text(_roleLabel(session.rol)),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              LinearProgressIndicator(value: number / session.preguntas.length),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.screenMargin),
            children: [
              Text(
                question.texto,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                multiple
                    ? 'Puedes elegir varias opciones.'
                    : 'Elige la opción que mejor te represente.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (textAnswer)
                TextFormField(
                  key: ValueKey<String>(question.id),
                  initialValue: selected.isEmpty ? '' : selected.first,
                  minLines: question.tipo == TipoPregunta.respuestaLarga
                      ? 4
                      : 1,
                  maxLines: question.tipo == TipoPregunta.respuestaLarga
                      ? 8
                      : 1,
                  decoration: const InputDecoration(
                    labelText: 'Tu respuesta',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: controller.setTextAnswer,
                )
              else
                for (final OpcionPregunta option in question.opciones)
                  _AnswerOption(
                    option: option,
                    selected: selected.contains(option.id),
                    multiple: multiple,
                    onTap: () => controller.selectOption(option.id ?? ''),
                  ),
              if (state.errorMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  state.errorMessage!,
                  style: TextStyle(color: colors.error),
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenMargin,
            AppSpacing.sm,
            AppSpacing.screenMargin,
            AppSpacing.md,
          ),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: state.currentIndex == 0
                    ? onExit
                    : controller.previous,
                icon: const Icon(Icons.arrow_back),
                label: Text(state.currentIndex == 0 ? 'Salir' : 'Anterior'),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: state.canAdvance && !state.isSaving
                    ? controller.next
                    : null,
                icon: state.isSaving
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        number == session.preguntas.length
                            ? Icons.check
                            : Icons.arrow_forward,
                      ),
                label: Text(
                  state.isSaving
                      ? 'Guardando'
                      : number == session.preguntas.length
                      ? 'Ver resultado'
                      : 'Siguiente',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnswerOption extends StatelessWidget {
  const _AnswerOption({
    required this.option,
    required this.selected,
    required this.multiple,
    required this.onTap,
  });

  final OpcionPregunta option;
  final bool selected;
  final bool multiple;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: selected ? colors.primaryContainer : colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                if (option.icon != null && option.icon!.isNotEmpty) ...[
                  Text(option.icon!, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Expanded(child: Text(option.label)),
                Icon(
                  multiple
                      ? selected
                            ? Icons.check_box
                            : Icons.check_box_outline_blank
                      : selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: selected ? colors.primary : colors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TestResultView extends StatelessWidget {
  const _TestResultView({
    required this.result,
    required this.onRestart,
    required this.onExit,
  });

  final VocationalTestResult result;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenMargin),
      children: [
        Icon(Icons.emoji_events_outlined, size: 48, color: colors.primary),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Tu resultado',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        if (result.categoriaPrincipal != null) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            _categoryLabel(result.categoriaPrincipal!),
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: colors.primary),
          ),
        ],
        if (result.categoriaSecundaria != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            'También te interesa ${_categoryLabel(result.categoriaSecundaria!)}',
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        for (final VocationalTestScore score in result.scores) ...[
          Row(
            children: [
              Expanded(child: Text(_categoryLabel(score.categoria))),
              Text('${score.porcentaje.round()}%'),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          LinearProgressIndicator(value: (score.porcentaje / 100).clamp(0, 1)),
          const SizedBox(height: AppSpacing.md),
        ],
        const SizedBox(height: AppSpacing.md),
        FilledButton.icon(
          onPressed: onRestart,
          icon: const Icon(Icons.replay),
          label: const Text('Realizar de nuevo'),
        ),
        TextButton(onPressed: onExit, child: const Text('Volver al inicio')),
      ],
    );
  }
}

class _TestLoadError extends StatelessWidget {
  const _TestLoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenMargin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.quiz_outlined, size: 42, color: colors.primary),
            const SizedBox(height: AppSpacing.md),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _roleLabel(String role) => switch (role) {
  'admin' => 'Administrador',
  'estudiante' => 'Estudiante',
  'institucion' => 'Institución',
  '' => 'Usuario',
  _ => role[0].toUpperCase() + role.substring(1),
};

String _categoryLabel(String category) =>
    _categoryLabels[category.toLowerCase()] ??
    category
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (String word) =>
              word.isEmpty ? word : word[0].toUpperCase() + word.substring(1),
        )
        .join(' ');

const Map<String, String> _categoryLabels = {
  'tecnologia': 'Tecnología',
  'salud': 'Salud',
  'ciencias': 'Ciencias',
  'diseno': 'Diseño',
  'diseño': 'Diseño',
  'arte': 'Arte',
  'educacion': 'Educación',
  'educación': 'Educación',
  'social': 'Ciencias Sociales',
  'comunicacion': 'Comunicación',
  'comunicación': 'Comunicación',
  'juridico': 'Derecho',
  'jurídico': 'Derecho',
  'negocios': 'Negocios',
  'administrativo': 'Administración',
  'humanidades': 'Humanidades',
  'ambiental': 'Ambiental',
  'deporte': 'Deportes',
};
