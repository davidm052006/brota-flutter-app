import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/network_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

Map<String, dynamic>? _asJsonMap(Object? value) =>
    value is Map<String, dynamic> ? value : null;

const _modules = <_Module>[
  _Module('usuarios', 'Usuarios', Icons.people_outline, [
    'nombre',
    'apellido',
    'email',
    'rol',
  ]),
  _Module('instituciones', 'Instituciones', Icons.account_balance_outlined, [
    'nombre',
    'ciudad',
    'tipo',
  ]),
  _Module('programas', 'Programas', Icons.school_outlined, [
    'nombre',
    'area_academica',
    'modalidad',
  ]),
  _Module('convocatorias', 'Convocatorias', Icons.campaign_outlined, [
    'titulo',
    'institucion',
    'fecha_cierre',
  ]),
  _Module('cuestionarios', 'Cuestionarios', Icons.quiz_outlined, [
    'nombre',
    'version',
    'activo',
  ]),
  _Module('preguntas', 'Preguntas', Icons.help_outline, [
    'texto',
    'tipo',
    'categoria',
  ]),
  _Module('contactos', 'Solicitudes', Icons.mail_outline, [
    'nombre',
    'email',
    'estado',
  ]),
  _Module('preguntas-comunidad', 'Reportes', Icons.flag_outlined, [
    'titulo',
    'area',
    'created_at',
  ]),
];

class _Module {
  const _Module(this.path, this.title, this.icon, this.fields);
  final String path, title;
  final IconData icon;
  final List<String> fields;
  bool get readOnly => path == 'preguntas-comunidad';
  bool get noCreate => readOnly || path == 'contactos';
  bool get noDelete => path == 'contactos';
}

class AdminPanelScreen extends ConsumerStatefulWidget {
  const AdminPanelScreen({super.key});
  @override
  ConsumerState<AdminPanelScreen> createState() => _AdminState();
}

