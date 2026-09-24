import 'package:dio/dio.dart';

import '../../../core/network/api_exception_mapper.dart';
import '../../../core/result/failure.dart';
import '../../../core/result/result.dart';
import '../domain/programas_page.dart';
import '../domain/programas_repository.dart';
import '../domain/programas_stats.dart';

final class ProgramasRepositoryImpl implements ProgramasRepository {
  ProgramasRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<Result<ProgramasPage>> getProgramas({
    String? area,
    String? search,
    required int page,
    int limit = 24,
  }) async {
    try {
      final Response<Map<String, dynamic>> response = await _dio
          .get<Map<String, dynamic>>(
            '/programas',
            queryParameters: {
              if (area != null && area.isNotEmpty) 'area': area,
              if (search != null && search.isNotEmpty) 'search': search,
              'page': page,
              'limit': limit,
            },
          );
      return Success(ProgramasPage.fromJson(response.data!));
    } on DioException catch (e) {
      return ResultError(mapDioExceptionToFailure(e));
    } catch (_) {
      return const ResultError(UnknownFailure());
    }
  }

  @override
  Future<Result<ProgramasStats>> getStats() async {
    try {
      final Response<Map<String, dynamic>> response = await _dio
          .get<Map<String, dynamic>>('/programas/stats');
      return Success(ProgramasStats.fromJson(response.data!));
    } on DioException catch (e) {
      return ResultError(mapDioExceptionToFailure(e));
    } catch (_) {
      return const ResultError(UnknownFailure());
    }
  }
}
