final class Cuestionario {
  const Cuestionario({
    required this.id,
    required this.nombre,
    required this.version,
    this.descripcion,
    required this.activo,
    required this.numPreguntas,
  });

  factory Cuestionario.fromJson(Map<String, dynamic> json) => Cuestionario(
    id: json['id'] as String,
    nombre: json['nombre'] as String? ?? '',
    version: json['version']?.toString() ?? '',
    descripcion: json['descripcion'] as String?,
    activo: json['activo'] as bool? ?? false,
    numPreguntas: _asInt(json['num_preguntas'] ?? json['numPreguntas']),
  );

  final String id;
  final String nombre;
  final String version;
  final String? descripcion;
  final bool activo;
  final int numPreguntas;
}

final class NuevoCuestionario {
  const NuevoCuestionario({
    required this.nombre,
    required this.version,
    this.descripcion,
  });

  final String nombre;
  final String version;
  final String? descripcion;

  Map<String, dynamic> toApi() => {
    'nombre': nombre,
    'version': version,
    'descripcion': descripcion,
  };
}

final class ActualizarCuestionario {
  const ActualizarCuestionario({
    required this.nombre,
    required this.version,
    this.descripcion,
    required this.activo,
    required this.numPreguntas,
  });

  final String nombre;
  final String version;
  final String? descripcion;
  final bool activo;
  final int numPreguntas;

  Map<String, dynamic> toApi() => {
    'nombre': nombre,
    'version': version,
    'descripcion': descripcion,
    'activo': activo,
  };
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
