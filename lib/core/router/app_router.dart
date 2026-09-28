import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/auth_repository.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/comunidad/presentation/screens/comunidad_screen.dart';
import '../../features/cuestionarios/presentation/screens/cuestionario_form_screen.dart';
import '../../features/cuestionarios/presentation/screens/cuestionarios_screen.dart';
import '../../features/cuestionarios/presentation/screens/pregunta_form_screen.dart';
import '../../features/cuestionarios/presentation/screens/preguntas_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/profesiones/presentation/screens/profesiones_screen.dart';
import '../../features/recursos/presentation/screens/recursos_screen.dart';
import '../../features/rutas/presentation/screens/rutas_screen.dart';
import '../../features/test_vocacional/presentation/screens/test_vocacional_screen.dart';
import 'dashboard_shell.dart';
import 'go_router_refresh_stream.dart';

const Set<String> _publicRoutes = {'/login', '/register', '/forgot-password'};

/// App-wide route table. Mirrors the auth-gated split in
/// `frontend/src/App.jsx` (`puedeAcceder` inline guard): everything
/// outside [_publicRoutes] requires a Supabase session, enforced here
/// once instead of per-screen.
final Provider<GoRouter> routerProvider = Provider<GoRouter>((ref) {
  final AuthRepository authRepository = ref.watch(authRepositoryProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(authRepository.authStateChanges()),
    redirect: (context, state) {
      final bool isLoggedIn = authRepository.currentUser != null;
      final bool isPublicRoute = _publicRoutes.contains(state.matchedLocation);

      if (!isLoggedIn && !isPublicRoute) return '/login';
      if (isLoggedIn && isPublicRoute) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/dashboard/rutas',
        builder: (context, state) => const RutasScreen(),
      ),
      // CRUD de cuestionarios (solo cuentas con rol institución). Va fuera del
      // StatefulShellRoute a propósito: sus branches son fijos y esto es un
      // flujo con push/pop propio, no una sexta pestaña de la barra.
      GoRoute(
        path: '/dashboard/cuestionarios',
        builder: (context, state) => const CuestionariosScreen(),
        routes: [
          GoRoute(
            path: 'nuevo',
            builder: (context, state) => const CuestionarioFormScreen(),
          ),
          GoRoute(
            path: ':id/editar',
            builder: (context, state) => CuestionarioFormScreen(
              cuestionarioId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: ':id/preguntas',
            builder: (context, state) => PreguntasScreen(
              cuestionarioId: state.pathParameters['id']!,
              nombreCuestionario: state.extra as String?,
            ),
            routes: [
              GoRoute(
                path: 'nueva',
                builder: (context, state) => PreguntaFormScreen(
                  cuestionarioId: state.pathParameters['id']!,
                ),
              ),
              GoRoute(
                path: ':preguntaId',
                builder: (context, state) => PreguntaFormScreen(
                  cuestionarioId: state.pathParameters['id']!,
                  preguntaId: state.pathParameters['preguntaId']!,
                ),
              ),
            ],
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            DashboardShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard/profesiones',
                builder: (context, state) => const ProfesionesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard/test',
                builder: (context, state) => const TestVocacionalScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard/recursos',
                builder: (context, state) => const RecursosScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard/comunidad',
                builder: (context, state) => const ComunidadScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
