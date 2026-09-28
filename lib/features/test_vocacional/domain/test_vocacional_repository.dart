import '../../../core/result/result.dart';
import 'test_vocacional_session.dart';

abstract interface class TestVocacionalRepository {
  Future<Result<TestVocacionalSession>> cargarTest(String userId);

  Future<Result<VocationalTestResult>> guardarResultado({
    required String perfilId,
    required String cuestionarioId,
    required Map<String, List<String>> respuestas,
  });
}
