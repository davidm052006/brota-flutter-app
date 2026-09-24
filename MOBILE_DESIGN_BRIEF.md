# Brief de diseño — Versión móvil de Brota

> Este documento es un **dossier de información**, no un mockup. La arquitectura (rutas, componentes, backend) ya está resuelta — lo único que falta es el **diseño visual de la versión móvil**. Toda la información aquí fue extraída directamente del código fuente actual (no de documentación desactualizada) para que el diseño se apoye en la realidad del proyecto, no en supuestos.
>
> **Tu trabajo:** diseñar la experiencia móvil (layouts, navegación móvil, jerarquía visual, interacciones) para cada pantalla listada abajo, respetando el sistema de marca ya establecido. Las decisiones de diseño visual específicas (cómo se ve cada pantalla, qué patrón de navegación usar, cómo se reorganiza cada sección) son tuyas — este documento te da los hechos, no la solución.
>
> ⚠️ **Vigencia (2026-08-23):** este documento se escribió el 2026-08-05.
> El repo web tuvo 48 commits desde esa fecha, algunos de los cuales
> cambian secciones enteras de abajo (el dashboard se rediseñó por
> completo, hay pantallas nuevas). Las secciones ya corregidas en esta
> pasada lo dicen explícitamente; para el detalle de auditoría completo
> y las fases propuestas para ponerse al día, ver `WEB_PARITY_ROADMAP.md`
> en la raíz de este repo — es el documento que prevalece sobre este
> brief donde haya conflicto.

---

## 0. Instrucciones de diseño (reglas de diseñador profesional)

Diseña como lo haría un diseñador de producto senior en un equipo de primer nivel. Concretamente:

- **Animaciones suaves y con propósito.** Transiciones de 150-300ms con easing natural (`ease-out` para entradas, `ease-in-out` para transiciones de estado). Nada de animaciones que se sientan mecánicas o que retrasen al usuario. El proyecto ya usa este lenguaje (`fadeSlideIn` 280ms, `revealField` 220ms) — mantén esa cadencia, no la rompas con algo más lento o más brusco.
- **Los botones deben verse clickeables/tocables.** Elevación sutil (sombra), feedback táctil claro al presionar (scale-down o darken en `:active`, no solo en `:hover` porque en móvil no hay hover), áreas de toque de mínimo 44×44px (guía de accesibilidad táctil de Apple/Google). El botón primario actual ya usa `hover:-translate-y-0.5` + sombra con glow de color — traduce ese mismo lenguaje de "elevación" a estados táctiles (`:active` con scale 0.97-0.98, por ejemplo).
- **Jerarquía visual clara.** Un elemento primario de acción por pantalla, no varios compitiendo. Usa el color primario (verde) con moderación — es acento, no relleno.
- **Consistencia con el sistema existente.** No inventes una nueva paleta, tipografía o radios de borde — usa los tokens documentados en la sección 1. Si algo no está cubierto por los tokens actuales (ej. un nuevo patrón de navegación inferior), extiéndelo con el mismo lenguaje visual, no con uno nuevo.
- **Mobile-first real, no "desktop encogido".** El desktop actual usa anchos fijos (1180px máx, sidebar fijo de 300px) y **no tiene ningún breakpoint responsive implementado todavía** — esto es diseño desde cero para móvil, no una adaptación de algo que ya funciona en pantallas chicas.
- **Accesibilidad táctil y legibilidad.** Contraste suficiente en ambos modos (claro/oscuro), tamaños de fuente legibles sin zoom (mínimo 14-16px en cuerpo), espaciado que no genere toques accidentales.
- **Estados vacíos, de carga y de error también son diseño.** El código actual ya maneja estos casos (ver spinners, mensajes "Cargando tu perfil…", estados de error) — no los omitas al diseñar cada pantalla.
- **Public vs. dashboard:** hay una landing pública (marketing, con animación de máquina de escribir en el hero) y un dashboard autenticado — ambos necesitan tratamiento móvil, con objetivos distintos (conversión vs. uso diario).

---

## 1. Sistema de marca (fuente de verdad: código, no BRAND.md)

⚠️ **Aviso importante:** el proyecto tiene un `BRAND.md` en la raíz, pero está **desactualizado** — documenta un verde `#16A34A` y tipografía genérica del sistema. El código real (`frontend/src/index.css`) usa una paleta y tipografía **distintas y más específicas**. Usa los valores de abajo (extraídos directamente de `index.css`), no los de `BRAND.md`.

