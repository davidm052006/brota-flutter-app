import 'package:brota_flutter_app/core/result/failure.dart';
import 'package:brota_flutter_app/core/result/result.dart';
import 'package:brota_flutter_app/features/auth/domain/app_user.dart';
import 'package:brota_flutter_app/features/auth/domain/auth_repository.dart';
import 'package:brota_flutter_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:brota_flutter_app/features/test_vocacional/domain/test_vocacional_repository.dart';
import 'package:brota_flutter_app/features/test_vocacional/domain/test_vocacional_session.dart';
import 'package:brota_flutter_app/features/test_vocacional/presentation/providers/test_vocacional_providers.dart';
import 'package:brota_flutter_app/features/test_vocacional/presentation/screens/test_vocacional_screen.dart';
import 'package:brota_flutter_app/features/cuestionarios/domain/opcion_pregunta.dart';
import 'package:brota_flutter_app/features/cuestionarios/domain/pregunta.dart';
import 'package:brota_flutter_app/features/cuestionarios/domain/tipo_pregunta.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final String role in ['estudiante', 'admin']) {
    testWidgets('$role puede responder el test y ver su resultado', (
      tester,
    ) async {
      await _pumpScreen(tester, role);

      expect(find.text(_roleLabel(role)), findsOneWidget);
      expect(find.text('Comenzar test'), findsOneWidget);
      await tester.tap(find.text('Comenzar test'));
      await tester.pumpAndSettle();
      expect(find.text('¿Qué disfrutas?'), findsOneWidget);

      await tester.tap(find.text('Crear'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ver resultado'));
      await tester.pumpAndSettle();

      expect(find.text('Tu resultado'), findsOneWidget);
      expect(find.text('Tecnología'), findsNWidgets(2));
    });
  }

  testWidgets('una cuenta de institución recibe el mensaje de acceso', (
    tester,
  ) async {
    await _pumpScreen(tester, 'institucion');

    expect(
      find.text(
        'Las cuentas de institución administran cuestionarios y no realizan el test.',
      ),
      findsOneWidget,
    );
  });
}

Future<void> _pumpScreen(WidgetTester tester, String role) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(_TestAuthRepository()),
        testVocacionalRepositoryProvider.overrideWithValue(
          _FakeTestVocacionalRepository(role),
        ),
      ],
      child: const MaterialApp(home: TestVocacionalScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

String _roleLabel(String role) =>
    role == 'admin' ? 'Administrador' : 'Estudiante';

class _FakeTestVocacionalRepository implements TestVocacionalRepository {
  _FakeTestVocacionalRepository(this.role);

  final String role;

  @override
  Future<Result<TestVocacionalSession>> cargarTest(String userId) async {
    if (role == 'institucion') {
      return const ResultError<TestVocacionalSession>(
        AuthFailure(
          'Las cuentas de institución administran cuestionarios y no realizan el test.',
        ),
      );
    }
    return Success<TestVocacionalSession>(
      TestVocacionalSession(
        perfilId: 'profile-1',
        rol: role,
        cuestionarioId: 'quiz-1',
        nombreCuestionario: 'RIASEC',
        version: '1',
        preguntas: const [
          Pregunta(
            id: 'question-1',
            cuestionarioId: 'quiz-1',
            texto: '¿Qué disfrutas?',
            tipo: TipoPregunta.opcionUnica,
            orden: 1,
            peso: 1,
            opciones: [
              OpcionPregunta(
                id: 'option-1',
                label: 'Crear',
                icon: '💻',
                orden: 0,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Future<Result<VocationalTestResult>> guardarResultado({
    required String perfilId,
    required String cuestionarioId,
    required Map<String, List<String>> respuestas,
  }) async => const Success<VocationalTestResult>(
    VocationalTestResult(
      id: 'result-1',
      categoriaPrincipal: 'tecnologia',
      scores: [
        VocationalTestScore(
          categoria: 'tecnologia',
          puntos: 5,
          porcentaje: 100,
        ),
      ],
    ),
  );
}

class _TestAuthRepository implements AuthRepository {
  @override
  AppUser? get currentUser =>
      const AppUser(id: 'user-1', email: 'test@brota.dev');

  @override
  Stream<AppUser?> authStateChanges() => Stream<AppUser?>.value(currentUser);

  @override
  Future<Result<AppUser>> signInWithEmail({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<Result<AppUser>> signUpWithEmail({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> signOut() => throw UnimplementedError();
}
