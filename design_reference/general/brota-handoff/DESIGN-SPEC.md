# Brota móvil — especificación de diseño

Plataforma colombiana de orientación vocacional gratuita para estudiantes de bachillerato (14–20 años).
Tagline: **Descubre quién quieres ser.**

Viewport de diseño: **390 × 844** (iPhone 14/15). Todo escala con flex/grid; nada depende de alto fijo salvo los frames de los mockups.

---

## 1. Tokens de color

### Primarios
| Token | Claro | Oscuro | Uso |
|---|---|---|---|
| `green-600` | `#16A34A` | — | CTA, iconos activos, acentos |
| `green-700` | `#15803D` | — | hover, texto de acento sobre fondo claro |
| `green-400` | — | `#4ADE80` | acento y CTA secundario en oscuro |
| `green-950` | `#052E16` | — | texto principal en claro |
| `green-200` | `#BBF7D0` | — | bordes y separadores en claro |
| `green-100` | `#DCFCE7` | — | fondos suaves, chips, iconos |
| `green-50` | `#F0FDF4` | — | fondos de tarjeta y campos |

### Fondos
| Contexto | Claro | Oscuro |
|---|---|---|
| App general | `#FFFFFF` | `#060D07` |
| Dashboard (gradiente vertical) | `#F0FDF4` → `#DCFCE7` | `#0A1A0A` → `#060D07` |
| Auth (crema, exclusivo) | `#F2EFEA` | `#0D110E` |
| Hero banner (gradiente 135°) | `#16A34A` → `#15803D` | `#15803D` → `#14532D` |
| Surface (cards, hojas) | `#FFFFFF` | `#1A1D24` |
| Surface elevado / bordes oscuros | — | `#2C3140` |

### Texto
- Claro: título/cuerpo `#052E16`; secundario `rgba(5,46,22,.6)`; meta `rgba(5,46,22,.45)`.
- Oscuro: título/cuerpo `#F0FDF4`; secundario `rgba(240,253,244,.55)`; meta `rgba(240,253,244,.45)`.

### Reglas
- Verde primario nunca como fondo de bloques largos de texto.
- Oscuro usa `green-400` donde claro usa `green-600`.
- Crema solo en auth.
- Máximo dos fondos por pantalla.

---

## 2. Tipografía

Stack: `Inter, system-ui, -apple-system, sans-serif`.

| Rol | Tamaño / peso / interlínea | Tracking |
|---|---|---|
| Display (hero marketing) | 34 / 800 / 1.1 | -0.03em |
| H1 pantalla | 27–28 / 800 / 1.2 | -0.025em |
| H2 sección | 21–25 / 700 / 1.25 | -0.015em |
| Título de tarjeta | 15–16 / 700 / 1.3 | — |
| Cuerpo | 14–15 / 400 / 1.55–1.65 | — |
| Cuerpo secundario | 13 / 400 / 1.5 | — |
| Label de campo | 12 / 500 / 1 | — |
| Meta / chip | 11 / 500 / 1 | — |
| Eyebrow (mayúsculas) | 10 / 600 / 1 | 0.1–0.12em |
| Tab bar | 10 / 500-600 / 1 | — |

Pregunta del test: 24 / 700 / 1.3 — una sola pregunta por pantalla.

---

## 3. Forma, espaciado, sombra

- Radios: frame 44 · hoja inferior 28 (arriba) · tarjeta grande 20–22 · tarjeta 18 · campo/botón 14–15 · chip 20 (pill) · icono contenedor 10–13.
- Padding horizontal de pantalla: **20–24px** (20 en listas densas, 22–24 en contenido de lectura).
- Gap vertical entre tarjetas: **10–14px**; entre bloques de sección: **16–20px**.
- Alturas: CTA principal **54**, CTA secundario **46–48**, campo **50–52**, chip **~34**, fila de lista **~56**.
- Sombra de CTA verde: `0 6px 16px rgba(22,163,74,.28)`.
- Sombra de tarjeta (rara vez): `0 2px 10px rgba(5,46,22,.05)`.
- Hoja inferior: `0 -12px 40px rgba(5,46,22,.25)` + overlay del fondo al 28% de opacidad.
- Focus de campo: borde `#16A34A` 1.5px + `box-shadow 0 0 0 3px rgba(22,163,74,.12)`.