### 1.1 Identidad

- **Nombre:** Brota
- **Concepto:** "Brotar" — crecimiento personal, el estudiante llega sin saber quién es y sale con un camino claro.
- **Tagline:** *"Descubre quién quieres ser."*
- **Producto:** plataforma colombiana de orientación vocacional gratuita para estudiantes de bachillerato (grados 9°-11°, 14-20 años) que van a elegir carrera, muchos sin acceso a un orientador vocacional profesional.
- **Voz:** segunda persona ("tú", "tu camino"), cercana, honesta, alentadora — nunca corporativa. Mensaje central: *"No hay respuesta incorrecta. No hay camino equivocado. Hay el tuyo."*
- **Emoji de marca:** 🌱 (aparece en saludos y contextos informales, nunca en botones de acción ni labels de formulario)

### 1.2 Logo

- **Archivo:** `frontend/public/logo-brota.png`
- **Uso actual en código:** `<img src="/logo-brota.png" alt="Brota" style={{ height: 28, width: 'auto' }} />` (navbar compacto) — en contextos más grandes se usa hasta 58px de alto (ver `Login.jsx` → `BrotaLogo`)
- Siempre `width: auto` — nunca distorsionar proporciones
- Hay también una imagen de fondo temática: `frontend/public/fondo-planta-crema.jpg` (usada en pantallas de auth)

#### 1.2.1 Mascota — se llama "Broti" (confirmado 2026-08-23, ya existe en el web)

⚠️ **Corrección importante:** esta sección decía "activo nuevo, exclusivo
de la versión móvil" — **es incorrecto**. La mascota ya existe en el web
con nombre propio, **Broti**, y un sistema de personalización completo
que el móvil todavía no replica. Ver `WEB_PARITY_ROADMAP.md` §1.3 para
el hallazgo completo. Resumen:

- El archivo `logo-feliz.svg` que ya usa el móvil es literalmente
  `MASCOTA_BASE` en `frontend/src/utils/brotiCatalog.js` — mismo asset,
  mismo linaje Recraft. No son mascotas distintas.
- El web permite personalizarla: `perfiles_usuario.broti_config` (JSONB
  `{variante, fondo}`), catálogo estático en `brotiCatalog.js`
  (`variante`: panda gratis / zorro de pago — reemplaza la imagen
  completa, no son piezas sueltas; `fondo`: 6 fotos, 2 gratis / 4 de
  pago, detrás de la mascota), persistido vía
  `PATCH /api/perfil/:userId/broti`. Componente `BrotiAvatar` reemplazó
  el círculo-con-inicial en navbar/perfil/comunidad.
- El móvil **no tiene equivalente de `BrotiAvatar` ni del sistema de
  personalización** — hoy solo usa las 4 expresiones fijas descritas
  abajo. Portar el catálogo (es estático, fácil de mapear a Dart) y la
  pantalla de personalización es la Fase C de `WEB_PARITY_ROADMAP.md`,
  no implementado todavía.
- Usa **"Broti"** (no solo "la mascota" o "perezoso") en código/copy
  nuevo del móvil para que el nombre sea consistente entre plataformas.

- **Ubicación:** `assets/icons/*.svg` en este repo Flutter (el web la tiene en `frontend/public/logos/`, mismos archivos). Perezoso/koala con lentes redondos y una hojita en la cabeza — la hoja conecta visualmente con el concepto "brotar" de la marca. Historial completo de la generación (Recraft AI), geometría exacta de cada pieza y lecciones de qué no repetir: `assets/icons/README.md`.
- **Formato:** SVG, `viewBox="0 0 1024 1024"`, fondo transparente. Flutter no renderiza SVG nativo — requiere el paquete `flutter_svg` (agregado a `pubspec.yaml`).
- **Color canónico:** `#21BD68` (el mismo `--primary` de modo claro de la sección 1.3) en el marco de las gafas y la hoja — es el único acento de color sobre un dibujo por lo demás en tonos café/crema neutros, así que ese verde es lo que ancla la mascota a la marca.
- **Variantes y cuándo usar cada una:**

  | Archivo | Expresión | Uso |
  |---|---|---|
  | `logo-base-limpio.svg` | Neutral, mirada al frente | Estado por defecto: saludo del dashboard, splash, contextos genéricos donde no hay un evento específico. |
  | `logo-guino.svg` | Ojo derecho guiñando | Tono amistoso/informal: onboarding, tips, micro-copy juguetón. |
  | `logo-triste.svg` | Ceño fruncido + lágrima | Estados de error o vacío (ej. "No encontramos programas para tu perfil", fallo de red). |
  | `logo-feliz.svg` | Sonrisa grande/celebración | Momentos de logro ya documentados en `FUNCTIONAL_CONTENT_BRIEF.md`: hito de racha (🔥 N días, `ProfileSidebar`) y pantalla de resultado del test vocacional (`TestResult`) al completarlo. |

  Todas parten de `logo-base-limpio.svg` — si se retoca la base, las demás deben reconstruirse desde ahí (no son archivos independientes entre sí).
