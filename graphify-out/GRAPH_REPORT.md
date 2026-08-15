# Graph Report - .  (2026-08-05)

## Corpus Check
- Corpus is ~36,480 words - fits in a single context window. You may not need a graph.

## Summary
- 420 nodes · 520 edges · 26 communities (25 shown, 1 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 2 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Auth Repository & Data Layer
- Color Tokens (Design System)
- Networking (Dio + Interceptors)
- Shared UI Widgets
- Auth Form State (Freezed)
- Linux Runner (GTK)
- Radius Tokens (Design System)
- Result/Failure Handling
- App Shell & Router
- iOS AppDelegate
- Register Screen
- App Theme Assembly
- Dashboard Screen & Tests
- Login Screen
- Auth Screens Routing
- Typography Tokens (Design System)
- Web App Manifest
- Forgot Password Screen
- App Env Config
- Router Refresh Stream
- AppUser Entity
- Android MainActivity

## God Nodes (most connected - your core abstractions)
1. `Failure` - 7 edges
2. `AuthRepository` - 7 edges
3. `_MyApplication` - 7 edges
4. `AppDelegate` - 5 edges
5. `themeModeProvider` - 5 edges
6. `DashboardScreen` - 5 edges
7. `BrotaApp` - 4 edges
8. `Result` - 4 edges
9. `_ForgotPasswordScreenState` - 4 edges
10. `_LoginScreenState` - 4 edges

## Surprising Connections (you probably didn't know these)
- `AuthRepositoryImpl` --implements--> `AuthRepository`  [EXTRACTED]
  lib/features/auth/data/auth_repository_impl.dart → lib/features/auth/domain/auth_repository.dart
- `my_application_activate()` --calls--> `fl_register_plugins()`  [INFERRED]
  linux/runner/my_application.cc → linux/flutter/generated_plugin_registrant.cc
- `main()` --calls--> `my_application_new()`  [INFERRED]
  linux/runner/main.cc → linux/runner/my_application.cc
- `BrotaApp` --references--> `routerProvider`  [EXTRACTED]
  lib/app/brota_app.dart → lib/core/router/app_router.dart
- `BrotaApp` --references--> `themeModeProvider`  [EXTRACTED]
  lib/app/brota_app.dart → lib/core/theme/theme_mode_provider.dart

## Import Cycles
- None detected.

## Communities (26 total, 1 thin omitted)

### Community 0 - "Auth Repository & Data Layer"
Cohesion: 0.07
Nodes (35): app_user.dart, AppUser? get, auth_form_state.dart, ../../../../core/network/network_providers.dart, ../../../core/result/failure.dart, ../../../../core/result/result.dart, ../../data/auth_repository_impl.dart, ../../domain/app_user.dart (+27 more)

### Community 1 - "Color Tokens (Design System)"
Cohesion: 0.05
Nodes (38): AppColors, darkBackground, darkSurfaceContainer, error, errorContainer, inversePrimary, lightBackground, lightInverseSurface (+30 more)

### Community 2 - "Networking (Dio + Interceptors)"
Cohesion: 0.08
Nodes (26): app/brota_app.dart, auth_interceptor.dart, core/env/app_env.dart, Dio, dio_client.dart, ../env/app_env.dart, Interceptor, _extractServerMessage (+18 more)

### Community 3 - "Shared UI Widgets"
Cohesion: 0.07
Nodes (27): ../../core/theme/app_radii.dart, IconData, Iterable, _Header, _RegisterFooter, BrotaPrimaryButton, build, isLoading (+19 more)

### Community 4 - "Auth Form State (Freezed)"
Cohesion: 0.08
Nodes (27): @freezed, AuthFormState, AuthFormStatus get, AuthFormStatus status, String?, _, AuthFormStatePatterns, class, errorMessage (+19 more)

### Community 5 - "Linux Runner (GTK)"
Cohesion: 0.09
Nodes (22): FlPluginRegistry, FlView, GApplication, gboolean, gchar, GObject, GtkApplication, fl_register_plugins() (+14 more)

### Community 6 - "Radius Tokens (Design System)"
Cohesion: 0.07
Nodes (25): AppRadii, full, fullRadius, lg, lgRadius, md, mdRadius, sm (+17 more)

### Community 7 - "Result/Failure Handling"
Cohesion: 0.11
Nodes (24): bool get, failure.dart, Failure? get, int?, AuthFailure, Failure, message, NetworkFailure (+16 more)

### Community 8 - "App Shell & Router"
Cohesion: 0.10
Nodes (24): ConsumerWidget, ../core/router/app_router.dart, ../core/theme/app_theme.dart, ../../../../core/theme/theme_mode_provider.dart, ../../features/auth/domain/auth_repository.dart, ../../features/auth/presentation/providers/auth_providers.dart, ../../features/auth/presentation/screens/forgot_password_screen.dart, ../../features/auth/presentation/screens/login_screen.dart (+16 more)

### Community 9 - "iOS AppDelegate"
Cohesion: 0.11
Nodes (14): Any, Bool, Flutter, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, FlutterSceneDelegate, AppDelegate (+6 more)

### Community 10 - "Register Screen"
Cohesion: 0.15
Nodes (14): ../controllers/register_controller.dart, FormState, registerControllerProvider, build, _confirmPasswordController, createState, dispose, _emailController (+6 more)

### Community 11 - "App Theme Assembly"
Cohesion: 0.15
Nodes (12): app_colors.dart, app_radii.dart, app_spacing.dart, app_typography.dart, AppTheme, _build, dark, _darkScheme (+4 more)

### Community 12 - "Dashboard Screen & Tests"
Cohesion: 0.17
Nodes (10): ../../../auth/presentation/providers/auth_providers.dart, ../../../../core/theme/app_spacing.dart, ../../core/theme/app_typography.dart, package:brota_flutter_app/shared/widgets/brota_text_field.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart, package:flutter_test/flutter_test.dart, StateProvider (+2 more)

### Community 13 - "Login Screen"
Cohesion: 0.15
Nodes (12): ColorScheme, ../controllers/login_controller.dart, createState, dispose, _emailController, _formKey, isLoading, _obscurePassword (+4 more)

### Community 14 - "Auth Screens Routing"
Cohesion: 0.18
Nodes (12): ConsumerState, ConsumerStatefulWidget, forgotPasswordControllerProvider, loginControllerProvider, build, ForgotPasswordScreen, _ForgotPasswordScreenState, build (+4 more)

### Community 15 - "Typography Tokens (Design System)"
Cohesion: 0.18
Nodes (10): AppTypography, bodyLg, bodyMd, button, displayLg, headlineLgMobile, headlineMd, _jakarta (+2 more)

### Community 16 - "Web App Manifest"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 17 - "Forgot Password Screen"
Cohesion: 0.20
Nodes (9): ../controllers/auth_form_state.dart, ../controllers/forgot_password_controller.dart, createState, dispose, _emailController, _formKey, _submit, ../../../../shared/widgets/brota_primary_button.dart (+1 more)

### Community 18 - "App Env Config"
Cohesion: 0.22
Nodes (8): apiBaseUrl, AppEnv, load, _require, supabaseAnonKey, supabaseUrl, package:flutter_dotenv/flutter_dotenv.dart, static String get

### Community 19 - "Router Refresh Stream"
Cohesion: 0.25
Nodes (7): ChangeNotifier, dart:async, dispose, GoRouterRefreshStream, _subscription, package:flutter/foundation.dart, StreamSubscription

### Community 20 - "AppUser Entity"
Cohesion: 0.50
Nodes (3): AppUser, email, id

## Knowledge Gaps
- **192 isolated node(s):** `XCTest`, `AppEnv`, `supabaseUrl`, `supabaseAnonKey`, `apiBaseUrl` (+187 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AuthRepository` connect `Auth Repository & Data Layer` to `App Shell & Router`?**
  _High betweenness centrality (0.023) - this node is a cross-community bridge._
- **Why does `build` connect `Auth Screens Routing` to `Login Screen`?**
  _High betweenness centrality (0.009) - this node is a cross-community bridge._
- **What connects `XCTest`, `AppEnv`, `supabaseUrl` to the rest of the system?**
  _192 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Auth Repository & Data Layer` be split into smaller, more focused modules?**
  _Cohesion score 0.06829268292682927 - nodes in this community are weakly interconnected._
- **Should `Color Tokens (Design System)` be split into smaller, more focused modules?**
  _Cohesion score 0.05128205128205128 - nodes in this community are weakly interconnected._
- **Should `Networking (Dio + Interceptors)` be split into smaller, more focused modules?**
  _Cohesion score 0.07526881720430108 - nodes in this community are weakly interconnected._
- **Should `Shared UI Widgets` be split into smaller, more focused modules?**
  _Cohesion score 0.07142857142857142 - nodes in this community are weakly interconnected._