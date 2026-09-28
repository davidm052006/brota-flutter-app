import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/result/failure.dart';
import '../../../../core/result/result.dart';
import '../../domain/cuestionario.dart';
import '../../domain/cuestionarios_repository.dart';
import '../providers/cuestionarios_providers.dart';

enum CuestionariosStatus { initial, loading, ready, error }

final class CuestionariosState {
  const CuestionariosState({
    this.status = CuestionariosStatus.initial,
    this.cuestionarios = const [],
    this.errorMessage,
    this.guardando = false,
  });

  final CuestionariosStatus status;
  final List<Cuestionario> cuestionarios;
  final String? errorMessage;

  /// Se separa de [status] a propósito: mientras se guarda o se borra, la
  /// lista sigue en pantalla con sus datos — solo se deshabilitan las acciones.
  final bool guardando;

  bool get estaVacio =>
      status == CuestionariosStatus.ready && cuestionarios.isEmpty;

  CuestionariosState copyWith({
    CuestionariosStatus? status,
    List<Cuestionario>? cuestionarios,
    String? errorMessage,
    bool? guardando,
  }) {
    return CuestionariosState(
      status: status ?? this.status,
      cuestionarios: cuestionarios ?? this.cuestionarios,
      errorMessage: errorMessage,
      guardando: guardando ?? this.guardando,
    );
  }
}

final StateNotifierProvider<CuestionariosController, CuestionariosState>
cuestionariosControllerProvider =
    StateNotifierProvider<CuestionariosController, CuestionariosState>(
      (ref) => CuestionariosController(
        ref.watch(cuestionariosRepositoryProvider),
      ),
    );

final class CuestionariosController extends StateNotifier<CuestionariosState> {
  CuestionariosController(this._repository)
    : super(const CuestionariosState()) {
    cargar();
  }

  final CuestionariosRepository _repository;

  Future<void> cargar() async {
    state = state.copyWith(status: CuestionariosStatus.loading);
    final Result<List<Cuestionario>> result = await _repository
        .getCuestionarios();
    state = result.fold(
      (lista) => state.copyWith(
        status: CuestionariosStatus.ready,
        cuestionarios: lista,
      ),
      (failure) => state.copyWith(
        status: CuestionariosStatus.error,
        errorMessage: failure.message,
      ),
    );
  }

  /// Devuelve el mensaje de error, o `null` si salió bien — así la pantalla
  /// decide si cierra el formulario o muestra el error sin perder lo tipeado.
  Future<String?> crear(CuestionarioInput input) =>
      _escribir(() => _repository.crearCuestionario(input));

  Future<String?> actualizar(String id, CuestionarioInput input) =>
      _escribir(() => _repository.actualizarCuestionario(id, input));

  Future<String?> eliminar(String id) =>
      _escribir(() => _repository.eliminarCuestionario(id));

  Future<String?> _escribir(Future<Result<Object?>> Function() operacion) async {
    state = state.copyWith(guardando: true);
    final Result<Object?> result = await operacion();
    final Failure? failure = result.failureOrNull;
    state = state.copyWith(guardando: false);
    if (failure != null) return failure.message;
    // Recargamos en vez de parchear la lista en memoria: activar un
    // cuestionario desactiva los otros del lado del servidor, así que el
    // estado local quedaría desincronizado.
    await cargar();
    return null;
  }
}