class _AdminState extends ConsumerState<AdminPanelScreen> {
  _Module module = _modules.first;
  List<Map<String, dynamic>> rows = [];
  bool loading = true;
  bool isAdmin = false;
  String? error;
  int page = 1, pages = 1;
  String search = '';
  Dio get dio => ref.read(dioProvider);
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);
    error = null;
    try {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) throw Exception('Inicia sesión para entrar al panel.');
      final Object? profileResponse = (await dio.get<Object?>(
        '/perfil/${user.id}',
      )).data;
      final Map<String, dynamic>? profileEnvelope = _asJsonMap(profileResponse);
      final Map<String, dynamic>? profile =
          _asJsonMap(profileEnvelope?['data']) ?? profileEnvelope;
      if (profile == null || profile['rol'] != 'admin') {
        throw Exception(
          'Esta sección está disponible solo para administradores.',
        );
      }
      setState(() => isAdmin = true);
      final Response<Object?> response = await dio.get<Object?>(
        '/admin/${module.path}',
        queryParameters: {
          'pagina': page,
          'limite': 10,
          if (search.isNotEmpty) 'busqueda': search,
        },
      );
      final Object? body = response.data;
      final Map<String, dynamic>? bodyMap = _asJsonMap(body);
      final Object? data = bodyMap?['data'] ?? body;
      if (data is! List<dynamic>) {
        throw const FormatException('Respuesta inesperada del servidor.');
      }
      final Map<String, dynamic> meta =
          _asJsonMap(bodyMap?['meta']) ?? const <String, dynamic>{};
      setState(() => rows = data.whereType<Map<String, dynamic>>().toList());
      pages = (meta['totalPaginas'] as num?)?.toInt() ?? 1;
    } on DioException catch (e) {
      error = _asJsonMap(e.response?.data)?['message']?.toString();
      error ??= e.response?.statusCode == 403
          ? 'No tienes permisos para este módulo.'
          : 'No fue posible cargar los datos.';
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  List<String> formFields(Map<String, dynamic>? row) {
    switch (module.path) {
      case 'usuarios':
        return [
          if (row == null) 'email',
          if (row == null) 'password',
          'nombre',
          'apellido',
          'ciudad',
          'nivel_educativo',
          'edad',
          'grado',
          'telefono',
          'rol',
        ];
      case 'instituciones':
        return [
          'nombre',
          'tipo',
          'ciudad',
          'departamento',
          'direccion',
          'telefono',
          'email',
          'sitio_web',
          'costo_promedio',
          'activa',
        ];
      case 'programas':
        return [
          'nombre',
          'tipo',
          'area_academica',
          'duracion',
          'modalidad',
          'descripcion',
          'requisitos',
          'costo_matricula',
          'institucion_id',
          'activo',
        ];
      case 'convocatorias':
        return [
          'tipo',
          'titulo',
          'institucion',
          'ciudad',
          'descripcion',
          'detalles',
          'url',
          'fecha_cierre',
          'activa',
        ];
      case 'cuestionarios':
        return ['nombre', 'version', 'descripcion', 'activo'];
      case 'preguntas':
        return [
          'cuestionario_id',
          'texto',
          'tipo',
          'orden',
          'categoria',
          'peso',
          'opciones',
        ];
      case 'contactos':
        return ['estado', 'notas_admin'];
      default:
        return [];
    }
  }

  Future<void> edit([Map<String, dynamic>? row]) async {
    final fields = formFields(row);
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _EditForm(
        title:
            (row == null ? 'Nuevo ' : 'Editar ') + module.title.toLowerCase(),
        fields: fields,
        row: row,
      ),
    );
    if (result == null) return;
    try {
      final id = row?['id'];
      if (module.path == 'contactos') {
        await dio.patch<dynamic>('/admin/contactos/$id', data: result);
      } else if (id == null) {
        await dio.post<dynamic>('/admin/${module.path}', data: result);
      } else {
        await dio.patch<dynamic>('/admin/${module.path}/$id', data: result);
      }
      await load();
    } on DioException catch (e) {
      toast(e);
    }
  }

  Future<void> remove(Map<String, dynamic> row) async {
    final id = row['id'];
    if (id == null) return;
    final yes = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Eliminar registro'),
        content: Text(
          '¿Eliminar ${row['nombre'] ?? row['titulo'] ?? row['texto'] ?? 'este registro'}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (yes != true) return;
    try {
      await dio.delete<dynamic>('/admin/${module.path}/$id');
      await load();
    } on DioException catch (e) {
      toast(e);
    }
  }

  void toast(DioException e) {
    final Map<String, dynamic>? responseData = _asJsonMap(e.response?.data);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          responseData != null
              ? (responseData['message']?.toString() ?? 'Error del servidor')
              : 'No se pudo completar la operación.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Panel de administración'),
      actions: [
        if (isAdmin)
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(
              child: Chip(
                avatar: Icon(Icons.admin_panel_settings_outlined, size: 18),
                label: Text('Administrador'),
              ),
            ),
          ),
      ],
    ),
    floatingActionButton: module.noCreate
        ? null
        : FloatingActionButton.extended(
            onPressed: edit,
            icon: const Icon(Icons.add),
            label: Text('Nuevo ${module.title.toLowerCase()}'),
          ),
    body: Column(
      children: [
        SizedBox(
          height: 64,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              for (final m in _modules)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    avatar: Icon(m.icon, size: 18),
                    label: Text(m.title),
                    selected: m == module,
                    onSelected: (_) {
                      setState(() {
                        module = m;
                        page = 1;
                        search = '';
                      });
                      load();
                    },
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar ${module.title.toLowerCase()}',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (v) {
              search = v.trim();
              page = 1;
              load();
            },
          ),
        ),
        Expanded(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock_outline, size: 44),
                        const SizedBox(height: 12),
                        Text(error!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: load,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 90),
                    children: [
                      if (rows.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 90),
                          child: Center(child: Text('No hay registros.')),
                        ),
                      for (final row in rows)
                        Card(
                          child: ListTile(
                            isThreeLine: true,
                            title: Text(
                              (row['nombre'] ??
                                      row['titulo'] ??
                                      row['texto'] ??
                                      row['email'] ??
                                      row['id'])
                                  .toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              module.fields
                                  .where((f) => row[f] != null)
                                  .map((f) => '$f: ${row[f]}')
                                  .join('\n'),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (v) {
                                if (v == 'edit') edit(row);
                                if (v == 'delete') remove(row);
                              },
                              itemBuilder: (_) => [
                                if (!module.readOnly)
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Editar'),
                                  ),
                                if (!module.noDelete)
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Eliminar'),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      if (pages > 1)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: page > 1
                                  ? () {
                                      page--;
                                      load();
                                    }
                                  : null,
                              icon: const Icon(Icons.chevron_left),
                            ),
                            Text('$page / $pages'),
                            IconButton(
                              onPressed: page < pages
                                  ? () {
                                      page++;
                                      load();
                                    }
                                  : null,
                              icon: const Icon(Icons.chevron_right),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
        ),
      ],
    ),
  );
}

