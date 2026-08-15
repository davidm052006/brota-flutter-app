# Mascota Brota — perezoso con lentes

Estado del trabajo de la mascota (perezoso/sloth) para Brota, generada con Recraft AI. Este documento existe para retomar el trabajo en otra sesión sin perder el contexto.

## Referencias originales
Las 6 imágenes `WhatsApp Image *.jpeg` son las referencias de estilo que dio el usuario (perezositos kawaii, contorno grueso, cuerpo café/crema). La mascota de Brota se basa en ese estilo pero solo de cara (sin cuerpo ni ramita), con lentes redondos añadidos.

## Inventario de archivos

| Archivo | Qué es | Estado |
|---|---|---|
| `logo base.svg` | Export crudo de Recraft, primera generación (lentes sin separar del ojo). **Superado, no usar.** | histórico |
| `lentes.svg` | Export crudo de Recraft, segunda generación — se le pidió que redibujara los lentes como pieza separada. **Fuente de verdad**, no editar directamente. | fuente, intacto |
| `logo-base-limpio.svg` | Base de trabajo actual: `lentes.svg` limpio (sin metadata C2PA ni el rect de fondo blanco) y con los 37 paths agrupados con IDs semánticos. Recoloreado (2026-08-15) de `#16A34A`/`#13AF6F` al verde real de marca `#21BD68`. | ✅ estable |
| `logo-guino.svg` | Variante: ojo derecho guiñando. Estructura del ojo cerrado confirmada por el usuario ("bien me gusta"); la última edición le devolvió el brillo de vidrio (ver receta final abajo) pero esa versión puntual no llegó a confirmarse en palabras antes de cerrar la sesión — revisar visualmente al retomar. Recoloreada (2026-08-15) igual que la base. | ✅ estructura correcta, ⚠️ confirmar el brillo de vidrio |
| `logo-triste.svg` | Variante: ceño fruncido + lágrima bajo el ojo izquierdo. Construida sobre `logo-base-limpio.svg`, no toca el grupo de ojos. Recoloreada (2026-08-15) igual que la base. | ✅ debería estar bien, no se re-verificó visualmente en la última tanda de fixes (solo toca nariz/boca/lágrima, no los ojos) |
| `logo-feliz.svg` | Variante nueva (2026-08-15): sonrisa grande/celebración. Construida sobre `logo-base-limpio.svg` ya recoloreado — solo toca `boca-nariz-2` (ensanchada y profundizada con un escalado paramétrico centrado en x=512, aplicado solo a la porción por debajo de y≈640 para no tocar la nariz), no toca ojos ni lentes. Pensada para el hito de racha (🔥 N días) y el resultado del test vocacional completado. | ✅ generada y verificada visualmente esta sesión |

Todas las variantes parten de `logo-base-limpio.svg` — si se vuelve a tocar la base, hay que reconstruir `logo-guino.svg`, `logo-triste.svg` y `logo-feliz.svg` desde la nueva versión (no son independientes).

## Estructura interna de `logo-base-limpio.svg`

viewBox `0 0 1024 1024`, sin fondo (transparente). IDs principales:

- `contorno-base` — silueta cabeza+orejas
- `cabeza-pelaje` — relleno café del pelaje
- `mascara-contorno` — silueta de la máscara facial crema
- `lentes-marco` — **el armazón real de las gafas** (extraído de `lentes.svg`, el único elemento que Recraft generó como pieza separada tras pedírselo explícitamente). `fill="none" stroke="#16A34A" stroke-width="18"`. Es un solo `<path>` con las dos lentes + el puente en un trazo continuo.
- `<g id="ojo-derecho">` / `<g id="ojo-izquierdo">` — 12-13 sub-piezas cada uno (ver tabla abajo). El sufijo numérico es solo orden de aparición, no tiene significado propio.
- `<g id="boca-nariz">` — nariz + línea de sonrisa
- `mascara-superior` — máscara facial, mitad superior
- `<g id="orejas">` — sombra interior + pelaje exterior de cada oreja
- `hoja` — brote verde en la cabeza (acento de marca)

