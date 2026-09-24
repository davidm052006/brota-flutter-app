# Hoja de ruta — poner al día el móvil respecto al web

> Generado 2026-08-23 auditando `Documentacion_Brota/backend` y `/frontend`
> en vivo (grafo de graphify + exploración de código + `git log`), porque
> `MOBILE_DESIGN_BRIEF.md` y `FUNCTIONAL_CONTENT_BRIEF.md` son del
> 2026-08-05 y el repo web tuvo **48 commits** desde esa fecha — varias
> secciones de esos dos briefs ya no describen el web real. Este
> documento no los reemplaza (siguen siendo la base de arquitectura y
> del mapeo de pantallas que no cambió), pero **prevalece sobre ellos**
> en los puntos listados en la sección 1.

---

## 0. Estado actual del móvil (para contexto)

Solo `auth` está completo (login/registro/forgot-password, Supabase real).
`dashboard` tiene una pantalla con `HeroBanner`+`QuickActions`+
`ContinueSection` recién restilados (íconos de marca, mascota). El resto
(`test_vocacional`, `profesiones`, `recursos`, `comunidad`, `rutas`,
`admin`, `contacto`, `perfil`) son placeholders de solo `presentation/`,
sin `domain`/`data` — ver `CLAUDE.md` "Estado de la implementación".

## 1. Correcciones a lo ya documentado (léelas antes de seguir)

### 1.1 `HeroBanner`/`QuickActions`/`ContinueSection` ya no existen en el web
El commit `fbef308` ("Rediseña el dashboard...") los borró como código
muerto. El dashboard real hoy es `BannerCarousel` (carrusel de 5 slides,
autoplay) + `FeedReciente` (grid de últimas publicaciones de comunidad) +
`ProfileSidebar` (racha + frase del día) — ver detalle en sección 3. El
móvil construyó su dashboard actual espejando la estructura **vieja**
porque el brief que la documentaba (2026-08-05) es anterior al rediseño.
No es un error de esa sesión — el web cambió después.

### 1.2 La racha SÍ tiene datos reales — no es "no inventar datos" ya
`MOBILE_DESIGN_BRIEF.md` §1.7 y §1.2.2 asumieron que no había fuente de
datos para una tarjeta de racha, así que se documentó como pendiente.
Eso era cierto en el sentido de que el móvil no tenía el endpoint
mapeado, pero **sí existe**: `GET /api/perfil/:userId` devuelve
`racha_dias`/`ultima_actividad` (recalculados server-side en cada
llamada). La tarjeta de racha con `logo-feliz.svg` que se documentó como
dirección visual futura ya es implementable con datos reales, no hace
falta esperar una feature `perfil` nueva — falta construir esa feature
(domain/data), que es justo el siguiente punto.

### 1.3 La mascota del móvil se llama "Broti" en el web — mismo personaje
Hallazgo más importante de esta auditoría. `frontend/src/utils/
brotiCatalog.js` define `MASCOTA_BASE = '/logos/logo-feliz.svg'` — el
mismo archivo, mismo linaje Recraft (`logo base.svg`→`lentes.svg`→
variantes) que ya documenta `assets/icons/README.md` del móvil. Es la
misma mascota, generada en algún momento para ambos proyectos, pero:
- El móvil nunca la nombra "Broti" (ni en código ni en docs) — la llama
  genéricamente "mascota Brota — perezoso con lentes".
- El web ya tiene un sistema de personalización (`perfiles_usuario.
  broti_config` JSONB: `{variante, fondo}`, catálogo estático de
  variantes panda/zorro + fondos, `PATCH /api/perfil/:userId/broti`,
  componente `BrotiAvatar` que reemplazó el círculo-con-inicial en
  navbar/perfil/comunidad) que el móvil no tiene ni conoce.
- Si el móvil sigue sin usar `BrotiAvatar`-equivalente, un mismo usuario
  ve una identidad visual distinta en web vs. móvil (su Broti
  personalizado en web, el avatar genérico o nada en móvil).

**Acción recomendada, no urgente pero barata**: renombrar las referencias
a la mascota como "Broti" en docs/comentarios del móvil (no rompe nada,
es solo nomenclatura) y trackear el sistema de personalización como
feature futura (sección 4).