---

## 4. Componentes

1. **StatusBar** — solo presentación en los mockups; en producción es la del sistema.
2. **TabBar (5)** — Inicio · Explorar · Test · Recursos · Comunidad. Icono 24px + label 10px. Activo: verde relleno + label verde. Fondo `#FFF`/`#0D110E`, borde superior `green-200`/`#1F2A22`, padding `9px 8px 24px` (safe area). Badge numérico verde con borde del color del fondo. **Oculta en auth, test y marketing.**
3. **AppHeader (dashboard)** — avatar + saludo en dos líneas + campana con punto + toggle de tema.
4. **PublicHeader (marketing)** — logo + nombre + "Entrar" + hamburguesa.
5. **BackHeader** — botón ‹ 38×38 en caja `green-50` + título 14/600 (+ acción a la derecha).
6. **StatPill (gamificación)** — 4 en fila: icono 20px, número 15/700, label 9/500 mayúsculas. Racha · Puntos · Insignias · % Test.
7. **HeroBanner** — gradiente verde, círculo blanco al 9% desbordado, eyebrow + titular 21/700, barra de progreso 8px, CTA blanco.
8. **QuickActionCard** — grid 2×2, icono 34px en caja `green-100`, título 14/600, meta 11/400.
9. **StreakStrip** — L M M J V S D; hechos círculo 30px verde con ✓; hoy con anillo `0 0 0 3px rgba(22,163,74,.2)`; futuros borde punteado.
10. **ChallengeRow** — icono + título + subtítulo + puntos a la derecha.
11. **Field** — label 12/500 arriba, caja 50–52px, radio 14, borde `green-200`; estado activo con focus ring.
12. **Chip / FilterChip** — pill; activo verde relleno con texto blanco, inactivo blanco con borde `green-200`.
13. **TabsRow** — chips deslizables horizontales (no subrayado) en Recursos y Comunidad; subrayado verde 2px solo en el detalle de programa.
14. **ProgramCard** — logo 46px + nombre + institución + badge de afinidad + chips de atributos.
15. **ResourceCard** — miniatura 56px (o portada 132px para el destacado) + tipo en eyebrow verde + título + meta.
16. **PostCard** — avatar 32px + autor/tiempo + chip de tipo + título 15/700 + extracto + pie con contadores.
17. **AnswerCard** — variante con columna de votos ▲ n ▼ a la izquierda.
18. **BottomSheet** — asa 44×5, título 19/700 + cerrar ✕, contenido, CTA 54px. Usada en modales de crear y menú de usuario.
19. **EmptyState** — placeholder de ilustración 140×120, título 22/800, texto y un CTA.
20. **ProgressHeader (test)** — ✕ + barra 8px + contador `12/60`.
21. **LikertScale** — 5 círculos (máx 52px, `aspect-ratio:1`) con números; seleccionado verde con ✓ y anillo; labels extremos "Nada como yo" / "Igualito a mí".
22. **ThemeSegmented** — Claro / Oscuro / Auto en caja `green-50`, activo blanco con sombra.
23. **Placeholder de imagen** — `repeating-linear-gradient(135deg,#DCFCE7 0 8px,#F0FDF4 8px 16px)` + borde `green-200` + etiqueta monoespaciada 10px. En oscuro: `#16281A`/`#0F1A11`.

---

## 5. Patrón de scroll

Cada pantalla es `display:flex; flex-direction:column` con altura completa:
header `flex:none` → contenido `flex:1; overflow-y:auto` → tab bar o CTA fijo `flex:none`.
En los mockups la columna de contenido usa `display:grid; grid-auto-rows:min-content` para que las tarjetas no se compriman al recortarse.

