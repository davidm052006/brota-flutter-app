# Brota — Flutter App

App móvil de Brota. Existe un backend/frontend web hermano (referenciados en
comentarios como `backend/src/...` y `frontend/src/...`); cuando el
comportamiento deba igualar al del web, revisa esas rutas antes de inventar
uno nuevo. En este equipo el hermano vive en
`/home/david/Proyectos/Documentacion_Brota/` (`frontend/src/`,
`backend/src/`) — es un repo Git aparte, no una carpeta de este proyecto.

`MOBILE_DESIGN_BRIEF.md` (raíz del repo) es el dossier de referencia para
diseñar la versión móvil: mapa completo de pantallas del web (públicas +
dashboard), qué endpoint de `backend/src/` habla cada una, y el sistema de
marca real extraído de `frontend/src/index.css`. Consúltalo antes de
diseñar cualquier pantalla nueva — evita inventar layouts o copys que el
producto ya resolvió en el web.

## Grafo de conocimiento (graphify)

`graphify-out/graph.json` (+ `graph.html` navegable, `GRAPH_REPORT.md`)
es un grafo de dependencias generado solo con extracción estructural
(AST de Dart — **sin subagentes ni API de IA**, así se construyó
deliberadamente para este repo). Cubre `lib/**/*.dart` — no incluye
`MOBILE_DESIGN_BRIEF.md` ni las imágenes de `design_reference/` porque
esa capa semántica se omitió a propósito. Para navegar dependencias entre
clases/archivos antes de tocar código, usa `graphify query "<pregunta>"`
o abre `graphify-out/graph.html`. Regenerar tras cambios grandes de
estructura con `/graphify --update`.

## Arquitectura: Clean Architecture por feature

Cada feature vive en `lib/features/<nombre>/` con tres capas. La regla de
dependencia es de un solo sentido: **presentation → domain ← data**. El
dominio no importa nada de `data` ni de `presentation`, ni de paquetes de
Flutter/Supabase/Dio.

```
features/<nombre>/
  domain/        Entidades planas + contratos abstractos (interfaces).
                 Sin lógica de red, sin Flutter, sin Supabase/Dio.
  data/          Implementaciones concretas de esos contratos
                 (`<X>RepositoryImpl`). Aquí sí vive Supabase/Dio y el
                 mapeo de excepciones a Failure.
  presentation/
    controllers/   StateNotifier + su StateNotifierProvider. Un método
                   público por caso de uso (`submit`, `loadX`, ...).
    providers/     Providers que exponen repositorios/servicios al resto
                   de presentation (p.ej. `authRepositoryProvider`).
    screens/       Widgets de pantalla completa (Scaffold).
```

`lib/core/` es transversal a todas las features: `network/` (Dio, mapeo de
errores), `result/` (`Result`/`Failure`), `router/` (go_router),
`theme/` (tokens de diseño), `env/` (config). `lib/shared/widgets/` son
widgets reutilizables sin estado de negocio (botones, inputs). Nada de
lógica de feature vive en `core` ni en `shared`.

**Antes de escribir código, ubica la capa correcta:**
- ¿Llama a Supabase/Dio/una API? → `data/`.
- ¿Es una regla de negocio o un contrato? → `domain/`.
- ¿Es UI, estado de UI o un provider de Riverpod? → `presentation/`.
- ¿Lo usan 2+ features tal cual, sin lógica de negocio? → `core/` o `shared/`.
- Si no encaja claramente en ninguna, es señal de que falta una feature
  nueva o de que el diseño está mal planteado — no lo fuerces en la que
  esté más a mano.

## Manejo de errores: `Result<T>` en el borde de I/O

Todo método de repositorio que toque red/DB devuelve `Future<Result<T>>`
(`lib/core/result/result.dart`), nunca lanza la excepción cruda hacia
arriba. El `catch` que traduce `DioException`/`AuthException`/etc. a un
`Failure` tipado (`lib/core/result/failure.dart`) vive en el `data/`, no en
el controller ni en la UI. Los controllers consumen con `result.fold(...)`
o `switch`. No metas `try/catch` en `presentation/` — si algo puede fallar
ahí, es que falta envolverlo en un repositorio.

## Estado: Riverpod

- Estado con lógica de casos de uso → `StateNotifier` + `StateNotifierProvider`
  (ver `LoginController`). El estado inmutable va en una clase `freezed`
  (`AuthFormState`).
