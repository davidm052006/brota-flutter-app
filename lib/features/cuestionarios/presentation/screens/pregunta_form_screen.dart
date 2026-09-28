import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/categoria_vocacional.dart';
import '../../domain/opcion_pregunta.dart';
import '../../domain/pregunta.dart';
import '../../domain/tipo_pregunta.dart';
import '../controllers/preguntas_controller.dart';
import '../widgets/opciones_editor.dart';

/// Etiquetas con las que se pre-carga una escala Likert. Mismas 5 posiciones
/// que dibuja `PreguntaLikert.jsx` en el web (de menor a mayor afinidad).
const List<String> _etiquetasLikert = [
  'Nada',
  'Poco',
  'Neutral',
  'Bastante',
  'Mucho',
];

/// Crear o editar una pregunta. [preguntaId] null = creación.
///
/// El formulario **cambia según el tipo elegido**, igual que en el web: única y
/// múltiple arrancan con dos opciones vacías, y Likert precarga las 5 etiquetas
/// de la escala.
class PreguntaFormScreen extends ConsumerStatefulWidget {
  const PreguntaFormScreen({
    required this.cuestionarioId,
    this.preguntaId,
    super.key,
  });

  final String cuestionarioId;
  final String? preguntaId;

  @override
  ConsumerState<PreguntaFormScreen> createState() => _PreguntaFormScreenState();
}

class _PreguntaFormScreenState extends ConsumerState<PreguntaFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _texto;
  late final TextEditingController _orden;
  late final TextEditingController _peso;

  TipoPregunta _tipo = TipoPregunta.opcionUnica;
  String? _categoria;
  List<OpcionPregunta> _opciones = const [];
  bool _inicializado = false;
  String? _error;

  bool get _esEdicion => widget.preguntaId != null;

  @override
  void initState() {
    super.initState();
    _texto = TextEditingController();
    _orden = TextEditingController();
    _peso = TextEditingController(text: '1.0');
    _opciones = _opcionesPorDefecto(_tipo);
  }

  @override
  void dispose() {
    _texto.dispose();
    _orden.dispose();
    _peso.dispose();
    super.dispose();
  }

  List<OpcionPregunta> _opcionesPorDefecto(TipoPregunta tipo) {
    if (tipo == TipoPregunta.likert) {
      return [
        for (final (int i, String etiqueta) in _etiquetasLikert.indexed)
          OpcionPregunta(label: etiqueta, orden: i),
      ];
    }
    return const [
      OpcionPregunta(label: '', orden: 0),
      OpcionPregunta(label: '', orden: 1),
    ];
  }

  void _precargar(PreguntasState state) {
    if (_inicializado || !_esEdicion) return;
    final Pregunta? actual = state.preguntas
        .where((p) => p.id == widget.preguntaId)
        .firstOrNull;
    if (actual == null) return;
    _texto.text = actual.texto;
    _orden.text = '${actual.orden}';
    _peso.text = '${actual.peso}';
    _tipo = actual.tipo;
    _categoria = actual.categoria?.isEmpty ?? true ? null : actual.categoria;
    _opciones = actual.opciones;
    _inicializado = true;
  }

  /// Cambiar de tipo solo reemplaza las opciones si las actuales siguen
  /// vacías: si ya se escribió algo, se conserva (cambiar única ↔ múltiple no
  /// debería tirar el trabajo hecho).
  void _cambiarTipo(TipoPregunta nuevo) {
    setState(() {
      final bool todasVacias = _opciones.every((o) => o.label.trim().isEmpty);
      _tipo = nuevo;
      if (todasVacias ||
          (nuevo == TipoPregunta.likert && _opciones.length < 3)) {
        _opciones = _opcionesPorDefecto(nuevo);
      }
    });
  }

  Future<void> _guardar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_opciones.length < OpcionesEditor.minimoOpciones) {
      setState(
        () => _error =
            'La pregunta necesita al menos ${OpcionesEditor.minimoOpciones} '
            'opciones.',
      );
      return;
    }
    if (_opciones.any((o) => o.label.trim().isEmpty)) {
      setState(() => _error = 'Todas las opciones necesitan texto.');
      return;
    }

    final PreguntasController controller = ref.read(
      preguntasControllerProvider(widget.cuestionarioId).notifier,
    );
    final PreguntaInput input = PreguntaInput(
      cuestionarioId: widget.cuestionarioId,
      texto: _texto.text.trim(),
      tipo: _tipo,
      orden: int.tryParse(_orden.text.trim()),
      categoria: _categoria,
      peso: double.tryParse(_peso.text.trim()) ?? 1.0,
      opciones: _opciones,
    );

    final String? error = _esEdicion
        ? await controller.actualizar(widget.preguntaId!, input)
        : await controller.crear(input);

    if (!mounted) return;
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final PreguntasState state = ref.watch(
      preguntasControllerProvider(widget.cuestionarioId),
    );
    _precargar(state);

    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar pregunta' : 'Nueva pregunta'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.maxContentWidth,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _texto,
                    enabled: !state.guardando,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Texto de la pregunta *',
                    ),
                    validator: (v) => (v ?? '').trim().isEmpty
                        ? 'El texto es obligatorio'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<TipoPregunta>(
                    initialValue: _tipo,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de pregunta',
                    ),
                    items: [
                      for (final TipoPregunta t in TipoPregunta.values)
                        DropdownMenuItem<TipoPregunta>(
                          value: t,
                          child: Text(t.label),
                        ),
                    ],
                    onChanged: state.guardando
                        ? null
                        : (v) => _cambiarTipo(v ?? TipoPregunta.porDefecto),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _tipo.descripcion,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<String?>(
                    initialValue: _categoria,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Categoría de la pregunta',
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        child: Text('Sin categoría'),
                      ),
                      for (final c in CategoriaVocacional.opciones)
                        DropdownMenuItem<String?>(
                          value: c.value,
                          child: Text(c.label),
                        ),
                    ],
                    onChanged: state.guardando
                        ? null
                        : (v) => setState(() => _categoria = v),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _orden,
                          enabled: !state.guardando,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Orden',
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: TextFormField(
                          controller: _peso,
                          enabled: !state.guardando,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Peso'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  OpcionesEditor(
                    opciones: _opciones,
                    tipo: _tipo,
                    habilitado: !state.guardando,
                    onChanged: (nuevas) => setState(() => _opciones = nuevas),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _error!,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton(
                    onPressed: state.guardando ? null : _guardar,
                    child: state.guardando
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_esEdicion ? 'Guardar cambios' : 'Crear'),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