### Anatomía de cada ojo (importante para futuras expresiones)

Cada ojo son 12-13 paths superpuestos dentro de un círculo (el "lente"). De adentro hacia afuera / por capas:

1. **Base del lente**: un disco oscuro (`#360E0A`, ligeramente más grande) + un disco claro encima (`#FFFEFE`, "vidrio"). Juntos casi llenan el círculo del marco.
2. **El ojo real**: dentro de esa base hay un cluster PEQUEÑO y separado — contorno + esclerótica blanca + iris gris + pupila negra — centrado en **la posición real del ojo, que NO coincide con el centro geométrico del aro**. El aro/lente tiene su centro en `y≈541`; el ojo real vive en `y≈568` (unas 27-30 unidades más abajo). Este desfase fue la causa del bug "el ojo del guiño quedó muy arriba".
3. **Medialunas de sombra/brillo** (`#937566`, `#C79570`, etc.) — decoran el "vidrio", dan sensación de reflejo. Si se dejan sueltas (sin el cluster de pupila en medio) casi cierran un círculo completo por sí solas → se lee como "un segundo ojo fantasma". Esto causó dos rondas de bugs.

**Receta final que quedó confirmada para "cerrar" un ojo (usada en el guiño derecho)**, de las 12 piezas de `ojo-derecho`:

- **Conservar**: `ojo-derecho-1` (disco oscuro base), `ojo-derecho-2` (disco blanco "vidrio"), `ojo-derecho-10` (el brillo diagonal de vidrio, único, no forma anillo).
- **Borrar**: `ojo-derecho-3,4,5,11,12` (las medialunas de sombra — casi cierran un círculo completo entre todas y se leen como "un segundo ojo fantasma") y `ojo-derecho-6,7,8,9` (el cluster del ojo real: contorno+esclerótica+iris+pupila).
- **Agregar**: una sola línea de guiño (`stroke`, sin relleno) centrada en la posición real del ojo, no en el centro del aro (ver geometría abajo). **No** agregarle una segunda curva de "sombra" detrás — por sutil que se vea en el render, se lee como un guiño fantasma duplicado. Tampoco hace falta un círculo nuevo tapando todo: dejar `ojo-derecho-1`/`-2` como están ya cubre el área correctamente.

Intentos que NO funcionaron (para no repetirlos): (a) tapar todo con un círculo nuevo encima → crea doble círculo visible porque el disco blanco original sigue ahí debajo; (b) dejar las medialunas de sombra sueltas sin el cluster de pupila en medio → arman el aro fantasma; (c) agregar una curva de sombra detrás de la línea de guiño → se lee como un segundo guiño.

**Sobre discrepancias "yo lo veo bien, el usuario lo ve mal"**: cuando esto pasa, no sigas iterando a ciegas sobre hipótesis — arma un artifact HTML que inserte el `<svg>` real (no una captura PNG) para que ambos vean exactamente el mismo render en el navegador. Elimina de raíz la duda de si es un problema del archivo o del visor/caché. Se usó para esta variante y ayudó a converger rápido.

### Geometría exacta (calculada con `svgpathtools`, no a ojo)

- Ojo/lente derecho: centro `(650.94, 541.03)`, radio `112.26` (línea central del trazo del marco; el marco tiene `stroke-width=18` así que el borde interior real está en radio ≈103).
- Ojo/lente izquierdo: centro `(373.16, 541.11)`, radio `112.13`.
- Posición real de la pupila (no la del centro del aro): ojo derecho ≈ `(657, 572)`, ojo izquierdo ≈ `(384, 570)`. La línea de guiño de `logo-guino.svg` usa el punto `(655, 568)` como centro.

### Paleta usada en las variantes

| Uso | Color |
|---|---|
| Marco de lentes / hoja | `#21BD68` (verde primario real de marca, `--primary` modo claro en `frontend/src/index.css` — antes `#16A34A`/`#13AF6F` de la generación Recraft, corregido 2026-08-15) |
| Crema de cara/máscara | `#E1CFC6` |
| Contorno oscuro / línea de guiño | `#360E0A` |
| Lágrima (triste) | relleno `#8ECFEB`, contorno `#360E0A` |