- **Estado real (actualizado 2026-08-15):** `logo-base-limpio.svg` ya está
  integrada en `HeroBanner` (saludo del dashboard) vía `BrotaIconBadge`.
  `logo-guino`/`logo-triste`/`logo-feliz` siguen sin un punto de
  integración en pantalla — el mapeo de arriba es el destino previsto
  para cada una, no implica que ya estén conectadas.

#### 1.2.2 Iconografía UI (16 iconos, activo nuevo)

- **Ubicación:** `assets/icons/icon-*.svg` — mismo estilo Recraft que la
  mascota (contorno `#360E0A`, crema `#E1CFC6`, acento `#21BD68`).
  Separados de una hoja de 16 en cuadrícula (`flat-vector-icon-sheet--16-
  icons-arranged-in-a-cle.svg`, que queda como fuente cruda, no se usa
  directo). Inventario completo, geometría y proceso de separación:
  `assets/icons/README.md`.
- **Regla de contraste:** la misma que 1.2.1 — fondo crema fijo
  (`BrotaIconBadge`), no reactivo al tema, porque el contorno casi negro
  pierde legibilidad sobre cualquier superficie oscura del `ColorScheme`.
- **Mapeo icono → uso:**

  | Icono | Uso previsto | Estado |
  |---|---|---|
  | `icon-profesiones.svg` (birrete) | "Explorar profesiones" | ✅ integrado en `QuickActions` |
  | `icon-confirmar.svg` (check) | "Realizar test" | ✅ integrado en `QuickActions` |
  | `icon-ruta.svg` (camino+bandera) | "Rutas formativas" | ✅ integrado en `QuickActions` |
  | `icon-recursos.svg` (libro) | "Explorar recursos" | ✅ integrado en `QuickActions` |
  | `icon-comunidad.svg` (burbujas) | tab/sección Comunidad | pendiente — ver nota bottom nav abajo |
  | `icon-favoritos.svg` (estrella) | favoritos | pendiente, sin pantalla propia todavía |
  | `icon-racha.svg` (llama) | racha del perfil | pendiente de **UI** solamente — el dato real ya existe (`GET /api/perfil/:userId` → `racha_dias`/`ultima_actividad`), corregido 2026-08-23 en `WEB_PARITY_ROADMAP.md` §1.2. Falta construir la feature `perfil` (domain/data), no esperar backend nuevo. |
  | `icon-ajustes.svg` (engranaje) | ajustes | pendiente, `/dashboard/ajustes` es placeholder |
  | `icon-mensajes.svg` (sobre) | mensajes | pendiente, `/dashboard/mensajes` es placeholder |
  | `icon-instituciones.svg` (edificio) | Admin → Instituciones | pendiente, panel admin no construido en móvil |
  | `icon-negocios.svg` (maletín) | categoría Negocios/Emprendimiento | pendiente — no está entre las 4 con ícono propio integradas, sigue en emoji dentro de `ProfesionesScreen`; falta test vocacional |
  | `icon-categoria-tecnologia/salud/ciencias/arte.svg` | categorías académicas (§2 de `FUNCTIONAL_CONTENT_BRIEF.md`) | ✅ integrados en `ProfesionesScreen` (chips de filtro de área) — faltan en test vocacional, que sigue placeholder |
  | `icon-buscar.svg` (lupa+hoja) | búsqueda genérica | ✅ integrado en la bottom nav (tab "Explorar"). El campo de búsqueda de `ProfesionesScreen` usa `Icons.search` de Material (ícono de input estándar, no de marca) — decisión consistente, no un olvido. |

- **Por qué la bottom nav (`dashboard_shell.dart`) no se tocó:** de sus 5
  tabs (Inicio/Explorar/Test/Recursos/Comunidad) solo 2 tienen icono
  equivalente en este set (Recursos, Comunidad). Mezclar 2 iconos
  ilustrados a color con 3 `Icons.*` monocromo en la misma barra se vería
  inconsistente — se prefirió dejarla 100% Material Icons por ahora en
  vez de una migración a medias. Revisar cuando exista un icono propio
  para Inicio/Explorar/Test, o decidir intencionalmente un mix.

