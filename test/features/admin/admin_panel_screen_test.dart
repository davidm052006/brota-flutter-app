import 'dart:convert';
import 'dart:typed_data';

import 'package:brota_flutter_app/core/network/network_providers.dart';
import 'package:brota_flutter_app/core/result/result.dart';
import 'package:brota_flutter_app/features/admin/presentation/screens/admin_panel_screen.dart';
import 'package:brota_flutter_app/features/auth/domain/app_user.dart';
import 'package:brota_flutter_app/features/auth/domain/auth_repository.dart';
import 'package:brota_flutter_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _FakeAdminApi api;
  late Dio dio;

  setUp(() {
    api = _FakeAdminApi();
    dio = Dio(BaseOptions(baseUrl: 'http://localhost:3001/api'))
      ..httpClientAdapter = api;
  });

  tearDown(() => dio.close(force: true));

  testWidgets('permite entrar al panel y carga la lista de usuarios', (
    tester,
  ) async {
    await _pumpPanel(tester, dio, _TestAuthRepository());
    await tester.pumpAndSettle();

    expect(find.text('Panel de administración'), findsOneWidget);
    expect(find.text('Administrador'), findsOneWidget);
    expect(find.text('Ana Pérez'), findsOneWidget);
    expect(
      api.requests.any((request) => request.path == '/admin/usuarios'),
      isTrue,
    );
  });

  testWidgets('rechaza el acceso cuando el perfil no es administrador', (
    tester,
  ) async {
    await _pumpPanel(tester, dio, _TestAuthRepository(), role: 'estudiante');
    await tester.pumpAndSettle();

    expect(
      find.text('Esta sección está disponible solo para administradores.'),
      findsOneWidget,
    );
    expect(find.text('Administrador'), findsNothing);
    expect(
      api.requests.any((request) => request.path.startsWith('/admin/')),
      isFalse,
    );
  });

  testWidgets('crea un cuestionario usando el endpoint administrativo', (
    tester,
  ) async {
    await _pumpPanel(tester, dio, _TestAuthRepository());
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView).first, const Offset(-600, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cuestionarios'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'RIASEC móvil');
    await tester.enterText(find.byType(TextFormField).at(1), '2');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    final createRequest = api.requests.lastWhere(
      (request) =>
          request.method == 'POST' && request.path == '/admin/cuestionarios',
    );
    expect(createRequest.data, {
      'nombre': 'RIASEC móvil',
      'version': '2',
      'descripcion': null,
      'activo': false,
    });
  });

  testWidgets('edita y elimina un cuestionario usando PATCH y DELETE', (
    tester,
  ) async {
    api.questionnaires.add({
      'id': 'questionnaire-1',
      'nombre': 'RIASEC base',
      'version': '1',
      'descripcion': 'Descripción inicial',
      'activo': false,
    });
    await _pumpPanel(tester, dio, _TestAuthRepository());
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(-600, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cuestionarios'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).first,
      'RIASEC actualizado',
    );
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(
      api.requests.any(
        (request) =>
            request.method == 'PATCH' &&
            request.path == '/admin/cuestionarios/questionnaire-1',
      ),
      isTrue,
    );

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
    await tester.pumpAndSettle();

    expect(
      api.requests.any(
        (request) =>
            request.method == 'DELETE' &&
            request.path == '/admin/cuestionarios/questionnaire-1',
      ),
      isTrue,
    );
  });
}

Future<void> _pumpPanel(
  WidgetTester tester,
  Dio dio,
  AuthRepository authRepository, {
  String role = 'admin',
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dioProvider.overrideWithValue(dio),
        authRepositoryProvider.overrideWithValue(authRepository),
      ],
      child: const MaterialApp(home: AdminPanelScreen()),
    ),
  );
  // The fake response can return either role without exposing credentials.
  _FakeAdminApi.currentRole = role;
}

class _TestAuthRepository implements AuthRepository {
  @override
  AppUser? get currentUser =>
      const AppUser(id: 'test-user', email: 'test@brota.dev');

  @override
  Stream<AppUser?> authStateChanges() => Stream.value(currentUser);

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

class _FakeAdminApi implements HttpClientAdapter {
  static String currentRole = 'admin';
  final List<RequestOptions> requests = [];
  final List<Map<String, dynamic>> questionnaires = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    dynamic body;
    var status = 200;

    if (options.path == '/perfil/test-user') {
      body = {
        'success': true,
        'data': {'rol': currentRole},
      };
    } else if (options.path == '/admin/usuarios' && options.method == 'GET') {
      body = {
        'success': true,
        'data': [
          {
            'id': 'user-1',
            'nombre': 'Ana Pérez',
            'apellido': 'López',
            'email': 'ana@brota.dev',
            'rol': 'estudiante',
          },
        ],
        'meta': {'totalPaginas': 1},
      };
    } else if (options.path == '/admin/cuestionarios' &&
        options.method == 'GET') {
      body = {'success': true, 'data': questionnaires};
    } else if (options.path == '/admin/cuestionarios' &&
        options.method == 'POST') {
      status = 201;
      questionnaires.add(Map<String, dynamic>.from(options.data as Map));
      body = {'success': true, 'data': options.data};
    } else if (options.path.startsWith('/admin/cuestionarios/') &&
        options.method == 'PATCH') {
      final id = options.path.split('/').last;
      final index = questionnaires.indexWhere((row) => row['id'] == id);
      if (index >= 0) {
        questionnaires[index] = {
          ...questionnaires[index],
          ...Map<String, dynamic>.from(options.data as Map),
        };
      }
      body = {'success': true};
    } else if (options.path.startsWith('/admin/cuestionarios/') &&
        options.method == 'DELETE') {
      final id = options.path.split('/').last;
      questionnaires.removeWhere((row) => row['id'] == id);
      body = {'success': true};
    } else {
      body = {'success': true, 'data': []};
    }

    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
