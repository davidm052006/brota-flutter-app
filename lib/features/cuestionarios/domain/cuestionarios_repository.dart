import '../../../core/result/result.dart';
import 'cuestionario.dart';
import 'pregunta.dart';

/// Contrato del CRUD de cuestionarios y preguntas de una institución.
///
/// La implementación (`CuestionariosRepositoryImpl`, en `data/`) habla con
/// `/api/institucion/*` vía Dio — **no** con `/api/admin/*`: aunque el panel
/// admin tiene endpoints con el mismo nombre, su CRUD de preguntas solo
/// escribe la columna legada `preguntas.opciones` (JSONB), que el motor del
/// test no lee, así que una pregunta creada por ahí no puntúa nada.
///
/// Ver `README.md` de esta carpeta para el mapeo método → endpoint.
abstract class CuestionariosRepository {
  Future<Result<List<Cuestionario>>> getCuestionarios();

  Future<Result<Cuestionario>> crearCuestionario(CuestionarioInput input);

  Future<Result<Cuestionario>> actualizarCuestionario(
    String id,
    CuestionarioInput input,
  );

  Future<Result<void>> eliminarCuestionario(String id);

  Future<Result<List<Pregunta>>> getPreguntas(String cuestionarioId);

  Future<Result<Pregunta>> crearPregunta(PreguntaInput input);

  /// Reemplaza las opciones de la pregunta por las de [input] — el backend
  /// borra las filas viejas de `opciones`/`pesos_opciones` y reinserta.
  Future<Result<Pregunta>> actualizarPregunta(String id, PreguntaInput input);

  Future<Result<void>> eliminarPregunta(String id);
}