### 1.3 Paleta de colores — tokens reales (CSS custom properties, `frontend/src/index.css`)

El proyecto define variables CSS que cambian automáticamente entre modo claro/oscuro vía la clase `.dark` en `<html>`. **Todo componente debe soportar ambos modos.**

**Modo claro** (`:root`):
```css
--bg:           #F4F3EC   /* fondo general de la app */
--surface:      #FFFFFF   /* fondo de cards, navbar, modales */
--surface-2:    #EFEEE5   /* fondo secundario, hover states sutiles */
--ink:          #15241B   /* texto principal */
--ink-soft:     #67756B   /* texto secundario/meta */
--line:         #E6E4DA   /* bordes y separadores */
--primary:      #21BD68   /* verde de marca — acento, CTA, íconos activos */
--primary-deep: #0E7D43   /* verde oscuro — hover, texto sobre fondo claro-verde */
--primary-ink:  #FFFFFF   /* texto sobre fondo primary */
--primary-soft: #E2F6EC   /* fondo verde muy sutil (tags, chips activos) */
--primary-glow: rgba(33,189,104,.28)  /* para sombras con glow de color */
--accent:       #E07A42   /* naranja — segundo acento (notificaciones, highlights) */
--accent-soft:  #FBE8DC   /* fondo naranja sutil */
--shadow:       0 4px 18px rgba(20,40,28,.06)
--shadow-md:    0 8px 24px rgba(20,40,28,.10)
```

**Modo oscuro** (`html.dark`):
```css
--bg:           #0C1310
--surface:      #151F19
--surface-2:    #1C2A22
--ink:          #EAF3EC
--ink-soft:     #94A69B
--line:         #27362D
--primary:      #34D27D   /* el verde se aclara en modo oscuro */
--primary-deep: #1FA862
--primary-ink:  #04301C
--primary-soft: #16301F
--primary-glow: rgba(52,210,125,.22)
--accent:       #F0996A
--accent-soft:  #2C2018
--shadow:       0 10px 30px rgba(0,0,0,.45)
--shadow-md:    0 14px 40px rgba(0,0,0,.55)
```

Otros tokens: `--radius-md: 12px` (radio de borde estándar para botones/inputs). Cards y elementos más grandes usan radios mayores ad-hoc (16-24px, ver componentes).

**Regla de uso:** el naranja (`--accent`) es el segundo color de marca — se usa para notificaciones (punto rojo/naranja en ícono de mensajes), highlights de racha/gamificación, y variación de acentos junto al verde en gradientes (ver `HeroBanner` y racha en `Dashboard.jsx`, que usan `linear-gradient(135deg, var(--accent), var(--primary))`).

### 1.4 Tipografía

Dos familias, cargadas vía Google Fonts (`@import` en `index.css`):

| Familia | Uso | Clase/selector |
|---|---|---|
| **Bricolage Grotesque** (400/700/800) | Titulares, display, nombres, cifras destacadas | clase `.font-display` |
| **Plus Jakarta Sans** (400-800) | Todo el cuerpo de texto, UI, formularios | fuente base del `body` |

Ejemplo real: el saludo del dashboard "Hola, {nombre} 👋" usa `.font-display` con `font-weight: 800, font-size: 30px`. El nombre "BROTA" en el navbar también usa Bricolage Grotesque 800.

### 1.5 Animaciones y micro-interacciones ya existentes (mantener este lenguaje)

Definidas en `index.css`:
- `fadeSlideIn` (280ms ease-out): opacity 0→1 + translateY(10px→0) — usada en cards de programas al aparecer
- `revealField` (220ms ease-out): similar pero translateY(-6px→0) — campos de formulario
- `blinkCursor` (900ms step-end infinite): cursor parpadeante de máquina de escribir — usado en el **efecto typewriter del hero de la landing** (`useTypewriter` en `LandingPage.jsx`)

Patrones inline (no en CSS global, pero consistentes en todo el código):
- Botones: `transition-all duration-200`, `hover:-translate-y-0.5` (elevación al hover), `active:translate-y-0`
- Cards interactivas (ej. quick actions del dashboard): `transform: translateY(-2px)` + sombra con glow de color al hover
- Barras de progreso: `transition-all duration-500`