class _EditForm extends StatefulWidget {
  const _EditForm({required this.title, required this.fields, this.row});
  final String title;
  final List<String> fields;
  final Map<String, dynamic>? row;
  @override
  State<_EditForm> createState() => _EditFormState();
}

class _EditFormState extends State<_EditForm> {
  final key = GlobalKey<FormState>();
  late final ctrls = {
    for (final f in widget.fields) f: TextEditingController(text: _initial(f)),
  };
  String _initial(String f) {
    final v = widget.row?[f];
    if (v == null) {
      return f == 'activa'
          ? 'true'
          : f == 'activo'
          ? 'false'
          : f == 'detalles'
          ? '{}'
          : f == 'opciones'
          ? '[]'
          : '';
    }
    return v is Map || v is List
        ? const JsonEncoder.withIndent('  ').convert(v)
        : v.toString();
  }

  @override
  void dispose() {
    for (final c in ctrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      20,
      16,
      20,
      MediaQuery.viewInsetsOf(context).bottom + 20,
    ),
    child: Form(
      key: key,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            for (final f in widget.fields)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextFormField(
                  controller: ctrls[f],
                  maxLines:
                      [
                        'descripcion',
                        'requisitos',
                        'detalles',
                        'opciones',
                      ].contains(f)
                      ? 4
                      : 1,
                  decoration: InputDecoration(
                    labelText: f,
                    helperText: ['detalles', 'opciones'].contains(f)
                        ? 'Formato JSON'
                        : null,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if ([
                          'nombre',
                          'titulo',
                          'texto',
                          'tipo',
                          'institucion',
                          'version',
                          'cuestionario_id',
                          'email',
                          'password',
                        ].contains(f) &&
                        (v == null || v.trim().isEmpty)) {
                      return 'Campo obligatorio';
                    }
                    if (['detalles', 'opciones'].contains(f) &&
                        v != null &&
                        v.trim().isNotEmpty) {
                      try {
                        jsonDecode(v);
                      } catch (_) {
                        return 'JSON inválido';
                      }
                    }
                    return null;
                  },
                ),
              ),
            FilledButton(
              onPressed: () {
                if (!key.currentState!.validate()) return;
                final out = <String, dynamic>{};
                for (final f in widget.fields) {
                  final v = ctrls[f]!.text.trim();
                  if (v.isEmpty) {
                    out[f] = null;
                  } else if (['detalles', 'opciones'].contains(f)) {
                    out[f] = jsonDecode(v);
                  } else if ([
                    'edad',
                    'orden',
                    'peso',
                    'costo_promedio',
                    'costo_matricula',
                  ].contains(f)) {
                    out[f] = num.tryParse(v) ?? v;
                  } else if (v == 'true' || v == 'false') {
                    out[f] = v == 'true';
                  } else {
                    out[f] = v;
                  }
                }
                Navigator.pop(context, out);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    ),
  );
}