- Estado simple sin lógica (toggles, flags de UI) → `StateProvider` directo
  (ver `themeModeProvider`), no crees un `StateNotifier` para esto.
- Los widgets nunca llaman `data/` directamente: siempre pasan por un
  provider/controller de `presentation/`.

## Reglas de código limpio

- **No repitas lo que ya existe.** Antes de escribir un widget, provider o
  helper, busca si `core/`, `shared/widgets/` o la feature ya tienen algo
  equivalente.
- **Cero lógica de negocio en widgets.** Un `build()` solo lee estado y
  dispara callbacks; cálculos, validaciones y llamadas async van en el
  controller o el repositorio.
- **Un archivo, una responsabilidad.** Si un archivo mezcla más de una
  capa (p.ej. un widget que también hace la llamada HTTP), sepáralo.
- **Sin abstracciones especulativas.** No agregues interfaces, parámetros
  opcionales o capas "por si acaso" para un caso de uso que no existe hoy.
  Tres líneas parecidas están bien; una abstracción prematura no.
- **Constructores const y `final`** en todo lo que lo permita (ya forzado
  por `analysis_options.yaml`: `prefer_const_constructors`,
  `prefer_final_fields`, `prefer_final_locals`, etc. — no los desactives).
- **Nombres explícitos, sin abreviar.** Sigue el estilo ya presente
  (`AuthRepository`, `LoginController`, `AppUser`) en vez de siglas propias.
- **UI en español, código en inglés.** Strings visibles al usuario van en
  español (como ya está en todo el repo); nombres de clases, métodos y
  variables en inglés.
- **No agregues dependencias nuevas en `pubspec.yaml`** para resolver algo
  que ya cubre una dependencia existente (Riverpod, Dio, go_router,
  freezed, Supabase). Si de verdad hace falta una nueva, dilo explícitamente
  antes de añadirla en vez de hacerlo en silencio.
- **Nada de comentarios que narren el "qué".** Solo comenta cuando el
  *por qué* no sea obvio (como los comentarios de `result.dart` o
  `auth_repository.dart` que explican una decisión, no lo que hace el código).

## Antes de dar por terminado un cambio

```bash
./flutter/bin/flutter analyze lib/
```

Debe salir "No issues found!" — el proyecto usa `strict-casts`,
`strict-inference` y `strict-raw-types`, además de las lint rules extra en
`analysis_options.yaml`. Si el cambio toca lógica con estado (`freezed`),
recuerda que el build_runner ya generó los `.g.dart`/`.freezed.dart`
existentes; no los edites a mano.

## Sistema de marca — fuente de verdad

`lib/core/theme/` (`AppColors`, `AppTypography`) refleja los tokens reales
del web (`frontend/src/index.css` `:root`/`html.dark`, documentados en
`MOBILE_DESIGN_BRIEF.md` sección 1.3-1.4): verde `#21BD68` (claro) /
`#34D27D` (oscuro), acento naranja `#E07A42`/`#F0996A`, tipografía dual
— **Bricolage Grotesque** para titulares/display, **Plus Jakarta Sans**
para cuerpo/UI.

Esto **no** es lo que había antes: el repo traía un sistema de marca
distinto en `design_reference/*/DESIGN.md` ("Organic Growth System",
verde `#006E2F`, una sola tipografía) usado para construir Login/Register.
Se migró (2026-08-05) a los tokens reales del web porque:
1. El propio `MOBILE_DESIGN_BRIEF.md` advierte que cualquier fuente que no
   sea `frontend/src/index.css` está desactualizada (incluido `BRAND.md`
   en el repo web) y prohíbe explícitamente inventar una paleta nueva.
2. La regla de la sección de arriba (igualar el comportamiento del web) es
   más fuerte para decisiones de marca que un mockup de referencia previo.
3. La migración fue de bajo riesgo: todas las pantallas y widgets
   compartidos (`BrotaPrimaryButton`, `BrotaTextField`, screens de auth)
   consumen `Theme.of(context).colorScheme` / `AppTypography.*`, nunca
   `AppColors` directamente — solo `app_theme.dart` referencia `AppColors`,
   así que el rebrand se propaga solo.

