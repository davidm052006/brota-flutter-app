import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Attaches the current Supabase session's JWT as a Bearer token on
/// every outgoing request, mirroring how `verificarAuth.js` on the
/// Node backend expects `Authorization: Bearer <supabase_jwt>`.
final class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._supabase, this._dio);

  final SupabaseClient _supabase;
  final Dio _dio;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.extra['authRetry'] == true) {
      handler.next(options);
      return;
    }

    final String? accessToken = _supabase.auth.currentSession?.accessToken;
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final RequestOptions request = err.requestOptions;
    if (err.response?.statusCode != 401 ||
        request.extra['authRetry'] == true ||
        _supabase.auth.currentSession == null) {
      handler.next(err);
      return;
    }

    try {
      final AuthResponse refreshed = await _supabase.auth.refreshSession();
      final String? accessToken = refreshed.session?.accessToken;
      if (accessToken == null) {
        await _supabase.auth.signOut();
        handler.next(err);
        return;
      }

      request
        ..headers['Authorization'] = 'Bearer $accessToken'
        ..extra['authRetry'] = true;
      final Response<dynamic> response = await _dio.fetch<dynamic>(request);
      handler.resolve(response);
    } on AuthException {
      await _supabase.auth.signOut();
      handler.next(err);
    } on DioException catch (retryError) {
      if (retryError.response?.statusCode == 401) {
        await _supabase.auth.signOut();
      }
      handler.next(retryError);
    } catch (_) {
      handler.next(err);
    }
  }
}
