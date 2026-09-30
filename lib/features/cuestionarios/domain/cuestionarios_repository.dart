import '../../../core/result/result.dart';
import 'cuestionario.dart';
import 'pregunta.dart';

abstract interface class CuestionariosRepository {
  Future<Result<List<Cuestionario>>> getCuestionarios();

  Future<Result<Cuestionario>> crearCuestionario(NuevoCuestionario input);

  Future<Result<Cuestionario>> actualizarCuestionario(
    String id,
    ActualizarCuestionario input,
  );

  Future<Result<void>> eliminarCuestionario(String id);

  Future<Result<List<Pregunta>>> getPreguntas(String cuestionarioId);

  Future<Result<Pregunta>> crearPregunta(NuevaPregunta input);

  Future<Result<Pregunta>> actualizarPregunta(
    String id,
    ActualizarPregunta input,
  );

  Future<Result<void>> eliminarPregunta(String id);
}
