# Cuestionarios

Repositorio de cuestionarios institucionales. Todas las rutas requieren una sesión con rol de institución.

| Método | Endpoint |
|---|---|
| `getCuestionarios` | `GET /api/institucion/cuestionarios` |
| `crearCuestionario` | `POST /api/institucion/cuestionarios` |
| `actualizarCuestionario` | `PATCH /api/institucion/cuestionarios/:id` |
| `eliminarCuestionario` | `DELETE /api/institucion/cuestionarios/:id` |
| `getPreguntas` | `GET /api/institucion/preguntas?cuestionario_id=:id` |
| `crearPregunta` | `POST /api/institucion/preguntas` |
| `actualizarPregunta` | `PATCH /api/institucion/preguntas/:id` |
| `eliminarPregunta` | `DELETE /api/institucion/preguntas/:id` |

Las opciones y sus pesos se envían dentro del body de la pregunta como `opciones: [{ label, icon, orden, pesos }]`.