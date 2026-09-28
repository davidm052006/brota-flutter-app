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

/// Respuesta con el envoltorio `{ success, data }` que usa el backend.
Response<dynamic> _ok(Object? data) => Response<dynamic>(
  requestOptions: RequestOptions(path: '/'),
  statusCode: 200,
  data: {'success': true, 'data': data},
);

DioException _fallo(int status, {String mensaje = 'algo salió mal'}) {
  final RequestOptions options = RequestOptions(path: '/');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response<dynamic>(
      requestOptions: options,
      statusCode: status,
      data: {'success': false, 'message': mensaje},
    ),
  );
}

void main() {
  late _MockDio dio;
  late CuestionariosRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    dio = _MockDio();
    repository = CuestionariosRepositoryImpl(dio);
  });

  const CuestionarioInput inputCuestionario = CuestionarioInput(
    nombre: 'Test interno',
    version: '1.0',
    descripcion: 'Para once',
  );

  const PreguntaInput inputPregunta = PreguntaInput(
    cuestionarioId: 'c1',
    texto: '¿Qué te gusta?',
    tipo: TipoPregunta.opcionUnica,
    opciones: [
      OpcionPregunta(label: 'Programar', orden: 0, pesos: {'tecnologia': 5}),
      OpcionPregunta(label: 'Dibujar', orden: 1, pesos: {'arte': 5}),
    ],
  );

  group('getCuestionarios', () {
    test('caso feliz: mapea la lista', () async {
      when(() => dio.get<dynamic>(any())).thenAnswer(
        (_) async => _ok([
          {'id': 'c1', 'nombre': 'Test interno', 'version': '1.0', 'activo': true},
        ]),
      );

      final Result<List<Cuestionario>> result = await repository
          .getCuestionarios();

      final List<Cuestionario>? lista = result.valueOrNull;
      expect(lista, hasLength(1));
      expect(lista!.first.nombre, 'Test interno');
      expect(lista.first.activo, isTrue);
    });

    test('error: un 403 explica que falta el rol institución', () async {
      when(() => dio.get<dynamic>(any())).thenThrow(_fallo(403));

      final Result<List<Cuestionario>> result = await repository
          .getCuestionarios();

      final Failure? failure = result.failureOrNull;
      expect(failure, isA<AuthFailure>());
      expect(failure!.message, contains('rol de institución'));
    });
  });

  group('crearCuestionario', () {
    test('caso feliz: devuelve el cuestionario creado', () async {
      when(
        () => dio.post<dynamic>(any(), data: any(named: 'data')),
      ).thenAnswer(
        (_) async => _ok({'id': 'c9', 'nombre': 'Nuevo', 'version': '2.0'}),
      );

      final Result<Cuestionario> result = await repository.crearCuestionario(
        inputCuestionario,
      );

      expect(result.valueOrNull?.id, 'c9');
    });

    test('error: un 500 da ServerFailure con el mensaje del backend', () async {
      when(
        () => dio.post<dynamic>(any(), data: any(named: 'data')),
      ).thenThrow(_fallo(500, mensaje: 'Error interno'));

      final Result<Cuestionario> result = await repository.crearCuestionario(
        inputCuestionario,
      );

      expect(result.failureOrNull, isA<ServerFailure>());
      expect(result.failureOrNull!.message, 'Error interno');
    });
  });

  group('actualizarCuestionario', () {
    test('caso feliz: si el PATCH solo confirma, rearma desde el input', () async {
      when(() => dio.patch<dynamic>(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: '/'),
          statusCode: 200,
          data: {'success': true, 'message': 'Cuestionario actualizado'},
        ),
      );

      final Result<Cuestionario> result = await repository
          .actualizarCuestionario('c1', inputCuestionario);

      expect(result.valueOrNull?.id, 'c1');
      expect(result.valueOrNull?.nombre, 'Test interno');
    });

    test('error: 404 propaga ServerFailure', () async {
      when(
        () => dio.patch<dynamic>(any(), data: any(named: 'data')),
      ).thenThrow(_fallo(404, mensaje: 'Cuestionario no encontrado'));

      final Result<Cuestionario> result = await repository
          .actualizarCuestionario('c1', inputCuestionario);

      expect(result.failureOrNull, isA<ServerFailure>());
    });
  });

  group('eliminarCuestionario', () {
    test('caso feliz', () async {
      when(() => dio.delete<dynamic>(any())).thenAnswer((_) async => _ok(null));
      expect((await repository.eliminarCuestionario('c1')).isSuccess, isTrue);
    });

    test('error: sin red da NetworkFailure', () async {
      when(() => dio.delete<dynamic>(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/'),
          type: DioExceptionType.connectionError,
        ),
      );
      expect(
        (await repository.eliminarCuestionario('c1')).failureOrNull,
        isA<NetworkFailure>(),
      );
    });
  });

  group('getPreguntas', () {
    test('caso feliz: aplana opciones y pesos, y ordena', () async {
      when(
        () => dio.get<dynamic>(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer(
        (_) async => _ok([
          {
            'id': 'p2',
            'texto': 'Segunda',
            'tipo': 'multiple',
            'orden': 2,
            'opciones': <Map<String, dynamic>>[],
          },
          {
            'id': 'p1',
            'texto': 'Primera',
            'tipo': 'seleccion',
            'orden': 1,
            'opciones': [
              {
                'id': 'o1',
                'label': 'Programar',
                'orden': 0,
                'pesos': {'tecnologia': 5},
              },
            ],
          },
        ]),
      );

      final Result<List<Pregunta>> result = await repository.getPreguntas('c1');
      final List<Pregunta> preguntas = result.valueOrNull!;

      expect(preguntas.map((p) => p.id), ['p1', 'p2']);
      // Los alias legados se normalizan al leer.
      expect(preguntas.first.tipo, TipoPregunta.opcionUnica);
      expect(preguntas[1].tipo, TipoPregunta.opcionMultiple);
      expect(preguntas.first.opciones.single.pesos['tecnologia'], 5);
    });

    test('error: 401 da AuthFailure', () async {
      when(
        () => dio.get<dynamic>(any(), queryParameters: any(named: 'queryParameters')),
      ).thenThrow(_fallo(401, mensaje: 'Token inválido'));

      expect(
        (await repository.getPreguntas('c1')).failureOrNull,
        isA<AuthFailure>(),
      );
    });
  });

  group('crearPregunta', () {
    test('caso feliz: manda el tipo canónico y las opciones anidadas', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => _ok({'id': 'p9', 'texto': '¿Qué te gusta?', 'tipo': 'opcion_unica'}),
      );

      final Result<Pregunta> result = await repository.crearPregunta(
        inputPregunta,
      );

      expect(result.valueOrNull?.id, 'p9');
      // El POST devuelve la fila sin opciones (van en tablas aparte): se
      // completan con las que mandamos.
      expect(result.valueOrNull?.opciones, hasLength(2));

      final Map<String, dynamic> enviado =
          verify(
                () => dio.post<dynamic>(any(), data: captureAny(named: 'data')),
              ).captured.single
              as Map<String, dynamic>;
      expect(enviado['tipo'], 'opcion_unica');
      expect(enviado['opciones'], hasLength(2));
      expect(
        (enviado['opciones'] as List).first,
        containsPair('pesos', {'tecnologia': 5}),
      );
    });

    test('error: un 400 se reporta como validación, no como fallo de servidor', () async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenThrow(
        _fallo(400, mensaje: 'Tipo de pregunta inválido: "cualquier_cosa".'),
      );

      final Result<Pregunta> result = await repository.crearPregunta(
        inputPregunta,
      );

      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(result.failureOrNull!.message, contains('Tipo de pregunta'));
    });
  });

  group('actualizarPregunta', () {
    test('caso feliz: re-numera el orden de las opciones al enviar', () async {
      when(() => dio.patch<dynamic>(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => _ok({'id': 'p1', 'texto': '¿Qué te gusta?'}),
      );

      await repository.actualizarPregunta('p1', inputPregunta);

      final Map<String, dynamic> enviado =
          verify(
                () => dio.patch<dynamic>(any(), data: captureAny(named: 'data')),
              ).captured.single
              as Map<String, dynamic>;
      final List<dynamic> opciones = enviado['opciones'] as List<dynamic>;
      expect((opciones[0] as Map)['orden'], 0);
      expect((opciones[1] as Map)['orden'], 1);
    });

    test('error: 403 explica el rol faltante', () async {
      when(
        () => dio.patch<dynamic>(any(), data: any(named: 'data')),
      ).thenThrow(_fallo(403));

      expect(
        (await repository.actualizarPregunta('p1', inputPregunta)).failureOrNull,
        isA<AuthFailure>(),
      );
    });
  });

  group('eliminarPregunta', () {
    test('caso feliz', () async {
      when(() => dio.delete<dynamic>(any())).thenAnswer((_) async => _ok(null));
      expect((await repository.eliminarPregunta('p1')).isSuccess, isTrue);
    });

    test('error: 404 da ServerFailure', () async {
      when(() => dio.delete<dynamic>(any())).thenThrow(_fallo(404));
      expect(
        (await repository.eliminarPregunta('p1')).failureOrNull,
        isA<ServerFailure>(),
      );
    });
  });
}
