enum TipoPregunta {
  opcionUnica('opcion_unica'),
  opcionMultiple('opcion_multiple'),
  likert('likert'),
  respuestaCorta('respuesta_corta'),
  respuestaLarga('respuesta_larga');

  const TipoPregunta(this.apiValue);

  final String apiValue;

  String toApi() => apiValue;

  static TipoPregunta fromApi(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'opcion_unica':
      case 'single':
      case 'seleccion':
        return TipoPregunta.opcionUnica;
      case 'opcion_multiple':
      case 'multiple':
        return TipoPregunta.opcionMultiple;
      case 'likert':
        return TipoPregunta.likert;
      case 'respuesta_corta':
        return TipoPregunta.respuestaCorta;
      case 'respuesta_larga':
        return TipoPregunta.respuestaLarga;
      default:
        return TipoPregunta.opcionUnica;
    }
  }
}