**Para móvil:** todo lo que hoy es `:hover` debe tener equivalente en `:active`/touch (no hay hover real en móvil). El lenguaje de "elevación + sombra con glow de color" es la firma visual del proyecto — consérvalo en botones y tarjetas tocables.

### 1.6 Componentes UI existentes (`frontend/src/components/Shared/`)

- **`Button.jsx`** — variantes `primary`, `secondary`, `danger`, `outline`. Base: `rounded-[12px]`, `px-5 py-2.5`, `font-semibold`, transición de 200ms con elevación al hover.
- **`Input.jsx`** — incluye toggle de mostrar/ocultar contraseña integrado, focus ring de `var(--color-primary)/30`, borde rojo + mensaje de error si `error` está presente.
- **`ProgressBar.jsx`** — barra simple, color configurable, transición de 500ms.
- **`Avatar.jsx`** — círculo con inicial del nombre, fondo `var(--primary)`.
- **`UserMenu.jsx`** — menú de usuario (navbar).

⚠️ Nota técnica menor: `Input.jsx` referencia `var(--color-surface)`, que **no está definido** en ningún lado del CSS actual (solo existe `--surface`, sin el prefijo `color-`). Es un bug latente preexistente — probablemente el input queda con fondo transparente. Vale la pena que el otro agente lo tenga en cuenta si toca ese componente, aunque no es parte del encargo de diseño en sí.

### 1.7 Dirección visual para gamificación (referencia: `design_reference/general/`)

Hay 3 capturas de referencia (`ref1.jpeg`, `ref2.jpeg`, `ref3.jpeg`) de una app de hábitos con estética oscura y muy gamificada (rachas, misiones, ligas, mascota-blob dentro de tarjetas). Son referencia de **estilo/tono**, no de contenido — son de una app de sueño/alarmas, un dominio distinto al de Brota. Al diseñar las pantallas de gamificación reales de Brota (la card de racha del `ProfileSidebar`, hitos del test vocacional, futuras misiones), traducir así:

- **Sí tomar de la referencia:**
  - Tratamiento de tarjeta oscura de alto contraste para destacar un momento de logro (racha, hito), separada visualmente del resto de la UI en modo claro.
  - Números grandes y en negrita para la métrica principal (ej. días de racha).
  - La mascota como ilustración-compañera anclada dentro de la tarjeta (no como ícono suelto en una esquina) — reforzando el logro, usando `logo-feliz.svg` en el momento de celebración.
  - Chips/badges tipo píldora para stats secundarias (⚡ puntos, 🎯 progreso).
- **No tomar de la referencia:** el contenido literal de su dominio (cama, pijama, luna, "ligas del sueño", streak-calendar ajeno) — Brota no es una app de sueño. Los momentos reales a ilustrar son únicamente los que ya documentan este brief y `FUNCTIONAL_CONTENT_BRIEF.md` (racha del test vocacional, resultado del test, progreso en Profesiones/Comunidad).
- **Lo que no cambia:** la paleta sigue siendo `#21BD68`/`#34D27D` (primario) + `#E07A42`/`#F0996A` (acento) de la sección 1.3, y la tipografía sigue siendo Bricolage Grotesque (display) + Plus Jakarta Sans (cuerpo) de la sección 1.4 — no se introduce una paleta ni tipografía nueva solo porque la referencia use otras. El fondo oscuro que ya define el modo oscuro del proyecto (`--bg: #0C1310`, `--surface: #151F19`) es compatible de fábrica con el lenguaje de tarjeta oscura de la referencia, así que una tarjeta de racha "modo oscuro siempre" (independiente del tema activo de la app, igual que la referencia) es una opción válida sin inventar tokens nuevos — usar `AppColors.darkBg`/`darkSurface` para esa tarjeta incluso si el resto de la pantalla está en modo claro.

### 1.8 Mapeo de tokens `brota-handoff` → tokens reales

(2026-08-15) `design_reference/general/brota-handoff/` (`DESIGN-SPEC.md`
+ 4 galerías HTML) es el paquete de diseño que reemplaza por completo a
los viejos mockups de Login (`login_dark`/`login_light`, borrados). Cubre
33 pantallas con estructura, componentes, spacing y radios detallados —
pero su paleta (`#16A34A`/`#4ADE80`, verde `green-*` de Tailwind tal
cual) y tipografía (Inter) **no son reales de marca**, son placeholders
del propio generador del mockup. Se usa el paquete solo para
layout/componentes; todo color/tipo sale de las secciones 1.3-1.4 de
arriba. Sin ampliar `AppRadii`/`AppSpacing` con una escala nueva — se
reutilizan los tokens ya existentes por cercanía:

