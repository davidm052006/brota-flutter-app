/// Una opción de respuesta, con los puntos que suma por categoría vocacional.
///
/// Las opciones no tienen endpoint propio: viajan anidadas en el body de la
/// pregunta, y el backend reemplaza las filas de `opciones`/`pesos_opciones`
/// completas en cada escritura. El `GET` las devuelve ya aplanadas, con
/// `pesos` como mapa `{ categoria: puntos }`.
final class OpcionPregunta {
  const OpcionPregunta({
    this.id,
    required this.label,
    this.icon,
    required this.orden,
    this.pesos = const {},
  });

  factory OpcionPregunta.fromJson(Map<String, dynamic> json) {
    return OpcionPregunta(
      id: json['id'] as String?,
      label: json['label'] as String? ?? '',
      icon: json['icon'] as String?,
      orden: (json['orden'] as num?)?.toInt() ?? 0,
      pesos: _pesosFromJson(json['pesos']),
    );
  }

  /// `id` es null mientras la opción solo existe en el editor: el backend la
  /// crea recién al guardar la pregunta.
  final String? id;
  final String label;
  final String? icon;
  final int orden;
  final Map<String, int> pesos;

  Map<String, dynamic> toJson() => {
    'label': label,
    if (icon != null && icon!.isNotEmpty) 'icon': icon,
    'orden': orden,
    'pesos': pesos,
  };

  OpcionPregunta copyWith({
    String? label,
    String? icon,
    int? orden,
    Map<String, int>? pesos,
  }) {
    return OpcionPregunta(
      id: id,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      orden: orden ?? this.orden,
      pesos: pesos ?? this.pesos,
    );
  }

  static Map<String, int> _pesosFromJson(Object? raw) {
    if (raw is! Map) return const {};
    final Map<String, int> pesos = {};
    raw.forEach((key, value) {
      final int? puntos = value is num
          ? value.toInt()
          : int.tryParse('$value');
      if (key is String && puntos != null && puntos > 0) pesos[key] = puntos;
    });
    return pesos;
  }
}
