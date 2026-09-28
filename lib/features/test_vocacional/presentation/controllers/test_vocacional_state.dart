import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../cuestionarios/domain/pregunta.dart';
import '../../domain/test_vocacional_session.dart';

part 'test_vocacional_state.freezed.dart';

@freezed
abstract class TestVocacionalState with _$TestVocacionalState {
  const TestVocacionalState._();

  const factory TestVocacionalState({
    @Default(false) bool isLoading,
    @Default(false) bool isSaving,
    @Default(false) bool started,
    TestVocacionalSession? session,
    @Default(0) int currentIndex,
    @Default({}) Map<String, List<String>> answers,
    VocationalTestResult? result,
    String? errorMessage,
  }) = _TestVocacionalState;

  Pregunta? get currentQuestion {
    final TestVocacionalSession? currentSession = session;
    if (currentSession == null || currentSession.preguntas.isEmpty) return null;
    return currentSession.preguntas[currentIndex];
  }

  bool get canAdvance {
    final Pregunta? question = currentQuestion;
    if (question == null) return false;
    final List<String> selected = answers[question.id] ?? const [];
    return selected.any((String answer) => answer.trim().isNotEmpty);
  }
}