---

## 6. Mapa de pantallas

| # | Pantalla | Ruta | Mockup |
|---|---|---|---|
| 1 | Landing | `/` | Marketing + Navegación |
| 2 | Servicios | `/servicios` | Marketing + Navegación |
| 3 | Saber más | `/saber-mas` | Marketing + Navegación |
| 4 | Contacto | `/contacto` | Marketing + Navegación |
| 5–6 | Privacidad / Términos | `/privacidad`, `/terminos` | Marketing + Navegación (misma plantilla) |
| 7 | Login (claro + oscuro) | `/login` | Auth + Home |
| 8 | Registro | `/registro` | Auth + Home |
| 9 | Recuperar contraseña + estado enviado | `/recuperar` | Auth + Home |
| 10 | Reset de contraseña | `/reset` | Auth + Home |
| 11 | Home (claro + oscuro) | `/dashboard` | Auth + Home |
| 12 | Perfil / completar perfil | `/dashboard/perfil` | Auth + Home |
| 13 | Intro del test | `/dashboard/test` | Test + Programas |
| 14a | Pregunta opción múltiple | `/dashboard/test/:n` | Test + Programas |
| 14b | Pregunta escala Likert | `/dashboard/test/:n` | Test + Programas |
| 15 | Progreso + mini-reto | `/dashboard/test/pausa` | Test + Programas |
| 16 | Resultado / perfil vocacional | `/dashboard/test/resultado` | Test + Programas |
| 17 | Listado de programas | `/dashboard/profesiones` | Test + Programas |
| 18 | Detalle de programa | `/dashboard/profesiones/:id` | Test + Programas |
| 19 | Recursos (tabs Todos y Becas) | `/dashboard/recursos` | Recursos + Comunidad |
| 20 | Feed de comunidad | `/dashboard/comunidad` | Recursos + Comunidad |
| 21 | Detalle de foro | `/dashboard/comunidad/foro/:id` | Recursos + Comunidad |
| 22 | Detalle de historia | `/dashboard/comunidad/historia/:id` | Recursos + Comunidad |
| 23 | Detalle de convocatoria | `/dashboard/comunidad/convocatoria/:id` | Recursos + Comunidad |
| 24 | Detalle de pregunta | `/dashboard/comunidad/pregunta/:id` | Recursos + Comunidad |
| 25 | Modal compartir historia | — | Recursos + Comunidad |
| 26 | Modal hacer pregunta | — | Recursos + Comunidad |
| 27 | Menú de usuario | — | Marketing + Navegación |
| 28 | Sistema de tab bar (3 estados) | — | Marketing + Navegación |
| 29 | Toggle de tema | — | Marketing + Navegación (dentro del menú) y Perfil |
| 30–33 | Rutas formativas · Favoritos · Mensajes · Ajustes | placeholders | Marketing + Navegación |

Fuera de alcance: panel de administración.

---

## 7. Notas de comportamiento

- **Gamificación**: racha diaria (se rompe a las 24h sin actividad), puntos por acción (+10 racha, +15 pregunta, +20 mini-reto, +25/+50 perfil, +200 test completo), insignias con estado bloqueado visible.
- **Test**: una pregunta por vista, autoguardado en cada respuesta, reanudable desde el home y desde la intro; pausa con mini-reto cada 15 preguntas.
- **Resultado**: porcentajes por área ordenados de mayor a menor; barras sobre `green-100`, ≥50% en `green-600`, <50% en `green-400`.
- **Comunidad**: FAB verde 58px sobre la tab bar abre las hojas de crear; opción anónima en preguntas; moderación previa en historias.
- **Tema**: Claro / Oscuro / Auto persistido; el toggle vive en el header del dashboard, en el menú de usuario y en perfil.
- **Accesibilidad**: contraste mínimo AA sobre fondos verdes claros usando `#052E16`; nunca texto blanco sobre `green-400`.
