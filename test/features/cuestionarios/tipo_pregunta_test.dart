import 'package:brota_flutter_app/features/cuestionarios/domain/tipo_pregunta.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TipoPregunta.fromApi', () {
    test('acepta las claves canónicas', () {
      expect(TipoPregunta.fromApi('opcion_unica'), TipoPregunta.opcionUnica);
      expect(
        TipoPregunta.fromApi('opcion_multiple'),
        TipoPregunta.opcionMultiple,
      );
      expect(TipoPregunta.fromApi('likert'), TipoPregunta.likert);
    });

    test('traduce los alias legados que siguen en la base', () {
      expect(TipoPregunta.fromApi('single'), TipoPregunta.opcionUnica);
      expect(TipoPregunta.fromApi('seleccion'), TipoPregunta.opcionUnica);
      expect(TipoPregunta.fromApi('multiple'), TipoPregunta.opcionMultiple);
    });

    test('tolera espacios y mayúsculas', () {
      expect(TipoPregunta.fromApi('  Single '), TipoPregunta.opcionUnica);
      expect(
        TipoPregunta.fromApi('OPCION_MULTIPLE'),
        TipoPregunta.opcionMultiple,
      );
    });

    test('cae al tipo por defecto ante lo desconocido o lo que no es texto', () {
      expect(TipoPregunta.fromApi('cualquier_cosa'), TipoPregunta.porDefecto);
      expect(TipoPregunta.fromApi(null), TipoPregunta.porDefecto);
      expect(TipoPregunta.fromApi(42), TipoPregunta.porDefecto);
      expect(TipoPregunta.fromApi(''), TipoPregunta.porDefecto);
    });
  });

  group('TipoPregunta.esValido', () {
    test('acepta canónicos y alias', () {
      for (final String valor in [
        'opcion_unica',
        'opcion_multiple',
        'likert',
        'single',
        'seleccion',
        'multiple',
      ]) {
        expect(TipoPregunta.esValido(valor), isTrue, reason: valor);
      }
    });

    test('rechaza desconocidos y no-strings', () {
      expect(TipoPregunta.esValido('cualquier_cosa'), isFalse);
      expect(TipoPregunta.esValido(''), isFalse);
      expect(TipoPregunta.esValido(null), isFalse);
      expect(TipoPregunta.esValido(7), isFalse);
    });
  });

  test('toApi siempre emite una clave canónica (el backend 400ea lo demás)', () {
    expect(TipoPregunta.fromApi('seleccion').toApi(), 'opcion_unica');
    expect(TipoPregunta.fromApi('multiple').toApi(), 'opcion_multiple');
  });

  test('solo opción múltiple admite varias respuestas', () {
    expect(TipoPregunta.opcionMultiple.seleccionMultiple, isTrue);
    expect(TipoPregunta.opcionUnica.seleccionMultiple, isFalse);
    expect(TipoPregunta.likert.seleccionMultiple, isFalse);
  });
}
