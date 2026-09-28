import 'package:brota_flutter_app/core/result/failure.dart';
import 'package:brota_flutter_app/core/result/result.dart';
import 'package:brota_flutter_app/features/cuestionarios/domain/cuestionario.dart';
import 'package:brota_flutter_app/features/cuestionarios/domain/cuestionarios_repository.dart';
import 'package:brota_flutter_app/features/cuestionarios/domain/opcion_pregunta.dart';
import 'package:brota_flutter_app/features/cuestionarios/domain/pregunta.dart';
import 'package:brota_flutter_app/features/cuestionarios/domain/tipo_pregunta.dart';
import 'package:brota_flutter_app/features/cuestionarios/presentation/providers/cuestionarios_providers.dart';
import 'package:brota_flutter_app/features/cuestionarios/presentation/screens/cuestionario_form_screen.dart';
import 'package:brota_flutter_app/features/cuestionarios/presentation/screens/cuestionarios_screen.dart';
import 'package:brota_flutter_app/features/cuestionarios/presentation/screens/pregunta_form_screen.dart';
import 'package:brota_flutter_app/features/cuestionarios/presentation/screens/preguntas_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Doble en memoria del repositorio. Las pantallas se prueban contra esto y no
/// contra Dio: lo que interesa acá es qué estado se pinta, no el transporte.
final class _FakeRepository implements CuestionariosRepository {
  _FakeRepository({
    this.cuestionarios = const [],
    this.preguntas = const [],
    this.failure,
  });

  List<Cuestionario> cuestionarios;
  List<Pregunta> preguntas;
  final Failure? failure;

  PreguntaInput? ultimaPreguntaCreada;
  CuestionarioInput? ultimoCuestionarioCreado;

  Result<T> _resultado<T>(T value) =>
      failure != null ? ResultError<T>(failure!) : Success<T>(value);

  @override
  Future<Result<List<Cuestionario>>> getCuestionarios() async =>
      _resultado(cuestionarios);

  @override
  Future<Result<Cuestionario>> crearCuestionario(CuestionarioInput input) async {
    ultimoCuestionarioCreado = input;
    return _resultado(
      Cuestionario(id: 'nuevo', nombre: input.nombre, version: input.version),
    );
  }

  @override
  Future<Result<Cuestionario>> actualizarCuestionario(
    String id,
    CuestionarioInput input,
  ) async => _resultado(
    Cuestionario(id: id, nombre: input.nombre, version: input.version),
  );

  @override
  Future<Result<void>> eliminarCuestionario(String id) async =>
      _resultado(null);

  @override
  Future<Result<List<Pregunta>>> getPreguntas(String cuestionarioId) async =>
      _resultado(preguntas);

  @override
  Future<Result<Pregunta>> crearPregunta(PreguntaInput input) async {
    ultimaPreguntaCreada = input;
    return _resultado(
      Pregunta(
        id: 'p-nueva',
        cuestionarioId: input.cuestionarioId,
        texto: input.texto,
        tipo: input.tipo,
        orden: 0,
        opciones: input.opciones,
      ),
    );
  }

  @override
  Future<Result<Pregunta>> actualizarPregunta(
    String id,
    PreguntaInput input,
  ) async => _resultado(
    Pregunta(
      id: id,
      cuestionarioId: input.cuestionarioId,
      texto: input.texto,
      tipo: input.tipo,
      orden: 0,
      opciones: input.opciones,
    ),
  );

  @override
  Future<Result<void>> eliminarPregunta(String id) async => _resultado(null);
}

Widget _app(Widget child, _FakeRepository repo) {
  return ProviderScope(
    overrides: [
      cuestionariosRepositoryProvider.overrideWithValue(repo),
    ],
    child: MaterialApp(home: child),
  );
}

const Cuestionario _cuestionarioDemo = Cuestionario(
  id: 'c1',
  nombre: 'Test interno de once',
  version: '1.0',
  activo: true,
  numPreguntas: 3,
);