| Handoff | Valor | Token real |
|---|---|---|
| Radio de campo/botón | 14–15px | `AppRadii.xl` (16) |
| Radio de card | 18px | `AppRadii.xl` (16) |
| Radio de card grande/hero | 20–22px | `AppRadii.xxl` (24) |
| Radio de logo/badge | 15–20px | `AppRadii.full` (círculo, ya usado por `BrotaIconBadge`) |
| Padding horizontal de pantalla | 20–24px | `AppSpacing.screenMargin` (20) |
| Gap entre campos | 16px | `AppSpacing.md` (16) |
| Altura CTA principal | 54px | Sin cambio — `BrotaPrimaryButton` ya fuerza 56px vía tema, diferencia de 2px es ruido |

Los placeholders de logo/ícono/ilustración del mockup (cajas rayadas
verdes con texto `"logo"`/`"icon"`, ver nota del propio autor en
`01...html:17`: *"Íconos y logo son placeholders neutros"*) son los
puntos donde va la mascota (`assets/icons/logo-*.svg`) o el set de
iconos (`assets/icons/icon-*.svg`) — nunca el placeholder geométrico
literal del HTML.

---

## 2. Mapa de pantallas — qué hay en cada una y qué hace

### 2.1 Público (sin autenticación)

| Ruta | Pantalla | Contenido / función |
|---|---|---|
| `/` | **Landing** | Navbar (logo + links: Conoce Brota, Beneficios, Testimonios, FAQ + CTA "Empezar gratis") → Hero con **efecto typewriter** en el titular + CTA dobles (primario "Empezar gratis" / secundario "Saber más") → TrustBar (4 stats: orientación gratuita, explorar áreas, resultados personalizados, toma decisiones) → sección "Cómo funciona" → Beneficios → Testimonial → FooterCTA → Footer. Redirige a `/dashboard` si ya hay sesión. |
| `/login` | **Login/Registro/Recuperar** | Un solo componente con 3 modos (`login`/`signup`/`forgotPassword`) manejados por `useAuth`. Layout desktop: grid de 2 columnas (branding a la izquierda, que cambia texto según el modo — ver copys en sección 1.1 — / card blanca de formulario a la derecha). Fondo crema `#F2EFEA` (exclusivo de pantallas de auth, no se usa en el dashboard). |
| `/reset-password` | **Reset de contraseña** | Formulario simple post-link de email. |
| `/servicios`, `/saber-mas`, `/privacidad`, `/terminos` | Páginas informativas estáticas | Contenido legal/institucional, prioridad baja para diseño móvil dedicado (pueden heredar patrones simples de texto+scroll). |
| `/contacto` | **Formulario de contacto** | Campos + selector de "asunto" (`asuntos_validos`), conecta a backend real (ver sección 3). |

### 2.2 Dashboard (autenticado) — usa `TopNavbar` horizontal + `DashboardLayout`

⚠️ **Toda esta sección se corrigió el 2026-08-23** — el commit `fbef308`
("Rediseña el dashboard…") reemplazó `HeroBanner`/`QuickActions`/
`ContinueSection` por completo (se borraron como código muerto) y se
agregaron varias pantallas nuevas sin equivalente móvil. Detalle
completo de la auditoría: `WEB_PARITY_ROADMAP.md`.

**Navegación actual (desktop):** `TopNavbar.jsx` sigue siendo una barra horizontal sticky con 6 tabs (Inicio, Explorar, Test vocacional, Rutas, Recursos, Comunidad). A la derecha cambió: el bloque de perfil (avatar Broti + nombre) ya **no navega** — abre una card flotante con nombre/ciudad/edad/% de perfil completo y un botón "Editar perfil →" a `/dashboard/perfil`; el ícono de engranaje ahora navega directo a `/dashboard/ajustes` (antes ajustes y perfil eran una sola pantalla). El ícono de mensajes 💬 con punto de notificación ahora es de **notificaciones reales**, no un placeholder. **Sigue siendo lo primero a rediseñar para móvil** — 6 tabs + esas acciones no caben en una pantalla de teléfono; se tradujo en la tab bar inferior de 5 ítems que ya implementó el móvil (`dashboard_shell.dart`) + el resto accesible desde Inicio/perfil.

