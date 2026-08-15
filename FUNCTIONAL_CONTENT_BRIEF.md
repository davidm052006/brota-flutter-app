# Brief de contenido funcional — Brota móvil

> Complemento de `MOBILE_DESIGN_BRIEF.md` (que cubría marca/visual). Este documento cubre **la lógica real** de cada pantalla que todavía es placeholder: qué datos maneja, qué reglas de negocio tiene, qué le pasa al usuario en cada estado, y con qué endpoint del backend habla. Todo extraído directamente del código fuente del hermano web (`~/Proyectos/Documentacion_Brota/frontend/`), no inventado ni aproximado.
>
> **Regla de sincronización del proyecto:** el repo web es la fuente de verdad de la lógica de negocio. El móvil **traduce** esa lógica a Dart/Flutter con el patrón Clean Architecture ya establecido en `lib/features/auth/` (domain = contratos + entidades, data = implementación contra el backend, presentation = UI + controllers) — no la reinventa. Cuando el web cambie una regla de negocio (un endpoint, un cálculo, una validación), este documento queda desactualizado en ese punto puntual; hay que volver a leer el archivo fuente citado abajo antes de tocar la feature correspondiente, no confiar en que este brief envejece bien indefinidamente.

---

## 0. Patrón a replicar (ya resuelto en `auth`)

Antes de construir cualquier feature nueva, mira `lib/features/auth/`:

- `domain/` — interfaces abstractas (`AuthRepository`) + entidades puras (`AppUser`). Sin dependencias de Supabase/Dio aquí.
- `data/` — implementación concreta (`AuthRepositoryImpl`) que sí habla con la red.
- `presentation/` — controllers (Riverpod, ver `login_controller.dart`) + screens, que solo dependen de la interfaz `domain`, nunca de la implementación.
- Todo método async que puede fallar devuelve `Result<T>` (`Success<T>` / `ResultError<T>`, en `lib/core/result/`), igual que el patrón `{ success, data, error }` que ya usa `apiClient.js` en el web (`parseResponse()`). Al traducir cada `service.js` de abajo, la forma es 1:1: `success:true/data` → `Success(value)`, `success:false/error` → `ResultError(Failure(...))`.

Todas las features de abajo (`test_vocacional`, `profesiones`, `recursos`, `comunidad`) hoy solo tienen `presentation/screens/<x>_screen.dart` como placeholder — les falta `domain/` y `data/`. Constrúyelas con esta misma estructura.

**Cliente HTTP:** ya existe `lib/core/network/dio_client.dart` con `AuthInterceptor` (inyecta el JWT de Supabase igual que `getAuthHeaders()` en el web) y `api_exception_mapper.dart` (traduce errores HTTP a `Failure`). Los repositorios nuevos deben inyectar ese Dio ya configurado, no crear uno nuevo.

**Base URL:** todos los endpoints de abajo son relativos a `/api` sobre el mismo backend Express (puerto 3001) que ya usa el web — confirmar la URL configurada en `lib/core/env/app_env.dart` apunta al mismo backend (local o el desplegado) que usa `VITE_API_URL` en el web.

---

## 1. Test vocacional — la feature más compleja

**Fuente:** `frontend/src/pages/dashboard/test-vocacional/TestVocacional.jsx` + `components/{TestIntro,TestQuestion,TestProgress,TestResult}.jsx` + `utils/vocacionalCategorias.js` + `services/perfilService.js`.

### 1.1 Máquina de estados (fases)

```
intro → test (pregunta por pregunta) → calculando → resultado
```

- **`intro`**: pantalla de bienvenida. Botón cambia según el estado previo del usuario (ver 1.2).
- **`test`**: una pregunta a la vez, con navegación anterior/siguiente. No se puede avanzar sin seleccionar al menos una opción (`puedeAvanzar = idsActuales.length > 0`).
- **`calculando`**: pantalla de loading breve mientras se guarda el resultado (spinner + "Analizando tus respuestas...").
- **`resultado`**: perfil vocacional + recomendaciones de programas reales.

### 1.2 Estado al entrar a `intro` — tres escenarios posibles

