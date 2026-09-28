import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/result/result.dart';
import '../../../cuestionarios/domain/pregunta.dart';
import '../../../cuestionarios/domain/tipo_pregunta.dart';
import '../../domain/test_vocacional_repository.dart';
import '../../domain/test_vocacional_session.dart';
import 'test_vocacional_state.dart';

final class TestVocacionalController
    extends StateNotifier<TestVocacionalState> {
  TestVocacionalController(this._repository)
    : super(const TestVocacionalState(isLoading: true));

  final TestVocacionalRepository _repository;

  Future<void> load(String userId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final Result<TestVocacionalSession> result = await _repository.cargarTest(
      userId,
    );
    switch (result) {
      case Success<TestVocacionalSession>(:final value):
        state = TestVocacionalState(session: value);
      case ResultError<TestVocacionalSession>(:final failure):
        state = TestVocacionalState(errorMessage: failure.message);
    }
  }

  void start() {
    state = state.copyWith(
      started: true,
      currentIndex: 0,
      answers: const {},
      result: null,
      errorMessage: null,
    );
  }

  void selectOption(String optionId) {
    final Pregunta? question = state.currentQuestion;
    if (question == null) return;
    final List<String> selected = state.answers[question.id] ?? const [];
    final List<String> updated;
    if (question.tipo == TipoPregunta.opcionMultiple) {
      updated = selected.contains(optionId)
          ? selected.where((String id) => id != optionId).toList()
          : [...selected, optionId];
    } else {
      updated = [optionId];
    }
    state = state.copyWith(
      answers: {...state.answers, question.id: updated},
      errorMessage: null,
    );
  }

  void setTextAnswer(String value) {
    final Pregunta? question = state.currentQuestion;
    if (question == null) return;
    state = state.copyWith(
      answers: {
        ...state.answers,
        question.id: [value],
      },
      errorMessage: null,
    );
  }

  void previous() {
    if (state.currentIndex == 0 || state.isSaving) return;
    state = state.copyWith(currentIndex: state.currentIndex - 1);
  }

  Future<void> next() async {
    final TestVocacionalSession? session = state.session;
    if (session == null || !state.canAdvance || state.isSaving) return;
    if (state.currentIndex < session.preguntas.length - 1) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
      return;
    }

    state = state.copyWith(isSaving: true, errorMessage: null);
    final Result<VocationalTestResult> result = await _repository
        .guardarResultado(
          perfilId: session.perfilId,
          cuestionarioId: session.cuestionarioId,
          respuestas: state.answers,
        );
    switch (result) {
      case Success<VocationalTestResult>(:final value):
        state = state.copyWith(isSaving: false, result: value);
      case ResultError<VocationalTestResult>(:final failure):
        state = state.copyWith(isSaving: false, errorMessage: failure.message);
    }
  }
}
