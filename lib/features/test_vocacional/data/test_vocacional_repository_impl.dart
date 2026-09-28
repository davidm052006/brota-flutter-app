import 'package:dio/dio.dart';

import '../../../core/network/api_exception_mapper.dart';
import '../../../core/result/failure.dart';
import '../../../core/result/result.dart';
import '../../cuestionarios/domain/pregunta.dart';
import '../domain/test_vocacional_repository.dart';
import '../domain/test_vocacional_session.dart';

final class TestVocacionalRepositoryImpl implements TestVocacionalRepository {
  TestVocacionalRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<Result<TestVocacionalSession>> cargarTest(String userId) async {
    try {
      final Response<Map<String, dynamic>> profileResponse = await _dio
          .get<Map<String, dynamic>>('/perfil/$userId');
      final Map<String, dynamic> profile = _responseData(profileResponse);
      final String profileId = profile['id'] as String;
      final String role = profile['rol'] as String? ?? '';
      if (role == 'institucion') {
        return const ResultError<TestVocacionalSession>(
          AuthFailure(
            'Las cuentas de institución administran cuestionarios y no realizan el test.',
          ),
        );
      }

      final Response<Map<String, dynamic>> questionnaireResponse = await _dio
          .get<Map<String, dynamic>>('/perfil/cuestionario');
      final Map<String, dynamic> data = _responseData(questionnaireResponse);
      final Object? rawQuestionnaire = data['cuestionario'];
      final Map<String, dynamic> questionnaire =
          rawQuestionnaire is Map<String, dynamic> ? rawQuestionnaire : data;
      final Object? rawQuestions = data['preguntas'];
      if (rawQuestions is! List<dynamic>) {
        throw const FormatException('El cuestionario no contiene preguntas.');
      }

      final List<Pregunta> questions = rawQuestions
          .map((item) => Pregunta.fromJson(item as Map<String, dynamic>))
          .toList();
      if (questions.isEmpty) {
        return const ResultError<TestVocacionalSession>(
          ValidationFailure(
            'El cuestionario activo todavía no tiene preguntas.',
          ),
        );
      }

      final String? questionnaireId =
          questionnaire['id'] as String? ?? data['id'] as String?;
      if (questionnaireId == null) {
        throw const FormatException(
          'El cuestionario no tiene un identificador.',
        );
      }

      return Success<TestVocacionalSession>(
        TestVocacionalSession(
          perfilId: profileId,
          rol: role,
          cuestionarioId: questionnaireId,
          nombreCuestionario:
              questionnaire['nombre'] as String? ?? 'Test vocacional',
          version: questionnaire['version']?.toString() ?? '',
          preguntas: questions,
        ),
      );
    } on DioException catch (error) {
      return ResultError<TestVocacionalSession>(
        mapDioExceptionToFailure(error),
      );
    } catch (_) {
      return const ResultError<TestVocacionalSession>(UnknownFailure());
    }
  }

  @override
  Future<Result<VocationalTestResult>> guardarResultado({
    required String perfilId,
    required String cuestionarioId,
    required Map<String, List<String>> respuestas,
  }) async {
    try {
      final Response<Map<String, dynamic>> response = await _dio
          .post<Map<String, dynamic>>(
            '/perfil/resultado',
            data: {
              'perfil_usuario_id': perfilId,
              'cuestionario_id': cuestionarioId,
              'respuestas': respuestas,
            },
          );
      return Success<VocationalTestResult>(
        VocationalTestResult.fromJson(_responseData(response)),
      );
    } on DioException catch (error) {
      return ResultError<VocationalTestResult>(mapDioExceptionToFailure(error));
    } catch (_) {
      return const ResultError<VocationalTestResult>(UnknownFailure());
    }
  }

  Map<String, dynamic> _responseData(Response<Map<String, dynamic>> response) {
    final Object? data = response.data?['data'];
    if (data is Map<String, dynamic>) return data;
    throw const FormatException('Respuesta del servidor inválida.');
  }
}