Al montar la pantalla se resuelven, en este orden, contra:
1. `localStorage` (equivalente Flutter: `shared_preferences` o similar) con clave `` `brota-test-${userId}` `` (función `storageKey(userId)` en `vocacionalCategorias.js`) — un borrador de progreso a medio hacer.
2. `GET /api/perfil/resultado/:perfilUsuarioId` — un resultado ya guardado en el backend.

Combinaciones y qué botones mostrar (ver `TestIntro.jsx`):

| `tieneResultado` | `tieneBorrador` | Botones mostrados |
|---|---|---|
| ✓ | ✓ | "✓ Ver mi resultado anterior" (primario) / "▶ Continuar test en progreso" / "↺ Reiniciar test" |
| ✓ | ✗ | "✓ Ver mi resultado anterior" (primario) / "↺ Reiniciar test" |
| ✗ | ✓ | "▶ Continuar donde lo dejé" (primario) / "↺ Empezar de nuevo" |
| ✗ | ✗ | "Comenzar test →" (único botón) |

⚠️ Nota real del código: un resultado previo con `categoriaPrincipal` vacía o `scores` vacío se **ignora silenciosamente** (comentario en el código: "bug de versión anterior con IDs likert incorrectos") — no lo trates como resultado válido si esos campos vienen vacíos.

Copy de la card de intro (usar tal cual, es voz de marca ya validada):
- Título: "Test Vocacional"
- Subtítulo: *"No hay respuestas correctas o incorrectas. Elige todo lo que realmente te represente."*
- 3 stats en grid: `❓ {N} preguntas` (N real del cuestionario, fallback 30) · `⏱️ 10–15 min` · `🎯 Perfil único`
- Cita: *"Tu camino comienza con un paso. Cada respuesta te acerca a descubrir tu mejor versión."*

### 1.3 Cargar el cuestionario

`GET /api/perfil/cuestionario` → `{ cuestionario: { id }, preguntas: [...] }`. Cada pregunta:
```
{ id, texto, tipo: 'single' | 'multiple' | 'likert', categoria?, opciones: [{ id, label, icon?, orden?, pesos? }] }
```
- **`single`** y **`likert`**: selección única — elegir una opción reemplaza la anterior (`[opcionId]`).
- **`multiple`**: selección múltiple — toggle (agrega/quita del array).
- **`likert`**: se renderiza como escala horizontal de 5 puntos con emojis fijos `['😕','🙁','😐','🙂','😄']` asignados por `orden` de la opción, no por contenido — las opciones reales (con sus UUIDs) vienen del backend, el componente solo les pega el emoji de escala encima.

### 1.4 Guardar progreso (autosave, sin backend)

Mientras `fase === 'test'`, cada cambio de pregunta o de selección persiste localmente: `{ cuestionarioId, preguntaIdx, seleccionadas, savedAt }` bajo la misma clave `storageKey(userId)`. Esto es lo que permite "continuar donde lo dejé" sin haber terminado el test — no depende del backend. Al terminar el test (llegar a `resultado`) o al reiniciar, se borra esa clave local.

### 1.5 Calcular el resultado — backend primero, cliente como respaldo

Al responder la última pregunta:
1. Se calcula un perfil **localmente** siempre, como respaldo (`calcularPerfilLocal` — suma los `pesos` de cada opción elegida por categoría, ordena de mayor a menor, normaliza a porcentaje sobre el máximo).
2. Si hay `perfilUsuarioId` y `cuestionarioId` (usuario real, no demo), se intenta `POST /api/perfil/resultado` con body `{ perfil_usuario_id, cuestionario_id, respuestas: seleccionadas }` — **el backend recalcula el perfil, el cliente solo envía las respuestas crudas**. Response: `{ id, perfil_vocacional: { categoriaPrincipal, categoriaSecundaria, scores: [{categoria, puntos, porcentaje}] } }`.
3. Si el backend falla (red, error, modo demo) → se usa el cálculo local silenciosamente, sin bloquear al usuario. Este fallback es una decisión de producto explícita, replícalo — el usuario nunca debe quedarse sin ver un resultado por un fallo de red.

