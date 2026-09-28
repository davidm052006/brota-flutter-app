import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/result/failure.dart';
import '../../../../core/result/result.dart';
import '../../domain/cuestionarios_repository.dart';
import '../../domain/pregunta.dart';
import '../providers/cuestionarios_providers.dart';

enum PreguntasStatus { initial, loading, ready, error }

final class PreguntasState {
  const PreguntasState({
    this.status = PreguntasStatus.initial,
    this.preguntas = const [],
    this.errorMessage,
    this.guardando = false,
  });

  final PreguntasStatus status;
  final List<Pregunta> preguntas;
  final String? errorMessage;
  final bool guardando;

  bool get estaVacio => status == PreguntasStatus.ready && preguntas.isEmpty;

  PreguntasState copyWith({
    PreguntasStatus? status,
    List<Pregunta>? preguntas,
    String? errorMessage,
    bool? guardando,
  }) {
    return PreguntasState(
      status: status ?? this.status,
      preguntas: preguntas ?? this.preguntas,
      errorMessage: errorMessage,
      guardando: guardando ?? this.guardando,
    );
  }
}

/// Familia por `cuestionarioId`: cada cuestionario tiene su propia lista de
/// preguntas y su propio estado de carga.
final StateNotifierProviderFamily<PreguntasController, PreguntasState, String>
preguntasControllerProvider =
    StateNotifierProvider.family<PreguntasController, PreguntasState, String>(
      (ref, cuestionarioId) => PreguntasController(
        ref.watch(cuestionariosRepositoryProvider),
        cuestionarioId,
      ),
    );

final class PreguntasController extends StateNotifier<PreguntasState> {
  PreguntasController(this._repository, this.cuestionarioId)
    : super(const PreguntasState()) {
    cargar();
  }

  final CuestionariosRepository _repository;
  final String cuestionarioId;

  Future<void> cargar() async {
    state = state.copyWith(status: PreguntasStatus.loading);
    final Result<List<Pregunta>> result = await _repository.getPreguntas(
      cuestionarioId,
    );
    state = result.fold(
      (lista) =>
          state.copyWith(status: PreguntasStatus.ready, preguntas: lista),
      (failure) => state.copyWith(
        status: PreguntasStatus.error,
        errorMessage: failure.message,
      ),
    );
  }

  /// null = salió bien; si no, el mensaje a mostrar sin cerrar el formulario.
  Future<String?> crear(PreguntaInput input) =>
      _escribir(() => _repository.crearPregunta(input));

  Future<String?> actualizar(String id, PreguntaInput input) =>
      _escribir(() => _repository.actualizarPregunta(id, input));

  Future<String?> eliminar(String id) =>
      _escribir(() => _repository.eliminarPregunta(id));

  Future<String?> _escribir(Future<Result<Object?>> Function() operacion) async {
    state = state.copyWith(guardando: true);
    final Result<Object?> result = await operacion();
    final Failure? failure = result.failureOrNull;
    state = state.copyWith(guardando: false);
    if (failure != null) return failure.message;
    await cargar();
    return null;
  }
}
