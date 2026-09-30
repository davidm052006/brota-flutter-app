import 'package:brota_flutter_app/core/result/failure.dart';
import 'package:brota_flutter_app/core/result/result.dart';
import 'package:brota_flutter_app/features/test_vocacional/data/test_vocacional_repository_impl.dart';
import 'package:brota_flutter_app/features/test_vocacional/domain/test_vocacional_session.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio dio;
  late TestVocacionalRepositoryImpl repository;

  setUp(() {
    dio = _MockDio();
    repository = TestVocacionalRepositoryImpl(dio);
  });

  for (final String role in ['estudiante', 'admin']) {
    test('$role puede cargar el test activo', () async {
      when(() => dio.get<Map<String, dynamic>>('/perfil/user-1')).thenAnswer(
        (_) async => _response('/perfil/user-1', {
          'success': true,
          'data': {'id': 'profile-1', 'rol': role},
        }),
      );
      when(
        () => dio.get<Map<String, dynamic>>('/perfil/cuestionario'),
      ).thenAnswer(
        (_) async => _response('/perfil/cuestionario', _questionnaireResponse),
      );

      final Result<TestVocacionalSession> result = await repository.cargarTest(
        'user-1',
      );

      expect(result.valueOrNull?.rol, role);
      expect(result.valueOrNull?.perfilId, 'profile-1');
      expect(result.valueOrNull?.preguntas, hasLength(1));
    });
  }

  test('rechaza el test para cuentas de institución', () async {
    when(() => dio.get<Map<String, dynamic>>('/perfil/user-1')).thenAnswer(
      (_) async => _response('/perfil/user-1', {
        'success': true,
        'data': {'id': 'profile-1', 'rol': 'institucion'},
      }),
    );

    final Result<TestVocacionalSession> result = await repository.cargarTest(
      'user-1',
    );

    expect(result.failureOrNull, isA<AuthFailure>());
    verifyNever(() => dio.get<Map<String, dynamic>>('/perfil/cuestionario'));
  });

  test(
    'envía las respuestas con el perfil propio y parsea el resultado',
    () async {
      final Map<String, dynamic> requestBody = {
        'perfil_usuario_id': 'profile-1',
        'cuestionario_id': 'quiz-1',
        'respuestas': {
          'question-1': ['option-1'],
        },
      };
      when(
        () => dio.post<Map<String, dynamic>>(
          '/perfil/resultado',
          data: requestBody,
        ),
      ).thenAnswer(
        (_) async => _response('/perfil/resultado', {
          'success': true,
          'data': {
            'id': 'result-1',
            'perfil_vocacional': {
              'categoriaPrincipal': 'tecnologia',
              'categoriaSecundaria': 'ciencias',
              'scores': [
                {'categoria': 'tecnologia', 'puntos': 10, 'porcentaje': 100},
              ],
            },
          },
        }, statusCode: 201),
      );

      final Result<VocationalTestResult> result = await repository
          .guardarResultado(
            perfilId: 'profile-1',
            cuestionarioId: 'quiz-1',
            respuestas: {
              'question-1': ['option-1'],
            },
          );

      expect(result.valueOrNull?.id, 'result-1');
      expect(result.valueOrNull?.categoriaPrincipal, 'tecnologia');
      expect(result.valueOrNull?.scores.single.porcentaje, 100);
    },
  );
}

const Map<String, dynamic> _questionnaireResponse = {
  'success': true,
  'data': {
    'id': 'quiz-1',
    'cuestionario': {'id': 'quiz-1', 'nombre': 'RIASEC', 'version': '1'},
    'preguntas': [
      {
        'id': 'question-1',
        'texto': '¿Qué disfrutas?',
        'tipo': 'opcion_unica',
        'orden': 1,
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
  },
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