`#937566` (tono de las medialunas de "vidrio") se probó como color de sombra detrás del guiño y se descartó — ver lección arriba.

## Prompt de Recraft usado para separar los lentes

El prompt que sí funcionó (pedido en modo edición de Recraft, sobre la imagen ya generada, no un prompt de generación desde cero):

```
Keep this exact sloth face illustration unchanged — same pose, proportions,
fur color, face mask, nose, mouth, ears, and leaf. The only fix needed: redraw
the round glasses as two fully separate, independently colorable vector
shapes layered on top of the face — one closed shape for the frame/rim, and
a separate closed shape for the lens/glass area inside it — neither merged,
blended, or overlapping with the eye patches, pupils, or fur shading behind
them. Keep every other element (eyes, pupils, eye patches, nose, mouth, ears,
fur, leaf) as its own separate flat-colored closed shape too, with no merged
or overlapping paths, so each part can be selected and recolored on its own.
```

Resultado: Recraft sí separó el marco (`lentes-marco`) como un único path independiente, pero de paso agregó los detalles de "vidrio" (medialunas de sombra/brillo) que no se habían pedido — eso es lo que generó la complejidad en `ojo-derecho`/`ojo-izquierdo`.

## Herramientas instaladas en esta sesión

Para trabajar SVG con precisión en vez de estimar centros/radios mirando capturas de pantalla:

- `svgpathtools` (Python, `pip install --break-system-packages`) — parsea el atributo `d` real en curvas Bézier, da bounding boxes exactos, ajuste de círculos por mínimos cuadrados, muestreo de puntos. Se usó para calcular toda la geometría de la sección anterior.
- `svgelements` (Python) — alternativa, entiende también `<g>` y transforms anidados.
- `pillow` + `numpy` (Python) — para inspeccionar renders PNG píxel a píxel (comparar versiones, medir colores).
- Ya estaban disponibles en el sistema: `rsvg-convert` (SVG → PNG) e `imagemagick` (`magick`/`convert`, para crop/resize/comparar). **No** está instalado Inkscape (no hay CLI para operaciones booleanas reales tipo unir/restar formas — si se necesita eso, instalarlo).

## Pendiente para la próxima sesión

1. **Confirmar visualmente la última versión de `logo-guino.svg`** (la que dejó el brillo de vidrio — base blanca + `ojo-derecho-10` + línea de guiño). El usuario ya había confirmado la versión sin brillo ("bien me gusta") antes de pedir que se le devolviera el brillo; esa última edición no se alcanzó a confirmar en palabras. Hay un artifact HTML publicado en esa sesión que compara base vs guiño en vivo (url solo válida dentro de esa conversación, no reproducible acá — si hace falta volver a comparar, generar uno nuevo con el mismo método: insertar el `<svg>` real de ambos archivos en un HTML y publicarlo). Sigue abierto — no tocado en esta sesión (solo se le corrigió color).
2. Si el guiño queda confirmado, aplicar la misma receta (sección "Receta final" arriba) a `logo-triste.svg` — que en principio no debería tener el mismo bug porque no toca el grupo de ojos, pero no se re-verificó visualmente tras las últimas correcciones. Sigue abierto.
3. ~~Decidir si vale la pena regenerar más expresiones (feliz grande, sorprendido, dormido, etc.)~~ — resuelto parcialmente esta sesión (2026-08-15): se generó `logo-feliz.svg` (sonrisa grande, solo `boca-nariz-2`, geometría calculada con `svgpathtools`, no a ojo). Sorprendido/dormido siguen sin priorizar — no hay un momento de producto documentado en los briefs que los necesite todavía.
4. Pendiente de sesión anterior, sigue abierto: animar la mascota (se descartaron herramientas de IA generativa tipo Kling/Pika por distorsionar el vector; la recomendación fue CSS/SMIL directo sobre estos grupos, o Rive).
5. ~~Nuevo (2026-08-15): las 4 variantes son ahora `.svg` puros sin forma de renderizarse en la app~~ — resuelto: se agregó `flutter_svg` a `pubspec.yaml` y `logo-base-limpio.svg` ya está integrada de verdad en `HeroBanner` (saludo del dashboard) vía el widget compartido `BrotaIconBadge` (`lib/shared/widgets/brota_icon_badge.dart`). `logo-guino`/`logo-triste`/`logo-feliz` siguen sin un punto de integración real en pantalla — ver `MOBILE_DESIGN_BRIEF.md` §1.2.1 para el mapeo previsto.
6. Nuevo (2026-08-15): se separó un segundo set — 16 iconos UI en `icon-*.svg` (ver sección siguiente). 4 de ellos ya están integrados en `QuickActions`; los otros 12 quedan documentados y listos, sin punto de integración todavía (categorías de test vocacional/profesiones, bottom nav, etc. — esas pantallas siguen siendo placeholders).

