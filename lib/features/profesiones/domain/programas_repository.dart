import '../../../core/result/result.dart';
import 'programas_page.dart';
import 'programas_stats.dart';

/// Contrato para el catálogo de programas educativos. La implementación
/// real (`ProgramasRepositoryImpl`, en `data/`) habla con el backend
/// Express vía Dio — este contrato no sabe nada de eso.
abstract class ProgramasRepository {
  /// [area] y [search] son filtros server-side. El filtro de modalidad
  /// (Presencial/A distancia/Virtual) es client-side sobre lo ya
  /// cargado — no es parámetro de esta llamada, ver
  /// `FUNCTIONAL_CONTENT_BRIEF.md` sección 2.
  Future<Result<ProgramasPage>> getProgramas({
    String? area,
    String? search,
    required int page,
    int limit = 24,
  });

  Future<Result<ProgramasStats>> getStats();
}
