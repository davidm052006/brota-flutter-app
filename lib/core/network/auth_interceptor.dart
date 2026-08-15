import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Attaches the current Supabase session's JWT as a Bearer token on
/// every outgoing request, mirroring how `verificarAuth.js` on the
/// Node backend expects `Authorization: Bearer <supabase_jwt>`.
final class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._supabase);

  final SupabaseClient _supabase;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final String? accessToken = _supabase.auth.currentSession?.accessToken;
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }
}
