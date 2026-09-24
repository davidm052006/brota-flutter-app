/// Un programa educativo (SNIES/MEN) tal como lo devuelve
/// `GET /api/programas` — ver `FUNCTIONAL_CONTENT_BRIEF.md` sección 2.
final class Programa {
  const Programa({
    required this.id,
    required this.nombre,
    required this.areaAcademica,
    required this.modalidad,
    required this.duracion,
    required this.institucionNombre,
  });

  factory Programa.fromJson(Map<String, dynamic> json) {
    return Programa(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      areaAcademica: json['area_academica'] as String? ?? '',
      modalidad: json['modalidad'] as String? ?? '',
      duracion: json['duracion'] as String? ?? '',
      institucionNombre:
          (json['instituciones'] as Map<String, dynamic>?)?['nombre']
              as String? ??
          '',
    );
  }

  final String id;
  final String nombre;
  final String areaAcademica;
  final String modalidad;
  final String duracion;
  final String institucionNombre;
}