| Ruta | Pantalla | Contenido / función |
|---|---|---|
| `/dashboard` | **Inicio** | ⚠️ Rediseñado. `BannerCarousel` (5 slides con autoplay 6s: slide 1 = estado real del test — nuevo/en-progreso/completado, misma lógica que tenía `ContinueSection`; slides 2-5 son banners informativos con copy placeholder, ajustables) → `FeedReciente` (grid de 4 tarjetas de últimas publicaciones de comunidad, `GET /api/comunidad/feed`; si hay menos de 4 reales se rellena con contenido de relleno hardcodeado que **nunca reemplaza** publicaciones reales) → `ProfileSidebar` (ya no rail fijo con completitud — ahora solo card de racha con gradiente accent→primary, con datos reales de `racha_dias`, click va a `/dashboard/racha`, y card de "frase del día"). |
| `/dashboard/test` | **Test vocacional** | Sin cambios de flujo. `TestResult` ahora además tiene un radar (Chart.js) por categoría y botón "Descargar PDF" (`utils/exportarPDF.js`, 100% cliente con `jspdf`+`html2canvas`) — nice-to-have, no bloquea el resto. |
| `/dashboard/profesiones` | **Explorar profesiones** | Sin cambios reportados desde el brief original. |
| `/dashboard/recursos` | **Recursos** | Sin cambios reportados. |
| `/dashboard/comunidad` | **Comunidad** | Mismo patrón de 4 tabs + FAB. Se agregó: `AutorInfo` (perfil real de un autor, solo visible a admin/moderador), y una barra de moderación (ocultar/eliminar/ver autor) en cada post/historia/pregunta — ambas son admin/moderador-only, **no aplican al estudiante en móvil**, se documentan por completitud. |
| `/dashboard/perfil` | **Perfil** *(nueva, no existe en móvil)* | Formulario de datos personales (nombre, apellido, ciudad, fecha de nacimiento en 3 selects, nivel educativo) + card "Tu foto de perfil es Broti" con `BrotiAvatar` y acceso a `/dashboard/broti`. |
| `/dashboard/racha` | **Racha** *(nueva, no existe en móvil)* | Página dedicada con la mascota animada según estado real (feliz/triste/guiño/neutral) y fondo dinámico. Datos reales ya disponibles (`racha_dias`), ver §1.2 de `WEB_PARITY_ROADMAP.md`. |
| `/dashboard/broti` | **Broti** *(nueva, no existe en móvil)* | Personalización de la mascota — dos tabs, "Mi Broti" (preview + equipados) y "Tienda" (grid por categoría `variante`/`fondo`). Ver §1.2.1 arriba para el catálogo. |
| `/dashboard/notificaciones` | **Notificaciones** *(nueva, reemplaza el placeholder "Mensajes")* | Lista armada al vuelo (sin tabla propia) combinando respuestas a preguntas propias + likes a historias propias, `GET /api/comunidad/notificaciones`. |
| `/dashboard/ajustes` | **Ajustes** *(cambió de alcance, no existe en móvil)* | Ya no incluye datos de perfil (se movieron a Perfil) — solo config: tipo de letra, cambio de contraseña (OTP), logout, sección "Próximamente". |
| `/dashboard/admin` | **Panel Admin** (solo rol admin) | Sin cambios de alcance para móvil — sigue **fuera de alcance**, ahora con una pestaña de Analíticas nueva (radar+barras de afinidad agregada) que tampoco aplica. |
| `/dashboard/rutas` | **Rutas formativas** | ⚠️ Ya **no es placeholder** — implementación real desde `9564818`: chips de área académica → contenido curado (`contenido_rutas`: materias comunes, temas previos, proyectos, links), sin LLM en tiempo real. Si el usuario ya hizo el test, separa "Relacionadas con tus resultados". Móvil todavía tiene `rutas_screen.dart` como placeholder. |
| `/dashboard/favoritos` | **Placeholder** | Sigue siendo `PaginaEnConstruccion` en ambos lados — sin cambios. |

---

## 3. Conexión con el backend — qué pantalla habla con qué API

Todas las llamadas van a `VITE_API_URL` (backend Express en puerto 3001), autenticadas vía JWT de Supabase (`Authorization: Bearer <token>`, inyectado por `getAuthHeaders()` en `apiClient.js`). Esto es puramente informativo — no cambia con el rediseño móvil, pero ayuda a entender qué es dato real (paginado, con estados de carga/error) vs. estático:

