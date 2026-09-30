/// Tipos de pregunta del test vocacional.
///
/// Réplica del catálogo del web (`frontend/src/utils/tiposPregunta.js` y su
/// espejo `backend/src/utils/tiposPregunta.js`, commit `b10ab48`). Las tres
/// claves canónicas son lo único que se escribe; los alias existen porque hay
/// filas guardadas con el vocabulario viejo que no se migraron a mano, así que
/// un `GET` puede devolver cualquiera de los seis valores.
///
/// El backend ahora responde 400 si se le manda un `tipo` fuera del catálogo
/// — por eso [toApi] siempre emite una clave canónica.
enum TipoPregunta {
  opcionUnica(
    apiValue: 'opcion_unica',
    label: 'Opción única',
    descripcion: 'El estudiante elige una sola opción entre varias tarjetas.',
    seleccionMultiple: false,
  ),
  opcionMultiple(
    apiValue: 'opcion_multiple',
    label: 'Opción múltiple',
    descripcion: 'El estudiante puede marcar todas las opciones que apliquen.',
    seleccionMultiple: true,
  ),
  likert(
    apiValue: 'likert',
    label: 'Escala Likert',
    descripcion: 'Escala gráfica de 5 puntos, de menor a mayor afinidad.',
    seleccionMultiple: false,
  );

  const TipoPregunta({
    required this.apiValue,
    required this.label,
    required this.descripcion,
    required this.seleccionMultiple,
  });

  final String apiValue;
  final String label;
  final String descripcion;
  final bool seleccionMultiple;

  /// A lo que cae un tipo desconocido: preferimos una pregunta editable con el
  /// tipo equivocado antes que reventar el parseo de toda la lista.
  static const TipoPregunta porDefecto = TipoPregunta.opcionUnica;

  /// Valores legados que siguen vivos en la base.
  static const Map<String, TipoPregunta> _alias = {
    'single': TipoPregunta.opcionUnica,
    'seleccion': TipoPregunta.opcionUnica,
    'multiple': TipoPregunta.opcionMultiple,
  };

  /// Cuántas opciones espera la escala Likert. No se bloquea el guardado si
  /// son otras — solo se advierte, igual que en el editor web.
  static const int opcionesEsperadasLikert = 5;

  /// Traduce un valor crudo de `preguntas.tipo` (canónico o legado).
  /// Nunca lanza: lo desconocido cae a [porDefecto].
  static TipoPregunta fromApi(Object? raw) {
    if (raw is! String) return porDefecto;
    final String clave = raw.trim().toLowerCase();
    for (final TipoPregunta tipo in TipoPregunta.values) {
      if (tipo.apiValue == clave) return tipo;
    }
    return _alias[clave] ?? porDefecto;
  }

  /// true si el valor crudo es uno de los que el backend acepta.
  static bool esValido(Object? raw) {
    if (raw is! String) return false;
    final String clave = raw.trim().toLowerCase();
    return TipoPregunta.values.any((t) => t.apiValue == clave) ||
        _alias.containsKey(clave);
  }

  String toApi() => apiValue;
}
