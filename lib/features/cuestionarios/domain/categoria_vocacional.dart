/// Categorías vocacionales a las que una opción puede sumar puntos.
///
/// Réplica de `CATEGORIA_OPCIONES` en
/// `frontend/src/utils/vocacionalCategorias.js`. Son las mismas claves que
/// usan `programas.area_academica` y el algoritmo de recomendación, así que
/// **no inventar valores nuevos acá**: una categoría que no exista del lado
/// web queda sin programas asociados y no aparece en ninguna recomendación.
///
/// `emprendimiento`/`ambiente` conviven con `negocios`/`ambiental` porque el
/// cuestionario histórico usa unas y el catálogo de programas las otras; el
/// backend las normaliza con `CATEGORIA_ALIAS` antes de consultar.
abstract final class CategoriaVocacional {
  static const List<({String value, String label})> opciones = [
    (value: 'tecnologia', label: 'Tecnología e Innovación'),
    (value: 'arte', label: 'Arte y Creatividad'),
    (value: 'ciencias', label: 'Ciencias e Investigación'),
    (value: 'social', label: 'Vocación Social y Humana'),
    (value: 'humanidades', label: 'Humanidades y Cultura'),
    (value: 'negocios', label: 'Negocios y Emprendimiento'),
    (value: 'emprendimiento', label: 'Emprendimiento e Innovación'),
    (value: 'salud', label: 'Salud y Bienestar'),
    (value: 'educacion', label: 'Educación y Pedagogía'),
    (value: 'comunicacion', label: 'Comunicación y Medios'),
    (value: 'ambiente', label: 'Medio Ambiente y Sostenibilidad'),
    (value: 'ambiental', label: 'Medio Ambiente y Sostenibilidad'),
    (value: 'deporte', label: 'Deporte y Actividad Física'),
    (value: 'juridico', label: 'Derecho y Justicia'),
    (value: 'administrativo', label: 'Gestión y Administración'),
  ];

  static String labelDe(String value) {
    for (final opcion in opciones) {
      if (opcion.value == value) return opcion.label;
    }
    return value;
  }
}