| Service frontend | Endpoints backend | Pantallas que lo usan |
|---|---|---|
| `authService.js` | `POST /api/auth/register-perfil` | Registro (`/login` modo signup) |
| `perfilService.js` | `GET/POST /api/perfil/cuestionario`, `/resultado`, `/recomendaciones`, `GET/PATCH /api/perfil/:userId`, `PATCH /api/perfil/:userId/broti` | Test vocacional, Perfil, Racha, Broti, recomendaciones |
| `programasService.js` | `GET /api/programas`, `GET /api/programas/stats` | Profesiones (listado paginado real, ~14.644 programas del MEN) |
| `comunidadService.js` | `GET/POST /api/comunidad/foros`, `/foros/:id/posts`, `/posts/:id`, `/posts/:id/votar`, `/posts/:id/respuestas`, `/historias`, `/historias/:id`, `/historias/:id/like`, `/preguntas`, `/preguntas/:id`, `/preguntas/:id/respuestas`, `/preguntas/:id/reportar`, `/convocatorias`, `/convocatorias/:id`, `GET /notificaciones`, `GET /feed` | Comunidad (4 tabs + detalle), Notificaciones, Dashboard (`FeedReciente`) |
| `rutasService.js` | `GET /api/rutas`, `GET /api/rutas/:area` | Rutas formativas (ya real, ver §2.2) |
| `contactoService.js` | `POST /api/contacto`, `GET/PATCH /api/admin/contactos` | Formulario de contacto público + AdminPanel |
| `adminService.js` | CRUD completo bajo `/api/admin/*` (usuarios, instituciones, programas, cuestionarios, preguntas, contactos) + `/api/admin/sincronizacion/*` + `GET /api/admin/analytics` | Panel Admin únicamente — fuera de alcance móvil |

**Fuera de esta tabla, admin/moderador-only, no aplica a móvil:** `PATCH/DELETE /api/comunidad/moderacion/*`, `GET /api/comunidad/moderacion/autor/:userId` (rol `moderador` o `admin`, ver `WEB_PARITY_ROADMAP.md` §2).

**Implicación de diseño:** las pantallas de Comunidad y Profesiones son las que más manejan estados de carga/paginación/infinite-scroll con datos reales — merecen especial atención a skeletons, pull-to-refresh (patrón móvil nativo que no existe en desktop) y estados vacíos. El resto de pantallas informativas (landing, recursos, páginas legales) son más estáticas.

---

## 4. Estructura visual del grafo de dependencias (contexto adicional)

Se generó un grafo de dependencias del código (`graphify-out/graph.json` y `graphify-out/graph.html`, navegable en el navegador) que agrupa el frontend en comunidades funcionales coherentes con lo descrito arriba: *Admin Panel*, *Comunidad (frontend)*, *Auth UI compartida*, *Layout y navegación*, *Config y componentes dashboard sueltos*. Confirma que no hay acoplamiento cruzado inesperado entre secciones — cada pantalla es razonablemente independiente, lo cual es una buena señal para poder rediseñar/reconstruir la capa visual pantalla por pantalla sin romper otras.

---

## 5. Restricciones técnicas a tener en cuenta

- **TailwindCSS v4**: el oxide scanner requiere `@source` explícitos en `frontend/src/index.css` para cada subdirectorio nuevo — si se agregan componentes en carpetas nuevas, hay que registrar la ruta ahí o el CSS no se genera.
- **Modo oscuro** vía clase `.dark` en `<html>` (no `prefers-color-scheme` automático) — todo diseño nuevo debe cubrir ambos modos con los tokens de la sección 1.3.
- **Sin sidebar vertical** — decisión de producto ya tomada para desktop (existe un `Sidebar.jsx` legado que ya no se usa). No es un requisito para móvil, pero indica que el equipo prefiere navegación horizontal/superior sobre lateral cuando es posible.
- El proyecto **no tiene ningún framework ni librería de componentes UI de terceros** (no MUI, no Chakra, no shadcn) — todo es Tailwind + estilos inline + CSS custom properties hechos a mano. Cualquier propuesta de diseño debe poder implementarse con ese mismo enfoque artesanal, no asumir una librería de componentes disponible.

---

## 6. Referencias visuales existentes (para tono, no para copiar literal)

Hay 8 mockups de diseño **de escritorio** ya implementados en `frontend/public/diseños/` (`01-Landing.png` … `08-Recursos.png`) — útiles como referencia de tono visual y jerarquía de contenido, pero fueron diseñados para desktop, no para trasladarse 1:1 a móvil.