void main() {
  group('CuestionariosScreen', () {
    testWidgets('muestra el estado vacío con su llamada a la acción', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(const CuestionariosScreen(), _FakeRepository()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Todavía no tenés cuestionarios'), findsOneWidget);
      expect(find.text('Crear cuestionario'), findsOneWidget);
    });

    testWidgets('lista los cuestionarios con su badge de activo', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const CuestionariosScreen(),
          _FakeRepository(cuestionarios: const [_cuestionarioDemo]),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Test interno de once'), findsOneWidget);
      expect(find.text('Activo'), findsOneWidget);
      expect(find.textContaining('3 preguntas'), findsOneWidget);
    });

    testWidgets('ante un error ofrece reintentar, no pantalla en blanco', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const CuestionariosScreen(),
          _FakeRepository(failure: const NetworkFailure()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Reintentar'), findsOneWidget);
    });
  });

  group('CuestionarioFormScreen', () {
    testWidgets('no deja crear sin nombre', (tester) async {
      final _FakeRepository repo = _FakeRepository();
      await tester.pumpWidget(_app(const CuestionarioFormScreen(), repo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Crear'));
      await tester.pumpAndSettle();

      expect(find.text('El nombre es obligatorio'), findsOneWidget);
      expect(repo.ultimoCuestionarioCreado, isNull);
    });

    testWidgets('crea con nombre y versión', (tester) async {
      final _FakeRepository repo = _FakeRepository();
      await tester.pumpWidget(_app(const CuestionarioFormScreen(), repo));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'Mi test');
      await tester.tap(find.text('Crear'));
      await tester.pumpAndSettle();

      expect(repo.ultimoCuestionarioCreado?.nombre, 'Mi test');
    });
  });

  group('PreguntasScreen', () {
    testWidgets('muestra el badge del tipo de cada pregunta', (tester) async {
      await tester.pumpWidget(
        _app(
          const PreguntasScreen(cuestionarioId: 'c1'),
          _FakeRepository(
            preguntas: const [
              Pregunta(
                id: 'p1',
                cuestionarioId: 'c1',
                texto: '¿Qué te gusta?',
                // Alias legado: debe mostrarse con su label canónico.
                tipo: TipoPregunta.opcionMultiple,
                orden: 1,
                opciones: [
                  OpcionPregunta(label: 'a', orden: 0),
                  OpcionPregunta(label: 'b', orden: 1),
                ],
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('¿Qué te gusta?'), findsOneWidget);
      expect(find.text('Opción múltiple'), findsOneWidget);
      expect(find.text('2 opciones'), findsOneWidget);
    });

    testWidgets('estado vacío invita a agregar la primera', (tester) async {
      await tester.pumpWidget(
        _app(const PreguntasScreen(cuestionarioId: 'c1'), _FakeRepository()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Agregar pregunta'), findsOneWidget);
    });
  });

  group('PreguntaFormScreen', () {
    testWidgets('arranca con 2 opciones vacías para opción única', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const PreguntaFormScreen(cuestionarioId: 'c1'),
          _FakeRepository(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Opción 1'), findsOneWidget);
      expect(find.text('Opción 2'), findsOneWidget);
      expect(find.text('Opción 3'), findsNothing);
    });

    testWidgets('al elegir Likert precarga las 5 etiquetas de la escala', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const PreguntaFormScreen(cuestionarioId: 'c1'),
          _FakeRepository(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<TipoPregunta>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Escala Likert').last);
      await tester.pumpAndSettle();

      expect(find.text('Opción 5'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Neutral'), findsOneWidget);
    });

    testWidgets('no guarda si alguna opción quedó sin texto', (tester) async {
      final _FakeRepository repo = _FakeRepository();
      await tester.pumpWidget(
        _app(const PreguntaFormScreen(cuestionarioId: 'c1'), repo),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, '¿Qué te gusta?');
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Crear'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Crear'));
      await tester.pumpAndSettle();

      expect(find.text('Todas las opciones necesitan texto.'), findsOneWidget);
      expect(repo.ultimaPreguntaCreada, isNull);
    });
  });
}
