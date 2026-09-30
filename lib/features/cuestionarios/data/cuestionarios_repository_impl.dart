import 'package:dio/dio.dart';

import '../../../core/network/api_exception_mapper.dart';
import '../../../core/result/failure.dart';
import '../../../core/result/result.dart';
import '../domain/cuestionario.dart';
import '../domain/cuestionarios_repository.dart';
import '../domain/pregunta.dart';

final class CuestionariosRepositoryImpl implements CuestionariosRepository {
  CuestionariosRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<Result<List<Cuestionario>>> getCuestionarios() =>
      _execute<List<Cuestionario>>(() async {
        final Response<Map<String, dynamic>> response = await _dio
            .get<Map<String, dynamic>>('/institucion/cuestionarios');
        final Object? rawData = response.data?['data'];
        if (rawData is! List<dynamic>) {
          throw const FormatException('Respuesta de cuestionarios inválida.');
        }
        return rawData
            .map((item) => Cuestionario.fromJson(item as Map<String, dynamic>))
            .toList();
      });

  @override
  Future<Result<Cuestionario>> crearCuestionario(NuevoCuestionario input) =>
      _execute<Cuestionario>(() async {
        final Response<Map<String, dynamic>> response = await _dio
            .post<Map<String, dynamic>>(
              '/institucion/cuestionarios',
              data: input.toApi(),
            );
        return Cuestionario.fromJson(_responseData(response));
      });

  @override
  Future<Result<Cuestionario>> actualizarCuestionario(
    String id,
    ActualizarCuestionario input,
  ) => _execute<Cuestionario>(() async {
    await _dio.patch<Map<String, dynamic>>(
      '/institucion/cuestionarios/$id',
      data: input.toApi(),
    );
    return Cuestionario(
      id: id,
      nombre: input.nombre,
      version: input.version,
      descripcion: input.descripcion,
      activo: input.activo,
      numPreguntas: input.numPreguntas,
    );
  });

  @override
  Future<Result<void>> eliminarCuestionario(String id) => _execute<void>(
    () async {
      await _dio.delete<Map<String, dynamic>>('/institucion/cuestionarios/$id');
    },
  );

  @override
  Future<Result<List<Pregunta>>> getPreguntas(String cuestionarioId) =>
      _execute<List<Pregunta>>(() async {
        final Response<Map<String, dynamic>> response = await _dio
            .get<Map<String, dynamic>>(
              '/institucion/preguntas',
              queryParameters: {'cuestionario_id': cuestionarioId},
            );
        final Object? rawData = response.data?['data'];
        if (rawData is! List<dynamic>) {
          throw const FormatException('Respuesta de preguntas inválida.');
        }
        return rawData
            .map((item) => Pregunta.fromJson(item as Map<String, dynamic>))
            .toList();
      });

  @override
  Future<Result<Pregunta>> crearPregunta(NuevaPregunta input) =>
      _execute<Pregunta>(() async {
        final Response<Map<String, dynamic>> response = await _dio
            .post<Map<String, dynamic>>(
              '/institucion/preguntas',
              data: input.toApi(),
            );
        final Map<String, dynamic> created = _responseData(response);
        return Pregunta(
          id: created['id'] as String,
          cuestionarioId: input.cuestionarioId,
          texto: input.texto,
          tipo: input.tipo,
          orden: input.orden,
          categoria: input.categoria,
          peso: input.peso,
          opciones: input.opciones,
        );
      });

  @override
  Future<Result<Pregunta>> actualizarPregunta(
    String id,
    ActualizarPregunta input,
  ) => _execute<Pregunta>(() async {
    await _dio.patch<Map<String, dynamic>>(
      '/institucion/preguntas/$id',
      data: input.toApi(),
    );
    return Pregunta(
      id: id,
      cuestionarioId: input.cuestionarioId,
      texto: input.texto,
      tipo: input.tipo,
      orden: input.orden,
      categoria: input.categoria,
      peso: input.peso,
      opciones: input.opciones,
    );
  });

  @override
  Future<Result<void>> eliminarPregunta(String id) => _execute<void>(() async {
    await _dio.delete<Map<String, dynamic>>('/institucion/preguntas/$id');
  });

  Future<Result<T>> _execute<T>(Future<T> Function() request) async {
    try {
      return Success<T>(await request());
    } on DioException catch (error) {
      return ResultError<T>(_mapDioFailure(error));
    } catch (_) {
      return ResultError<T>(const UnknownFailure());
    }
  }

  Failure _mapDioFailure(DioException error) {
    final Failure failure = mapDioExceptionToFailure(error);
    if (error.response?.statusCode == 403 &&
        failure.message.startsWith('Error del servidor (403)')) {
      return const AuthFailure(
        'Necesitas una cuenta vinculada a una institución para gestionar cuestionarios.',
      );
    }
    return failure;
  }

  Map<String, dynamic> _responseData(Response<Map<String, dynamic>> response) {
    final Object? data = response.data?['data'];
    if (data is Map<String, dynamic>) return data;
    throw const FormatException('Respuesta del servidor inválida.');
  }
}
