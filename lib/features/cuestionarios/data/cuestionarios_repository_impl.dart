import 'package:dio/dio.dart';

import '../../../core/network/api_exception_mapper.dart';
import '../../../core/result/failure.dart';
import '../../../core/result/result.dart';
import '../domain/cuestionario.dart';
import '../domain/cuestionarios_repository.dart';
import '../domain/pregunta.dart';

/// Implementación contra `/api/institucion/*`. Todos los endpoints exigen una
/// sesión con rol `institucion` y quedan scoped server-side a la institución
/// vinculada a la cuenta (`req.institucionId`), así que acá nunca se manda un
/// `institucion_id`.
final class CuestionariosRepositoryImpl implements CuestionariosRepository {
  CuestionariosRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<Result<List<Cuestionario>>> getCuestionarios() {
    return _guard(() async {
      final Response<dynamic> response = await _dio.get<dynamic>(
        '/institucion/cuestionarios',
      );
      return _listaDeDatos(response.data).map(Cuestionario.fromJson).toList();
    });
  }

  @override
  Future<Result<Cuestionario>> crearCuestionario(CuestionarioInput input) {
    return _guard(() async {
      final Response<dynamic> response = await _dio.post<dynamic>(
        '/institucion/cuestionarios',
        data: input.toJson(),
      );
      return Cuestionario.fromJson(_objetoDeDatos(response.data));
    });
  }

  @override
  Future<Result<Cuestionario>> actualizarCuestionario(
    String id,
    CuestionarioInput input,
  ) {
    return _guard(() async {
      final Response<dynamic> response = await _dio.patch<dynamic>(
        '/institucion/cuestionarios/$id',
        data: input.toJson(),
      );
      // El PATCH puede responder solo `{ success, message }`; en ese caso
      // reconstruimos el modelo con lo que acabamos de mandar en vez de pegar
      // otro GET solo para refrescar una fila.
      final Map<String, dynamic> data = _objetoDeDatos(response.data);
      if (data.isEmpty) {
        return Cuestionario(
          id: id,
          nombre: input.nombre,
          version: input.version,
          descripcion: input.descripcion,
          activo: input.activo,
        );
      }
      return Cuestionario.fromJson(data);
    });
  }

  @override
  Future<Result<void>> eliminarCuestionario(String id) {
    return _guard<void>(
      () => _dio.delete<dynamic>('/institucion/cuestionarios/$id'),
    );
  }

  @override
  Future<Result<List<Pregunta>>> getPreguntas(String cuestionarioId) {
    return _guard(() async {
      final Response<dynamic> response = await _dio.get<dynamic>(
        '/institucion/preguntas',
        queryParameters: {'cuestionario_id': cuestionarioId},
      );
      final List<Pregunta> preguntas = _listaDeDatos(response.data)
          .map((json) => Pregunta.fromJson(json, cuestionarioId: cuestionarioId))
          .toList();
      preguntas.sort((a, b) => a.orden.compareTo(b.orden));
      return preguntas;
    });
  }

  @override
  Future<Result<Pregunta>> crearPregunta(PreguntaInput input) {
    return _guard(() async {
      final Response<dynamic> response = await _dio.post<dynamic>(
        '/institucion/preguntas',
        data: input.toJson(),
      );
      return _preguntaDeRespuesta(response.data, input);
    });
  }

  @override
  Future<Result<Pregunta>> actualizarPregunta(String id, PreguntaInput input) {
    return _guard(() async {
      final Response<dynamic> response = await _dio.patch<dynamic>(
        '/institucion/preguntas/$id',
        data: input.toJson(),
      );
      return _preguntaDeRespuesta(response.data, input, id: id);
    });
  }

  @override
  Future<Result<void>> eliminarPregunta(String id) {
    return _guard<void>(
      () => _dio.delete<dynamic>('/institucion/preguntas/$id'),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Envuelve una llamada y traduce todo lo que pueda salir mal a un [Failure]
  /// tipado — ninguna DioException escapa de esta capa.
  Future<Result<T>> _guard<T>(Future<T> Function() operacion) async {
    try {
      return Success(await operacion());
    } on DioException catch (e) {
      return ResultError(_mapear(e));
    } catch (_) {
      return const ResultError(
        UnknownFailure('No se pudo procesar la respuesta del servidor.'),
      );
    }
  }

  /// `mapDioExceptionToFailure` ya extrae el `message` del backend, pero un
  /// 403 acá tiene una causa muy concreta y vale la pena decirla en castellano
  /// de gente en vez de dejar pasar el mensaje genérico de la API.
  Failure _mapear(DioException e) {
    final int? status = e.response?.statusCode;
    if (status == 403) {
      return const AuthFailure(
        'Tu cuenta no tiene rol de institución, así que no puede administrar '
        'cuestionarios. Pedile a un administrador que la vincule a una '
        'institución.',
      );
    }
    if (status == 400) {
      final Failure base = mapDioExceptionToFailure(e);
      // Un 400 acá siempre es dato mal armado (tipo fuera del catálogo, menos
      // de 2 opciones...), no un fallo de servidor: se muestra como validación
      // para que la UI lo trate como corregible.
      return ValidationFailure(base.message);
    }
    return mapDioExceptionToFailure(e);
  }

  /// El backend responde `{ success, data }`; algunas rutas devuelven la lista
  /// pelada. Se acepta cualquiera de las dos formas.
  Iterable<Map<String, dynamic>> _listaDeDatos(Object? body) {
    final Object? data = body is Map<String, dynamic> ? body['data'] : body;
    if (data is! List) return const [];
    return data.whereType<Map<String, dynamic>>();
  }

  Map<String, dynamic> _objetoDeDatos(Object? body) {
    if (body is! Map<String, dynamic>) return const {};
    final Object? data = body['data'];
    if (data is Map<String, dynamic>) return data;
    // `{ success, message }` sin `data` es una confirmación, no el objeto:
    // devolverlo haría que Cuestionario/Pregunta.fromJson armara un modelo
    // vacío con id ''. Solo se acepta el body pelado cuando ni siquiera tiene
    // el envoltorio `success`.
    if (body.containsKey('success') || body.containsKey('data')) {
      return const {};
    }
    return body;
  }

  /// Igual que en el cuestionario: si el PATCH solo confirma, rearmamos la
  /// pregunta desde el input para no forzar un GET extra.
  Pregunta _preguntaDeRespuesta(
    Object? body,
    PreguntaInput input, {
    String? id,
  }) {
    final Map<String, dynamic> data = _objetoDeDatos(body);
    if (data.isEmpty) {
      return Pregunta(
        id: id ?? '',
        cuestionarioId: input.cuestionarioId,
        texto: input.texto,
        tipo: input.tipo,
        orden: input.orden ?? 0,
        categoria: input.categoria,
        peso: input.peso,
        opciones: input.opciones,
      );
    }
    final Pregunta creada = Pregunta.fromJson(
      data,
      cuestionarioId: input.cuestionarioId,
    );
    // El POST devuelve la fila de `preguntas` sin las opciones (se insertan
    // después, en tablas aparte): las completamos con las que mandamos.
    if (creada.opciones.isEmpty && input.opciones.isNotEmpty) {
      return Pregunta(
        id: creada.id,
        cuestionarioId: creada.cuestionarioId,
        texto: creada.texto,
        tipo: creada.tipo,
        orden: creada.orden,
        categoria: creada.categoria,
        peso: creada.peso,
        opciones: input.opciones,
      );
    }
    return creada;
  }
}
