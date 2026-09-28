/// Un cuestionario propio de la institución.
///
/// `institucion_id` no viaja en este modelo a propósito: los endpoints de
/// `/api/institucion/*` ya están scoped server-side a la institución de la
/// cuenta, y el backend ignora cualquier `institucion_id` que mande el cliente.
final class Cuestionario {
  const Cuestionario({
    required this.id,
    required this.nombre,
    required this.version,
    this.descripcion,
    this.activo = false,
    this.numPreguntas,
  });

  factory Cuestionario.fromJson(Map<String, dynamic> json) {
    return Cuestionario(
      id: json['id'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
      version: json['version'] as String? ?? '',
      descripcion: json['descripcion'] as String?,
      activo: json['activo'] as bool? ?? false,
      numPreguntas:
          (json['num_preguntas'] as num?)?.toInt() ??
          (json['numPreguntas'] as num?)?.toInt(),
    );
  }

  final String id;
  final String nombre;
  final String version;
  final String? descripcion;

  /// Activar uno desactiva los OTROS de la misma institución — nunca el
  /// cuestionario global ni los de otra institución. Esa regla la aplica el
  /// backend, acá solo se refleja.
  final bool activo;

  final int? numPreguntas;
}

/// Payload de creación/edición de un cuestionario.
final class CuestionarioInput {
  const CuestionarioInput({
    required this.nombre,
    required this.version,
    this.descripcion,
    this.activo = false,
  });

  final String nombre;
  final String version;
  final String? descripcion;
  final bool activo;

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'version': version,
    if (descripcion != null) 'descripcion': descripcion,
    'activo': activo,
  };
}