## Set de iconos UI (2026-08-15)

`flat-vector-icon-sheet--16-icons-arranged-in-a-cle.svg` es una hoja de
16 iconos generada con Recraft (mismo estilo que la mascota — contorno
`#360E0A`, relleno crema `#E1CFC6`, acento verde). Es fuente cruda, igual
que `lentes.svg`/`logo base.svg` de la mascota: **no se usa directo en la
app**. Se separó en clústeres espaciales (agrupando los `<path>` de la
hoja por posición en la cuadrícula 4×4 con `svgpathtools`, no a mano) en
16 archivos independientes, cada uno con su propio `viewBox` recortado al
contenido real + padding, y el verde recoloreado a `#21BD68` igual que la
mascota (la hoja original traía 3 verdes distintos de Recraft:
`#0E8013`, `#16A34A`, `#35531C`, ninguno el real de marca).

| Archivo | Icono | Uso previsto | Integrado en |
|---|---|---|---|
| `icon-buscar.svg` | lupa + hoja | búsqueda/explorar (genérico) | — |
| `icon-confirmar.svg` | check | confirmación, test | `QuickActions` ("Realizar test") |
| `icon-ruta.svg` | camino + bandera | Rutas formativas | `QuickActions` ("Rutas formativas") |
| `icon-recursos.svg` | libro | Recursos | `QuickActions` ("Explorar recursos") |
| `icon-comunidad.svg` | 2 burbujas de chat | Comunidad | — |
| `icon-profesiones.svg` | birrete | Explorar profesiones | `QuickActions` ("Explorar profesiones") |
| `icon-favoritos.svg` | estrella | Favoritos | — |
| `icon-racha.svg` | llama | Racha (sin backend todavía) | — |
| `icon-ajustes.svg` | engranaje | Ajustes | — |
| `icon-mensajes.svg` | sobre | Mensajes | — |
| `icon-instituciones.svg` | edificio | Admin → Instituciones | — |
| `icon-negocios.svg` | maletín | categoría Negocios/Emprendimiento | — |
| `icon-categoria-tecnologia.svg` | laptop `</>` | categoría Tecnología | — |
| `icon-categoria-salud.svg` | escudo+cruz | categoría Salud | — |
| `icon-categoria-ciencias.svg` | matraz | categoría Ciencias | — |
| `icon-categoria-arte.svg` | paleta | categoría Arte/Diseño | — |

**Regla de contraste (aplica también a la mascota):** el contorno
`#360E0A` de estas ilustraciones pierde casi todo el contraste sobre
cualquier superficie oscura del tema (`AppColors.darkBg`, `darkSurface`,
`darkPrimarySoft`). Por eso siempre se renderizan dentro de un badge
circular de fondo crema fijo (`BrotaIconBadge`,
`lib/shared/widgets/brota_icon_badge.dart`) — no reactivo al tema, igual
que `logo-brota.png` es un asset de paleta fija. Verificado visualmente
en modo claro y oscuro antes de integrar (ver `MOBILE_DESIGN_BRIEF.md`
§1.2.2 para el detalle de la integración y qué queda pendiente).
