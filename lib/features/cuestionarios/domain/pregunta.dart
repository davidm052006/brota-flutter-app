import 'opcion_pregunta.dart';
import 'tipo_pregunta.dart';

/// Una pregunta del cuestionario, con sus opciones y pesos ya resueltos.
///
/// Viene de `GET /api/institucion/preguntas?cuestionario_id=...`, que devuelve
/// el mismo shape que `perfilController.obtenerCuestionario` usa para armar el
/// test — o sea, lo que el estudiante va a ver de verdad.
final class Pregunta {
  const Pregunta({
    required this.id,
    required this.cuestionarioId,
    required this.texto,
    required this.tipo,
    required this.orden,
    this.categoria,
    this.peso = 1.0,
    this.opciones = const [],
  });

  factory Pregunta.fromJson(
    Map<String, dynamic> json, {
    String? cuestionarioId,
  }) {
    final Object? rawOpciones = json['opciones'];
    // Lista mutable siempre: `const []` acá reventaba el sort de abajo con
    // UnsupportedError en cualquier respuesta sin `opciones` — que es
    // exactamente lo que devuelve el POST de una pregunta nueva.
    final List<OpcionPregunta> opciones = rawOpciones is List
        ? rawOpciones
              .whereType<Map<String, dynamic>>()
              .map(OpcionPregunta.fromJson)
              .toList()
        : <OpcionPregunta>[];
    opciones.sort((a, b) => a.orden.compareTo(b.orden));

    return Pregunta(
      id: json['id'] as String? ?? '',
      cuestionarioId:
          json['cuestionario_id'] as String? ?? cuestionarioId ?? '',
      texto: json['texto'] as String? ?? '',
      // fromApi nunca lanza: un tipo legado o desconocido no debe romper el
      // parseo de la lista entera.
      tipo: TipoPregunta.fromApi(json['tipo']),
      orden: (json['orden'] as num?)?.toInt() ?? 0,
      categoria: json['categoria'] as String?,
      peso: (json['peso'] as num?)?.toDouble() ?? 1.0,
      opciones: opciones,
    );
  }

  final String id;
  final String cuestionarioId;
  final String texto;
  final TipoPregunta tipo;
  final int orden;
  final String? categoria;
  final double peso;
  final List<OpcionPregunta> opciones;
}

/// Payload de creación/edición de una pregunta. Separado de [Pregunta] porque
/// al crear todavía no hay `id`, y porque las opciones van anidadas.
final class PreguntaInput {
  const PreguntaInput({
    required this.cuestionarioId,
    required this.texto,
    required this.tipo,
    this.orden,
    this.categoria,
    this.peso = 1.0,
    required this.opciones,
  });

  final String cuestionarioId;
  final String texto;
  final TipoPregunta tipo;
  final int? orden;
  final String? categoria;
  final double peso;
  final List<OpcionPregunta> opciones;

  Map<String, dynamic> toJson() => {
    'cuestionario_id': cuestionarioId,
    'texto': texto,
    'tipo': tipo.toApi(),
    if (orden != null) 'orden': orden,
    if (categoria != null && categoria!.isNotEmpty) 'categoria': categoria,
    'peso': peso,
    'opciones': [
      for (final (int i, OpcionPregunta o) in opciones.indexed)
        // El orden se re-numera al enviar: el editor deja reordenar, y así el
        // índice de la lista es siempre la fuente de verdad.
        o.copyWith(orden: i).toJson(),
    ],
  };
}
