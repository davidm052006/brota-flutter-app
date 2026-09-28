import 'package:brota_flutter_app/core/result/failure.dart';
import 'package:brota_flutter_app/core/result/result.dart';
import 'package:brota_flutter_app/features/cuestionarios/data/cuestionarios_repository_impl.dart';
import 'package:brota_flutter_app/features/cuestionarios/domain/cuestionario.dart';
import 'package:brota_flutter_app/features/cuestionarios/domain/opcion_pregunta.dart';
import 'package:brota_flutter_app/features/cuestionarios/domain/pregunta.dart';
import 'package:brota_flutter_app/features/cuestionarios/domain/tipo_pregunta.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio dio;
  late CuestionariosRepositoryImpl repository;

  setUp(() {
    dio = _MockDio();
    repository = CuestionariosRepositoryImpl(dio);
  });

  group('TipoPregunta', () {
    test('normaliza los alias legado y usa opción única como fallback', () {
      expect(TipoPregunta.fromApi('single'), TipoPregunta.opcionUnica);
      expect(TipoPregunta.fromApi('seleccion'), TipoPregunta.opcionUnica);
      expect(TipoPregunta.fromApi('multiple'), TipoPregunta.opcionMultiple);
      expect(TipoPregunta.fromApi('legacy_unknown'), TipoPregunta.opcionUnica);
      expect(TipoPregunta.opcionMultiple.toApi(), 'opcion_multiple');
    });
  });

  group('cuestionarios', () {
    test('lista cuestionarios institucionales', () async {
      when(
        () => dio.get<Map<String, dynamic>>('/institucion/cuestionarios'),
      ).thenAnswer(
        (_) async => _response('/institucion/cuestionarios', {
          'success': true,
          'data': [_questionnaireJson],
        }),
      );

      final Result<List<Cuestionario>> result = await repository
          .getCuestionarios();

      expect(result.valueOrNull?.single.numPreguntas, 3);
    });

    test('mapea el error al listar cuestionarios', () async {
      when(
        () => dio.get<Map<String, dynamic>>('/institucion/cuestionarios'),
      ).thenThrow(_networkError('/institucion/cuestionarios'));

      final Result<List<Cuestionario>> result = await repository
          .getCuestionarios();

      expect(result.failureOrNull, isA<NetworkFailure>());
    });

    test('crea un cuestionario y lo convierte desde la respuesta', () async {
      const NuevoCuestionario input = NuevoCuestionario(
        nombre: 'RIASEC',
        version: '2',
        descripcion: 'Orientación vocacional',
      );
      when(
        () => dio.post<Map<String, dynamic>>(
          '/institucion/cuestionarios',
          data: input.toApi(),
        ),
      ).thenAnswer(
        (_) async => _response('/institucion/cuestionarios', {
          'success': true,
          'data': _questionnaireJson,
        }, statusCode: 201),
      );

      final Result<Cuestionario> result = await repository.crearCuestionario(
        input,
      );

      expect(result.valueOrNull?.id, 'questionnaire-1');
    });

    test('mapea el error al crear un cuestionario', () async {
      const NuevoCuestionario input = NuevoCuestionario(
        nombre: 'RIASEC',
        version: '2',
      );
      when(
        () => dio.post<Map<String, dynamic>>(
          '/institucion/cuestionarios',
          data: input.toApi(),
        ),
      ).thenThrow(_serverError('/institucion/cuestionarios'));

      final Result<Cuestionario> result = await repository.crearCuestionario(
        input,
      );

      expect(result.failureOrNull, isA<ServerFailure>());
    });

    test('actualiza y devuelve el cuestionario enviado', () async {
      const ActualizarCuestionario input = ActualizarCuestionario(
        nombre: 'RIASEC actualizado',
        version: '3',
        activo: true,
        numPreguntas: 3,
      );
      when(
        () => dio.patch<Map<String, dynamic>>(
          '/institucion/cuestionarios/questionnaire-1',
          data: input.toApi(),
        ),
      ).thenAnswer(
        (_) async => _response('/institucion/cuestionarios/questionnaire-1', {
          'success': true,
          'message': 'Cuestionario actualizado',
        }),
      );

      final Result<Cuestionario> result = await repository
          .actualizarCuestionario('questionnaire-1', input);

      expect(result.valueOrNull?.nombre, 'RIASEC actualizado');
      expect(result.valueOrNull?.numPreguntas, 3);
    });

    test(
      'muestra un mensaje institucional claro ante un 403 sin detalle',
      () async {
        const ActualizarCuestionario input = ActualizarCuestionario(
          nombre: 'RIASEC',
          version: '1',
          activo: false,
          numPreguntas: 0,
        );
        when(
          () => dio.patch<Map<String, dynamic>>(
            '/institucion/cuestionarios/questionnaire-1',
            data: input.toApi(),
          ),
        ).thenThrow(
          _httpError('/institucion/cuestionarios/questionnaire-1', 403),
        );

        final Result<Cuestionario> result = await repository
            .actualizarCuestionario('questionnaire-1', input);

        expect(result.failureOrNull, isA<AuthFailure>());
        expect(result.failureOrNull?.message, contains('cuenta vinculada'));
      },
    );

    test('elimina un cuestionario', () async {
      when(
        () => dio.delete<Map<String, dynamic>>(
          '/institucion/cuestionarios/questionnaire-1',
        ),
      ).thenAnswer(
        (_) async => _response('/institucion/cuestionarios/questionnaire-1', {
          'success': true,
          'message': 'Cuestionario eliminado',
        }),
      );

      final Result<void> result = await repository.eliminarCuestionario(
        'questionnaire-1',
      );

      expect(result.isSuccess, isTrue);
    });

    test('mapea el error al eliminar un cuestionario', () async {
      when(
        () => dio.delete<Map<String, dynamic>>(
          '/institucion/cuestionarios/questionnaire-1',
        ),
      ).thenThrow(_serverError('/institucion/cuestionarios/questionnaire-1'));

      final Result<void> result = await repository.eliminarCuestionario(
        'questionnaire-1',
      );

      expect(result.failureOrNull, isA<ServerFailure>());
    });
  });

  group('preguntas', () {
    test('lista preguntas con opciones y pesos aplanados', () async {
      when(
        () => dio.get<Map<String, dynamic>>(
          '/institucion/preguntas',
          queryParameters: {'cuestionario_id': 'questionnaire-1'},
        ),
      ).thenAnswer(
        (_) async => _response('/institucion/preguntas', {
          'success': true,
          'data': [
            {
              'id': 'question-1',
              'cuestionario_id': 'questionnaire-1',
              'texto': '¿Qué disfrutas?',
              'tipo': 'multiple',
              'orden': 1,
              'categoria': 'tecnologia',
              'peso': 1,
              'opciones': [
                {
                  'id': 'option-1',
                  'label': 'Crear',
                  'icon': '💻',
                  'orden': 0,
                  'pesos': {'tecnologia': 5},
                },
              ],
            },
          ],
        }),
      );

      final Result<List<Pregunta>> result = await repository.getPreguntas(
        'questionnaire-1',
      );

      expect(result.valueOrNull?.single.tipo, TipoPregunta.opcionMultiple);
      expect(result.valueOrNull?.single.opciones.single.pesos['tecnologia'], 5);
    });

    test('mapea el error al listar preguntas', () async {
      when(
        () => dio.get<Map<String, dynamic>>(
          '/institucion/preguntas',
          queryParameters: {'cuestionario_id': 'questionnaire-1'},
        ),
      ).thenThrow(_serverError('/institucion/preguntas'));

      final Result<List<Pregunta>> result = await repository.getPreguntas(
        'questionnaire-1',
      );

      expect(result.failureOrNull, isA<ServerFailure>());
    });

    test('crea una pregunta con opciones y pesos anidados', () async {
      const NuevaPregunta input = NuevaPregunta(
        cuestionarioId: 'questionnaire-1',
        texto: '¿Qué disfrutas?',
        tipo: TipoPregunta.opcionMultiple,
        orden: 1,
        opciones: [
          OpcionPregunta(
            label: 'Crear',
            icon: '💻',
            orden: 0,
            pesos: {'tecnologia': 5},
          ),
          OpcionPregunta(label: 'Leer', orden: 1),
        ],
      );
      when(
        () => dio.post<Map<String, dynamic>>(
          '/institucion/preguntas',
          data: input.toApi(),
        ),
      ).thenAnswer(
        (_) async => _response('/institucion/preguntas', {
          'success': true,
          'data': {'id': 'question-1'},
        }, statusCode: 201),
      );

      final Result<Pregunta> result = await repository.crearPregunta(input);

      expect(result.valueOrNull?.id, 'question-1');
      expect(result.valueOrNull?.opciones.first.pesos['tecnologia'], 5);
    });

    test('mapea el error al crear una pregunta', () async {
      const NuevaPregunta input = NuevaPregunta(
        cuestionarioId: 'questionnaire-1',
        texto: '¿Qué disfrutas?',
        tipo: TipoPregunta.opcionUnica,
        orden: 1,
      );
      when(
        () => dio.post<Map<String, dynamic>>(
          '/institucion/preguntas',
          data: input.toApi(),
        ),
      ).thenThrow(_serverError('/institucion/preguntas'));

      final Result<Pregunta> result = await repository.crearPregunta(input);

      expect(result.failureOrNull, isA<ServerFailure>());
    });

    test('actualiza una pregunta y sus opciones completas', () async {
      const ActualizarPregunta input = ActualizarPregunta(
        cuestionarioId: 'questionnaire-1',
        texto: 'Pregunta actualizada',
        tipo: TipoPregunta.opcionUnica,
        orden: 2,
        opciones: [
          OpcionPregunta(label: 'Nueva opción', orden: 0),
          OpcionPregunta(label: 'Otra opción', orden: 1),
        ],
      );
      when(
        () => dio.patch<Map<String, dynamic>>(
          '/institucion/preguntas/question-1',
          data: input.toApi(),
        ),
      ).thenAnswer(
        (_) async => _response('/institucion/preguntas/question-1', {
          'success': true,
          'message': 'Pregunta actualizada',
        }),
      );

      final Result<Pregunta> result = await repository.actualizarPregunta(
        'question-1',
        input,
      );

      expect(result.valueOrNull?.texto, 'Pregunta actualizada');
      expect(result.valueOrNull?.opciones, hasLength(2));
    });

    test('mapea el error al actualizar una pregunta', () async {
      const ActualizarPregunta input = ActualizarPregunta(
        cuestionarioId: 'questionnaire-1',
        texto: 'Pregunta',
        tipo: TipoPregunta.opcionUnica,
        orden: 1,
      );
      when(
        () => dio.patch<Map<String, dynamic>>(
          '/institucion/preguntas/question-1',
          data: input.toApi(),
        ),
      ).thenThrow(_serverError('/institucion/preguntas/question-1'));

      final Result<Pregunta> result = await repository.actualizarPregunta(
        'question-1',
        input,
      );

      expect(result.failureOrNull, isA<ServerFailure>());
    });

    test('elimina una pregunta', () async {
      when(
        () => dio.delete<Map<String, dynamic>>(
          '/institucion/preguntas/question-1',
        ),
      ).thenAnswer(
        (_) async => _response('/institucion/preguntas/question-1', {
          'success': true,
          'message': 'Pregunta eliminada',
        }),
      );

      final Result<void> result = await repository.eliminarPregunta(
        'question-1',
      );

      expect(result.isSuccess, isTrue);
    });

    test('mapea el error al eliminar una pregunta', () async {
      when(
        () => dio.delete<Map<String, dynamic>>(
          '/institucion/preguntas/question-1',
        ),
      ).thenThrow(_serverError('/institucion/preguntas/question-1'));

      final Result<void> result = await repository.eliminarPregunta(
        'question-1',
      );

      expect(result.failureOrNull, isA<ServerFailure>());
    });
  });
}

const Map<String, dynamic> _questionnaireJson = {
  'id': 'questionnaire-1',
  'nombre': 'RIASEC',
  'version': '2',
  'descripcion': 'Orientación vocacional',
  'activo': false,
  'num_preguntas': 3,
};

Response<Map<String, dynamic>> _response(
  String path,
  Map<String, dynamic> data, {
  int statusCode = 200,
}) => Response<Map<String, dynamic>>(
  data: data,
  requestOptions: RequestOptions(path: path),
  statusCode: statusCode,
);

DioException _networkError(String path) => DioException(
  requestOptions: RequestOptions(path: path),
  type: DioExceptionType.connectionError,
);

DioException _serverError(String path) => _httpError(path, 500);

DioException _httpError(String path, int statusCode) => DioException(
  requestOptions: RequestOptions(path: path),
  response: Response<Map<String, dynamic>>(
    requestOptions: RequestOptions(path: path),
    statusCode: statusCode,
  ),
  type: DioExceptionType.badResponse,
);