### 1.6 Categorías vocacionales — tabla completa (usar literal, es contenido de producto)

Fuente: `utils/vocacionalCategorias.js`. Claves normalizadas (`toLowerCase()`), con emoji + título + descripción + color semántico (no es un hex, es una etiqueta tipo Tailwind `blue/purple/teal/rose/amber/emerald` — en Flutter mapear cada una a los tokens de `AppColors` más cercanos, ya que no existe paleta multicolor en el sistema de marca):

| clave | emoji | título | color |
|---|---|---|---|
| `tecnologia` | 💻 | Tecnología e Innovación | blue |
| `arte` | 🎨 | Arte y Creatividad | purple |
| `diseño` | ✏️ | Diseño y Comunicación Visual | purple |
| `ciencias` | 🔬 | Ciencias e Investigación | teal |
| `social` | ❤️ | Vocación Social y Humana | rose |
| `humanidades` | 📖 | Humanidades y Cultura | amber |
| `negocios` | 💼 | Negocios y Emprendimiento | amber |
| `emprendimiento` | 🚀 | Emprendimiento e Innovación | amber |
| `salud` | 🏥 | Salud y Bienestar | rose |
| `educacion` | 📚 | Educación y Pedagogía | emerald |
| `comunicacion` | 📡 | Comunicación y Medios | blue |
| `ambiente` / `ambiental` | 🌿 | Medio Ambiente y Sostenibilidad | emerald |
| `deporte` | ⚽ | Deporte y Actividad Física | teal |
| `juridico` | ⚖️ | Derecho y Justicia | purple |
| `administrativo` | 📊 | Gestión y Administración | blue |

Cada una tiene además una **descripción larga** (1-2 frases, tono "tú" de marca) — cópialas literal del archivo fuente citado arriba, son copy de producto ya escrito y aprobado, no las reescribas.

