import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../env/app_env.dart';
import 'auth_interceptor.dart';

/// Configured [Dio] instance for talking to the Node/Express backend
/// (`backend/src/routes/*.js` in Documentacion_Brota) — auth, perfil,
/// programas, comunidad, contacto, admin.
Dio buildDioClient(SupabaseClient supabase) {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: '${AppEnv.apiBaseUrl}/api',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: const {'Content-Type': 'application/json'},
    ),
  );
  dio.interceptors.add(AuthInterceptor(supabase));
  return dio;
}