### 1.4 Reset-password es más barato de lo que se asumió en Fase 1
El plan de Fase 1 (auth) excluyó la pantalla de reset por asumir que
necesitaba trabajo de dominio nuevo. En realidad el web lo resuelve
100% con el SDK de Supabase (`resetPasswordForEmail` /
`verifyOtp(type:'recovery')` / `updateUser`), sin backend Express propio
— `supabase_flutter` expone los mismos métodos. Solo falta configurar el
deep link de retorno en el proyecto Supabase. Sigue sin ser parte de
Fase 1 (ya cerrada), pero es un candidato barato para una fase próxima,
no bloqueado por nada del lado de dominio salvo extender `AuthRepository`
con 3 métodos nuevos.

### 1.5 Google OAuth — confirmado que no existe en ningún lado
Ni frontend ni backend implementan `signInWithOAuth`. La exclusión del
botón de Google en Fase 1 (auth) fue la decisión correcta y sigue siendo
válida — no hay nada que consumir todavía.

---

## 2. Inventario fresco de endpoints (reemplaza la sección 3 de `FUNCTIONAL_CONTENT_BRIEF.md` donde difiera)

Todo bajo `/api`, backend Express + Supabase. `verificarAuth` = requiere
sesión; `verificarAdmin` = rol `admin`; `verificarModeracion` = rol
`admin` o `moderador`.

| Dominio | Endpoints | Nota |
|---|---|---|
| Auth | `POST /auth/register-perfil` | sin cambios |
| Perfil | `GET /perfil/cuestionario`, `POST /perfil/resultado`, `GET/DELETE /perfil/resultado/:id`, `GET /perfil/recomendaciones/:id`, `PATCH /perfil/recomendaciones/:id/vista`, `GET/PATCH /perfil/:userId`, **`PATCH /perfil/:userId/broti`** | el último es nuevo (Broti) |
| Programas | `GET /programas/stats`, `GET /programas` | sin cambios |
| **Rutas** | `GET /rutas`, `GET /rutas/:area` | **nuevo** — antes no existía, la pantalla era placeholder en ambos lados |
| Contacto | `POST /contacto` | sin cambios |
| Comunidad | foros/posts/historias/preguntas/convocatorias ya documentados, + **`GET /comunidad/notificaciones`**, **`GET /comunidad/feed`**, **`POST /preguntas/:id/reportar`**, **`/comunidad/moderacion/*`** (3 endpoints, solo admin/moderador) | 4 bloques nuevos |
| Admin | ya documentado, + **`GET /admin/analytics`** | nuevo, fuera de alcance móvil (panel admin ya excluido en `MOBILE_DESIGN_BRIEF.md` §2.2) |

Esquema real de `perfiles_usuario` (para el `domain/data` de una futura
feature `perfil`): `id, user_id, rol, nombre, apellido, edad, ciudad,
nivel_educativo, condiciones_socioeconomicas jsonb, ultima_actividad,
racha_dias, baneado_preguntas_hasta, broti_config jsonb`. Las tablas
`perfiles`/`perfiles_vocacionales` que a veces se mencionan en briefs
viejos **no existen** — no las repliques.

---

## 3. Qué pantallas nuevas/cambiadas tiene el web sin equivalente móvil

| Pantalla web | Ruta | Estado en móvil |
|---|---|---|
| Dashboard (`BannerCarousel`+`FeedReciente`+`ProfileSidebar`) | `/dashboard` | Móvil tiene la versión vieja (HeroBanner/QuickActions/ContinueSection) — ver 1.1 |
| Perfil | `/dashboard/perfil` | No existe — antes vivía dentro de un Ajustes que tampoco existe en móvil |
| Racha | `/dashboard/racha` | No existe — mascota animada según estado real, ver 1.2 |
| Broti (tienda/personalización) | `/dashboard/broti` | No existe, ver 1.3 |
| Notificaciones | `/dashboard/notificaciones` | No existe (reemplazó el placeholder "Mensajes" en el mapa viejo) |
| Rutas (contenido real) | `/dashboard/rutas` | Móvil tiene `rutas_screen.dart` placeholder — ahora hay contenido real que traer |
| Ajustes (solo config) | `/dashboard/ajustes` | No existe en móvil |
| `AutorInfo` (perfil de autor, solo mod/admin) | `/dashboard/comunidad/autor/:id` | No aplica a móvil salvo que se decida dar rol moderador ahí — bajo valor, ver 4 |

