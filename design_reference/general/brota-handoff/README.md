# Brota móvil — paquete de diseño para Claude Code

Mockups móviles (390×844) de la app Brota, listos para implementarse.
Todo el color, tipografía, espaciado y microcopy sale de `DESIGN-SPEC.md`.

## Contenido

- `DESIGN-SPEC.md` — especificación completa: tokens, componentes, pantalla por pantalla.
- `tokens.css` — variables CSS de la paleta (claro y oscuro).
- `tailwind.tokens.js` — fragmento para `tailwind.config.js`.
- `mockups/` — 4 galerías HTML. Ábrelas en el navegador; cada frame es una pantalla real, no una imagen.

## Cómo usarlo con Claude Code

1. Lee `DESIGN-SPEC.md` completo antes de escribir código.
2. Implementa primero los tokens (`tokens.css` o el fragmento de Tailwind). No inventes colores fuera de esa paleta.
3. Construye en este orden: tab bar y layout base → auth → home → test → explorar → recursos → comunidad → marketing.
4. Para cada pantalla, abre el mockup correspondiente (tabla en DESIGN-SPEC) e inspecciona el HTML: los valores de padding, radio, tamaños y pesos tipográficos están inline y son la fuente de verdad.
5. Íconos y logo son placeholders geométricos a propósito: reemplázalos por el set final (Heroicons o los assets de marca) manteniendo el tamaño de caja (24px en tab bar, 14-16px dentro de chips y filas).
6. Las ilustraciones son placeholders rayados con etiqueta monoespaciada. Deja el contenedor con su tamaño y `border-radius`; solo cambia el contenido.

## Reglas que no se negocian

- Verde primario `#16A34A` solo en CTA, iconos activos y acentos. Nunca como fondo de texto largo.
- En modo oscuro los verdes bajan a `#4ADE80`.
- El crema `#F2EFEA` es exclusivo de las pantallas de autenticación.
- Área táctil mínima 44px.
- Voz en segunda persona, cercana y honesta. Verbos: Descubre, Explora, Encuentra, Empieza, Crece.
