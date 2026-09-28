import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/cuestionario.dart';
import '../controllers/cuestionarios_controller.dart';

/// Crear o editar un cuestionario. [cuestionarioId] null = creación.
class CuestionarioFormScreen extends ConsumerStatefulWidget {
  const CuestionarioFormScreen({this.cuestionarioId, super.key});

  final String? cuestionarioId;

  @override
  ConsumerState<CuestionarioFormScreen> createState() =>
      _CuestionarioFormScreenState();
}

class _CuestionarioFormScreenState
    extends ConsumerState<CuestionarioFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _version;
  late final TextEditingController _descripcion;
  bool _activo = false;
  bool _inicializado = false;
  String? _error;

  bool get _esEdicion => widget.cuestionarioId != null;

  @override
  void initState() {
    super.initState();
    _nombre = TextEditingController();
    _version = TextEditingController(text: '1.0');
    _descripcion = TextEditingController();
  }

  @override
  void dispose() {
    _nombre.dispose();
    _version.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  /// Los datos a editar salen de la lista ya cargada, no de un GET por id: el
  /// backend no expone `GET /cuestionarios/:id` y la lista siempre está en
  /// memoria cuando se llega acá.
  void _precargar(CuestionariosState state) {
    if (_inicializado || !_esEdicion) return;
    final Cuestionario? actual = state.cuestionarios
        .where((c) => c.id == widget.cuestionarioId)
        .firstOrNull;
    if (actual == null) return;
    _nombre.text = actual.nombre;
    _version.text = actual.version;
    _descripcion.text = actual.descripcion ?? '';
    _activo = actual.activo;
    _inicializado = true;
  }

  Future<void> _guardar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final CuestionariosController controller = ref.read(
      cuestionariosControllerProvider.notifier,
    );
    final CuestionarioInput input = CuestionarioInput(
      nombre: _nombre.text.trim(),
      version: _version.text.trim(),
      descripcion: _descripcion.text.trim(),
      activo: _activo,
    );

    final String? error = _esEdicion
        ? await controller.actualizar(widget.cuestionarioId!, input)
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
    final CuestionariosState state = ref.watch(cuestionariosControllerProvider);
    _precargar(state);

    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar cuestionario' : 'Nuevo cuestionario'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.maxFormWidth,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nombre,
                    enabled: !state.guardando,
                    decoration: const InputDecoration(labelText: 'Nombre *'),
                    validator: (v) => (v ?? '').trim().isEmpty
                        ? 'El nombre es obligatorio'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _version,
                    enabled: !state.guardando,
                    decoration: const InputDecoration(labelText: 'Versión *'),
                    validator: (v) => (v ?? '').trim().isEmpty
                        ? 'La versión es obligatoria'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _descripcion,
                    enabled: !state.guardando,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SwitchListTile(
                    value: _activo,
                    onChanged: state.guardando
                        ? null
                        : (v) => setState(() => _activo = v),
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Activo'),
                    subtitle: const Text(
                      'Activarlo desactiva tus otros cuestionarios. No afecta '
                      'al cuestionario general de Brota ni al de otras '
                      'instituciones.',
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