Si la categoría que devuelve el backend no está en esta tabla: fallback con emoji 🌟, título = la clave capitalizada, descripción genérica, color rotando por `['emerald','blue','purple','amber','teal','rose']` según el índice. Esto pasa de verdad (hay claves `emprendimiento`/`ambiente` en el cuestionario que no siempre coinciden 1:1 con `area_academica` de programas — ver `CLAUDE.md` del web, bug #1 documentado ahí, ya resuelto en backend con `CATEGORIA_ALIAS` pero vale la pena que el cliente tolere claves desconocidas igual).

### 1.7 Pantalla de resultado

- Card principal: emoji grande + "TU PERFIL VOCACIONAL" (label pequeño mayúsculas) + título de la categoría principal + descripción. Si hay categoría secundaria, chip debajo: "Perfil secundario: **{título}**".
- Barra de distribución: lista de hasta 5 categorías con emoji + barra de progreso + porcentaje, la primera marcada "Principal".
- **Recomendaciones de programas reales**: `GET /api/perfil/recomendaciones/:resultadoId` → array de programas con `{ id, nombre, descripcion, institucion, ciudad, departamento, area, modalidad, duracion, compatibilidad }`. `compatibilidad` es 0-100; ≥85 se resalta en verde primario, ≥70 en azul (`#4A90D9`, no es un token de marca — color ad-hoc solo para este caso), el resto en gris neutro. Al tocar una recomendación no vista, `PATCH /api/perfil/recomendaciones/:id/vista` marca `vista: true` (solo una vez, es tracking de qué ya miró el usuario).
- Estados de la sección de recomendaciones: cargando (skeletons) → error (con botón "Reintentar") → vacío ("No encontramos programas para tu perfil. Intenta explorar la sección de Profesiones.") → lista.
- Acciones al pie: "Ver rutas formativas →" (navega a rutas, hoy placeholder también en el web) y "↺ Volver a hacer el test" (llama `DELETE /api/perfil/resultado/:perfilUsuarioId`, limpia todo el estado local y vuelve a `intro`).

### 1.8 Card "Test vocacional" en el Dashboard (`ContinueSection`)

Ya existe `continue_section.dart` en el móvil como placeholder — esta es su lógica real (`frontend/src/pages/dashboard/components/ContinueSection.jsx`):

4 estados posibles, cada uno con ícono/texto/botón propio:

| Estado | Cómo se detecta | Ícono | Texto | Botón |
|---|---|---|---|---|
| `cargando` | mientras resuelve | 🌱 | "Cargando..." | "..." (disabled) |
| `en-progreso` | hay borrador local con progreso > 0 | 📝 | "En progreso — continúa donde lo dejaste" | "Continuar →" |
| `completado` | hay resultado guardado en backend | 🎉 | "Perfil: {título de categoría principal}" | "Ver resultado →" |
| `nuevo` | ninguno de los anteriores | 🧑‍🎓 | "Descubre tus intereses y fortalezas" | "Comenzar →" |

Barra de progreso: `en-progreso` estima `min(round(preguntaIdx/30 * 100), 95)` (nunca llega a 100% hasta terminar de verdad); `completado` = 100%; `nuevo` = 0%. Si `completado` o `en-progreso`, aparece un botón secundario "🗑 Eliminar" con confirmación inline ("¿Seguro?" / "Sí, borrar" / "Cancelar") que borra tanto el borrador local como el resultado en backend.

---

## 2. Profesiones

**Fuente:** `frontend/src/pages/dashboard/Profesiones.jsx` + `services/programasService.js`.

- `GET /api/programas?area=&search=&page=&limit=24` — paginado real, 24 por página. Response: `{ data: [...], total, totalPages }`. Cada programa: `{ id, nombre, area_academica, modalidad, duracion, instituciones: { nombre } }`.
- `GET /api/programas/stats` → `{ total, areas: [{ area, count }] }` — para los contadores del sidebar de filtros.
- Búsqueda con **debounce de 350ms** (0ms si se limpia la búsqueda) antes de disparar la query — evita golpear el backend en cada tecla.
- "Cargar más" (no infinite scroll automático — botón explícito) hace `append=true`, concatena resultados en vez de reemplazar.
- Filtro de modalidad (`Presencial` / `A distancia` / `Virtual`) se aplica **en cliente** sobre lo ya cargado, no es un parámetro de la query — ojo con esto si el móvil pagina, el filtro de modalidad solo ve lo que ya bajó.
- 14 categorías académicas con emoji + color de acento (verde o naranja, alternando por categoría — no hay una regla semántica detrás, es solo variedad visual): `tecnologia 💻`, `salud 🩺`, `ciencias 🔬`, `diseño 🎨`, `arte 🎭`, `educacion 🎓`, `social 🤝`, `comunicacion 📡`, `juridico ⚖️`, `negocios 📈`, `administrativo 🏛️`, `humanidades 📖`, `ambiental 🌱`, `deporte ⚽` — nota que estas claves **no son idénticas** a las del test vocacional (p.ej. `administrativo` usa 🏛️ aquí y 📊 en el test; `ambiental` aquí vs `ambiente`/`ambiental` en el test) — no asumas una única fuente de emojis compartida entre features, cada pantalla del web tiene la suya propia y así se replicó — mantenlo así para no introducir un acoplamiento que el propio web no tiene.
- Footer fijo de atribución de datos: *"Datos oficiales del Ministerio de Educación Nacional — Programas activos del SNIES · fuente: datos.gov.co · licencia CC-BY-SA 4.0"* — cópialo literal, es requisito de la licencia de los datos.

---

## 3. Recursos — contenido 100% estático (sin backend)

**Fuente:** `frontend/src/pages/dashboard/Recursos.jsx`. Esta pantalla **no llama a ningún endpoint** — es un array hardcodeado de 18 recursos con filtro y búsqueda en cliente. Puedes portar el array literal a una constante Dart (`List<Recurso>` con los mismos campos) en vez de construir una capa `data/` con red — no hay nada que sincronizar con el backend aquí.

Categorías: `todos ✨`, `guias 📄`, `videos ▶️` (label "YouTube"), `becas 🎓`, `herramientas 🔧`.

Cada recurso: `{ id, categoria, emoji, tint: 'green'|'accent', tag, titulo, descripcion, accion, url }`. El botón de acción abre `url` en el navegador externo (son todos enlaces reales a datos.gov.co, ICETEX, SENA, ICFES, Coursera, YouTube, etc. — no rutas internas).

Footer fijo: *"¿Conoces un recurso útil que no está aquí? Próximamente podrás sugerir recursos desde esta sección. Por ahora, compártelo con tu orientador."*

La lista completa de los 18 recursos (título, categoría, tag, descripción, URL) está en `frontend/src/pages/dashboard/Recursos.jsx` líneas 13-32 — cópiala literal, es contenido curado a mano (becas y guías reales de instituciones colombianas), no lo regeneres ni resumas.

---

## 4. Comunidad — la feature con más interacción de usuario

**Fuente:** `frontend/src/pages/dashboard/Comunidad.jsx` + `comunidad/components/*` + `services/comunidadService.js` + esquema real: `backend/scripts/migration_comunidad.sql`.

### 4.1 Modelo de datos (tablas reales de Supabase)

- **`foros`** (catálogo fijo, ya sembrado): `id` (texto, no UUID — es slug: `tecnologia`, `salud`, `negocios`, `artes`, `educacion`, `ambiente`), `icon`, `nombre`, `descripcion`. Son 6 foros temáticos fijos, no los crea el usuario.
- **`posts_foro`**: post dentro de un foro. `{ id, foro_id, user_id, titulo, contenido, anonimo, autor_nombre, votos, created_at }`.
- **`votos_post`**: un voto por usuario por post (`UNIQUE(post_id, user_id)`), `direccion: 'up'|'down'` — **votar de nuevo con la misma dirección debería quitar el voto (toggle), no duplicarlo**; votar en dirección contraria lo cambia. Replica esta semántica exacta en el cliente (deshabilitar el botón tras votar y mostrar el estado no es suficiente si el backend permite cambiar de voto).
- **`respuestas_post`**: `{ id, post_id, user_id, contenido, anonimo, autor_nombre, votos, es_mejor_respuesta, created_at }`.
- **`historias`**: requieren moderación — `publicada: BOOLEAN DEFAULT FALSE`. El listado que ve el usuario (`GET /historias`) solo debe traer las `publicada=true`; una historia recién enviada por el usuario **no aparece de inmediato** en el feed público — comunica esto en el modal de envío (el web no tiene un mensaje explícito de "en revisión", pero es el comportamiento real, vale la pena que el móvil sí lo diga para no confundir al usuario).
- **`likes_historia`**: un like por usuario por historia (`UNIQUE`), sin dirección — es binario, dar like otra vez lo quita.
- **`preguntas_comunidad`**: **se publican inmediatamente** (sin moderación, a diferencia de historias). `{ id, user_id, titulo, area, anonimo, autor_nombre, resuelta, created_at }`.
- **`respuestas_pregunta`**: `{ id, pregunta_id, user_id, contenido, anonimo, autor_nombre, votos, es_mejor, created_at }`.
- **`convocatorias`**: gestionadas solo por administradores (no hay creación desde la app de estudiante). `{ id, tipo, titulo, institucion, ciudad, descripcion, detalles: JSONB, url, fecha_cierre, activa }`. El campo `detalles` es JSON libre — en la práctica trae `{ requisitos: string[], pasos: [{num, texto}] }` (ver ejemplos reales en `migration_comunidad.sql` líneas 138-183, con 5 convocatorias de ejemplo: Jóvenes en Acción, ICETEX, SENA, Universidad Nacional, feria en Corferias — útiles como datos de prueba realistas si necesitas placeholders).

### 4.2 Las 4 pestañas (tabs)

`Foros` / `Historias reales` / `Preguntas` / `Convocatorias` — se cargan las 4 en paralelo al entrar (`Promise.all`), no de forma perezosa por tab. Cabecera de la pantalla, copy literal: *"🌱 Espacio para crecer juntos"* (badge) + *"Aquí, otros estudiantes ya encontraron su camino. El tuyo también está aquí."* (subtítulo).

### 4.3 FAB (botón flotante) — ya es un patrón mobile-native, consérvalo

Visible en todas las tabs excepto `convocatorias` (ahí no hay FAB — los estudiantes no crean convocatorias). Su función cambia según la tab activa:
- Tab `historias` → ícono ✍️, abre el modal de compartir historia.
- Cualquier otra tab (`foros`, `preguntas`) → ícono `+`, abre el modal de hacer pregunta.

### 4.4 Formularios modales — campos exactos

**Compartir historia** (`ModalCompartirHistoria.jsx`):
```
{ titulo, area: 'Artes' (default), contenido, carrera, institucion, anonimo: true (default) }
```
Campos de texto: Título (placeholder "¿Cómo fue tu camino?", requerido), Carrera (opcional), Institución (opcional), Contenido (textarea, placeholder "Cuéntanos cómo fue tu proceso…", requerido). Toggle: "Publicar como anónimo · Tu nombre no será visible." (activado por defecto).

**Hacer pregunta** (`ModalHacerPregunta.jsx`):
```
{ titulo, area: 'Tecnología' (default), anonimo: false (default) }
```
Un solo campo: textarea "titulo" (placeholder "¿Qué quieres saber?", requerido, 3 filas — es la pregunta en sí, no hay campo de contenido separado). Toggle: "Publicar como anónimo." (**desactivado** por defecto, a diferencia del de historias — verifica este detalle, es intencional: preguntas tienden a ser públicas, historias tienden a ser anónimas).

### 4.5 Endpoints (`services/comunidadService.js`, todos bajo `/api/comunidad`)

| Acción | Endpoint |
|---|---|
| Listar foros | `GET /foros` |
| Posts de un foro | `GET /foros/:foroId/posts?orden=` |
| Crear post | `POST /foros/:foroId/posts` |
| Ver post | `GET /posts/:postId` |
| Votar post | `POST /posts/:postId/votar` |
| Responder post | `POST /posts/:postId/respuestas` |
| Listar historias | `GET /historias` |
| Ver historia | `GET /historias/:id` |
| Compartir historia | `POST /historias` |
| Dar like | `POST /historias/:id/like` |
| Listar preguntas | `GET /preguntas` |
| Ver pregunta | `GET /preguntas/:id` |
| Hacer pregunta | `POST /preguntas` |
| Responder pregunta | `POST /preguntas/:id/respuestas` |
| Marcar mejor respuesta | `PATCH /preguntas/:pregId/respuestas/:rId/mejor` |
| Listar convocatorias | `GET /convocatorias` |
| Ver convocatoria | `GET /convocatorias/:id` |

### 4.6 Reset de scroll al volver desde el logo

Detalle de UX menor pero real: si el usuario está en `/dashboard/comunidad` y toca el logo de Brota (que normalmente lleva a `/dashboard`), en vez de navegar afuera **resetea el feed** — vuelve a la tab `foros` y hace scroll suave al top (`TopNavbar.jsx`, ver el `onClick` especial del logo). En móvil, el equivalente natural sería: si ya estás en la tab de Comunidad del bottom nav y la vuelves a tocar, resetea a la subtab `foros` + scroll to top, en vez de no hacer nada.

---

## 5. Rutas — sin contenido todavía, en ambos lados

`/dashboard/rutas` es un placeholder también en el web (`PaginaEnConstruccion`, sin funcionalidad real). No hay nada que replicar aquí — el móvil ya está a la par con solo tener su placeholder (`rutas_screen.dart` ya existe). No inviertas tiempo de lógica de negocio en esta feature hasta que el web la construya primero.

---

## 6. Resumen de prioridad sugerida

Coincide con lo que ya identificó la sesión anterior en `CLAUDE.md` del propio proyecto Flutter: **Profesiones** es la de mejor relación esfuerzo/valor para ir después de auth (un solo endpoint paginado, sin estado complejo). Test vocacional es la más valiosa para el producto pero también la más compleja (state machine de 4 fases + autosave local + fallback de cálculo cliente/servidor). Comunidad es la que tiene más superficie de interacción (votos, likes, mejor-respuesta, moderación de historias) — déjala para el final. Recursos es casi gratis (un array estático) y puede hacerse en paralelo con cualquiera de las anteriores sin dependencias.
