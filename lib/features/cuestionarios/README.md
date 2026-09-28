# Feature `cuestionarios`

CRUD de los cuestionarios propios de una institución y de las preguntas de
cada uno, con sus opciones y los puntos que cada opción suma por categoría
vocacional.

Solo aplica a cuentas con rol `institucion`. La entrada de navegación
(`_BarraInstitucion` en `core/router/dashboard_shell.dart`) se monta según
`esInstitucionProvider`, y el backend rechaza con 403 a cualquier otra cuenta.

## Mapeo método → endpoint

Todos cuelgan de `${AppEnv.apiBaseUrl}/api` (lo arma `buildDioClient`).

| Método del repositorio | Endpoint |
|---|---|
| `getCuestionarios()` | `GET /institucion/cuestionarios` |
| `crearCuestionario(input)` | `POST /institucion/cuestionarios` |
| `actualizarCuestionario(id, input)` | `PATCH /institucion/cuestionarios/:id` |
| `eliminarCuestionario(id)` | `DELETE /institucion/cuestionarios/:id` |
| `getPreguntas(cuestionarioId)` | `GET /institucion/preguntas?cuestionario_id=…` |
| `crearPregunta(input)` | `POST /institucion/preguntas` |
| `actualizarPregunta(id, input)` | `PATCH /institucion/preguntas/:id` |
| `eliminarPregunta(id)` | `DELETE /institucion/preguntas/:id` |

## Por qué `/api/institucion` y no `/api/admin`

El panel admin tiene endpoints con el mismo nombre, pero su CRUD de preguntas
(`backend/src/controllers/admin/preguntasController.js`) solo escribe la
columna legada `preguntas.opciones` (JSONB), que el motor del test **no lee**.
El de institución sí gestiona las tablas relacionales `opciones` y
`pesos_opciones`, que son las que `perfilController.obtenerCuestionario` usa
para armar el test y calcular el perfil. Una pregunta creada contra `/admin`
no suma puntos a ninguna categoría.

## Las opciones no tienen endpoint propio

Viajan anidadas en el body de la pregunta:

```json
{ "opciones": [ { "label": "…", "icon": "🎨", "orden": 0,
                  "pesos": { "tecnologia": 5 } } ] }
```

En cada `POST`/`PATCH` el backend **reemplaza** las filas de
`opciones`/`pesos_opciones` de esa pregunta (borra y reinserta), así que el
editor siempre manda el estado completo, no un diff. El `GET` las devuelve ya
aplanadas, con `pesos` como mapa.

Dos consecuencias en `data/`: el `POST` devuelve la fila de `preguntas` **sin**
sus opciones (se insertan después, en tablas aparte), y algunos `PATCH`
responden solo `{ success, message }`. En los dos casos el modelo se completa
con lo que acabamos de enviar en vez de encadenar un `GET` extra.

## Tipos de pregunta

`domain/tipo_pregunta.dart` replica el catálogo del web
(`frontend/src/utils/tiposPregunta.js`, commit `b10ab48`): tres claves
canónicas — `opcion_unica`, `opcion_multiple`, `likert` — más los alias
legados `single`/`seleccion` → única y `multiple` → múltiple, que siguen vivos
en filas que nunca se migraron.

- `fromApi` nunca lanza: lo desconocido cae a `opcionUnica`.
- `toApi` siempre emite una clave canónica, porque desde `b10ab48` el backend
  responde **400** ante un tipo fuera del catálogo.

Si se agrega un tipo, hay que tocarlo en los tres lados: acá, en el catálogo
del frontend web y en su espejo del backend.

## Categorías

`domain/categoria_vocacional.dart` replica `CATEGORIA_OPCIONES` de
`frontend/src/utils/vocacionalCategorias.js`. Son las mismas claves que usa
`programas.area_academica`: **no inventar valores nuevos**, o la categoría
queda sin programas y no aparece en ninguna recomendación.

## Errores

Todo sale como `Result<T>` con un `Failure` tipado; ninguna `DioException`
escapa de `data/`. Dos casos con trato propio sobre
`mapDioExceptionToFailure`:

- **403** → `AuthFailure` explicando que la cuenta no tiene rol institución
  (es la causa real, y el mensaje genérico de la API no lo dice).
- **400** → `ValidationFailure`, no `ServerFailure`: acá un 400 siempre es dato
  mal armado (tipo inválido, menos de 2 opciones) y la UI debe tratarlo como
  corregible.
