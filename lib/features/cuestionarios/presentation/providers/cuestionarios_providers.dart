import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/cuestionarios_repository_impl.dart';
import '../../domain/cuestionarios_repository.dart';

final Provider<CuestionariosRepository> cuestionariosRepositoryProvider =
    Provider<CuestionariosRepository>(
      (ref) => CuestionariosRepositoryImpl(ref.watch(dioProvider)),
    );

/// ¿La cuenta logueada es una institución?
///
/// La app no tenía ninguna noción del rol del usuario (`AppUser` es
/// deliberadamente fino y no hay feature `perfil` todavía), así que se resuelve
/// acá con la misma regla que `frontend/src/hooks/useInstitucion.js`: leer el
/// perfil del backend y mirar `rol`. Cuando exista una feature `perfil` de
/// verdad, esto debería mudarse ahí y este provider quedar como un `select`.
///
/// Ante cualquier error devuelve `false` — sin rol confirmado, la sección no
/// se muestra.
final FutureProvider<bool> esInstitucionProvider = FutureProvider<bool>((
  ref,
) async {
  final String? userId = ref.watch(supabaseClientProvider).auth.currentUser?.id;
  if (userId == null) return false;

  try {
    final Response<dynamic> response = await ref
        .watch(dioProvider)
        .get<dynamic>('/perfil/$userId');
    final Object? body = response.data;
    final Object? data = body is Map<String, dynamic> ? body['data'] : body;
    if (data is! Map<String, dynamic>) return false;
    return data['rol'] == 'institucion';
  } on DioException {
    return false;
  } catch (_) {
    return false;
  }
});
