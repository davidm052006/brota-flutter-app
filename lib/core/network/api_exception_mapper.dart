import 'package:dio/dio.dart';

import '../result/failure.dart';

/// Maps whatever a Dio call throws into the app's typed [Failure]
/// hierarchy, so repositories never leak Dio/HTTP details to callers.
Failure mapDioExceptionToFailure(Object error) {
  if (error is! DioException) {
    return const UnknownFailure();
  }

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
    case DioExceptionType.connectionError:
      return const NetworkFailure();
    case DioExceptionType.badCertificate:
      return const NetworkFailure('No se pudo verificar la conexión segura.');
    case DioExceptionType.cancel:
      return const UnknownFailure('La solicitud fue cancelada.');
    case DioExceptionType.badResponse:
      final int? statusCode = error.response?.statusCode;
      final Object? data = error.response?.data;
      final String message =
          _extractServerMessage(data) ??
          'Error del servidor (${statusCode ?? 'desconocido'}).';
      if (statusCode == 401 || statusCode == 403) {
        return AuthFailure(message);
      }
      return ServerFailure(message, statusCode: statusCode);
    case DioExceptionType.unknown:
      return const NetworkFailure();
  }
}

String? _extractServerMessage(Object? data) {
  if (data is Map<String, dynamic>) {
    final Object? message = data['message'] ?? data['error'];
    if (message is String) return message;
  }
  return null;
}