(2026-08-15) Los mockups viejos de Login (`design_reference/login_dark/`,
`login_light/`) se borraron — quedaron reemplazados por
`design_reference/general/brota-handoff/` (`DESIGN-SPEC.md` + 4 galerías
HTML, 33 pantallas). Mismo criterio de siempre aplicado a este paquete
nuevo: **layout/componentes/spacing sí, color/tipografía no** — su
paleta es verde Tailwind genérico (`#16A34A`) e Inter, ninguno de los dos
es real de marca. Mapeo de sus tokens a los de arriba:
`MOBILE_DESIGN_BRIEF.md` §1.8.

No hay token web para `error`/`danger` (el `Button.jsx` del web cae a un
rojo Tailwind genérico) — `AppColors` usa rojo estándar (`#EF4444` claro /
`#F87171` oscuro) por convención, no por un valor de marca real.

**Mascota — se llama "Broti" (corregido 2026-08-23, NO es exclusiva del
móvil):** `assets/icons/*.svg` — perezoso con lentes y una hojita, 4
variantes de expresión (`logo-base-limpio`/`logo-guino`/`logo-triste`/
`logo-feliz`), verde del marco/hoja alineado al `#21BD68` de arriba.
Requiere `flutter_svg` (agregado a `pubspec.yaml`) porque Flutter no
renderiza SVG nativo. **Es la misma mascota que el web ya tiene con
nombre propio y sistema de personalización** (`perfiles_usuario.
broti_config`, catálogo de variantes/fondos) — el móvil todavía no lo
replica. Detalle completo: `MOBILE_DESIGN_BRIEF.md` §1.2.1,
`FUNCTIONAL_CONTENT_BRIEF.md` §8, `assets/icons/README.md` y
`WEB_PARITY_ROADMAP.md` §1.3.

## Estado de la implementación

`auth` y `profesiones` están completos (`AuthRepositoryImpl` sobre
Supabase; `ProgramasRepositoryImpl` sobre Dio/backend Express, con
búsqueda debounced, paginación "cargar más" y filtro de área
server-side + modalidad client-side — ver `FUNCTIONAL_CONTENT_BRIEF.md`
sección 2 y `WEB_PARITY_ROADMAP.md` §4 Fase A). Todo lo demás del mapa
de pantallas en `MOBILE_DESIGN_BRIEF.md` sección 2 (Landing pública,
Test vocacional, Recursos, Comunidad, Admin) **no existe todavía** —
`lib/features/dashboard/` es un placeholder de una sola pantalla (con los
íconos/mascota de marca ya integrados, ver commits recientes). Antes de
construir una feature nueva, revisa la sección 2-3 del brief para el mapa
de pantallas y endpoints, y el grafo (`graphify query`) para ver qué ya
existe en `lib/` que se pueda reutilizar.

⚠️ **`MOBILE_DESIGN_BRIEF.md` y `FUNCTIONAL_CONTENT_BRIEF.md` son del
2026-08-05** y el web hermano avanzó bastante desde entonces (rediseño de
dashboard, Rutas ya real, pantallas nuevas: Perfil/Racha/Broti/
Notificaciones). Ambos briefs ya se corrigieron en los puntos que
cambiaron — pero antes de construir cualquier feature nueva, lee primero
`WEB_PARITY_ROADMAP.md`: tiene el inventario de endpoints fresco y las
fases sugeridas, y prevalece sobre los briefs viejos donde haya
conflicto.

**Antes de empezar cualquier fase de `WEB_PARITY_ROADMAP.md`, lee
`~/Proyectos/Documentacion_Brota/CHANGELOG_PARA_MOVIL.md`** (repo
hermano) — desde el 2026-08-23 el proyecto web deja ahí un registro
incremental de cambios que afectan al móvil (endpoints, esquema,
pantallas, marca). Si ese changelog tiene entradas más nuevas que la
última fecha revisada acá, hay que incorporarlas antes de confiar en los
tres documentos — es mucho más barato que repetir la auditoría manual
completa que generó `WEB_PARITY_ROADMAP.md`.

## Entorno local

- El SDK de Flutter vive embebido en `flutter/` dentro del propio repo
  (no está en un `PATH` global de forma confiable para apps GUI) — usa
  `./flutter/bin/flutter` o confía en que VS Code ya tiene
  `dart.flutterSdkPath` apuntando ahí (`.vscode/settings.json`).
- Dispositivo web de desarrollo: Opera GX vía `CHROME_EXECUTABLE`, ver
  `.vscode/launch.json` (config "brota (Opera GX - Web)").
