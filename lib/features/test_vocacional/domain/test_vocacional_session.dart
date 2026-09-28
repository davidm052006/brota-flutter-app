import '../../cuestionarios/domain/pregunta.dart';

final class TestVocacionalSession {
  const TestVocacionalSession({
    required this.perfilId,
    required this.rol,
    required this.cuestionarioId,
    required this.nombreCuestionario,
    required this.version,
    required this.preguntas,
  });

  final String perfilId;
  final String rol;
  final String cuestionarioId;
  final String nombreCuestionario;
  final String version;
  final List<Pregunta> preguntas;
}

final class VocationalTestScore {
  const VocationalTestScore({
    required this.categoria,
    required this.puntos,
    required this.porcentaje,
  });

  factory VocationalTestScore.fromJson(Map<String, dynamic> json) =>
      VocationalTestScore(
        categoria: json['categoria'] as String? ?? '',
        puntos: _asDouble(json['puntos']),
        porcentaje: _asDouble(json['porcentaje']),
      );

  final String categoria;
  final double puntos;
  final double porcentaje;
}

final class VocationalTestResult {
  const VocationalTestResult({
    required this.id,
    this.categoriaPrincipal,
    this.categoriaSecundaria,
    this.scores = const [],
  });

  factory VocationalTestResult.fromJson(Map<String, dynamic> json) {
    final Object? rawProfile = json['perfil_vocacional'];
    final Map<String, dynamic> profile = rawProfile is Map<String, dynamic>
        ? rawProfile
        : const {};
    final Object? rawNestedProfile = profile['perfil'];
    final Map<String, dynamic> normalized =
        rawNestedProfile is Map<String, dynamic> ? rawNestedProfile : profile;
    final Object? rawScores = normalized['scores'];

    return VocationalTestResult(
      id: json['id'] as String? ?? '',
      categoriaPrincipal: normalized['categoriaPrincipal'] as String?,
      categoriaSecundaria: normalized['categoriaSecundaria'] as String?,
      scores: rawScores is List<dynamic>
          ? rawScores
                .whereType<Map<String, dynamic>>()
                .map(VocationalTestScore.fromJson)
                .toList()
          : const [],
    );
  }

  final String id;
  final String? categoriaPrincipal;
  final String? categoriaSecundaria;
  final List<VocationalTestScore> scores;
}

double _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
