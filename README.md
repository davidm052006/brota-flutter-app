# Brota — App móvil

App móvil de Brota (Flutter), plataforma colombiana de orientación
vocacional gratuita para estudiantes de bachillerato. Hermana de un
proyecto web (React + Express + Supabase) que es la fuente de verdad de
marca, backend y lógica de negocio — ver `CLAUDE.md` para el detalle
completo de arquitectura y convenciones de este repo.

## Requisitos

- **Flutter 3.44.8** (channel `stable`, Dart `3.12.2`) — instalar desde
  [flutter.dev](https://docs.flutter.dev/get-started/install) o con
  [FVM](https://fvm.app/) si manejas varias versiones. Verificar con:
  ```bash
  flutter --version
  ```
- Git.
- Un editor con soporte Dart/Flutter (VS Code recomendado — el repo trae
  `.vscode/launch.json` con una config lista para correr en Chrome).

> Nota: este repo trae una carpeta `flutter/` en `.gitignore` — es el SDK
> embebido que usa una de las máquinas del equipo para no depender del
> `PATH` global, pero **no se versiona**. Usa tu propio `flutter` del
> `PATH` normalmente.

## Poner el proyecto a andar

```bash
git clone <url-de-este-repo>
cd brota_flutter_app

cp .env.example .env
# completa .env con las keys reales de Supabase/backend (pídeselas a David)

flutter pub get
flutter run -d chrome   # o -d linux / un emulador / dispositivo físico
```

## Variables de entorno (`.env`)

Ver `.env.example` — se necesitan `SUPABASE_URL`, `SUPABASE_ANON_KEY` y
`API_BASE_URL` (backend Express, ver `lib/core/env/app_env.dart`). Sin
estas variables la app lanza un error explícito al arrancar en vez de
fallar en silencio.

## Comandos útiles

```bash
flutter analyze lib/    # debe salir "No issues found!" antes de cualquier PR
flutter test            # tests unitarios/widget
```

## Dónde orientarte

- **`CLAUDE.md`** — arquitectura (Clean Architecture por feature),
  convenciones de código, sistema de marca y estado real de cada
  feature. Léelo antes de tocar código.
- **`MOBILE_DESIGN_BRIEF.md`** — mapa de pantallas, sistema de diseño
  (colores/tipografía/iconografía) y qué mockups de referencia usar.
- **`FUNCTIONAL_CONTENT_BRIEF.md`** — lógica de negocio y endpoints de
  cada pantalla que todavía es placeholder.
- **`design_reference/general/brota-handoff/`** — mockups HTML del
  rediseño visual en curso (33 pantallas).
