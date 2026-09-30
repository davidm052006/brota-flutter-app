import 'opcion_pregunta.dart';
import 'tipo_pregunta.dart';

final class Pregunta {
  const Pregunta({
    required this.id,
    required this.cuestionarioId,
    required this.texto,
    required this.tipo,
    required this.orden,
    this.categoria,
    required this.peso,
    this.opciones = const [],
  });

  factory Pregunta.fromJson(Map<String, dynamic> json) => Pregunta(
    id: json['id'] as String,
    cuestionarioId: json['cuestionario_id'] as String? ?? '',
    texto: json['texto'] as String? ?? '',
    tipo: TipoPregunta.fromApi(json['tipo'] as String?),
    orden: _asInt(json['orden']),
    categoria: json['categoria'] as String?,
    peso: _asDouble(json['peso']),
    opciones: (json['opciones'] as List<dynamic>? ?? const [])
        .map((item) => OpcionPregunta.fromJson(item as Map<String, dynamic>))
        .toList(),
  );

  final String id;
  final String cuestionarioId;
  final String texto;
  final TipoPregunta tipo;
  final int orden;
  final String? categoria;
  final double peso;
  final List<OpcionPregunta> opciones;
}

final class NuevaPregunta {
  const NuevaPregunta({
    required this.cuestionarioId,
    required this.texto,
    required this.tipo,
    required this.orden,
    this.categoria,
    this.peso = 1,
    this.opciones = const [],
  });

  final String cuestionarioId;
  final String texto;
  final TipoPregunta tipo;
  final int orden;
  final String? categoria;
  final double peso;
  final List<OpcionPregunta> opciones;

  Map<String, dynamic> toApi() => {
    'cuestionario_id': cuestionarioId,
    'texto': texto,
    'tipo': tipo.toApi(),
    'orden': orden,
    'categoria': categoria,
    'peso': peso,
    'opciones': opciones.map((option) => option.toApi()).toList(),
  };
}

final class ActualizarPregunta {
  const ActualizarPregunta({
    required this.cuestionarioId,
    required this.texto,
    required this.tipo,
    required this.orden,
    this.categoria,
    this.peso = 1,
    this.opciones = const [],
  });

  final String cuestionarioId;
  final String texto;
  final TipoPregunta tipo;
  final int orden;
  final String? categoria;
  final double peso;
  final List<OpcionPregunta> opciones;

  Map<String, dynamic> toApi() => {
    'texto': texto,
    'tipo': tipo.toApi(),
    'orden': orden,
    'categoria': categoria,
    'peso': peso,
    'opciones': opciones.map((option) => option.toApi()).toList(),
  };
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 1;
}