Test vocacional y Profesiones/Recursos/Comunidad (las 4 features ya
mapeadas en `FUNCTIONAL_CONTENT_BRIEF.md`) no cambiaron de forma
sustancial — ese brief sigue siendo confiable para ellas, salvo que
Comunidad ahora también tiene notificaciones/feed/moderación (arriba).

---

## 4. Fases propuestas

Orden por esfuerzo/valor, no por fecha — cada fase es independiente y
sigue el patrón Clean Architecture ya establecido en `auth`
(`domain` → `data` → `presentation/controllers`).

| Fase | Qué | Por qué en ese orden |
|---|---|---|
| **A** | Construir `domain`/`data` de `test_vocacional`, ~~`profesiones`~~, `recursos`, `comunidad` contra el inventario de endpoints ya documentado (mayormente sin cambios respecto al brief viejo). **`profesiones` completa (2026-08-23)** — `ProgramasRepository`/`ProgramasRepositoryImpl` sobre Dio, controller con debounce/paginación/filtros, pantalla real, verificado contra el backend real (no solo mocks). Faltan las otras 3. | Es lo que ya estaba priorizado antes de esta auditoría (`FUNCTIONAL_CONTENT_BRIEF.md` §6) y sigue siendo válido — mejor relación esfuerzo/valor |
| **B** | Rehacer `dashboard` para que hable con la feature `perfil` nueva (racha real vía `GET /perfil/:userId`) y con el `feed` de comunidad — versión propia para móvil, no una copia 1:1 del carrusel web | Depende de tener `domain/data` de `comunidad` (fase A) y de crear la feature `perfil` |
| **C** | Feature `perfil`: pantalla de datos personales + integrar Broti (nombrar la mascota, `BrotiAvatar`-equivalente, opcionalmente pantalla de personalización) | Desbloquea B; el catálogo de Broti es estático, fácil de portar a Dart |
| **D** | Rutas formativas real (ya no placeholder) — `GET /rutas`, `GET /rutas/:area` | Bajo esfuerzo (2 endpoints, contenido curado sin lógica) |
| **E** | Notificaciones | Depende de `comunidad` (fase A) |
| **F** | Cross-cutting: auto-logout a los 30 min de inactividad | Portable 1:1 (timer + listener de gestos), no depende de ninguna feature — se puede hacer en paralelo con cualquier fase |
| **G** | Reset-password (ver 1.4) | Barato, extiende `AuthRepository`, sin dependencias nuevas |
| Fuera de alcance | Analíticas admin, exportar PDF, moderación de comunidad, rol moderador | Son admin-facing o de bajo valor para el estudiante — `MOBILE_DESIGN_BRIEF.md` ya excluye el panel admin del móvil explícitamente |

## 5. Siguiente paso sugerido

No se implementó nada de código en esta pasada — es solo la ruta. Cuando
decidas por cuál fase arrancar, esa fase entra a `EnterPlanMode` propio
(cada una toca varios archivos nuevos: `domain/`+`data/`+`presentation/
controllers/` como mínimo), igual que se hizo con la Fase 1 de auth.

## 6. "Fase 0" — documentación, completa (2026-08-23)

Antes de tocar código de cualquier fase A-G, se refrescaron los
documentos de contexto con los hallazgos de esta auditoría:

- `MOBILE_DESIGN_BRIEF.md` — §1.2.1 (Broti), §1.2.2 (racha con datos
  reales), §2.2 (dashboard reescrita), §3 (endpoints nuevos).
- `FUNCTIONAL_CONTENT_BRIEF.md` — §5 (Rutas ya no es placeholder), §7
  (Notificaciones, nueva), §8 (Perfil/Racha/Broti, nueva).
- `CLAUDE.md` (este repo) — mascota renombrada a Broti, aviso de
  vigencia de los briefs.
- `CLAUDE.md` + `CHANGELOG_PARA_MOVIL.md` (repo web, sin commitear
  todavía — quedan como archivos locales para que se revisen/committeen
  del lado del equipo web) — mecanismo para que el web deje un rastro
  incremental de cambios relevantes al móvil, en vez de necesitar otra
  auditoría manual completa la próxima vez.

Con esto, arrancar cualquier fase A-G ya no requiere releer el web desde
cero — los tres documentos de este repo reflejan el estado real.
